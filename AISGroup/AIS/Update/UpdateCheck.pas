unit UpdateCheck;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-6-10
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Update,
  UpdateGenerate,
  System.Generics.Collections;

type

  // ���¼��
  TUpdateCheck = class
  private
    //
    FFolder: string;
    // ����˸����ļ�
    FServerUpdateFile: string;
    // ��������
    FUpdateGenerate: TUpdateGenerate;
  protected

  public
    // ���췽��
    constructor Create;
    // ��������
    destructor Destroy; override;
    // ����·��
    procedure SetFolder(AFolder: string);
    // ����ǲ�����Ҫ����
    function CheckIsNeedUpdate: Boolean;
  end;

implementation

{ TUpdateCheck }

constructor TUpdateCheck.Create;
begin
  inherited;
  FUpdateGenerate := TUpdateGenerate.Create;
end;

destructor TUpdateCheck.Destroy;
begin
  FUpdateGenerate.Free;
  inherited;
end;

procedure TUpdateCheck.SetFolder(AFolder: string);
begin

end;

function TUpdateCheck.CheckIsNeedUpdate: Boolean;
begin

end;

end.
