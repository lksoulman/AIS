unit UpdateCheck;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-6-10
// Comments：
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

  // 更新检查
  TUpdateCheck = class
  private
    //
    FFolder: string;
    // 服务端更新文件
    FServerUpdateFile: string;
    // 更新生成
    FUpdateGenerate: TUpdateGenerate;
  protected

  public
    // 构造方法
    constructor Create;
    // 析构函数
    destructor Destroy; override;
    // 加载路径
    procedure SetFolder(AFolder: string);
    // 检查是不是需要更新
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
