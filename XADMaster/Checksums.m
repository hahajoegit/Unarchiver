#import "Checksums.h"



@implementation CSHandle (Checksums)

-(BOOL)hasChecksum { return NO; }
-(BOOL)isChecksumCorrect { return YES; }

@end


uint16_t XADCRC16Reverse(uint16_t prevcrc,uint8_t byte,const uint16_t *table)
{
	return table[(prevcrc>>8)^byte]^(prevcrc<<8);
}

uint32_t XADCRC(uint32_t prevcrc,uint8_t byte,const uint32_t *table)
{
	return table[(prevcrc^byte)&0xff]^(prevcrc>>8);
}

uint32_t XADCalculateCRC(uint32_t prevcrc,uint8_t *buffer,int length,const uint32_t *table)
{
	uint32_t crc=prevcrc;
	for(int i=0;i<length;i++) crc=XADCRC(crc,buffer[i],table);
	return crc;
}

int XADUnReverseCRC16(int val)
{
	val=((val>>8)&0x00FF)|((val&0x00FF)<<8);
	return val;
}

const uint32_t XADCRCTable_a001[256]=
{
	0x00000000,0x0000c0c1,0x0000c181,0x00000140,0x0000c301,0x000003c0,0x00000280,0x0000c241,
	0x0000c601,0x000006c0,0x00000780,0x0000c741,0x00000500,0x0000c5c1,0x0000c481,0x00000440,
	0x0000cc01,0x00000cc0,0x00000d80,0x0000cd41,0x00000f00,0x0000cfc1,0x0000ce81,0x00000e40,
	0x00000a00,0x0000cac1,0x0000cb81,0x00000b40,0x0000c901,0x000009c0,0x00000880,0x0000c841,
	0x0000d801,0x000018c0,0x00001980,0x0000d941,0x00001b00,0x0000dbc1,0x0000da81,0x00001a40,
	0x00001e00,0x0000dec1,0x0000df81,0x00001f40,0x0000dd01,0x00001dc0,0x00001c80,0x0000dc41,
	0x00001400,0x0000d4c1,0x0000d581,0x00001540,0x0000d701,0x000017c0,0x00001680,0x0000d641,
	0x0000d201,0x000012c0,0x00001380,0x0000d341,0x00001100,0x0000d1c1,0x0000d081,0x00001040,
	0x0000f001,0x000030c0,0x00003180,0x0000f141,0x00003300,0x0000f3c1,0x0000f281,0x00003240,
	0x00003600,0x0000f6c1,0x0000f781,0x00003740,0x0000f501,0x000035c0,0x00003480,0x0000f441,
	0x00003c00,0x0000fcc1,0x0000fd81,0x00003d40,0x0000ff01,0x00003fc0,0x00003e80,0x0000fe41,
	0x0000fa01,0x00003ac0,0x00003b80,0x0000fb41,0x00003900,0x0000f9c1,0x0000f881,0x00003840,
	0x00002800,0x0000e8c1,0x0000e981,0x00002940,0x0000eb01,0x00002bc0,0x00002a80,0x0000ea41,
	0x0000ee01,0x00002ec0,0x00002f80,0x0000ef41,0x00002d00,0x0000edc1,0x0000ec81,0x00002c40,
	0x0000e401,0x000024c0,0x00002580,0x0000e541,0x00002700,0x0000e7c1,0x0000e681,0x00002640,
	0x00002200,0x0000e2c1,0x0000e381,0x00002340,0x0000e101,0x000021c0,0x00002080,0x0000e041,
	0x0000a001,0x000060c0,0x00006180,0x0000a141,0x00006300,0x0000a3c1,0x0000a281,0x00006240,
	0x00006600,0x0000a6c1,0x0000a781,0x00006740,0x0000a501,0x000065c0,0x00006480,0x0000a441,
	0x00006c00,0x0000acc1,0x0000ad81,0x00006d40,0x0000af01,0x00006fc0,0x00006e80,0x0000ae41,
	0x0000aa01,0x00006ac0,0x00006b80,0x0000ab41,0x00006900,0x0000a9c1,0x0000a881,0x00006840,
	0x00007800,0x0000b8c1,0x0000b981,0x00007940,0x0000bb01,0x00007bc0,0x00007a80,0x0000ba41,
	0x0000be01,0x00007ec0,0x00007f80,0x0000bf41,0x00007d00,0x0000bdc1,0x0000bc81,0x00007c40,
	0x0000b401,0x000074c0,0x00007580,0x0000b541,0x00007700,0x0000b7c1,0x0000b681,0x00007640,
	0x00007200,0x0000b2c1,0x0000b381,0x00007340,0x0000b101,0x000071c0,0x00007080,0x0000b041,
	0x00005000,0x000090c1,0x00009181,0x00005140,0x00009301,0x000053c0,0x00005280,0x00009241,
	0x00009601,0x000056c0,0x00005780,0x00009741,0x00005500,0x000095c1,0x00009481,0x00005440,
	0x00009c01,0x00005cc0,0x00005d80,0x00009d41,0x00005f00,0x00009fc1,0x00009e81,0x00005e40,
	0x00005a00,0x00009ac1,0x00009b81,0x00005b40,0x00009901,0x000059c0,0x00005880,0x00009841,
	0x00008801,0x000048c0,0x00004980,0x00008941,0x00004b00,0x00008bc1,0x00008a81,0x00004a40,
	0x00004e00,0x00008ec1,0x00008f81,0x00004f40,0x00008d01,0x00004dc0,0x00004c80,0x00008c41,
	0x00004400,0x000084c1,0x00008581,0x00004540,0x00008701,0x000047c0,0x00004680,0x00008641,
	0x00008201,0x000042c0,0x00004380,0x00008341,0x00004100,0x000081c1,0x00008081,0x00004040,
};

