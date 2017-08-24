unit SecuConst;

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
  SysUtils,
  SecurityType;

const
  // ��Դ֤ȯ�г�����
  // SELECT DISTINCT SecuCategory FROM SecuMain ORDER BY SecuCategory
  GILDATA_SECUMARKET_SHFE      = 10;  // �Ϻ��ڻ�������(Shanghai futures exchange)	10
  GILDATA_SECUMARKET_DLME      = 13;  // ������Ʒ������(Dalian Mercantile Exchange)	13
  GILDATA_SECUMARKET_ZZME      = 15;  // ֣����Ʒ������(Zhengzhou Mercantile Exchange)	15
  GILDATA_SECUMARKET_ASX       = 49;  // �Ĵ�����֤ȯ������(Australian Stock Exchange)	49
  GILDATA_SECUMARKET_NZSE      = 50;  // ������֤ȯ������(New Zealand Stock Exchange)	50
  GILDATA_SECUMARKET_CFFE      = 51;  // �й������ڻ�������(China Financial Futures Exchange)	51
  GILDATA_SECUMARKET_ECASE     = 52;  // �������޼�����ɽ��֤ȯ������(Egypt, Cairo and Alexander Stock Exchange)	52
  GILDATA_SECUMARKET_ABASE     = 54;  // ����͢����ŵ˹����˹֤ȯ������(Buenos Aires stock exchange of Argentina)	54
  GILDATA_SECUMARKET_BSPSE     = 55;  // ����ʥ����֤ȯ������(St Paul stock exchange of Brazil)	55
  GILDATA_SECUMARKET_MSE       = 56;  // ī����֤ȯ������(Mexican Stock Exchange)	56
  GILDATA_SECUMARKET_MKLSE     = 57;  // �������Ǽ�¡��֤ȯ������(Kuala Lumpur stock exchange of Malaysia)	57
  GILDATA_SECUMARKET_JOSE      = 58;  // �ձ�����֤ȯ������(Osaka stock exchange, Japan)	58
  GILDATA_SECUMARKET_ISE       = 65;  // ӡ��������֤ȯ������(Indonesia Stock Exchange)	65
  GILDATA_SECUMARKET_TSE       = 66;  // ̩��֤ȯ������(The Stock Exchange of Thailand)	66
  GILDATA_SECUMARKET_SSE       = 67;  // �����׶�֤ȯ������(Seoul Stock Exchange)	67
  GILDATA_SECUMARKET_TKSE      = 68;  // ����֤ȯ������(The Tokyo Stock Exchange)	68
  GILDATA_SECUMARKET_SPSE      = 69;  // �¼���֤ȯ������(Singapore Stock Exchange)	69
  GILDATA_SECUMARKET_TWSE      = 70;  // ̨��֤ȯ������(Taiwan Stock Exchange)	70
  GILDATA_SECUMARKET_OTCM      = 71;  // ��̨�����г�(Over-the-counter market)	71
  GILDATA_SECUMARKET_HKSE      = 72;  // ���������(Hongkong Stock Exchange)	72
  GILDATA_SECUMARKET_PM        = 73;  // һ���г�(Primary Market)	73
  GILDATA_SECUMARKET_GIM       = 74;  // ��Դָ���г�(GILDATA index market)	74
  GILDATA_SECUMARKET_AOE       = 75;  // ��������������(Other exchanges in Asia)	75
  GILDATA_SECUMARKET_ASE       = 76;  // ����֤ȯ������	76
  GILDATA_SECUMARKET_NSE       = 77;  // ������˹���֤ȯ������(Nasdaq Stock Exchange)	77
  GILDATA_SECUMARKET_NYSE      = 78;  // ŦԼ֤ȯ������(New York stock exchange)	78
  GILDATA_SECUMARKET_USAOTM    = 79;  // �������������г�(Other trading markets in the United States)	79
  GILDATA_SECUMARKET_CTSE      = 80;  // ���ô���׶�֤ȯ������(Toronto stock exchange, Canada)	80
  GILDATA_SECUMARKET_TBM       = 81;  // �����г�(Third board Market)	81
  GILDATA_SECUMARKET_SHSE      = 83;  // �Ϻ�֤ȯ������(Shanghai Stock Exchange)	83
  GILDATA_SECUMARKET_OTM       = 84;  // �����г�(OTHER Market)	84
  GILDATA_SECUMARKET_LSE       = 85;  // �׶�֤ȯ������(London Stock Exchange)	85
  GILDATA_SECUMARKET_FPSE      = 86;  // ��������֤ȯ������(Paris stock exchange, France)	86
  GILDATA_SECUMARKET_GFSE      = 87;  // �¹������˸�֤ȯ������(Frankfurt stock exchange, Germany)	87
  GILDATA_SECUMARKET_OEE       = 88;  // ŷ������������(Other European exchanges)	88
  GILDATA_SECUMARKET_IBBM      = 89;  // ���м�ծȯ�г�(Interbank bond market)	89
  GILDATA_SECUMARKET_SZSE      = 90;  // ����֤ȯ������(Shenzhen Stock Exchange)	90
  GILDATA_SECUMARKET_OTCBB     = 91;  // ����OTCBB�г�	91
  GILDATA_SECUMARKET_OOTC      = 92;  // ����OtherOTC�г�	92
  GILDATA_SECUMARKET_SHIBLM    = 93;  // �Ϻ����м�ͬҵ����г�(Shanghai interbank lending market)	93
  GILDATA_SECUMARKET_SSSE      = 94;  // ��ʿ֤ȯ������(Swiss Stock Exchange)	94
  GILDATA_SECUMARKET_HLASE     = 95;  // ������ķ˹�ص�֤ȯ������(Amsterdam stock exchange of Holland)	95
  GILDATA_SECUMARKET_JSE       = 96;  // Լ����˹��֤ȯ������(Johannesburg Stock Exchange)	96
  GILDATA_SECUMARKET_LIFOE     = 97;  // �׶ع��ʽ����ڻ���Ȩ������(London International Financial Futures Options Exchange)	97
  GILDATA_SECUMARKET_NYSEE     = 98;  // ŦԼ��ŷ֤ȯ������(NYSE Euronext)	98
  GILDATA_SECUMARKET_TKIBLM    = 99;  // ����ͬҵ����г�(Tokyo interbank lending market)	99
  GILDATA_SECUMARKET_LIBLM     = 101; // �׶�����ͬҵ����г�(London interbank lending market)	101
  GILDATA_SECUMARKET_HKIBLM    = 102; // �������ͬҵ����г�(Hongkong interbank lending market)	102
  GILDATA_SECUMARKET_SIBLM     = 103; // �¼�������ͬҵ����г�(Interbank lending market in Singapore)	103
  GILDATA_SECUMARKET_CIBLM     = 104; // �й�����ͬҵ����г�(China interbank lending market)	104
  GILDATA_SECUMARKET_EIBLM     = 105; // ŷԪ����ͬҵ����г�(Euro interbank lending market)	105
  GILDATA_SECUMARKET_BSE       = 106; // ��³����֤ȯ������(Brussels Stock Exchange)	106
  GILDATA_SECUMARKET_JKSE      = 107; // �żӴ�֤ȯ������(Jakarta Stock Exchange)	107
  GILDATA_SECUMARKET_JPTM      = 109; // �ձ���˹��˽����г�(Japan's trading market)	109
  GILDATA_SECUMARKET_TASE      = 110; // ����ά��֤ȯ������(Tel-Aviv Stock Exchange)	110
  GILDATA_SECUMARKET_LBSE      = 120; // ¬ɭ��֤ȯ������(Luxemburg Stock Exchange)120
  GILDATA_SECUMARKET_BMSE      = 130; // ��Ľ��֤ȯ������(Bermuda Stock Exchange)	130
  GILDATA_SECUMARKET_PSE       = 140; // ������֤ȯ������(Prague Stock Exchange)	140
  GILDATA_SECUMARKET_FHSE      = 160; // �����ն�����֤ȯ������(Helsinki stock exchange of Finland)	160
  GILDATA_SECUMARKET_ITSE      = 161; // �����֤ȯ������(Italy Stock Exchange)	161
  GILDATA_SECUMARKET_CSE       = 162; // �籾����֤ȯ������(Copenhagen Stock Exchange)	162
  GILDATA_SECUMARKET_OB        = 180; // Ų����˹½֤ȯ������(Oslo Bors)	180
  GILDATA_SECUMARKET_SKKE      = 190; // ������˹��˽�����(South Korea kosda exchange)	190
  GILDATA_SECUMARKET_SLSE      = 200; // ˹�¸��Ħ֤ȯ������(stockholm stock exchange)	200
  GILDATA_SECUMARKET_WSE       = 201; // ��ɳ֤ȯ������(Warsaw Stock Exchange)	201
  GILDATA_SECUMARKET_IBSE      = 202; // ��˹̹����֤ȯ������(Istanbul Stock Exchange)	202
  GILDATA_SECUMARKET_INSE      = 210; // ӡ�ȹ���֤ȯ������(National stock exchange of India)	210
  GILDATA_SECUMARKET_SGSE      = 220; // ʥ���Ǹ�֤ȯ������(Santiago Stock Exchange)	220
  GILDATA_SECUMARKET_AVSE      = 230; // �µ���άҲ��֤ȯ������(Vienna stock exchange of Austria)	230
  GILDATA_SECUMARKET_MDSE      = 240; // �����������֤ȯ������(Madrid Stock Exchange)	240
  GILDATA_SECUMARKET_GAES      = 250; // ϣ���ŵ�֤ȯ������(Athens stock exchange, Greece)	250
  GILDATA_SECUMARKET_ISSE      = 260; // ������֤ȯ������(Irish stock exchange)	260
  GILDATA_SECUMARKET_TWSCM     = 270; // ̨��֤ȯ��̨�����г�(Taiwan securities counter market)	270
  GILDATA_SECUMARKET_PPSE      = 280; // ���ɱ�֤ȯ������(Philippines Stock Exchange)	280
  GILDATA_SECUMARKET_BBSE      = 290; // ӡ������֤ȯ������(Bombay Stock Exchange)	290
  GILDATA_SECUMARKET_AAPSE     = 300; // �Ĵ�������̫֤ȯ������(Australia Asia Pacific Stock Exchange)	300
  GILDATA_SECUMARKET_IAPP      = 310; // ������˽ļ��Ʒ���������ϵͳ(Inter agency private products pricing and service system)	310
  GILDATA_SECUMARKET_RMSE      = 320; // ����˹Ī˹��֤ȯ������(Russian Moscow Stock Exchange)	320
  GILDATA_SECUMARKET_SHHKM     = 330; // ����ͨ�����г�(Shanghai and Hong Kong through the joint market)	330
  GILDATA_SECUMARKET_SZGKM     = 340; // ���ͨ�����г�(Shenzhen and Hong Kong joint market)	340
  GILDATA_SECUMARKET_HKSM      = 350; // �۹�ͨ�����г�(Hong Kong stocks through the joint market)	350

  // ��Դ֤ȯ����
  // SELECT DISTINCT SecuMarket FROM SecuMain ORDER BY SecuMarket
  GILDATA_SECUCATEGORY_A_STOCK                        = 1;  // A��	1
  GILDATA_SECUCATEGORY_B_STOCK                        = 2;  // B��	2
  GILDATA_SECUCATEGORY_H_STOCK                        = 3;  // H��	3
  GILDATA_SECUCATEGORY_INDEX                          = 4;  // ����	4
  GILDATA_SECUCATEGORY_BUYBACK                        = 5;  // ��ծ�ع�	5
  GILDATA_SECUCATEGORY_NATIONALDEBT_CRSH              = 6;  // ��ծ�ֻ�	6
  GILDATA_SECUCATEGORY_FINANCIAL_BOND                 = 7;  // ����ծȯ	7
  GILDATA_SECUCATEGORY_OPEN_FUND                      = 8;  // ����ʽ����	8
  GILDATA_SECUCATEGORY_CONVERTIBLE_BOND               = 9;  // ��ת��ծȯ	9
  GILDATA_SECUCATEGORY_OTHER                          = 10; // ����	10
  GILDATA_SECUCATEGORY_ENTERPRISE_BOND                = 11; // ��ҵծȯ	11
  GILDATA_SECUCATEGORY_ENTERPRISE_BUYBACK             = 12; // ��ҵծȯ�ع�	12
  GILDATA_SECUCATEGORY_INVESTMENT_FUND                = 13; // Ͷ�ʻ���	13
  GILDATA_SECUCATEGORY_CENTRAL_BANK_BILL              = 14; // ����Ʊ��	14
  GILDATA_SECUCATEGORY_SZ_PROXY_SH_STOCK              = 15; // ���д����й�Ʊ
  GILDATA_SECUCATEGORY_SH_PROXY_SZ_STOCK              = 16; // ���д������й�Ʊ
  GILDATA_SECUCATEGORY_ASSET_BACKED                   = 17; // �ʲ�֧��֤ȯ	17     // bond
  GILDATA_SECUCATEGORY_ASSET_SECURITIZATION_PRODUCTS  = 18; // �ʲ�֤ȯ����Ʒ	18   // bond
  GILDATA_SECUCATEGORY_BUYOUT_REPO                    = 19; // ���ʽ�ع�	19       // repo
  GILDATA_SECUCATEGORY_DERIVATIVE_WARRANT             = 20; // ����Ȩ֤	20         // Ȩ֤
  GILDATA_SECUCATEGORY_EQUITY_WARRANT                 = 21; // �ɱ�Ȩ֤	21
  GILDATA_SECUCATEGORY_STOCK_IN_FUTURES               = 22; // ��ָ�ڻ�	22
  GILDATA_SECUCATEGORY_COMMERCIAL_BANK_DEPOSIT        = 23; // ��ҵ���ж��ڴ��	23   // ���
  GILDATA_SECUCATEGORY_OTHER_STOCK                    = 24; // ������Ʊ	24           //��Ʊ
  GILDATA_SECUCATEGORY_OX_BEAR_CERTIFICATE            = 25; // ţ��֤	25             // Ȩ֤
  GILDATA_SECUCATEGORY_INCOME_GROWTH_LINE             = 26; // ����������	26
  GILDATA_SECUCATEGORY_NEW_PLEDGED_REPO               = 27; // ����Ѻʽ�ع�	27       // �ع�
  GILDATA_SECUCATEGORY_LOCAL_GOVENMENT_DEBT           = 28; // �ط�����ծ	28         // bond
  GILDATA_SECUCATEGORY_EXCHANGE_BOND                  = 29; // �ɽ�����˾ծ	29       // bond
  GILDATA_SECUCATEGORY_LENDING                        = 30; // ���	30               // ���
  GILDATA_SECUCATEGORY_CREDIT_RISK_MITIGATION_VOUCHER = 31; // ���÷��ջ���ƾ֤	31
  GILDATA_SECUCATEGORY_FLOATING_INTEREST_RATE         = 32; // ��Ϣծ��Ϣ��׼����	32
  GILDATA_SECUCATEGORY_TIME_DEPOSIT_CERTIFICATE       = 33; // ���ڴ��ƾ֤	33       ///  ���
  GILDATA_SECUCATEGORY_STOCK_OPTION                   = 34; // ������Ȩ	34           //  ��Ȩ
  GILDATA_SECUCATEGORY_LARGE_DEPOSIT_CERTIFICATE      = 35; // �����ƾ֤	35       ///  ���
  GILDATA_SECUCATEGORY_STOCK_HK                       = 51; // �۹�	51               // stock
  GILDATA_SECUCATEGORY_STAPLED_SECURITIES             = 52; // �϶�֤ȯ	52
  GILDATA_SECUCATEGORY_STOCK_RED_CHIPS                = 53; // ����	53             // stock
  GILDATA_SECUCATEGORY_PREFERRED_STOCK                = 55; // ���ȹ�	55                          // stock
  GILDATA_SECUCATEGORY_FUND                           = 60; // ����	60                            // fund
  GILDATA_SECUCATEGORY_TRUST_FUND                     = 61; // ���л���	61                        // fund
  GILDATA_SECUCATEGORY_ETF_FUND                       = 62; // ETF����	62                        // fund
  GILDATA_SECUCATEGORY_PARTICIPATION_CERTIFICATE      = 63; // ����֤��	63
  GILDATA_SECUCATEGORY_LEVER_AND_REVERSE_PRODUCTS     = 64; // �ܸ˼������Ʒ	64
  GILDATA_SECUCATEGORY_DEBT_SECURITIES                = 65; // ծ��֤ȯ	65
  GILDATA_SECUCATEGORY_EXCHANGE_FUND_BILL             = 66; // ����Ʊ��	66                        // bond
  GILDATA_SECUCATEGORY_AMERICAN_SECURITIES            = 69; // ����֤ȯ(��������ƻ�)	69
  GILDATA_SECUCATEGORY_ORDINARY_DEPOSITARY_RECEIPT    = 71; // ��ͨԤ��֤ȯ	71
  GILDATA_SECUCATEGORY_PRE_PREFERRED_SECURITIES       = 72; // ����Ԥ��֤ȯ	72
  GILDATA_SECUCATEGORY_STOCK                          = 73; // ��Ʊ	73
  GILDATA_SECUCATEGORY_COMMON_STOCK                   = 74; // ��ͨ��	74
  GILDATA_SECUCATEGORY_AMERICAN_DEPOSITARY_RECEIP     = 75; // �������й�Ʊ��ADS��	75

  // ������ȯ����
  GILDATA_MARGIN_NONE                       = 0;  // �������ʲ�����ȯ
  GILDATA_MARGIN_FINANCE                    = 10; // ������
  GILDATA_MARGIN_LOAN                       = 20; // ����ȯ
  GILDATA_MARGIN_FINANCE_AND_LOAN           = 30; // �����ʿ���ȯ

  // �۹�ͨ��ʶ����
  GIlDATA_THROUGH_NONE                      = 0;   // ��ͨ��־
  GIlDATA_THROUGH_HK_SH                     = 1;   // �۹�ͨ��
  GIlDATA_THROUGH_SH                        = 2;   // ����ͨ
  GIlDATA_THROUGH_SZ                        = 3;   // ���ͨ
  GIlDATA_THROUGH_HK_SZ                     = 4;   // �۹�ͨ��
  GIlDATA_THROUGH_HK_SH_SZ                  = 5;   // �۹�ͨ(����)

  // �̶�����֤ȯ
  GIlDATA_INNERCODE_YUEBAO                  = 64119;

  // ����״̬
  GIlDATA_LISTING                           = 1;  //����	1
  GIlDATA_PRE_LISTING                       = 2;  //Ԥ����	2
  GIlDATA_STOP                              = 3;  //��ͣ	3
  GIlDATA_LISTING_FAILURE                   = 4;  //����ʧ��	4
  GIlDATA_TERMINATED                        = 5;  //��ֹ	5
  GIlDATA_OTHER                             = 9;  //����	9
  GIlDATA_TRADING                           = 10; //����	10
  GIlDATA_SUSPENDED                         = 11; //ͣ��	11
  GIlDATA_DELIST                            = 12; //ժ��	12

