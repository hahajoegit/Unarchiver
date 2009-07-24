#import "XADOldNSISParser.h"
#import "CSZlibHandle.h"
#import "NSDateXAD.h"

static int IndexOfLargestEntry(const int *entries,int num);

// TODO: exclude uninstallers?
static BOOL IsOlderSignature(const uint8_t *ptr)
{
	static const uint8_t OlderSignature[15]={0xbe,0xad,0xde,0x4e,0x75,0x6c,0x6c,0x53,0x6f,0x66,0x74,0x49,0x6e,0x73,0x74};
	if(memcmp(ptr+1,OlderSignature,15)!=0) return NO;
	if((ptr[0]&0xfc)!=0xec) return NO;
	return YES;
}

static BOOL IsOldSignature(const uint8_t *ptr)
{
	static const uint8_t OldSignature[16]={0xef,0xbe,0xad,0xde,0x4e,0x75,0x6c,0x6c,0x53,0x6f,0x66,0x74,0x49,0x6e,0x73,0x74};
	if(memcmp(ptr+4,OldSignature,16)!=0) return NO;
	return YES;
}

@implementation XADOldNSISParser

+(int)requiredHeaderSize { return 0x10000; }

+(BOOL)recognizeFileWithHandle:(CSHandle *)handle firstBytes:(NSData *)data name:(NSString *)name
{
	const uint8_t *bytes=[data bytes];
	int length=[data length];

	for(int offs=0;offs<length+4+16;offs+=512)
	{
		if(IsOlderSignature(bytes+offs)) return YES;
		if(IsOldSignature(bytes+offs)) return YES;
	}
	return NO;
}


-(void)parse
{
	CSHandle *fh=[self handle];

	[fh skipBytes:512];
	for(;;)
	{
		uint8_t buf[20];
		[fh readBytes:sizeof(buf) toBuffer:buf];
		[fh skipBytes:-(int)sizeof(buf)];

		if(IsOlderSignature(buf)) { [self parseOlderFormatWithHandle:fh]; return; }
		if(IsOldSignature(buf)) { [self parseOldFormatWithHandle:fh]; return; }
		[fh skipBytes:512];
	}
}

-(void)parseOlderFormatWithHandle:(CSHandle *)fh
{
	[fh skipBytes:16];
	uint32_t headerlength=[fh readUInt32LE];
	uint32_t headeroffset=[fh readUInt32LE];
	uint32_t totallength=[fh readUInt32LE];

	base=[fh offsetInFile];
NSLog(@"%d %d",headeroffset,headerlength);
	CSHandle *hh=[self handleForBlockAtOffset:headeroffset length:headerlength];

	NSData *data=[hh remainingFileContents];
	NSLog(@"%@",data);
}

