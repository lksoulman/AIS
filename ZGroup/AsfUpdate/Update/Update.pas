unit Update;

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
  SysUtils;

type

  TUpgradeType = (utOrdinary,     // 普通升级类型
                  utForce         // 强制升级类型
                  );

  TUpdate = class
  private
    // 文件名称
    FName: string;
    // 文件大小
    FSize: Int64;
    // 文件的校验值，检查文件下载是不是完全
    FCrcValue: string;
    // 文件的MD5值，用于检查版本更新
    FMD5Value: string;
    // 文件的相对路径 (相对于Bin目录的路径)
    FRelativeFolder: string;
    // 生成时间
    FGenerateTime: TDateTime;
    // 文件升级类型
    FUpgradeType: TUpgradeType;
  protected
  public
    // 构造方法
    constructor Create;
    // 析构函数
    destructor Destroy; override;
    // 重置数据
    procedure ResetValue;
    // 赋值方法
    procedure Assign(AUpdate: TUpdate);
    // Int 转 UpdateType
    function IntToUpgradeType(AValue: Integer): TUpgradeType;
    // UpdateType 转 Int
    function UpgradeTypeToInt(AUpgradeType: TUpgradeType): Integer;

    property Size: Int64 read FSize write FSize;
    property Name: string read FName write FName;
    property CrcValue: string read FCrcValue write FCrcValue;
    property MD5Value: string read FMD5Value write FMD5Value;
    property RelativeFolder: string read FRelativeFolder write FRelativeFolder;
    property GenerateTime: TDateTime read FGenerateTime write FGenerateTime;
    property UpgradeType: TUpgradeType read FUpgradeType write FUpgradeType;
  end;

implementation

{ TUpdate }

constructor TUpdate.Create;
begin
  inherited;
  ResetValue;
end;

destructor TUpdate.Destroy;
begin

  inherited;
end;

procedure TUpdate.ResetValue;
begin
  FName := '';
  FSize := 0;
  FCrcValue := '';
  FMD5Value := '';
  FRelativeFolder := '';
end;

procedure TUpdate.Assign(AUpdate: TUpdate);
begin
  if AUpdate = nil then Exit;

  FName := AUpdate.Name;
  FSize := AUpdate.Size;
  FCrcValue := AUpdate.CrcValue;
  FMD5Value := AUpdate.CrcValue;
  FRelativeFolder := AUpdate.RelativeFolder;
end;

function TUpdate.IntToUpgradeType(AValue: Integer): TUpgradeType;
begin
  case AValue of
    0:
      begin
        Result := utOrdinary;
      end;
    1:
      begin
        Result := utForce;
      end;
  end;
end;

function TUpdate.UpgradeTypeToInt(AUpgradeType: TUpgradeType): Integer;
begin
  case AUpgradeType of
    utOrdinary:
      begin
        Result := 0;
      end;
    utForce:
      begin
        Result := 1;
      end;
  end;
end;

end.