////////////////////////////////////////////////////////////////////////////////

  // ������ȯ����
  MARGIN_NONE                               = $00; // �������ʲ�����ȯ
  MARGIN_FINANCE                            = $01; // ������
  MARGIN_LOAN                               = $02; // ����ȯ
  MARGIN_FINANCE_AND_LOAN                   = $03; // �����ʿ���ȯ
  MARGIN_MASK                               = $0F; // ����

  // �۹�ͨ��ʶ����
  THROUGH_NONE                              = $00; // ��ͨ��־
  THROUGH_HK_SH                             = $10; // �۹�ͨ��
  THROUGH_SH                                = $20; // ����ͨ
  THROUGH_SZ                                = $30; // ���ͨ
  THROUGH_HK_SZ                             = $40; // �۹�ͨ��
  THROUGH_HK_SH_SZ                          = $50; // �۹�ͨ(����)
  THROUGH_MASK                              = $F0; // ����

  //

type

  TGildataUtil = class
  public
    // ����ת��
    class function ValueConvertMargin(AInt: Integer): Byte;
    // ͨת��
    class function ValueConvertThrough(AInt: Integer): Byte;
    // ת��������ȯ����
    class function ValueConvertMarginType(AMargin: Integer): TMarginType;
    // ת��ͨ����
    class function ValueConvertThroughType(AThrough: Integer): TThroughType;
    // ת������״̬
    class function ValueConvertListedStateType(AListedState: Integer): TListedStateType;
    // ת������
    class function ValueConvertSecurityType(AInnerCode, ASecuMarket, ASecuCategory: Integer): TSecurityType;
  end;