-(void)parseOldFormatWithHandle:(CSHandle *)fh
{
	uint32_t flags=[fh readUInt32LE];
	[fh skipBytes:16];

	uint32_t headerlength=[fh readUInt32LE];
	uint32_t headeroffset=[fh readUInt32LE];
	uint32_t totallength=[fh readUInt32LE];

	base=[fh offsetInFile];

	uint32_t datalength=totallength-32;
	if(flags&1) datalength-=4;

	NSDictionary *blocks=[self parseBlockOffsetsWithTotalSize:datalength];
	CSHandle *hh=[self handleForBlockAtOffset:headeroffset length:headerlength];
	NSData *header=[hh readDataOfLength:headerlength];
	NSDictionary *strings=[self parseStringsWithData:header];

	const uint8_t *bytes=[header bytes];
	int length=[header length];

	// Heuristic to find the size of entries, and the opcode for extract file entries.
	// Find candidates for extract opcodes, and measure the distances between them and
	// which opcodes they have.
	int stride6counts[3]={0},stride7counts[3]={0};
	int stride6phases[6]={0},stride7phases[7]={0};
	int lastpos=0;
	for(int i=24;i<stringtable&&i+24<=length;i+=4)
	{
		int opcode=CSUInt32LE(bytes+i);
		if(opcode==3||opcode==4||opcode==5) // possible ExtractFile
		{
			uint32_t overwrite=CSUInt32LE(bytes+i+4);
			uint32_t filenameoffs=CSUInt32LE(bytes+i+8);
			uint32_t dataoffs=CSUInt32LE(bytes+i+12);
			if(overwrite<4)
			if([strings objectForKey:[NSNumber numberWithInt:filenameoffs]])
			if([blocks objectForKey:[NSNumber numberWithInt:dataoffs]])
			{
				int pos=i/4;
				if((pos-lastpos)%6==0)
				{
					stride6counts[opcode-3]++;
					stride6phases[pos%6]++;
				}
				if((pos-lastpos)%7==0)
				{
					stride7counts[opcode-3]++;
					stride7phases[pos%7]++;
				}
				lastpos=pos;
			}
		}
	}

	int totalstride6=stride6counts[0]+stride6counts[1]+stride6counts[2];
	int totalstride7=stride7counts[0]+stride7counts[1]+stride7counts[2];

	int stride,extractopcode,phase;
	if(totalstride6>totalstride7)
	{
		stride=6;
		extractopcode=IndexOfLargestEntry(stride6counts,3)+3;
		phase=IndexOfLargestEntry(stride6phases,6);
		
	}
	else
	{
		stride=7;
		extractopcode=IndexOfLargestEntry(stride7counts,3)+3;
		phase=IndexOfLargestEntry(stride7phases,7);
	}

	NSLog(@"stride %d, opcode %d, phase %d",stride,extractopcode,phase);

	XADPath *dir=[self XADPath];

	for(int i=(stride+phase)*4;i<stringtable&&i+24<=length;i+=4*stride)
	{
		int opcode=CSUInt32LE(bytes+i);
		uint32_t args[6];
		for(int j=1;j<stride;j++) args[j-1]=CSUInt32LE(bytes+i+j*4);

		if(opcode==extractopcode)
		{
			uint32_t overwrite=args[0];
			NSData *filename=[strings objectForKey:[NSNumber numberWithInt:args[1]]];
			NSNumber *offs=[NSNumber numberWithUnsignedInt:args[2]];
			NSNumber *block=[blocks objectForKey:offs];
			uint32_t datetimehigh=args[3];
			uint32_t datetimelow=args[4];

			if(overwrite<4&&filename&&block)
			{
				uint32_t len=[block unsignedIntValue];

				NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
					[dir pathByAppendingPathComponent:[self XADStringWithData:filename]],XADFileNameKey,
					[NSNumber numberWithUnsignedInt:len&0x7fffffff],XADCompressedSizeKey,
					[NSDate XADDateWithWindowsFileTimeLow:datetimelow high:datetimehigh],XADLastModificationDateKey,
					offs,@"NSISDataOffset",
				nil];

				if(len&0x80000000)
				{
					[dict setObject:[self XADStringWithString:@"Deflate"] forKey:XADCompressionNameKey];
				}
				else
				{
					[dict setObject:[self XADStringWithString:@"None"] forKey:XADCompressionNameKey];
					[dict setObject:[NSNumber numberWithUnsignedInt:len&0x7fffffff] forKey:XADFileSizeKey];
				}

				[self addEntryWithDictionary:dict];

				continue;
			}
		}
		if(opcode==3&&extractopcode==4&&stride==6) // New createdir
		{
			if(args[1]==1&&args[2]==0&&args[3]==0&&args[4]==0)
			{
				NSData *path=[strings objectForKey:[NSNumber numberWithInt:args[0]]];
				dir=[self cleanedPathForData:path];
				continue;
			}
		}
		if(opcode==extractopcode-2) // Old setdir
		{
			if(args[1]==0&&args[2]==0&&args[3]==0&&args[4]==0)
			{
				NSData *path=[strings objectForKey:[NSNumber numberWithInt:args[0]]];
				dir=[self cleanedPathForData:path];
				continue;
			}
		}
	}

//	NSData *data=[hh remainingFileContents];
//	NSLog(@"%@",data);
}

-(NSDictionary *)parseBlockOffsetsWithTotalSize:(uint32_t)totalsize
{
	NSMutableDictionary *dict=[NSMutableDictionary dictionary];

	CSHandle *fh=[self handle];
	[fh seekToFileOffset:base];

	uint32_t size=0;
	while(size<totalsize)
	{
		uint32_t val=[fh readUInt32LE];
		uint32_t len=val&0x7fffffff;
		[dict setObject:[NSNumber numberWithUnsignedInt:val] forKey:[NSNumber numberWithInt:size]];
		[fh skipBytes:len];
		size+=len+4;
	}

	return dict;
}

