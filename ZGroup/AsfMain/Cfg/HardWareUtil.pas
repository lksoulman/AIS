unit HardWareUtil;

interface

uses
  Windows,
  Classes,
  SysUtils;

  // Get Mac Address
  function GetMacAddress: AnsiString;

  // Get Volume Serial Number
  function GetVolumeSerialNumber: AnsiString;

  // Get HardDisk Serial Number
  function GetHardDiskSerialNumber: AnsiString;

implementation

uses
  CrtExport;

  function GetMacAddress: AnsiString;
  var
    LHModule: Cardinal;
    LGUID1, LGUID2: TGUID;
    LUuidCreate : function(GUID: PGUID): Longint; stdcall;
  begin
    Result := '00:00:00:00:00';
    LHModule := LoadLibrary('rpcrt4.dll');
    if LHModule <> 0 then begin
      if Win32Platform <>VER_PLATFORM_WIN32_NT then begin
        @LUuidCreate := GetProcAddress(LHModule, 'UuidCreate')
      end else begin
        @LUuidCreate := GetProcAddress(LHModule, 'UuidCreateSequential');
      end;
      if Assigned(LUuidCreate) then begin
        if (LUuidCreate(@LGUID1) = 0)
          and (LUuidCreate(@LGUID2) = 0)
          and (LGUID1.D4[2] = LGUID2.D4[2])
          and (LGUID1.D4[3] = LGUID2.D4[3])
          and (LGUID1.D4[4] = LGUID2.D4[4])
          and (LGUID1.D4[5] = LGUID2.D4[5])
          and (LGUID1.D4[6] = LGUID2.D4[6])
          and (LGUID1.D4[7] = LGUID2.D4[7]) then
        begin
         Result :=
          IntToHex(LGUID1.D4[2], 2) + ':' +
          IntToHex(LGUID1.D4[3], 2) + ':' +
          IntToHex(LGUID1.D4[4], 2) + ':' +
          IntToHex(LGUID1.D4[5], 2) + ':' +
          IntToHex(LGUID1.D4[6], 2) + ':' +
          IntToHex(LGUID1.D4[7], 2);
        end;
      end;
      FreeLibrary(LHModule);
    end;
  end;

  function GetVolumeSerialNumber: AnsiString;
  var
    LPStr: PAnsiChar;
    LIndex, LLen: Integer;
    LVolumeSerialNumber, LMaxComponentLength, LFileSystemFlags: DWORD;
    LStrSysDriver: array [0..MAX_PATH-1] of AnsiChar;
    LSerialNumber: array [0..MAX_PATH-1] of AnsiChar;
  begin
    FillMemory(@LStrSysDriver[0], MAX_PATH, 0);
    FillMemory(@LSerialNumber[0], MAX_PATH, 0);

    GetSystemDirectoryA(@LStrSysDriver[0], MAX_PATH);
    for LIndex := 0 to MAX_PATH - 1 do begin
      if (LStrSysDriver[LIndex] = #0)
        or (LStrSysDriver[LIndex] = ':') then begin
        Break;
      end;
    end;

    if LIndex < MAX_PATH then begin
      LStrSysDriver[LIndex + 1] := #0;
    end;

    LLen:= StrLen(LStrSysDriver);
    if LLen < MAX_PATH - 1 then begin
      LStrSysDriver[LLen] := '\';
      LStrSysDriver[LLen + 1] := #0;
      LPStr := @LStrSysDriver[0];
      GetVolumeInformationA(LPStr, nil, 0, @LVolumeSerialNumber,
        LMaxComponentLength, LFileSystemFlags, nil, 0);
      Result := AnsiString(IntToHex(LVolumeSerialNumber , 4));
    end else begin
      Result := '';
    end;
  end;

  function GetHardDiskSerialNumber: AnsiString;
  type
    TDriverResult= record
      ControllerType: Integer;      //  0 - primary, 1 - secondary, 2 - Tertiary, 3 - Quaternary
      DriveMS: Integer;             //  0 - master, 1 - slave
      DriveModelNumber: String;
      DriveSerialNumber: String;
      DriveControllerRevisionNumber: String;
      ControllerBufferSizeOnDrive: Int64;
      DriveType: String;            //  fixed or removable or unknown
      DriveSizeBytes: Int64;
    end;

    TDriverResultDynArray = Array Of TDriverResult;
{$Align 1}
    TVersionInParams = record
      bVersion: Byte;                         // Binary driver version.
      bRevision: Byte;                        // Binary driver revision.
      bReserved: Byte;                        // Not used.
      bIDEDeviceMap: Byte;                    // Bit map of IDE devices.
      fCapabilities: Cardinal;                // Bit mask of driver capabilities.
      dwReserved: array [0..3] of Cardinal;   // For future use.
    end;
{$Align On}
    PVersionInParams = ^TVersionInParams;

    TVersionOutParams = record
      bVersion: Byte;                         // Binary driver version.
      bRevision: Byte;                        // Binary driver revision.
      bReserved: Byte;                        // Not used.
      bIDEDeviceMap: Byte;                    // Bit map of IDE devices.
      fCapabilities: Longword;                // Bit mask of driver capabilities.
      dwReserved: array [0..3] of Longword;   // For future use.
    end;
    PVersionOutParams = ^TVersionOutParams;

    // IDE registers
    TIdeRegs = record
      bFeaturesReg: Byte;         // Used for specifying SMART "commands".
      bSectorCountReg: Byte;      // IDE sector count register
      bSectorNumberReg: Byte;     // IDE sector number register
      bCylLowReg: Byte;           // IDE low order cylinder value
      bCylHighReg: Byte;          // IDE high order cylinder value
      bDriveHeadReg: Byte;        // IDE drive/head register
      bCommandReg: Byte;          // Actual IDE command.
      bReserved: Byte;            // reserved for future use.  Must be zero.
    end;
    PIdeRegs = ^TIdeRegs;

{$ALIGN 1}
    TSendCmdInParams = record
      cBufferSize: Longword;                    //  Buffer size in bytes
      irDriveRegs: TIdeRegs;                    //  Structure with drive register values.
      bDriveNumber: Byte;                       //  Physical drive number to send command to (0,1,2,3).
      bReserved: array[0..2] of Byte;           //  Reserved for future expansion.
      dwReserved: array [0..3] of Longword;     //  For future use.
      bBuffer: array [0..0] of Byte;            //  Input buffer.     //!TODO: this is array of single element
    end;
{$ALIGN on}
    PSendCmdInParams = ^TSendCmdInParams;

{$ALIGN 1}
   // Status returned from driver
    DRIVERSTATUS = record
      bDriverError: Byte;                   //  Error code from driver, or 0 if no error.
      bIDEStatus: Byte;                     //  Contents of IDE Error register. Only valid when bDriverError is SMART_IDE_ERROR.
      bReserved: array [0..1] of Byte;      //  Reserved for future expansion.
      dwReserved: array [0..1] of Longword; //  Reserved for future expansion.
    end;
{$ALIGN on}
    PDRIVERSTATUS = ^DRIVERSTATUS;

{$ALIGN 1}
    TSendCmdOutParams = record
      cBufferSize: Longword;//  Size of bBuffer in bytes
      DriverStatus: DRIVERSTATUS;//  Driver status structure.
      bBuffer: array [0..0] of Byte;//  Buffer of arbitrary length in which to store the data read from the                                                       // drive.
    end;
{$ALIGN on}
    PSendCmdOutParams = ^TSendCmdOutParams;

    TSrbIoControl = record
      HeaderLength: Cardinal;
      Signature: array [0..8-1] of Byte;
      Timeout: Cardinal;
      ControlCode: Cardinal;
      ReturnCode: Cardinal;
      Length: Cardinal;
    end;
    PSrbIoControl = ^TSrbIoControl;

  // The following struct defines the interesting part of the IDENTIFY
  // buffer:
{$ALIGN 1}
    TIdSector = record
      wGenConfig: Word;
      wNumCyls: Word;
      wReserved: Word;
      wNumHeads: Word;
      wBytesPerTrack: Word;
      wBytesPerSector: Word;
      wSectorsPerTrack: Word;
      wVendorUnique: array [0..3-1] of Word;
      sSerialNumber: array [0..20-1] of AnsiChar;
      wBufferType: Word;
      wBufferSize: Word;
      wECCSize: Word;
      sFirmwareRev: array [0..8-1] of AnsiChar;
      sModelNumber: array [0..40-1] of AnsiChar;
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
      ulCurrentSectorCapacity: Cardinal;
      wMultSectorStuff: Word;
      ulTotalAddressableSectors: Cardinal;
      wSingleWordDMA: Word;
      wMultiWordDMA: Word;
      bReserved: array [0..128-1] of Byte;
    end;
{$ALIGN on}
    PIdSector = ^TIdSector;

{$Z4} //size of each enumeration type should be equal 4
    TStoragePropertyID = (StorageDeviceProperty = 0,
                          StorageAdapterProperty
                          );
{$Z1}

{$Z4} //size of each enumeration type should be equal 4
    TStorageQueryType = (PropertyStandardQuery = 0,     // Retrieves the descriptor
                         PropertyExistsQuery,           // Used to test whether the descriptor is supported
                         PropertyMaskQuery,             // Used to retrieve a mask of writeable fields in the descriptor
                         PropertyQueryMaxDefined        // use to validate the value
                         );
{$Z1}
//
//{$ALIGN 1}
    TStoragePropertyQuery = record
      PropertyId: TStoragePropertyID;                 // ID of the property being retrieved
      QueryType: TStorageQueryType;                   // Flags indicating the type of query being performed
      AdditionalParameters: array [0..0] of UCHAR;    // Space for additional parameters if necessary
    end;
{$ALIGN on}
    PStoragePropertyQuery = ^TStoragePropertyQuery;

    TStorageBusType = (
      BusTypeUnknown = $00,
      BusTypeScsi,
      BusTypeAtapi,
      BusTypeAta,
      BusType1394,
      BusTypeSsa,
      BusTypeFibre,
      BusTypeUsb,
      BusTypeRAID,
      BusTypeiScsi,
      BusTypeSas,
      BusTypeSata,
      BusTypeSd,
      BusTypeMmc,
      BusTypeMax,
      BusTypeMaxReserved = $7F);

{$ALIGN 4}
    TStorageDeviceDescriptor = record
      // Sizeof(STORAGE_DEVICE_DESCRIPTOR)
      Version: Cardinal;
      // Total size of the descriptor, including the space for additional
      // data and id strings
      Size: Cardinal;
      // The SCSI-2 device type
      DeviceType: Byte;
      // The SCSI-2 device type modifier (if any) - this may be zero
      DeviceTypeModifier: Byte;
      // Flag indicating whether the device's media (if any) is removable.  This
      // field should be ignored for media-less devices
      RemovableMedia: Byte;
      // Flag indicating whether the device can support mulitple outstanding
      // commands.  The actual synchronization in this case is the responsibility
      // of the port driver.
      CommandQueueing: Byte;
      // Byte offset to the zero-terminated ascii string containing the device's
      // vendor id string.  For devices with no such ID this will be zero
      VendorIdOffset: Cardinal;
      // Byte offset to the zero-terminated ascii string containing the device's
      // product id string.  For devices with no such ID this will be zero
      ProductIdOffset: Cardinal;
      // Byte offset to the zero-terminated ascii string containing the device's
      // product revision string.  For devices with no such string this will be
      // zero
      ProductRevisionOffset: Cardinal;
      // Byte offset to the zero-terminated ascii string containing the device's
      // serial number.  For devices with no serial number this will be zero
      SerialNumberOffset: Cardinal;
      // Contains the bus type (as defined above) of the device.  It should be
      // used to interpret the raw device properties at the end of this structure
      // (if any)
      BusType: TStorageBusType;
      // The number of bytes of bus-specific data which have been appended to
      // this descriptor
      RawPropertiesLength: Cardinal;
      // Place holder for the first byte of the bus specific property data
      RawDeviceProperties: array [0..1-1] of Byte;
    end;
    PStorageDeviceDescriptor = ^TStorageDeviceDescriptor;
{$ALIGN on}

    TMediaType = (
      Unknown,                // Format is unknown
      F5_1Pt2_512,            // 5.25", 1.2MB,  512 bytes/sector
      F3_1Pt44_512,           // 3.5",  1.44MB, 512 bytes/sector
      F3_2Pt88_512,           // 3.5",  2.88MB, 512 bytes/sector
      F3_20Pt8_512,           // 3.5",  20.8MB, 512 bytes/sector
      F3_720_512,             // 3.5",  720KB,  512 bytes/sector
      F5_360_512,             // 5.25", 360KB,  512 bytes/sector
      F5_320_512,             // 5.25", 320KB,  512 bytes/sector
      F5_320_1024,            // 5.25", 320KB,  1024 bytes/sector
      F5_180_512,             // 5.25", 180KB,  512 bytes/sector
      F5_160_512,             // 5.25", 160KB,  512 bytes/sector
      RemovableMedia,         // Removable media other than floppy
      FixedMedia,             // Fixed hard disk media
      F3_120M_512,            // 3.5", 120M Floppy
      F3_640_512,             // 3.5" ,  640KB,  512 bytes/sector
      F5_640_512,             // 5.25",  640KB,  512 bytes/sector
      F5_720_512,             // 5.25",  720KB,  512 bytes/sector
      F3_1Pt2_512,            // 3.5" ,  1.2Mb,  512 bytes/sector
      F3_1Pt23_1024,          // 3.5" ,  1.23Mb, 1024 bytes/sector
      F5_1Pt23_1024,          // 5.25",  1.23MB, 1024 bytes/sector
      F3_128Mb_512,           // 3.5" MO 128Mb   512 bytes/sector
      F3_230Mb_512,           // 3.5" MO 230Mb   512 bytes/sector
      F8_256_128,             // 8",     256KB,  128 bytes/sector
      F3_200Mb_512,           // 3.5",   200M Floppy (HiFD)
      F3_240M_512,            // 3.5",   240Mb Floppy (HiFD)
      F3_32M_512              // 3.5",   32Mb Floppy
    );

    TDiskGeometry = record
      Cylinders: Int64; //LARGE_INTEGER
      MediaType: TMediaType;
      TracksPerCylinder: Cardinal;
      SectorsPerTrack: Cardinal;
      BytesPerSector: Cardinal;
    end;
    PDiskGeometry = ^TDiskGeometry;

    TDiskGeometryEx = record
      Geometry: TDiskGeometry;
      DiskSize: Int64; //LARGE_INTEGER
      Data: array [0..1-1] of Byte;
    end;
    PDiskGeometryEx = ^TDiskGeometryEx;

{$ALIGN 1}
    TIdentifyData = record
      GeneralConfiguration: Word;             // 00 00
      NumberOfCylinders: Word;                // 02  1
      Reserved1: Word;                        // 04  2
      NumberOfHeads: Word;                    // 06  3
      UnformattedBytesPerTrack: Word;         // 08  4
      UnformattedBytesPerSector: Word;        // 0A  5
      SectorsPerTrack: Word;                  // 0C  6
      VendorUnique1: array [0..3-1] of Word;                 // 0E  7-9
      SerialNumber: array [0..10-1] of Word;                 // 14  10-19
      BufferType: Word;                       // 28  20
      BufferSectorSize: Word;                 // 2A  21
      NumberOfEccBytes: Word;                 // 2C  22
      FirmwareRevision: array [0..4-1] of  Word;              // 2E  23-26
      ModelNumber: array [0..20-1] of  Word;                  // 36  27-46
      MaximumBlockTransfer: Byte;             // 5E  47
      VendorUnique2: Byte;                    // 5F
      DoubleWordIo: Word;                     // 60  48
      Capabilities: Word;                     // 62  49
      Reserved2: Word;                        // 64  50
      VendorUnique3: Byte;                    // 66  51
      PioCycleTimingMode: Byte;               // 67
      VendorUnique4: Byte;                    // 68  52
      DmaCycleTimingMode: Byte;               // 69
      // Delhpi has no bit fields. Fortunately, we don't need this
      // record memebers in our application. So, we can simplify declaration of the record.
      //    USHORT TranslationFieldsValid:1;        // 6A  53
      //    USHORT Reserved3:15;
      TranslationFieldsValid: Word;         // 6A  53 //Reserved3 is in the last 15 bits.

      NumberOfCurrentCylinders: Word;         // 6C  54
      NumberOfCurrentHeads: Word;             // 6E  55
      CurrentSectorsPerTrack: Word;           // 70  56
      CurrentSectorCapacity: Cardinal;            // 72  57-58
      CurrentMultiSectorSetting: Word;        //     59
      UserAddressableSectors: Cardinal;           //     60-61

      //USHORT SingleWordDMASupport : 8;        //     62
      //USHORT SingleWordDMAActive : 8;
      //USHORT MultiWordDMASupport : 8;         //     63
      //USHORT MultiWordDMAActive : 8;
      //USHORT AdvancedPIOModes : 8;            //     64
      //USHORT Reserved4 : 8;
      SingleWordDMASupport: Word;        //     62 //SingleWordDMAActive is in the second byte
      MultiWordDMASupport: Word;         //     63 //MultiWordDMAActive is in the second byte
      AdvancedPIOModes: Word;            //     64 //Reserved4 is in the second byte

      MinimumMWXferCycleTime: Word;           //     65
      RecommendedMWXferCycleTime: Word;       //     66
      MinimumPIOCycleTime: Word;              //     67
      MinimumPIOCycleTimeIORDY: Word;         //     68
      Reserved5: array [0..2-1] of  Word;                     //     69-70
      ReleaseTimeOverlapped: Word;            //     71
      ReleaseTimeServiceCommand: Word;        //     72
      MajorRevision: Word;                    //     73
      MinorRevision: Word;                    //     74
      Reserved6: array [0..50-1] of  Word;                    //     75-126
      SpecialFunctionsEnabled: Word;          //     127
      Reserved7: array [0..128-1] of  Word;                   //     128-255
    end;
{$ALIGN on}
    PIdentifyData = ^TIdentifyData;

    TRtIdeDInfo = record
      IDEExists: array [0..3] of Byte;
      DiskExists: array [0..7] of Byte;
      DisksRawInfo: array[0..8*256 - 1] of Word;
    end;
    PRtIdeDInfo = ^TRtIdeDInfo;


    TDiskData = Array [0..255 - 1] of DWORD;
    PDiskData = ^TDiskData;

  const
    MAX_IDE_DRIVES = 16;

  const
    // IOCTL commands
    DFP_GET_VERSION = $00074080;
    DFP_SEND_DRIVE_COMMAND = $0007c084;
    DFP_RECEIVE_DRIVE_DATA = $0007c088;

    FILE_DEVICE_SCSI = $0000001b;
    IOCTL_SCSI_MINIPORT_IDENTIFY = ((FILE_DEVICE_SCSI shl 16) + $0501);
    IOCTL_SCSI_MINIPORT = $0004D008;  //  see NTDDSCSI.H for definition

  const
    //  Valid values for the bCommandReg member of IDEREGS.
    IDE_ATAPI_IDENTIFY = $A1;   //  Returns ID sector for ATAPI.
    IDE_ATA_IDENTIFY = $EC;     //  Returns ID sector for ATA.
    IDENTIFY_BUFFER_SIZE = 512;
  var
    LIsSuccess: Boolean;
    LId, LAttempt: Integer;
    LcbBytesReturned: DWORD;
    LIP: Integer; //dv: index in array instead of original pointer
    LOSVersionInfo: OSVERSIONINFO;
    LDriverResults: TDriverResultDynArray;
    LHardDiskModelNumber: Array [0..1023] Of AnsiChar;
    LHardDiskSerialNumber: Array [0..1023] Of AnsiChar;

    // function to decode the serial numbers of IDE hard drives
	  // using the IOCTL_STORAGE_QUERY_PROPERTY command
    function FlipAndCodeBytes (APAnsiChar: PAnsiChar; APos: Integer; AFlip: Integer; ABuf: PAnsiChar): String;
    var
      i, j, k: Integer;
      p: Integer;
      c: AnsiChar;
      t: AnsiChar;
    begin
       j := 0;
       k := 0;

       ABuf [0] := Chr(0);
       if (APos <= 0) then begin
          Result := ABuf;
          exit;
       end;

       if (j = 0) then begin
          p := 0;

          // First try to gather all characters representing hex digits only.
          j := 1;
          k := 0;
          ABuf[k] := Chr(0);
          i := APos;
          while (j <> 0) and (APAnsiChar[i] <> Chr(0)) do begin
            c := tolower(APAnsiChar[i]);

            if (isspace(c)) then c := Chr(0);

            inc(p);
            ABuf[k] :=  AnsiChar(Chr(Ord(ABuf[k]) shl 4));

            if ((c >= '0') and (c <= '9'))
              then ABuf[k] := AnsiChar(Chr(Ord(ABuf[k]) or Byte(Ord(c) - Ord('0'))))
              else if ((c >= 'a') and (c <= 'f'))
                then ABuf[k] := AnsiChar(Chr(Ord(ABuf[k]) or Byte(Ord(c) - Ord('a') + 10)))
                else begin
                  j := 0;
                  break;
                end;

            if (p = 2) then begin
              if ((ABuf[k] <> Chr(0)) and (not isprint(ABuf[k]))) then begin
                 j := 0;
                 break;
              end;
              inc(k);
              p := 0;
              ABuf[k] := Chr(0);
            end;
            inc(i);
          end;
       end;

       if (j = 0) then begin
          // There are non-digit characters, gather them as is.
          j := 1;
          k := 0;
          i := APos;
          while ( (j <> 0) and (APAnsiChar[i] <> Chr(0)) ) do begin
            c := APAnsiChar[i];

            if ( not isprint(c)) then begin
              j := 0;
              break;
            end;

            ABuf[(k)] := c;
            inc(k);
            inc(i);
          end;
       end;

       if (j = 0) then begin
          // The characters are not there or are not printable.
          k := 0;
       end;

       ABuf[k] := Chr(0);

       if (AFlip <> 0) then begin
          // AFlip adjacent characters
          j := 0;
          while (j < k) do begin
            t := ABuf[j];
            ABuf[j] := ABuf[j + 1];
            ABuf[j + 1] := t;
            j := j + 2;
          end
       end;

       // Trim any beginning and end space
       i := -1;
       j := -1;
       k := 0;
       while (ABuf[k] <> Chr(0)) do begin
          if (not isspace(ABuf[k])) then begin
            if (i < 0) then i := k;
            j := k;
          end;
          inc(k);
       end;

       if ((i >= 0) and (j >= 0)) then begin
          k := i;
          while ( ( k <= j) and (ABuf[k] <> Chr(0)) ) do begin
             ABuf[k - i] := ABuf[k];
             inc(k);
          end;
          ABuf[k - i] := Chr(0);
       end;

       Result := ABuf;
    end;

    procedure CopyToBuffer(ADiskdata: TDiskData;
               AFirstIndex, ALastIndex: Integer;
		           ABuffer: PAnsiChar);
    var
       LIndex, LPosition: Integer;
    begin
      LPosition := 0;
      // each integer has two characters stored in it backwards
      for LIndex := AFirstIndex to ALastIndex do begin
        // get high byte for 1st character
        ABuffer[LPosition] := AnsiChar(Chr(ADiskdata[LIndex] div 256));
        Inc(LPosition);

        // get low byte for 2nd character
        ABuffer[LPosition] := AnsiChar(Chr(ADiskdata[LIndex] mod 256));
        Inc(LPosition);
      end;

      // end the string
      ABuffer[LPosition] := Chr(0);

      //  cut off the trailing blanks
      LIndex := LPosition - 1;
      while (LIndex >0) do begin
        if not IsSpace(AnsiChar(ABuffer[LIndex])) then begin
          break;
        end;
        ABuffer[LIndex] := Chr(0);
        dec(LIndex);
      end;
    end;

    function PrintIdeInfo(ADriverNo: Integer; ADiskdata: Tdiskdata): TDriverResult;
    var
      LSectors: Int64;
      LModelNumber: array [0..1024-1] of AnsiChar;
      LSerialNumber: array [0..1024-1] of AnsiChar;
      LRevisionNumber: array [0..1024-1] of AnsiChar;
    begin
      //  copy the hard drive serial number to the buffer
      CopyToBuffer(ADiskdata, 10, 19, @LSerialNumber);
      CopyToBuffer(ADiskdata, 27, 46, @LModelNumber);
      CopyToBuffer(ADiskdata, 23, 26, @LRevisionNumber);

      // serial number must be alphanumeric, (but there can be leading spaces on IBM drives)
      if ((Chr(0) = LHardDiskSerialNumber[0])
        and (Isalnum(LSerialNumber[0]) or IsAlnum(LSerialNumber[19])))
       then begin
        StrCopy(PAnsiChar(@LHardDiskModelNumber), PAnsiChar(@LModelNumber));
        StrCopy(PAnsiChar(@LHardDiskSerialNumber), PAnsiChar(@LSerialNumber));
      end;

      Result.ControllerType := ADriverNo div 2;
      Result.DriveMS := ADriverNo mod 2;
      Result.DriveModelNumber := LModelNumber;
      Result.DriveSerialNumber := LSerialNumber;
      Result.DriveControllerRevisionNumber := LRevisionNumber;
      Result.ControllerBufferSizeOnDrive := ADiskData[21] * 512;
      if ((ADiskData[0] and $0080) <> 0) then begin
        Result.DriveType := 'Removable'
      end else if ((ADiskData [0] and $0040) <> 0) then begin
        Result.DriveType := 'Fixed'
      end else begin
        Result.DriveType := 'Unknown';
      end;
      //  calculate size based on 28 bit or 48 bit addressing
      //  48 bit addressing is reflected by bit 10 of word 83

      if (0 <> (ADiskData[83] and $400)) then begin
        LSectors := ADiskData[103] * Int64(65536) * Int64(65536) * Int64(65536) +
              ADiskData[102] * Int64(65536) * Int64(65536) +
              ADiskData[101] * Int64(65536) +
              ADiskData[100];
      end else begin
        LSectors := ADiskData[61] * 65536 + ADiskData[60];
      end;

      //  there are 512 bytes in a sector
      Result.DriveSizeBytes := LSectors * 512;
    end;

    // GetIdentify
    // Function: Send an IDENTIFY command to the drive
    // bDriveNum = 0-3
    // bIDCmd = IDE_ATA_IDENTIFY or IDE_ATAPI_IDENTIFY
    function GetIdentify(AhDrive: THandle; APSendCmdInParams: PSendCmdInParams;
                     APSendCmdOutParams: PSendCmdOutParams; AbIDCmd: Byte; AbDriveNum: Byte;
                     AlpcbBytesReturned: PCardinal): Boolean;
    begin
      // Set up data structures for IDENTIFY command.
      APSendCmdInParams^.cBufferSize := IDENTIFY_BUFFER_SIZE;
      APSendCmdInParams^.irDriveRegs.bFeaturesReg := 0;
      APSendCmdInParams^.irDriveRegs.bSectorCountReg := 1;
      // APSendCmdInParams ^. irDriveRegs.bSectorNumberReg = 1;
      APSendCmdInParams^.irDriveRegs.bCylLowReg := 0;
      APSendCmdInParams^.irDriveRegs.bCylHighReg := 0;

      // Compute the drive number.
      APSendCmdInParams^.irDriveRegs.bDriveHeadReg := $A0 or ((AbDriveNum and 1) shl 4);

      // The command can either be IDE identify or ATAPI identify.
      APSendCmdInParams^.irDriveRegs.bCommandReg := AbIDCmd;
      APSendCmdInParams^.bDriveNumber := AbDriveNum;
      APSendCmdInParams^.cBufferSize := IDENTIFY_BUFFER_SIZE;

      Result := DeviceIoControl(AhDrive,
                  DFP_RECEIVE_DRIVE_DATA,
                  Pointer(APSendCmdInParams),
                  SizeOf(TSendCmdInParams) - 1,
                  Pointer(APSendCmdOutParams),
                  SizeOf(APSendCmdOutParams) + IDENTIFY_BUFFER_SIZE - 1,
                  AlpcbBytesReturned^,
                  nil
                  );
    end;

    function GetPhysicalDriverFromWin9X(var ADriveResults: TDriverResultDynArray): Boolean;
    const
      VxDFunctionIdesDInfo = 1;
    var
      LResult: Boolean;
      LStatus: LongBool;
      LhDriver: THandle;
      LDiskData: TDiskData;
      LBytesReturned: DWORD;
      LRtIdeDInfo: TRtIdeDInfo;
      LPRtIdeDInfo: PRtIdeDInfo;
      LIndexI, LIndexJ, LDriverCount: Integer;
    begin
      LDriverCount := 0;
      LBytesReturned := 0;
      SetLength(ADriveResults, 8);
      // set the thread priority high so that we get exclusive access to the disk
      LStatus := SetPriorityClass(GetCurrentProcess(), REALTIME_PRIORITY_CLASS);
      LPRtIdeDInfo := @LRtIdeDInfo;
      ZeroMemory(LPRtIdeDInfo, SizeOf(TRtIdeDInfo));
      LhDriver := CreateFile ('\\.\IDE21201.VXD',
                    0,
                    0,
                    nil,
                    0,
                    FILE_FLAG_DELETE_ON_CLOSE,
                    0);
      if LhDriver <> INVALID_HANDLE_VALUE then begin
        LResult := DeviceIoControl(LhDriver,
                     VxDFunctionIdesDInfo,
                     nil,
                     0,
                     LPRtIdeDInfo,
                     SizeOf(TRtIdeDInfo),
                     LBytesReturned,
                     nil);
        if LResult then begin
          for LIndexI := 0 to 7 do begin
            if ((LPRtIdeDInfo^.DiskExists[LIndexI]
              and LPRtIdeDInfo^.IDEExists[LIndexI div 2]) <> 0) then begin
              for LIndexJ := 0 to 255 do begin
                LDiskData[LIndexJ] := LPRtIdeDInfo^.DisksRawInfo[LIndexI * 256 + LIndexJ];
              end;
              ADriveResults[LDriverCount] := PrintIdeInfo(LIndexI, LDiskData);
              Inc(LDriverCount);
            end;
          end;
        end;
      end;
      // reset the thread priority back to normal
      // SetThreadPriority (GetCurrentThread(), THREAD_PRIORITY_NORMAL);
      SetPriorityClass (GetCurrentProcess(), NORMAL_PRIORITY_CLASS);
      SetLength(ADriveResults, LDriverCount);
      Result := LDriverCount > 0;
    end;

    function GetPhysicalDriverFromWinNTWithAdminRights(var ADriveResults: TDriverResultDynArray): Boolean;
    var
      LbIDCmd: Byte;   // IDE or ATAPI IDENTIFY cmd
      LResult: Boolean;
      LhDriver: THandle;
      LPIdSector: PWord;
      LDiskData: TDiskData;
      LDriveName: Array [0..255] Of Char;
      LSendCmdInParams: TSendCmdInParams;
      LVersionOutParams: TVersionOutParams;
      LIndex, LDriverNo, LDriverCount: Integer;
      LIdOutCmd: Array [0..SizeOf(TSendCmdInParams) + IDENTIFY_BUFFER_SIZE - 2] Of Byte;
    begin
      SetLength(ADriveResults, MAX_IDE_DRIVES - 1);
      for LDriverNo := 0 to MAX_IDE_DRIVES - 1 do begin
        StrCopy(LDriveName, PChar(Format('\\.\PhysicalDrive%d', [LDriverNo])));
        // Windows NT, Windows 2000, must have admin rights
        LhDriver := CreateFile(LDriveName,
                       GENERIC_READ or GENERIC_WRITE,
                       FILE_SHARE_READ or FILE_SHARE_WRITE,
                       nil,
                       OPEN_EXISTING,
                       0,
                       0);

        if LhDriver <> INVALID_HANDLE_VALUE then begin
          LcbBytesReturned := 0;

          FillMemory(@LVersionOutParams, SizeOf(LVersionOutParams), 0);
          // Get the version, etc of PhysicalDrive IOCTL
          LResult := DeviceIoControl(LhDriver,
                       DFP_GET_VERSION,
                       nil,
                       0,
                       @LVersionOutParams,
                       SizeOf(LVersionOutParams),
                       LcbBytesReturned,
                       nil);
          if not LResult then begin

          end;

          if LVersionOutParams.bIDEDeviceMap <= 0 then begin

          end else begin
            if (((LVersionOutParams.bIDEDeviceMap shr LDriverNo) and $10) <> 0) then begin
              LbIDCmd := IDE_ATAPI_IDENTIFY
            end else begin
              LbIDCmd := IDE_ATA_IDENTIFY;
            end;

            FillMemory(@LSendCmdInParams, SizeOf(LSendCmdInParams), 0);
            FillMemory(@LIdOutCmd[0], SizeOf(LIdOutCmd), 0);

            LResult := GetIdentify(LhDriver,
                          @LSendCmdInParams,
                          PSendCmdOutParams(@LIdOutCmd[0]),
                          BYTE(LbIDCmd),
                          BYTE(LDriverNo),
                          @LcbBytesReturned);
            if LResult then begin
              //-               DWORD diskdata [256];
              //=               USHORT *pIdSector = (USHORT *) ((PSENDCMDOUTPARAMS) IdOutCmd) -> bBuffer;
              LPIdSector := PWord(@PSendCmdOutParams(@LIdOutCmd[0])^.bBuffer[0]); //!TOCHECK
              //delphi has no arithmetic for pointers; so, emulate it using arrays
              for LIndex := 0 to 255 do begin
                LDiskData[LIndex] := PDiskData(LPIdSector)[LIndex];
              end;

              ADriveResults[LDriverCount] := PrintIdeInfo(LDriverNo, LDiskData);
              Inc(LDriverCount);
            end;
          end;
          CloseHandle(LhDriver);
        end;
      end;
      SetLength(ADriveResults, LDriverCount);
      Result := LDriverCount > 0;
    end;

    function GetPhysicalDriverFromWinNTWithZoreRights(var ADriveResults: TDriverResultDynArray): Boolean;
    var
      LSize: Int64;
      LResult: Boolean;
      LhDriver: THandle;
      LFixed: String;
      LDriverName: array [0..255] of Char;
      LcbBytesReturned: Cardinal;
      LPDiskGeometryEx: PDiskGeometryEx;
      LPStorageDeviceDescriptor: PStorageDeviceDescriptor;
      LBuffer: array [0..10000 - 1] of AnsiChar;
      LVendorId: array [0..10000 - 1] of AnsiChar;
      LModelNumber: array [0..10000 - 1] of AnsiChar;
      LSerialNumber: array [0..10000 - 1] of AnsiChar;
      LProductRevision: array [0..10000 - 1] of AnsiChar;
      LStoragePropertyQuery: TStoragePropertyQuery;
      LIndex, LDriverNo, LDriverCount, LFindDriverId: Integer;
    begin
      LDriverCount := 0;
      SetLength(ADriveResults, MAX_IDE_DRIVES - 1);
      for LDriverNo := 0 to MAX_IDE_DRIVES - 1 do begin
        LFindDriverId := -1;
        StrCopy(LDriverName, PChar(Format('\\.\PhysicalDrive%d', [LDriverNo])));
        LhDriver := CreateFile(LDriverName,
                      0,
                      FILE_SHARE_READ or FILE_SHARE_WRITE,
                      nil,
                      OPEN_EXISTING,
                      0,
                      0);
        if (LhDriver <> INVALID_HANDLE_VALUE) then begin
          LcbBytesReturned := 0;
          FillMemory(@LStoragePropertyQuery, SizeOf(LStoragePropertyQuery), 0);
          LStoragePropertyQuery.PropertyId := StorageDeviceProperty;
          LStoragePropertyQuery.QueryType := PropertyStandardQuery;
          FillMemory(@LBuffer, SizeOf(LBuffer), 0);
          LResult := DeviceIoControl(LhDriver,
                       IOCTL_STORAGE_QUERY_PROPERTY,
                       @LStoragePropertyQuery,
                       SizeOf(LStoragePropertyQuery),
				               @LBuffer,
                       SizeOf(LBuffer),
                       LcbBytesReturned,
                       nil);
          if LResult then begin
            LPStorageDeviceDescriptor := PStorageDeviceDescriptor(@LBuffer[0]);
            FlipAndCodeBytes(LBuffer, LPStorageDeviceDescriptor^.VendorIdOffset, 0, LVendorId);
            FlipAndCodeBytes(LBuffer, LPStorageDeviceDescriptor^.ProductIdOffset, 0, LModelNumber );
            FlipAndCodeBytes(LBuffer, LPStorageDeviceDescriptor^.ProductRevisionOffset, 0, LProductRevision);
            FlipAndCodeBytes(LBuffer, LPStorageDeviceDescriptor^.SerialNumberOffset, 1, LSerialNumber);

            if ( (Chr(0) = LHardDiskSerialNumber[0])
              and (Isalnum(LSerialNumber[0]) or IsAlnum(LSerialNumber[19]))) then begin
              StrCopy(LHardDiskModelNumber, LModelNumber);
              StrCopy(LHardDiskSerialNumber, LSerialNumber);
              ADriveResults[LDriverCount].ControllerType := 0; //unknown
              ADriveResults[LDriverCount].DriveMS := 0; //unknown
              ADriveResults[LDriverCount].DriveModelNumber := LHardDiskModelNumber;
              ADriveResults[LDriverCount].DriveSerialNumber := LHardDiskSerialNumber;
              ADriveResults[LDriverCount].DriveControllerRevisionNumber := ''; //unknown
              ADriveResults[LDriverCount].ControllerBufferSizeOnDrive := 0; //unknown
              ADriveResults[LDriverCount].DriveSizeBytes := 0; //unknown
              ADriveResults[LDriverCount].DriveType := 'Unknown';
              LFindDriverId := LDriverCount;
              Inc(LDriverCount);
            end;
            LResult := DeviceIoControl(LhDriver,
                       IOCTL_DISK_GET_DRIVE_GEOMETRY_EX,
                       nil,
                       0,
				               @LBuffer[0],
                       SizeOf(LBuffer),
                       LcbBytesReturned,
                       nil);
            if LResult then begin
              LPDiskGeometryEx := PDiskGeometryEx(@LBuffer[0]);
              if LPDiskGeometryEx^.Geometry.MediaType = FixedMedia then begin
                LFixed := 'Fixed';
              end else begin
                LFixed := 'removable';
              end;
              LSize := LPDiskGeometryEx^.DiskSize;
              if LFindDriverId <> -1 then begin
                ADriveResults[LFindDriverId].DriveSizeBytes := LSize;
                ADriveResults[LFindDriverId].DriveType := LFixed;
              end;
            end;
          end;
          CloseHandle(LhDriver);
        end;
      end;
      SetLength(ADriveResults, LDriverCount);
      Result := LDriverCount > 0;
    end;

    function GetPhysicalDriverFromWinNTWithUsingSmart(var ADriveResults: TDriverResultDynArray): Boolean;
    const
      ID_CMD = $EC; // Returns ID sector for ATA
    var
      LResult: Boolean;
      LhDriver: THandle;
      LPIdSector: PWord;
      LDiskData: TDiskData;
      LDriverName: array [0..255] of Char;
      LSendCmdInParams: PSendCmdInParams;
      LVersionOutParams: TVersionOutParams;
      LcbBytesReturned, LCmdSize, LBytesReturned: Cardinal;
      LIndex, LDriverNo, LDriverCount, LFindDriverId: Integer;
    begin
      LDriverCount := 0;
      SetLength(ADriveResults, MAX_IDE_DRIVES - 1);
      for LDriverNo := 0 to MAX_IDE_DRIVES - 1 do begin
        StrCopy(LDriverName, PChar(Format('\\.\PhysicalDrive%d', [LDriverNo])));
        LhDriver := CreateFile(LDriverName,
                      GENERIC_READ or GENERIC_WRITE,
                      FILE_SHARE_DELETE or FILE_SHARE_READ or FILE_SHARE_WRITE,
                      nil,
                      OPEN_EXISTING,
                      0,
                      0);

        if LhDriver <> INVALID_HANDLE_VALUE then begin
          LcbBytesReturned := 0;
          // Get the version, etc of PhysicalDrive IOCTL
          FillMemory(@LVersionOutParams, SizeOf(LVersionOutParams), 0);
          LResult := DeviceIoControl(LhDriver,
                       SMART_GET_VERSION,
                       nil,
                       0,
                       @LVersionOutParams,
                       SizeOf(LVersionOutParams),
                       LcbBytesReturned,
                       nil);
          if LResult then begin
            LCmdSize := SizeOf(TSendCmdInParams) + IDENTIFY_BUFFER_SIZE;
            GetMem(LSendCmdInParams, LCmdSize);
            try
              LBytesReturned := 0;
              LSendCmdInParams^.irDriveRegs.bCommandReg := ID_CMD;
              LResult := DeviceIoControl (LhDriver,
                           SMART_RCV_DRIVE_DATA,
                           LSendCmdInParams,
                           SizeOf(TSendCmdInParams),
                           LSendCmdInParams,
                           LCmdSize,
                           LBytesReturned,
                           nil);
              if LResult then begin
                LPIdSector := PWord(PIdentifyData(@PSendCmdOutParams(LSendCmdInParams)^.bBuffer[0]));
                for LIndex := 0 to 255 do begin
                  LDiskData[LIndex] := PDiskData(LPIdSector)[LIndex];
                end;

                ADriveResults[LDriverCount] := PrintIdeInfo(LDriverNo, LDiskData);
                Inc(LDriverCount);
              end;
            finally
              FreeMem(LSendCmdInParams);
            end;
          end;
          CloseHandle(LhDriver);
        end;
      end;
      SetLength(ADriveResults, LDriverCount);
      Result := LDriverCount > 0;
    end;

    function GetScsiDriverFromWinNT(var ADriveResults: TDriverResultDynArray): Boolean;
    const
      SENDIDLENGTH = SizeOf(TSendCmdOutParams) + IDENTIFY_BUFFER_SIZE;
    var
      LDummy: DWORD;
      LResult: Boolean;
      LhDriver: THandle;
      PIdSectorPtr: PWord;
      LDiskData: TDiskData;
      LPIdSector: PIdSector;
      LPSrbIoControl: PSrbIoControl;
      LDriverName: array [0..255] of Char;
      LPSendCmdInParams: PSendCmdInParams;
      LPSendCmdOutParams: PSendCmdOutParams;
      LController, LIndex, LDriverCount, LDriverNo: Integer;
      LBuffer: array [0..SizeOf(TSrbIoControl) + SENDIDLENGTH - 1] of AnsiChar;
    begin
      LDriverCount := 0;
      SetLength(ADriveResults, 15);
      for LController := 0 to 15 do begin
        //  Try to get a handle to PhysicalDrive IOCTL, report failure and exit if can't.
        StrCopy(LDriverName, PChar(Format('\\.\Scsi%d:', [LController])));
        //  Windows NT, Windows 2000, any rights should do
        LhDriver := CreateFile(LDriverName,
                               GENERIC_READ or GENERIC_WRITE,
                               FILE_SHARE_READ or FILE_SHARE_WRITE,
                               nil,
                               OPEN_EXISTING,
                               0,
                               0);
        if LhDriver <> INVALID_HANDLE_VALUE then begin
          for LDriverNo := 0 to 1 do begin
            //-char buffer [sizeof (SRB_IO_CONTROL) + SENDIDLENGTH];
            LPSrbIoControl := PSrbIoControl(@LBuffer[0]);
            LPSendCmdInParams := PSendCmdInParams(LBuffer + SizeOf(TSrbIoControl));
            //-DWORD dummy;

            FillMemory(@LBuffer[0], SizeOf(LBuffer), 0);
            LPSrbIoControl^.HeaderLength := SizeOf(TSrbIoControl);
            LPSrbIoControl^.Timeout := 10000;
            LPSrbIoControl^.Length := SENDIDLENGTH;
            LPSrbIoControl^.ControlCode := IOCTL_SCSI_MINIPORT_IDENTIFY;
            StrLCopy(PChar(@LPSrbIoControl^.Signature), 'SCSIDISK', 8);

            LPSendCmdInParams^.irDriveRegs.bCommandReg := IDE_ATA_IDENTIFY;
            LPSendCmdInParams^.bDriveNumber := LDriverNo;

            LResult := DeviceIoControl(LhDriver,
                         IOCTL_SCSI_MINIPORT,
                         @LBuffer[0],
                         SizeOf(TSrbIoControl) + SENDIDLENGTH - 1,
                         @LBuffer[0],
                         SizeOf(TSrbIoControl) + SENDIDLENGTH,
                         LDummy,
                         nil);
            if LResult then begin
              LPSendCmdOutParams := PSENDCMDOUTPARAMS(LBuffer + SizeOf(TSrbIoControl)); //!TOCHECK
              LPIdSector := PIdSector(@LPSendCmdOutParams^.bBuffer[0]);
              if (LPIdSector^.sModelNumber[0] <> Chr(0) ) then begin
                //-DWORD diskdata [256];
                //-ijk := 0;
                pIdSectorPtr := PWord(LPIdSector);
                for LIndex := 0 to 255 do begin
                  LDiskData[LIndex] := PDiskData(LPIdSector)[LIndex];
                end;
                ADriveResults[LDriverCount] := PrintIdeInfo(LController * 2 + LDriverNo, LDiskData);
                Inc(LDriverCount);
              end;
            end;
          end;
          CloseHandle(LhDriver);
        end;
      end;
      SetLength(ADriveResults, LDriverCount);
      Result := LDriverCount > 0;
    end;


  begin
    LId := 0;
    FillMemory(@LHardDiskSerialNumber[0], SizeOf(LHardDiskSerialNumber), 0);
    FillMemory(@LOSVersionInfo, SizeOf(LOSVersionInfo), 0);
    LOSVersionInfo.dwOSVersionInfoSize := SizeOf(OSVERSIONINFO);
    GetVersionEx(LOSVersionInfo);
    if LOSVersionInfo.dwPlatformId = VER_PLATFORM_WIN32_NT then begin
      // this works under WinNT4 or Win2K if you have admin rights
      // Trying to read the drive IDs using physical access with admin rights
      LIsSuccess := GetPhysicalDriverFromWinNTWithAdminRights(LDriverResults);
      if not LIsSuccess then begin
        LIsSuccess := GetScsiDriverFromWinNT(LDriverResults);
        if not LIsSuccess then begin
          LIsSuccess := GetPhysicalDriverFromWinNTWithZoreRights(LDriverResults);
          if LIsSuccess then begin
             LIsSuccess := GetPhysicalDriverFromWinNTWithUsingSmart(LDriverResults);
          end;
        end;
      end;
    end else begin
      //  this works under Win9X and calls a VXD
      LAttempt := 0;
      LIsSuccess := False;
      while (LAttempt < 10)
        and (not LIsSuccess)
        and (Chr(0) = LHardDiskSerialNumber[0]) do begin
        Inc(LAttempt);
        LIsSuccess := GetPhysicalDriverFromWin9X(LDriverResults);
      end;
    end;
    if (Ord(LHardDiskSerialNumber[0]) > 0) then begin
      LIP := 0;
      //  ignore first 5 characters from western digital hard drives if
         //  the first four characters are WD-W
      if (0 = StrLComp(LHardDiskSerialNumber, 'WD-W', 4)) then begin
        Inc(LIP, 5);
      end;

      while ((LHardDiskSerialNumber[LIP] <> Chr(0))
        and (LIP < 1024))  do begin
        if ('-' = LHardDiskSerialNumber[LIP]) then begin
          Inc(LIP);
          Continue;
        end;
        LId := LId * 10;
        case LHardDiskSerialNumber[LIP] of
          '0': LId := LId + 0;
          '1': LId := LId + 1;
          '2': LId := LId + 2;
          '3': LId := LId + 3;
          '4': LId := LId + 4;
          '5': LId := LId + 5;
          '6': LId := LId + 6;
          '7': LId := LId + 7;
          '8': LId := LId + 8;
          '9': LId := LId + 9;
          'a', 'A': LId := LId + 10;
          'b', 'B': LId := LId + 11;
          'c', 'C': LId := LId + 12;
          'd', 'D': LId := LId + 13;
          'e', 'E': LId := LId + 14;
          'f', 'F': LId := LId + 15;
          'g', 'G': LId := LId + 16;
          'h', 'H': LId := LId + 17;
          'i', 'I': LId := LId + 18;
          'j', 'J': LId := LId + 19;
          'k', 'K': LId := LId + 20;
          'l', 'L': LId := LId + 21;
          'm', 'M': LId := LId + 22;
          'n', 'N': LId := LId + 23;
          'o', 'O': LId := LId + 24;
          'p', 'P': LId := LId + 25;
          'q', 'Q': LId := LId + 26;
          'r', 'R': LId := LId + 27;
          's', 'S': LId := LId + 28;
          't', 'T': LId := LId + 29;
          'u', 'U': LId := LId + 30;
          'v', 'V': LId := LId + 31;
          'w', 'W': LId := LId + 32;
          'x', 'X': LId := LId + 33;
          'y', 'Y': LId := LId + 34;
          'z', 'Z': LId := LId + 35;
        end;
        Inc(LIP);
      end;
    end;
    LId := LId mod 100000000;
    if (nil <> StrPos(LHardDiskModelNumber, 'IBM-')) then begin
      LId := LId + 300000000;
    end else if ( (nil <> StrPos(LHardDiskModelNumber, 'MAXTOR')) or
            (nil <> StrPos (LHardDiskModelNumber, 'Maxtor')) ) then begin
      LId := LId + 400000000;
    end else if (nil <> StrPos(LHardDiskModelNumber, 'WDC ')) then begin
      LId := LId + 500000000;
    end else begin
      LId := LId + 600000000;
    end;
    Result := Trim(LHardDiskSerialNumber);
  end;

end.