const uint32_t XADCRCReverseTable_1021[256]=
{
	0x00000000,0x00002110,0x00004220,0x00006330,0x00008440,0x0000a550,0x0000c660,0x0000e770,
	0x00000881,0x00002991,0x00004aa1,0x00006bb1,0x00008cc1,0x0000add1,0x0000cee1,0x0000eff1,
	0x00003112,0x00001002,0x00007332,0x00005222,0x0000b552,0x00009442,0x0000f772,0x0000d662,
	0x00003993,0x00001883,0x00007bb3,0x00005aa3,0x0000bdd3,0x00009cc3,0x0000fff3,0x0000dee3,
	0x00006224,0x00004334,0x00002004,0x00000114,0x0000e664,0x0000c774,0x0000a444,0x00008554,
	0x00006aa5,0x00004bb5,0x00002885,0x00000995,0x0000eee5,0x0000cff5,0x0000acc5,0x00008dd5,
	0x00005336,0x00007226,0x00001116,0x00003006,0x0000d776,0x0000f666,0x00009556,0x0000b446,
	0x00005bb7,0x00007aa7,0x00001997,0x00003887,0x0000dff7,0x0000fee7,0x00009dd7,0x0000bcc7,
	0x0000c448,0x0000e558,0x00008668,0x0000a778,0x00004008,0x00006118,0x00000228,0x00002338,
	0x0000ccc9,0x0000edd9,0x00008ee9,0x0000aff9,0x00004889,0x00006999,0x00000aa9,0x00002bb9,
	0x0000f55a,0x0000d44a,0x0000b77a,0x0000966a,0x0000711a,0x0000500a,0x0000333a,0x0000122a,
	0x0000fddb,0x0000dccb,0x0000bffb,0x00009eeb,0x0000799b,0x0000588b,0x00003bbb,0x00001aab,
	0x0000a66c,0x0000877c,0x0000e44c,0x0000c55c,0x0000222c,0x0000033c,0x0000600c,0x0000411c,
	0x0000aeed,0x00008ffd,0x0000eccd,0x0000cddd,0x00002aad,0x00000bbd,0x0000688d,0x0000499d,
	0x0000977e,0x0000b66e,0x0000d55e,0x0000f44e,0x0000133e,0x0000322e,0x0000511e,0x0000700e,
	0x00009fff,0x0000beef,0x0000dddf,0x0000fccf,0x00001bbf,0x00003aaf,0x0000599f,0x0000788f,
	0x00008891,0x0000a981,0x0000cab1,0x0000eba1,0x00000cd1,0x00002dc1,0x00004ef1,0x00006fe1,
	0x00008010,0x0000a100,0x0000c230,0x0000e320,0x00000450,0x00002540,0x00004670,0x00006760,
	0x0000b983,0x00009893,0x0000fba3,0x0000dab3,0x00003dc3,0x00001cd3,0x00007fe3,0x00005ef3,
	0x0000b102,0x00009012,0x0000f322,0x0000d232,0x00003542,0x00001452,0x00007762,0x00005672,
	0x0000eab5,0x0000cba5,0x0000a895,0x00008985,0x00006ef5,0x00004fe5,0x00002cd5,0x00000dc5,
	0x0000e234,0x0000c324,0x0000a014,0x00008104,0x00006674,0x00004764,0x00002454,0x00000544,
	0x0000dba7,0x0000fab7,0x00009987,0x0000b897,0x00005fe7,0x00007ef7,0x00001dc7,0x00003cd7,
	0x0000d326,0x0000f236,0x00009106,0x0000b016,0x00005766,0x00007676,0x00001546,0x00003456,
	0x00004cd9,0x00006dc9,0x00000ef9,0x00002fe9,0x0000c899,0x0000e989,0x00008ab9,0x0000aba9,
	0x00004458,0x00006548,0x00000678,0x00002768,0x0000c018,0x0000e108,0x00008238,0x0000a328,
	0x00007dcb,0x00005cdb,0x00003feb,0x00001efb,0x0000f98b,0x0000d89b,0x0000bbab,0x00009abb,
	0x0000754a,0x0000545a,0x0000376a,0x0000167a,0x0000f10a,0x0000d01a,0x0000b32a,0x0000923a,
	0x00002efd,0x00000fed,0x00006cdd,0x00004dcd,0x0000aabd,0x00008bad,0x0000e89d,0x0000c98d,
	0x0000267c,0x0000076c,0x0000645c,0x0000454c,0x0000a23c,0x0000832c,0x0000e01c,0x0000c10c,
	0x00001fef,0x00003eff,0x00005dcf,0x00007cdf,0x00009baf,0x0000babf,0x0000d98f,0x0000f89f,
	0x0000176e,0x0000367e,0x0000554e,0x0000745e,0x0000932e,0x0000b23e,0x0000d10e,0x0000f01e,
};


