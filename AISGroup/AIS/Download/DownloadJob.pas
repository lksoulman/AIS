unit DownloadJob;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-7-28
// Comments：
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
    // 下载地址
    FUrl: string;
    // 下载文件名称
    FFileName: string;
    // 文件大小
    FFileSize: Integer;
    // 是不是已经下载完成
    FIsFinish: Boolean;
    // 已经下载的文件大小
    FFinishSize: Integer;
    // 本地保存目录
    FLocalSavePath: string;
  protected
  public
    // 构造方法
    constructor Create;
    // 析构函数
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
