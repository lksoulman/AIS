unit SecurityImpl;

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
  Security,
  SecuUpdate,
  SecurityType;

type

  TSecurityImpl = class(TInterfacedObject, ISecurity, ISecuUpdate)
  private
    // ֤ȯ����
    FInnerCode: Integer;
    // ֤ȯ����
    FSecuCode: string;
    // ��׺
    FSuffix: string;
    // ֤ȯ���
    FSecuAbbr: string;
    // ֤ȯƴ��
    FSecuSpell: string;
    // ֤ȯ������
    FFormerAbbr: string;
    // ֤ȯ������ƴ��
    FFormerSpell: string;
    // ֤ȯ�г�
    FSecuMarket: Byte;
    // ����״̬
    FListedState: Byte;
    // ֤ȯ���
    FSecuCategory: Byte;
    // ֤ȯ�����־
    FSecuCategoryI: Byte;
    // ֤ȯ����
    FSecurityType: TSecurityType;
  protected
    // ��ʼ������
    procedure DoUpdateData;
  public
    // ���캯��
    constructor Create;
    // ��������
    destructor Destroy; override;

    { ISecurity }

    // ��ȡ֤ȯ�ڲ�����
    function GetInnerCode: Integer; safecall;
    // ��ȡ֤ȯ����
    function GetSecuCode: WideString; safecall;
    // ��ȡ֤ȯ��׺
    function GetSuffix: WideString; safecall;
    // ��ȡ֤ȯ�г�
    function GetSecuMarket: Integer; safecall;
    // ��ȡ֤ȯ֤ȯ���
    function GetSecuCategory: Integer; safecall;
    // ��ȡ֤ȯ���
    function GetSecuAbbr: WideString; safecall;
    // ��ȡ֤ȯƴ��
    function GetSecuSpell: WideString; safecall;
    // ��ȡ���������
    function GetFormerAbbr: WideString; safecall;
    // ��ȡ������ƴ��
    function GetFormerSpell: WideString; safecall;
    // ֤ȯ����
    function GetSecurityType: TSecurityType; safecall;
    // ����״̬
    function GetListedStateType: TListedStateType; safecall;
    // ������ȯ����
    function GetSecuMarginType: TMarginType; safecall;
    // ͨ����
    function GetSecuThroughType: TThroughType; safecall;

    {ISecuUpdate}

    // ��������
    procedure UpdateSecurityData; safecall;
    // ��������
    procedure SetInnerCode(AInnerCode: Integer); safecall;
    // ����֤ȯ����
    procedure SetSecuCode(ASecuCode: string); safecall;
    // ���ô���֤ȯ��׺
    procedure SetSuffic(ASuffix: string); safecall;
    // ����֤ȯ���
    procedure SetSecuAbbr(ASecuAbbr: string); safecall;
    // ����֤ȯƴ��
    procedure SetSecuSpell(ASecuSpell: string); safecall;
    // ����֤ȯ���������
    procedure SetFormerAbbr(AFormerAbbr: string); safecall;
    // ����֤ȯ������ƴ��
    procedure SetFormerSpell(AFormerSpell: string); safecall;
    // ����֤ȯ�г�
    procedure SetSecuMarket(ASecuMarket: Byte); safecall;
    // ��������״̬
    procedure SetListedState(AListedState: Byte); safecall;
    // ����֤ȯ����
    procedure SetSecuCategory(ASecuCategory: Byte); safecall;
    // ����������ȯ��ͨ����
    procedure SetSecuCategoryI(ASecuCategoryI: Byte); safecall;


    property InnerCode: Integer read FInnerCode write FInnerCode;
    property SecuCode: string read FSecuCode write FSecuCode;
    property Suffix: string read FSuffix write FSuffix;
    property SecuAbbr: string read FSecuAbbr write FSecuAbbr;
    property SecuSpell: string read FSecuSpell write FSecuSpell;
    property FormerAbbr: string read FFormerAbbr write FFormerAbbr;
    property FormerSpell: string read FFormerSpell write FFormerSpell;
    property SecuMarket: Byte read FSecuMarket write FSecuMarket;
    property ListedState: Byte read FListedState write FListedState;
    property SecuCategory: Byte read FSecuCategory write FSecuCategory;
    property SecuCategoryI: Byte read FSecuCategoryI write FSecuCategoryI;
  end;

