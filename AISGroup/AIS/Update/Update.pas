unit Update;

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
  SysUtils;

type

  TUpgradeType = (utOrdinary,     // ��ͨ��������
                  utForce         // ǿ����������
                  );

  TUpdate = class
  private
    // �ļ�����
    FName: string;
    // �ļ���С
    FSize: Int64;
    // �ļ���У��ֵ������ļ������ǲ�����ȫ
    FCrcValue: string;
    // �ļ���MD5ֵ�����ڼ��汾����
    FMD5Value: string;
    // �ļ������·�� (�����BinĿ¼��·��)
    FRelativeFolder: string;
    // ����ʱ��
    FGenerateTime: TDateTime;
    // �ļ���������
    FUpgradeType: TUpgradeType;
  protected
  public
    // ���췽��
    constructor Create;
    // ��������
    destructor Destroy; override;
    // ��������
    procedure ResetValue;
    // ��ֵ����
    procedure Assign(AUpdate: TUpdate);
    // Int ת UpdateType
    function IntToUpgradeType(AValue: Integer): TUpgradeType;
    // UpdateType ת Int
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
