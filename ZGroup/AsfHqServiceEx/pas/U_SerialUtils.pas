unit U_SerialUtils;

interface

uses
  Windows, Classes, SysUtils;


type
  TIDERegs = packed record
    bFeaturesReg: BYTE;
    bSectorCountReg: BYTE;
    bSectorNumberReg: BYTE;
    bCylLowReg: BYTE;
    bCylHighReg: BYTE;
    bDriveHeadReg: BYTE;
    bCommandReg: BYTE;
    bReserved: BYTE;
  end;

  TSendCmdInParams = packed record
    cBufferSize: DWORD;
    irDriveRegs: TIDERegs;
    bDriveNumber: BYTE;
    bReserved: array[0..2] of Byte;
    dwReserved: array[0..3] of DWORD;
    bBuffer: array[0..0] of Byte;
  end;

  TIdSector = packed record
    wGenConfig: Word;
    wNumCyls: Word;
    wReserved: Word;
    wNumHeads: Word;
    wBytesPerTrack: Word;
    wBytesPerSector: Word;
    wSectorsPerTrack: Word;
    wVendorUnique: array[0..2] of Word;
    sSerialNumber: array[0..19] of AnsiChar;
    wBufferType: Word;
    wBufferSize: Word;
    wECCSize: Word;
    sFirmwareRev: array[0..7] of AnsiChar;
    sModelNumber: array[0..39] of AnsiChar;
    wMoreVendorUnique: Word;
    wDoubleWordIO: Word;
    wCapabilities: Word;
    wReserved1: Word;
    wPIOTiming: Word;
    wDMATiming: Word;
    wBS: Word;
    wNumCurrentCyls: Word;
    wNumCurrentHeads: Word;
    wNumCurrentSectorsPerTrack: Word;
    ulCurrentSectorCapacity: DWORD;
    wMultSectorStuff: Word;
    ulTotalAddressableSectors: DWORD;
    wSingleWordDMA: Word;
    wMultiWordDMA: Word;
    bReserved: array[0..127] of BYTE;
  end;

  PIdSector = ^TIdSector;
  TDriverStatus = packed record
    bDriverError: Byte;
    bIDEStatus: Byte;
    bReserved: array[0..1] of Byte;
    dwReserved: array[0..1] of DWORD;
  end;

  TSendCmdOutParams = packed record
    cBufferSize: DWORD;
    DriverStatus: TDriverStatus;
    bBuffer: array[0..0] of BYTE;
  end;

//获取硬盘的出厂系列号；
function GetIdeSerialNumber: AnsiString;

//获取系统盘卷标序列号，每次格式化均不相同
function GetSysDriveSerialNum: DWORD;

implementation


function GetIdeSerialNumber: AnsiString; //获取硬盘的出厂系列号；
  const
    IDENTIFY_BUFFER_SIZE = 512;
  var
    hDevice: Thandle;
    cbBytesReturned: DWORD;
    SCIP: TSendCmdInParams;
    aIdOutCmd: array[0..(SizeOf(TSendCmdOutParams) + IDENTIFY_BUFFER_SIZE-1)-1] of Byte;
    IdOutCmd: TSendCmdOutParams absolute aIdOutCmd;
  procedure ChangeByteOrder(var Data; Size: Integer);
  var
    ptr: PAnsiChar;
    i: Integer;
    c: AnsiChar;
  begin
    ptr := @Data;
    for I := 0 to (Size shr 1) - 1 do
    begin
      c := ptr^;
      ptr^ := (ptr + 1)^;
      (ptr + 1)^ := c;
      Inc(ptr, 2);
    end;
  end;
begin
  Result := '';
  if SysUtils.Win32Platform = VER_PLATFORM_WIN32_NT then
  begin // Windows NT, Windows 2000
    hDevice := CreateFile('\\.\PhysicalDrive0', GENERIC_READ or GENERIC_WRITE, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0);
  end
  else // Version Windows 95 OSR2, Windows 98
    hDevice := CreateFile('\\.\SMARTVSD', 0, 0, nil, CREATE_NEW, 0, 0);
    if hDevice = INVALID_HANDLE_VALUE then
      Exit;
  try
    FillChar(SCIP, SizeOf(TSendCmdInParams) - 1, #0);
    FillChar(aIdOutCmd, SizeOf(aIdOutCmd), #0);
    cbBytesReturned := 0;
    with SCIP do
    begin
      cBufferSize := IDENTIFY_BUFFER_SIZE;
      with irDriveRegs do
      begin
        bSectorCountReg := 1;
        bSectorNumberReg := 1;
        bDriveHeadReg := $A0;
        bCommandReg := $EC;
      end;
      end;
    if not DeviceIoControl(hDevice, $0007C088, @SCIP, SizeOf(TSendCmdInParams) - 1, @aIdOutCmd, SizeOf(aIdOutCmd), cbBytesReturned, nil) then
    Exit;
  finally
    CloseHandle(hDevice);
  end;
  
  with PIdSector(@IdOutCmd.bBuffer)^ do
  begin
    ChangeByteOrder(sSerialNumber, SizeOf(sSerialNumber));
    (PAnsiChar(@sSerialNumber) + SizeOf(sSerialNumber))^:= #0;
    Result := PAnsiChar(@sSerialNumber);
  end;
end;

function GetSysDriveSerialNum: DWORD;
var
  dwSerialNum, dwMaxCompLen, dwFileSysFlag:DWORD;
  strSysDrive: string;
  szDirBuff: array[0..MAX_PATH] of Char;
begin
  GetWindowsDirectory(szDirBuff, MAX_PATH);

  strSysDrive := ExtractFileDrive(szDirBuff) + '\';
  dwMaxCompLen := 0;
  dwFileSysFlag := 0;
  dwSerialNum := 0;
  GetVolumeInformation(Pchar(strSysDrive), nil,0, @dwSerialNum, dwMaxCompLen, dwFileSysFlag, nil, 0);
  Result := dwSerialNum;
end;
  
end.
