unit LanguageChinese;

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

  TLanguageChinese = class(TLanguage)
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

{ TLanguageChinese }

constructor TLanguageChinese.Create;
begin
  inherited;

end;

destructor TLanguageChinese.Destroy;
begin

  inherited;
end;

procedure TLanguageChinese.DoInitLanguageTextDic;
begin

end;

end.
