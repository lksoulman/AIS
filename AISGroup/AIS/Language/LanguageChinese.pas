unit LanguageChinese;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-21
// Comments��
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
    // ��ʼ���ֵ�
    procedure DoInitLanguageTextDic; override;
  public
    // ���캯��
    constructor Create; override;
    // ��������
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