implementation

{ TGildataUtil }

class function TGildataUtil.ValueConvertMargin(AInt: Integer): Byte;
begin
  case AInt of
    GILDATA_MARGIN_FINANCE:
      begin
        Result := MARGIN_FINANCE;
      end;
    GILDATA_MARGIN_LOAN:
      begin
        Result := MARGIN_LOAN;
      end;
    GILDATA_MARGIN_FINANCE_AND_LOAN:
      begin
        Result := MARGIN_FINANCE_AND_LOAN;
      end;
  else
    Result := MARGIN_NONE;
  end;
end;

class function TGildataUtil.ValueConvertThrough(AInt: Integer): Byte;
begin
  case AInt of
    GIlDATA_THROUGH_HK_SH:
      begin
        Result := THROUGH_HK_SH;
      end;
    GIlDATA_THROUGH_SH:
      begin
        Result := THROUGH_SH;
      end;
    GIlDATA_THROUGH_SZ:
      begin
        Result := THROUGH_SZ;
      end;
    GIlDATA_THROUGH_HK_SZ:
      begin
        Result := THROUGH_HK_SZ;
      end;
    GIlDATA_THROUGH_HK_SH_SZ:
      begin
        Result := THROUGH_HK_SH_SZ;
      end;
  else
    Result := THROUGH_NONE;
  end;