const uint32_t XADCRCTable_edb88320[256]=
{
	0x00000000,0x77073096,0xee0e612c,0x990951ba,0x076dc419,0x706af48f,0xe963a535,0x9e6495a3,
	0x0edb8832,0x79dcb8a4,0xe0d5e91e,0x97d2d988,0x09b64c2b,0x7eb17cbd,0xe7b82d07,0x90bf1d91,
	0x1db71064,0x6ab020f2,0xf3b97148,0x84be41de,0x1adad47d,0x6ddde4eb,0xf4d4b551,0x83d385c7,
	0x136c9856,0x646ba8c0,0xfd62f97a,0x8a65c9ec,0x14015c4f,0x63066cd9,0xfa0f3d63,0x8d080df5,
	0x3b6e20c8,0x4c69105e,0xd56041e4,0xa2677172,0x3c03e4d1,0x4b04d447,0xd20d85fd,0xa50ab56b,
	0x35b5a8fa,0x42b2986c,0xdbbbc9d6,0xacbcf940,0x32d86ce3,0x45df5c75,0xdcd60dcf,0xabd13d59,
	0x26d930ac,0x51de003a,0xc8d75180,0xbfd06116,0x21b4f4b5,0x56b3c423,0xcfba9599,0xb8bda50f,
	0x2802b89e,0x5f058808,0xc60cd9b2,0xb10be924,0x2f6f7c87,0x58684c11,0xc1611dab,0xb6662d3d,
	0x76dc4190,0x01db7106,0x98d220bc,0xefd5102a,0x71b18589,0x06b6b51f,0x9fbfe4a5,0xe8b8d433,
	0x7807c9a2,0x0f00f934,0x9609a88e,0xe10e9818,0x7f6a0dbb,0x086d3d2d,0x91646c97,0xe6635c01,
	0x6b6b51f4,0x1c6c6162,0x856530d8,0xf262004e,0x6c0695ed,0x1b01a57b,0x8208f4c1,0xf50fc457,
	0x65b0d9c6,0x12b7e950,0x8bbeb8ea,0xfcb9887c,0x62dd1ddf,0x15da2d49,0x8cd37cf3,0xfbd44c65,
	0x4db26158,0x3ab551ce,0xa3bc0074,0xd4bb30e2,0x4adfa541,0x3dd895d7,0xa4d1c46d,0xd3d6f4fb,
	0x4369e96a,0x346ed9fc,0xad678846,0xda60b8d0,0x44042d73,0x33031de5,0xaa0a4c5f,0xdd0d7cc9,
	0x5005713c,0x270241aa,0xbe0b1010,0xc90c2086,0x5768b525,0x206f85b3,0xb966d409,0xce61e49f,
	0x5edef90e,0x29d9c998,0xb0d09822,0xc7d7a8b4,0x59b33d17,0x2eb40d81,0xb7bd5c3b,0xc0ba6cad,
	0xedb88320,0x9abfb3b6,0x03b6e20c,0x74b1d29a,0xead54739,0x9dd277af,0x04db2615,0x73dc1683,
	0xe3630b12,0x94643b84,0x0d6d6a3e,0x7a6a5aa8,0xe40ecf0b,0x9309ff9d,0x0a00ae27,0x7d079eb1,
	0xf00f9344,0x8708a3d2,0x1e01f268,0x6906c2fe,0xf762575d,0x806567cb,0x196c3671,0x6e6b06e7,
	0xfed41b76,0x89d32be0,0x10da7a5a,0x67dd4acc,0xf9b9df6f,0x8ebeeff9,0x17b7be43,0x60b08ed5,
	0xd6d6a3e8,0xa1d1937e,0x38d8c2c4,0x4fdff252,0xd1bb67f1,0xa6bc5767,0x3fb506dd,0x48b2364b,
	0xd80d2bda,0xaf0a1b4c,0x36034af6,0x41047a60,0xdf60efc3,0xa867df55,0x316e8eef,0x4669be79,
	0xcb61b38c,0xbc66831a,0x256fd2a0,0x5268e236,0xcc0c7795,0xbb0b4703,0x220216b9,0x5505262f,
	0xc5ba3bbe,0xb2bd0b28,0x2bb45a92,0x5cb36a04,0xc2d7ffa7,0xb5d0cf31,0x2cd99e8b,0x5bdeae1d,
	0x9b64c2b0,0xec63f226,0x756aa39c,0x026d930a,0x9c0906a9,0xeb0e363f,0x72076785,0x05005713,
	0x95bf4a82,0xe2b87a14,0x7bb12bae,0x0cb61b38,0x92d28e9b,0xe5d5be0d,0x7cdcefb7,0x0bdbdf21,
	0x86d3d2d4,0xf1d4e242,0x68ddb3f8,0x1fda836e,0x81be16cd,0xf6b9265b,0x6fb077e1,0x18b74777,
	0x88085ae6,0xff0f6a70,0x66063bca,0x11010b5c,0x8f659eff,0xf862ae69,0x616bffd3,0x166ccf45,
	0xa00ae278,0xd70dd2ee,0x4e048354,0x3903b3c2,0xa7672661,0xd06016f7,0x4969474d,0x3e6e77db,
	0xaed16a4a,0xd9d65adc,0x40df0b66,0x37d83bf0,0xa9bcae53,0xdebb9ec5,0x47b2cf7f,0x30b5ffe9,
	0xbdbdf21c,0xcabac28a,0x53b39330,0x24b4a3a6,0xbad03605,0xcdd70693,0x54de5729,0x23d967bf,
	0xb3667a2e,0xc4614ab8,0x5d681b02,0x2a6f2b94,0xb40bbe37,0xc30c8ea1,0x5a05df1b,0x2d02ef8d,
};
