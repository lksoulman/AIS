unit LanguageTraditionalChinese;

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
  Language;

type

  TLanguageTraditionalChinese = class(TLanguage)
  private
  protected
  // 初始化字典
    procedure DoInitLanguageTextDic; override;
  public
    // 构造函数
    constructor Create; override;
    // 析构函数
    destructor Destroy; override;
  end;


implementation

{ TLanguageTraditionalChinese }

constructor TLanguageTraditionalChinese.Create;
begin
  inherited;

end;

destructor TLanguageTraditionalChinese.Destroy;
begin

  inherited;
end;

procedure TLanguageTraditionalChinese.DoInitLanguageTextDic;
begin

end;

end.
