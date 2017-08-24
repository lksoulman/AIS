unit Language;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-21
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  LanguageType,
  CommonRefCounter,
  Generics.Collections;

type

  TLanguage = class(TAutoObject)
  private
  protected
    // 语言类型
    FLanguageType: TLanguageType;
    // 语言包文本字典
    FLanguageTextDic: TDictionary<Integer, string>;

    // 初始化字典
    procedure DoInitLanguageTextDic; virtual;
  public
    // 构造函数
    constructor Create; override;
    // 析构函数
    destructor Destroy; override;
    // 通过语言包文本ID获取语言包的文本
    function GetLanguageText(ALanguageID: Integer): string;
  end;

implementation

{ TLanguage }

constructor TLanguage.Create;
begin
  inherited;
  FLanguageTextDic := TDictionary<Integer, string>.Create(1000);
  DoInitLanguageTextDic;
end;

destructor TLanguage.Destroy;
begin
  FLanguageTextDic.Free;
  inherited;
end;

procedure TLanguage.DoInitLanguageTextDic;
begin

end;

function TLanguage.GetLanguageText(ALanguageID: Integer): string;
begin
  FLanguageTextDic.TryGetValue(ALanguageID, Result);
end;

end.
