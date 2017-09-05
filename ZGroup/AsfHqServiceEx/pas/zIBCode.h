/*
 * =====================================================================================
 *
 *       Filename:  zIBCode.h
 *
 *    Description:  
 *
 *        Version:  1.0
 *        Created:  2012年06月25日 14时06分35秒
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  yjmin
 *        Company:  
 *
 * =====================================================================================
 */
#ifndef Z_IB_CODE_H_YJM
#define Z_IB_CODE_H_YJM

#ifdef __cplusplus
extern "C" {
#endif
/* 
 * 如果压缩成功则返回0，返回其他值表示失败；
 * 如果返回-1，表示输入参数错误；
 * 如果返回-2；表示编码后的长度超过6个字节
 * 如果返回-3；表示输入的字符串长度为0或者超过11字节；
 * 如果返回-4；表示输入的字符串中含有特殊字符（非字母数字的类型）
 * */
int  encodeInterbankBondCode( const unsigned char *pCode, unsigned char pOut[6] );


/* 
 * 如果返回0表示成功，否则失败；
 * 如果返回-1，表示输入编码错误；
 * 如果返回-2，表示输入的pCode长度不够；
 * */
int decodeInterbankBondCode( const unsigned char pIn[6], unsigned char *pCode, int iCodeBuffLen );


#ifdef __cplusplus
}
#endif
#endif