end;

class function TGildataUtil.ValueConvertMarginType(AMargin: Integer): TMarginType;
begin
  case AMargin of
    MARGIN_FINANCE:
      begin
        Result := mtFinance;
      end;
    MARGIN_LOAN:
      begin
        Result := mtLoan;
      end;
    MARGIN_FINANCE_AND_LOAN:
      begin
        Result := mtFinanceAndLoan;
      end;
  else
    Result := mtNone;
  end;
end;

class function TGildataUtil.ValueConvertThroughType(AThrough: Integer): TThroughType;
begin
  case AThrough of
    THROUGH_HK_SH:
      begin
        Result := ttHKSH;
      end;
    THROUGH_SH:
      begin
        Result := ttSH;
      end;
    THROUGH_SZ:
      begin
        Result := ttSZ;
      end;
    THROUGH_HK_SZ:
      begin
        Result := ttHKSZ;
      end;
    THROUGH_HK_SH_SZ:
      begin
        Result := ttHKSHSZ;
      end;
  else
    Result := ttNone;
  end;
end;

class function TGildataUtil.ValueConvertSecurityType(AInnerCode, ASecuMarket,
  ASecuCategory: Integer): TSecurityType;
begin
  case ASecuCategory of
    1, 2:
      begin
        if ASecuMarket = 81 then begin
          Result := stNewThirdBoardStock;
        end else begin
          Result := stHSStock;
        end;
      end;
    3, 20, 21, 25, 51, 52, 53, 55, 63, 65, 71, 72:
      begin
        Result := stHKStock;
      end;
    4, 910, 920:
      begin
        if AInnerCode = GIlDATA_INNERCODE_YUEBAO then begin
          Result := stYuEBaoIndex;
        end else begin
          case ASecuMarket of
            49, 50, 52, 54, 55, 56, 57, 58, 65, 66,
            67, 68, 69, 70, 72, 75, 76, 77, 78, 79,
            80, 85, 86, 87, 88, 94, 95, 98, 106, 107,
            109, 110, 120, 130, 140, 160, 161, 162, 180, 190,
            200, 201, 210, 220, 230, 240, 250, 260, 270, 280,
            290, 300, 320:
              Result := stForeignIndex;
          else
            Result := stIndex;
          end;
        end;
      end;
    61, 62, 82, 84, 85, 86, 1301, 1302:
      begin
        Result := stInnerFund;
      end;
    81:
      begin
        Result := stOuterNonCurrencyFund;
      end;
    83:
      begin
        Result := stOuterCurrencyFund;
      end;
    6, 7, 11, 14, 18, 17, 28:
      begin
        if (ASecuMarket = 83) or (ASecuMarket =90) then begin
          Result := stHSBond;
        end else begin
          Result := stBond;
        end;
      end;
    5, 12, 19, 27:
      begin
        if (ASecuMarket = 83) or (ASecuMarket =90) then begin
          Result := stBuyBackBond;
        end;
      end;
    9, 29:
      begin
        Result := stConvertibleBond;
      end;
    801, 802:
      begin
        Result := stCommodityFutures;
      end;
    803, 804:
      begin
        Result := stFinancialFutures;
      end;
  else
    Result := stHSStock;
  end;
end;

class function TGildataUtil.ValueConvertListedStateType(AListedState: Integer): TListedStateType;
begin
  if (AListedState = GIlDATA_LISTING)
    or (AListedState = GIlDATA_TRADING)
    or (AListedState = GIlDATA_SUSPENDED) then begin
    Result := ltListing;
  end else begin
    Result := ltDeListing;
  end;
end;

end.

