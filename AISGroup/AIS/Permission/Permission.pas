unit Permission;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-17
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

type

  TPermission = class
  private
    // 权限编号
    FPermNo: Integer;
    // 下载文件名称
    FPermName: string;
    // 权限结束时间
    FEndDate: TDateTime;
    // 权限开始时间
    FStartDate: TDateTime;
  protected
  public
    // 构造方法
    constructor Create;
    // 析构函数
    destructor Destroy; override;

    property PermNo: Integer read FPermNo write FPermNo;
    property PermName: string read FPermName write FPermName;
    property EndDate: TDateTime read FEndDate write FEndDate;
    property StartDate: TDateTime read FStartDate write FStartDate;
  end;

implementation

{ TPermission }

constructor TPermission.Create;
begin
  inherited;

end;

destructor TPermission.Destroy;
begin

  inherited;
end;

end.
