unit LanguageTraditionalChinese;

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

  TLanguageTraditionalChinese = class(TLanguage)
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