-(NSDictionary *)parseStringsWithData:(NSData *)data
{
	const uint8_t *bytes=[data bytes];
	int length=[data length];

	// Find last location with three zero bytes in a row. The string table shouldn't be anywhere
	// before this. (Could perhaps work with just doubles, too.)
	int lasttriple=0;
	for(int i=0;i<length-2;i++)
	{
		if(bytes[i]==0&&bytes[i+1]==0&&bytes[i+2]==0) lasttriple=i;
	}

	// Scan the start of the header for things that look like string table offsets.
	// The last thing after the strings seems to be a single flag value in most or
	// all versions, so stop after reaching this.
	int maxnumoffsets=27;
	uint32_t stringoffset[maxnumoffsets];
	int numoffsets=0;
	int maxoffset=0;
	for(int i=0;i+4<=length && numoffsets<maxnumoffsets;i+=4)
	{
		uint32_t val=CSUInt32LE(bytes+i);
		if(i>40 && val==0||val==1) break;
		if(val!=0 && val+lasttriple+3<length)
		{
			stringoffset[numoffsets]=val;
			numoffsets++;
			if(val>maxoffset) maxoffset=val;
		}
	}

	// Then start testing offsets trying to find one that has null bytes just before all the
	// string first bytes found in the header.
	stringtable=0;
	for(int i=lasttriple+2;i+maxoffset<length;i++)
	{
		BOOL failed=NO;
		for(int j=0;j<numoffsets && !failed;j++)
		{
			if(bytes[i+stringoffset[j]-1]!=0) failed=YES;
		}

		if(!failed)
		{
			stringtable=i;
			break;
		}
	}

	if(!stringtable) [XADException raiseNotSupportedException];

	// Extract strings
	NSMutableDictionary *dict=[NSMutableDictionary dictionary];
	int start=stringtable;
	for(int i=stringtable;i<length;i++)
	{
		if(bytes[i]==0)
		{
			[dict setObject:[NSData dataWithBytes:&bytes[start] length:i-start]
			forKey:[NSNumber numberWithInt:start-stringtable]];
			start=i+1;
		}
	}

	return dict;
}

-(XADPath *)cleanedPathForData:(NSData *)data
{
	const uint8_t *bytes=[data bytes];
	int length=[data length];

	if(length==8 && memcmp(bytes,"$INSTDIR",8)==0) return [self XADPath];
	if(length>=9 && memcmp(bytes,"$INSTDIR\\",9)==0) return [self XADPathWithBytes:bytes+9 length:length-9 separators:XADWindowsPathSeparator];
	else if(length>=1 && bytes[0]=='$') return [self XADPathWithBytes:bytes+1 length:length-1 separators:XADWindowsPathSeparator];
	else return [self XADPathWithData:data separators:XADWindowsPathSeparator];
}



-(CSHandle *)handleForBlockAtOffset:(off_t)offs
{
	return [self handleForBlockAtOffset:offs length:CSHandleMaxLength];
}

-(CSHandle *)handleForBlockAtOffset:(off_t)offs length:(off_t)length
{
	CSHandle *fh=[self handle];
	[fh seekToFileOffset:offs+base];
	uint32_t len=[fh readUInt32LE];
	CSHandle *sub=[fh nonCopiedSubHandleOfLength:len&0x7fffffff];
	if((len&0x80000000))
	{
		CSZlibHandle *handle=[CSZlibHandle zlibHandleWithHandle:sub length:length];
		[handle setEndStreamAtInputEOF:YES];
		return handle;
	}
	else return sub;
}




-(CSHandle *)handleForEntryWithDictionary:(NSDictionary *)dict wantChecksum:(BOOL)checksum
{
	return [self handleForBlockAtOffset:[[dict objectForKey:@"NSISDataOffset"] unsignedIntValue]];
}

-(NSString *)formatName { return @"Old NSIS"; }

@end


static int IndexOfLargestEntry(const int *entries,int num)
{
	int max=INT_MIN,index=0;
	for(int i=0;i<num;i++)
	{
		if(entries[i]>max)
		{
			max=entries[i];
			index=i;
		}
	}
	return index;
}
