unit Language;

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
  LanguageType,
  CommonRefCounter,
  Generics.Collections;

type

  TLanguage = class(TAutoObject)
  private
  protected
    // ��������
    FLanguageType: TLanguageType;
    // ���԰��ı��ֵ�
    FLanguageTextDic: TDictionary<Integer, string>;

    // ��ʼ���ֵ�
    procedure DoInitLanguageTextDic; virtual;
  public
    // ���캯��
    constructor Create; override;
    // ��������
    destructor Destroy; override;
    // ͨ�����԰��ı�ID��ȡ���԰����ı�
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
