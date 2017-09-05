unit DownloadJob;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-7-28
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

type

  TDownloadJob = class
  private
    // ���ص�ַ
    FUrl: string;
    // �����ļ�����
    FFileName: string;
    // �ļ���С
    FFileSize: Integer;
    // �ǲ����Ѿ��������
    FIsFinish: Boolean;
    // �Ѿ����ص��ļ���С
    FFinishSize: Integer;
    // ���ر���Ŀ¼
    FLocalSavePath: string;
  protected
  public
    // ���췽��
    constructor Create;
    // ��������
    destructor Destroy; override;

    property Url: string read FUrl write FUrl;
    property FileName: string read FFileName write FFileName;
    property FileSize: Integer read FFileSize write FFileSize;
    property IsFinish: Boolean read FIsFinish write FIsFinish;
    property FinishSize: Integer read FFinishSize write FFinishSize;
    property LocalSavePath: string read FLocalSavePath write FLocalSavePath;
  end;

implementation

{ TDownloadJob }

constructor TDownloadJob.Create;
begin
  inherited;
  FUrl := '';
  FFileName := '';
  FFileSize := 0;
  FIsFinish := False;
  FFinishSize := 0;
  FLocalSavePath := '';
end;

destructor TDownloadJob.Destroy;
begin

  inherited;
end;

end.
