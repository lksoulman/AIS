unit CommandPerm;

interface

uses
  Windows,
  Classes,
  SysUtils,
  CommandImpl,
  CommonRefCounter;

type

  // 命令权限
  TCommandPerm = class(TAutoObject)
  private
    // 权限编号
    FPermNo: Integer;
    // 权限掩码
    FPermMask: Integer;
    // 命令 ID
    FCommandID: Integer;
    // 命名创建类
    FCommandClass: TCommandImplClass;
  protected
  public
    // 构造函数
    constructor Create; override;
    // 析构函数
    destructor Destroy; override;

    property PermNo: Integer read FPermNo write FPermNo;
    property PermMask: Integer read FPermMask write FPermMask;
    property CommandID: Integer read FCommandID write FCommandID;
    property CommandClass: TCommandImplClass read FCommandClass write FCommandClass;
  end;

implementation

{ TCommandPerm }

constructor TCommandPerm.Create;
begin
  inherited;

end;

destructor TCommandPerm.Destroy;
begin

  inherited;
end;

end.