implementation

uses
  SecuConst;

{ TSecurityImpl }

constructor TSecurityImpl.Create;
begin
  inherited;

end;

destructor TSecurityImpl.Destroy;
begin

  inherited;
end;

procedure TSecurityImpl.DoUpdateData;
begin
  FSecurityType := TGildataUtil.ValueConvertSecurityType(FInnerCode, FSecuMarket, FSecuCategory);
end;

function TSecurityImpl.GetInnerCode: Integer;
begin
  Result := FInnerCode;
end;

function TSecurityImpl.GetSecuCode: WideString;
begin
  Result := FSecuCode;
end;

function TSecurityImpl.GetSuffix: WideString;
begin
  Result := FSuffix;
end;

function TSecurityImpl.GetSecuMarket: Integer;
begin
  Result := FSecuMarket;
end;

function TSecurityImpl.GetSecuCategory: Integer;
begin
  Result := FSecuCategory;
end;

function TSecurityImpl.GetSecuAbbr: WideString;
begin
  Result := FSecuAbbr;
end;

function TSecurityImpl.GetSecuSpell: WideString;
begin
  Result := FSecuSpell;
end;

function TSecurityImpl.GetFormerAbbr: WideString;
begin
  Result := FFormerAbbr;
end;

function TSecurityImpl.GetFormerSpell: WideString;
begin
  Result := FFormerSpell;
end;

function TSecurityImpl.GetSecurityType: TSecurityType;
begin
  Result := FSecurityType;
end;

function TSecurityImpl.GetListedStateType: TListedStateType;
begin
  Result := TGildataUtil.ValueConvertListedStateType(FListedState);
end;

function TSecurityImpl.GetSecuMarginType: TMarginType;
var
  LByte: Byte;
begin
  LByte := (FSecuCategoryI and MARGIN_MASK);
  Result := TGildataUtil.ValueConvertMarginType(LByte);
end;

function TSecurityImpl.GetSecuThroughType: TThroughType;
var
  LByte: Byte;
begin
  LByte := (FSecuCategoryI and THROUGH_MASK) shr 4;
  Result := TGildataUtil.ValueConvertThroughType(LByte);
end;

procedure TSecurityImpl.UpdateSecurityData;
begin
  DoUpdateData;
end;

procedure TSecurityImpl.SetInnerCode(AInnerCode: Integer);
begin
  FInnerCode := AInnerCode;
end;

procedure TSecurityImpl.SetSecuCode(ASecuCode: string);
begin
  FSecuCode := ASecuCode;
end;

procedure TSecurityImpl.SetSuffic(ASuffix: string);
begin
  FSuffix := ASuffix;
end;

procedure TSecurityImpl.SetSecuAbbr(ASecuAbbr: string);
begin
  FSecuAbbr := ASecuAbbr;
end;

procedure TSecurityImpl.SetSecuSpell(ASecuSpell: string);
begin
  FSecuSpell := ASecuSpell;
end;

procedure TSecurityImpl.SetFormerAbbr(AFormerAbbr: string);
begin
  FFormerAbbr := AFormerAbbr;
end;

procedure TSecurityImpl.SetFormerSpell(AFormerSpell: string);
begin
  FFormerSpell := AFormerSpell;
end;

procedure TSecurityImpl.SetSecuMarket(ASecuMarket: Byte);
begin
  FSecuMarket := ASecuMarket;
end;

procedure TSecurityImpl.SetListedState(AListedState: Byte);
begin
  FListedState := AListedState;
end;

procedure TSecurityImpl.SetSecuCategory(ASecuCategory: Byte);
begin
  FSecuCategory := ASecuCategory;
end;

procedure TSecurityImpl.SetSecuCategoryI(ASecuCategoryI: Byte);
begin
  FSecuCategoryI := ASecuCategoryI;
end;

end.
