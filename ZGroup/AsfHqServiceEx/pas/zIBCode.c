/*
 * =====================================================================================
 *
 *       Filename:  zIBCode.c
 *
 *    Description:  
 *
 *        Version:  1.0
 *        Created:  2012年06月25日 13时35分16秒
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  yjmin
 *        Company:  
 *
 * =====================================================================================
 */
#include<string.h>

#ifdef __cplusplus
extern "C" {
#endif
int  encodeInterbankBondCode( const unsigned char *pCode, unsigned char pOut[6] )
{
	memset( pOut, 0, sizeof(char)*6);
	if( pCode )
	{
		int iLen = strlen( (const char*)pCode );
		int index=0, bitLen = 4;
		if( iLen<1 || iLen>11 )
			return -3;//输入的字符串长度为0或者超过11位
		pOut[0] = iLen<<4;
		while( index<iLen )
		{
			if( pCode[index] >= '0' && pCode[index] <= '9' )
			{
				int value = pCode[index] - '0';
				int surplus = 8-bitLen%8;
				if( bitLen + 4 > 6*8 )
					return -2;//编码后的长度超过6个字节
				if( surplus < 4 )
				{
					pOut[bitLen/8] |= value>>(4-surplus);
					pOut[bitLen/8+1] = (value<<(8-4+surplus))&0xFF;
				}else{
					pOut[bitLen/8] |= value<<(surplus-4);
				}
				bitLen += 4;
			}
			else if( pCode[index] >= 'a' && pCode[index] <= 'z' )
			{
				int diff =  pCode[index] - 'a';
				int surplus = 8-bitLen%8;
				if( diff > 21 )
				{
					int value = (15<<3) | (diff-18);
					if( bitLen + 7 > 6*8 )
						return -2;//编码后的长度超过6个字节
					if( surplus < 7 )
					{
						pOut[bitLen/8] |= value>>(7-surplus);
						pOut[bitLen/8+1] = (value<<(8-7+surplus))&0xFF;
					}else{
						pOut[bitLen/8] |= value<<(surplus-7);
					}
					bitLen += 7;
				}
				else{
					int value = ((diff/4+10) << 2) | diff%4;
					if( bitLen + 6 > 6*8 )
						return -2;//编码后的长度超过6个字节
					if( surplus < 6 )
					{
						pOut[bitLen/8] |= value>>(6-surplus);
						pOut[bitLen/8+1] = (value<<(8-6+surplus))&0xFF;
					}else{
						pOut[bitLen/8] |= value<<(surplus-6);
					}
					bitLen += 6;
				}
			}
			else if( pCode[index] >= 'A' && pCode[index] <= 'Z' )
			{
				int diff =  pCode[index] - 'A';
				int surplus = 8-bitLen%8;
				if( diff > 21 )
				{
					int value = (15<<3) | (diff-18);
					if( bitLen + 7 > 6*8 )
						return -2;//编码后的长度超过6个字节
					if( surplus < 7 )
					{
						pOut[bitLen/8] |= value>>(7-surplus);
						pOut[bitLen/8+1] = (value<<(8-7+surplus))&0xFF;
					}else{
						pOut[bitLen/8] |= value<<(surplus-7);
					}
					bitLen += 7;
				}
				else{
					int value = ((diff/4+10) << 2) | diff%4;
					if( bitLen + 6 > 6*8 )
						return -2;//编码后的长度超过6个字节
					if( surplus < 6 )
					{
						pOut[bitLen/8] |= value>>(6-surplus);
						pOut[bitLen/8+1] = (value<<(8-6+surplus))&0xFF;
					}else{
						pOut[bitLen/8] |= value<<(surplus-6);
					}
					bitLen += 6;
				}
			}
			else{
				return -4;//输入的字符串中含有特殊字符
			}
			++index;
		}
		return 0;//成功编码
	}
	return -1;//输入参数错误
}

int decodeInterbankBondCode( const unsigned char pIn[6], unsigned char *pCode, int iCodeBuffLen )
{
	int iLen = pIn[0]>>4;
	int bitLen = 4;
	int iCount = 0;
	if( iLen<1 || iLen > 11 )
		return -1;//输入编码错误
	if( iCodeBuffLen < iLen )
		return -2;//pCode的长度不够
	memset(pCode, 0, sizeof(char)*iCodeBuffLen );
	while( bitLen < 6*8 && iCount<iLen )
	{
		int value;
		int skip  = bitLen%8;
		int surplus = 8-skip;
		if( surplus < 4 )
		{
			value = ((pIn[bitLen/8]<<skip & 0xFF) >> 4) | (pIn[bitLen/8+1]>>4+surplus);
		}
		else{
			value = (pIn[bitLen/8] << skip & 0xFF)>> skip+surplus-4;
		}

		bitLen += 4;
		if( value < 10 )
		{
			pCode[iCount++] = '0'+value;
		}
		else{
			int v;
			skip  = bitLen%8;
			surplus = 8-skip;
			if( surplus < 2 )
			{
				v = ((pIn[bitLen/8]<<skip & 0xFF) >> 6) | (pIn[bitLen/8+1]>>6+surplus);
			}
			else{
				v = (pIn[bitLen/8] << skip & 0xFF)>> skip+surplus-2;
			}

			bitLen += 2;
			if( value == 15 && v > 1 )
			{
				skip  = bitLen%8;
				surplus = 8-skip;
				pCode[iCount++] = 'A'+(value-10)*4 + v*2 - 2 + ((pIn[bitLen/8]<<skip & 0xFF)>>7);
				++bitLen;
			}
			else{
				pCode[iCount++] = 'A'+(value-10)*4+v;
			}
		}
	}
	if( iCount != iLen )
		return -1;
	return 0;
}

#ifdef __cplusplus
}
#endif
