unit SecuMain;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� SecuMain Memory Table
// Author��      lksoulman
// Date��        2017-9-2
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  CommonObject;

type

  // ֤ȯ����
  TSecurityType = ( stHSStock,                  // �����Ʊ
                    stHKStock,                  // �۹�
                    stUSStock,                  // ����
                    stNewThirdBoardStock,       // ������
                    stIndex,                    // ָ��
                    stForeignIndex,             // ����ָ��
                    stYuEBaoIndex,              // ������ָ��
                    stBond,                     // ��ͨծȯ
                    stHSBond,                   // ����ծȯ
                    stBuyBackBond,              // ծȯ�ع�
                    stConvertibleBond,          // ��תծ
                    stInnerFund,                // ���ڻ���
                    stOuterCurrencyFund,        // �������(����)
                    stOuterNonCurrencyFund,     // �������(�ǻ���)
                    stCommodityFutures,         // ��Ʒ�ڻ�
                    stFinancialFutures          // �����ڻ�
                   );

  // ������ȯ����
  TMarginType = ( mtNone,                       // �������ʲ�����ȯ
                  mtFinance,                    // ������
                  mtLoan,                       // ����ȯ
                  mtFinanceAndLoan              // �����ʿ���ȯ
                 );

  // ͨ����
  TThroughType = ( ttNone,
                   ttHKSH,                      // �۹�ͨ��
                   ttHKSZ,                      // �۹�ͨ��
                   ttHKSHSZ,                    // �۹�ͨ����
                   ttSH,                        // ����ͨ
                   ttSZ                         // ���ͨ
                   );

  // ����״̬
  TListedType = ( ltListing,                    // ����
                  ltDeListing                   // ������
                  );

  // SecuMain Item
  TSecuMainItem = packed record
    FIsUsed: Boolean;                           // �ǲ�������
    FInnerCode: Int32;                          // ֤ȯ����
    FSecuMarket: UInt8;                         // ֤ȯ�г�
    FListedState: UInt8;                        // ����״̬
    FSecuCategory: UInt16;                      // ֤ȯ���
    FSecuSpecialMark: UInt8;                    // ֤ȯ������(������ȯ���۹�ͨ������ͨ�����ͨ)
    FMarginType: TMarginType;                   // ������ȯ����
    FThroughType: TThroughType;                 // �۹�ͨ������ͨ�����ͨ
    FSecurityType: TSecurityType;               // ֤ȯ����
    FSecuAbbr: string;                          // ֤ȯ���
    FSecuCode: string;                          // ֤ȯ����
    FSecuSpell: string;                         // ֤ȯƴ��
    FSecuSuffix: string;                        // ֤ȯ��׺
    FFormerAbbr: string;                        // ֤ȯ������
    FFormerSpell: string;                       // ֤ȯ������ƴ��

    // Set Update
    function SetUpdate: boolean;
    // Get Margin
    function GetMargin: Integer;
    // Get Through
    function GetThrough: Integer;
    // Get MarginType
    function GetMarginType: TMarginType;
    // Get Through Type
    function GetThroughType: TThroughType;
    // Get Security Type
    function GetSecurityType: TSecurityType;
  end;

  // SecuMain Item Pointer
  PSecuMainItem = ^TSecuMainItem;

  // SecuMain Item Pointer Dynamic Array
  TPSecuMainItemDynArray = Array Of PSecuMainItem;

  // SecuMain Memory Table Interface
  ISecuMain = Interface(IInterface)
    ['{B0E5F129-246A-4537-A142-D745D6D1B859}']
    // Lock
    procedure Lock; safecall;
    // Un Lock
    procedure UnLock; safecall;
    // Get Item Count
    function GetItemCount: Integer; safecall;
    // Get Item
    function GetItem(AIndex: Integer): PSecuMainItem; safecall;
    // Get Item By InnerCode
    function GetItemByInnerCode(AInnerCode: Integer): PSecuMainItem; safecall;
  end;

  // SecuMain Query
  ISecuMainQuery = Interface(IInterface)
    ['{CB6B22C8-1BCF-449A-9328-8D9E85046448}']
    // Get Security By InnerCode
    function GetSecurity(AInnerCode: Integer): PSecuMainItem; safecall;
    // Get Securitys By InnerCodes
    function GetSecuritys(AInnerCodes: TIntegerDynArray; var APSecuMainItems: TPSecuMainItemDynArray): Boolean; safecall;
  end;

implementation

uses
  SecuMainConst;

{ TSecuMainItem }

function TSecuMainItem.SetUpdate: boolean;
begin
  Result := True;
end;

function TSecuMainItem.GetMargin: Integer;
var
  LMargin: UInt8;
begin
  LMargin := FSecuSpecialMark and MARGIN_MASK;
  LMargin := LMargin shr 4;
  Result := LMargin;
end;

function TSecuMainItem.GetThrough: Integer;
begin
  Result := (FSecuSpecialMark and THROUGH_MASK);
end;

function TSecuMainItem.GetMarginType: TMarginType;
begin
  Result := FMarginType;
end;

function TSecuMainItem.GetThroughType: TThroughType;
begin
  Result := FThroughType;
end;

function TSecuMainItem.GetSecurityType: TSecurityType;
begin
  Result := FSecurityType;
end;

end.
