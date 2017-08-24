unit SecurityImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-7-23
// Comments：
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
    // 证券内码
    FInnerCode: Integer;
    // 证券内码
    FSecuCode: string;
    // 后缀
    FSuffix: string;
    // 证券简称
    FSecuAbbr: string;
    // 证券拼音
    FSecuSpell: string;
    // 证券曾用名
    FFormerAbbr: string;
    // 证券曾用名拼音
    FFormerSpell: string;
    // 证券市场
    FSecuMarket: Byte;
    // 上市状态
    FListedState: Byte;
    // 证券类别
    FSecuCategory: Byte;
    // 证券多个标志
    FSecuCategoryI: Byte;
    // 证券类型
    FSecurityType: TSecurityType;
  protected
    // 初始化数据
    procedure DoUpdateData;
  public
    // 构造函数
    constructor Create;
    // 析构函数
    destructor Destroy; override;

    { ISecurity }

    // 获取证券内部编码
    function GetInnerCode: Integer; safecall;
    // 获取证券代码
    function GetSecuCode: WideString; safecall;
    // 获取证券后缀
    function GetSuffix: WideString; safecall;
    // 获取证券市场
    function GetSecuMarket: Integer; safecall;
    // 获取证券证券类别
    function GetSecuCategory: Integer; safecall;
    // 获取证券简称
    function GetSecuAbbr: WideString; safecall;
    // 获取证券拼音
    function GetSecuSpell: WideString; safecall;
    // 获取曾用名简称
    function GetFormerAbbr: WideString; safecall;
    // 获取曾用名拼音
    function GetFormerSpell: WideString; safecall;
    // 证券类型
    function GetSecurityType: TSecurityType; safecall;
    // 上市状态
    function GetListedStateType: TListedStateType; safecall;
    // 融资融券类型
    function GetSecuMarginType: TMarginType; safecall;
    // 通类型
    function GetSecuThroughType: TThroughType; safecall;

    {ISecuUpdate}

    // 更新数据
    procedure UpdateSecurityData; safecall;
    // 设置内码
    procedure SetInnerCode(AInnerCode: Integer); safecall;
    // 设置证券代码
    procedure SetSecuCode(ASecuCode: string); safecall;
    // 设置代码证券后缀
    procedure SetSuffic(ASuffix: string); safecall;
    // 设置证券简称
    procedure SetSecuAbbr(ASecuAbbr: string); safecall;
    // 设置证券拼音
    procedure SetSecuSpell(ASecuSpell: string); safecall;
    // 设置证券曾用名简称
    procedure SetFormerAbbr(AFormerAbbr: string); safecall;
    // 设置证券曾用名拼音
    procedure SetFormerSpell(AFormerSpell: string); safecall;
    // 设置证券市场
    procedure SetSecuMarket(ASecuMarket: Byte); safecall;
    // 设置上市状态
    procedure SetListedState(AListedState: Byte); safecall;
    // 设置证券类型
    procedure SetSecuCategory(ASecuCategory: Byte); safecall;
    // 设置融资融券、通类型
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
