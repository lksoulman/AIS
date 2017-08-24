unit SecurityType;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-7-23
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

type

  // ֤ȯ����
  TSecurityType = ( stHSStock,              // �����Ʊ
                    stHKStock,              // �۹�
                    stUSStock,              // ����
                    stNewThirdBoardStock,   // ������
                    stIndex,                // ָ��
                    stForeignIndex,         // ����ָ��
                    stYuEBaoIndex,          // ������ָ��
                    stBond,                 // ��ͨծȯ
                    stHSBond,               // ����ծȯ
                    stBuyBackBond,          // ծȯ�ع�
                    stConvertibleBond,      // ��תծ
                    stInnerFund,            // ���ڻ���
                    stOuterCurrencyFund,    // �������(����)
                    stOuterNonCurrencyFund, // �������(�ǻ���)
                    stCommodityFutures,     // ��Ʒ�ڻ�
                    stFinancialFutures      // �����ڻ�
                   );

  // ������ȯ����
  TMarginType = ( mtNone,                  // �������ʲ�����ȯ
                  mtFinance,               // ������
                  mtLoan,                  // ����ȯ
                  mtFinanceAndLoan         // �����ʿ���ȯ
                 );

  // ͨ����
  TThroughType = ( ttNone,
                   ttHKSH,                 // �۹�ͨ��
                   ttHKSZ,                 // �۹�ͨ��
                   ttHKSHSZ,               // �۹�ͨ����
                   ttSH,                   // ����ͨ
                   ttSZ                    // ���ͨ
                   );

  // ����״̬
  TListedStateType = ( ltListing,                // ����
                       ltDeListing               // ������
                      );


implementation

end.
