unit PlugInConst;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º PlugIn Const
// Author£º      lksoulman
// Date£º        2017-8-30
// Comments£º    
//
////////////////////////////////////////////////////////////////////////////////

interface

//type
//
//  // PlugIn Info
//  TPlugInInfo = packed record
//    FId: Integer;
//    FName: string;
//  end;
//
//  // PlugIn Info Pointer
//  PPlugInInfo = ^TPlugInInfo;
//
//  // PlugIn Info Dynamic Array
//  TPPlugInInfoDynArray = Array Of PPlugInInfo;
//
//  // Libary Info
//  TLibaryInfo = packed record
//    FId: Integer;
//    FName: string;
//    FPlugInInfoCount: Integer;
//    FPlugInInfos: TPPlugInInfoDynArray;
//
//    procedure AddPlugInInfo(APPlugInInfo: PPlugInInfo);
//  end;
//
//  // Libary Info Pointer
//  PLibaryInfo = ^TLibaryInfo;
//
//  // Libary Info Dynamic Array
//  TPLibaryInfoDynArray = Array Of PLibaryInfo;



const
//
//  LIBARYINFOS: Array [0..10] Of TLibaryInfo = (
//    (FId: 1000000; FName: 'AsfMain.exe'; FPlugInInfos:()),
//    (), );

// Exe
  LIB_ASFMAIN                     = 'AsfMain.exe';      // Application
  LIB_ID_ASFMAIN                  = 1000000;            // Application ID
  LIB_PLUGIN_ID_LOGIN             = 1000001;

  LIB_ASFSERVICE                  = 'AsfService.dll';
  LIB_ID_ASFSERVICE               = 2000000;
  LIB_PLUGIN_ID_BASICSERVICE      = 2000001;
  LIB_PLUGIN_ID_ASSETSERVICE      = 2000002;

  LIB_ASFTOOL                     = 'AsfTool.dll';
  LIB_ID_ASFTOOL                  = 3000000;
  LIB_PLUGIN_ID_SERVICEEXPLORER   = 3000001;
  LIB_PLUGIN_ID_UPDATEEXPLORER    = 3000002;

  LIB_ASFAUTH                     = 'AsfAuth.dll';      // dynamic libary Name
  LIB_ID_ASFAUTH                  = 4000000;            // dynamic libary ID
  PLUGIN_ID_PROAUTH               = 4000001;            // PlugIn ID
  PLUGIN_ID_HQAUTH                = 4000002;            // PlugIn ID

  LIB_ASFCACHE                    = 'AsfCache.dll';     // dynamic libary Name
  LIB_ID_ASFCACHE                 = 5000000;            // dynamic libary ID
  PLUGIN_ID_BASECACHE             = 5000001;            // PlugIn ID
  PLUGIN_ID_USERCACHE             = 5000002;            // PlugIn ID
  PLUGIN_ID_USERASSETCACHE        = 5000003;            // PlugIn ID

  LIB_ASFMEM                      = 'AsfMem.dll';       // dynamic libary Name
  LIB_ID_ASFMEM                   = 6000000;            // dynamic libary ID
  PLUGIN_ID_SECUMAIN              = 6000001;
  PLUGIN_ID_KEYFAIRYMGR           = 6000002;

  LIB_ASFAUI                      = 'AsfAUI.dll';       //
  LIB_ID_ASFAUI                   = 7000000;            //
  PLUGIN_ID_MAINFRAMEUI           = 7000001;

// dll
  DYN_LIB_ASFHQCORE             = 'AsfHqCore.dll';    // dynamic libary Name
  DYN_LIB_ID_ASFHQCORE            = 5000000;            // dynamic libary ID
    PLUGIN_ID_HQCOREMGR           = 5000001;            // PlugIn ID

// dll
  DYN_LIB_ASFMSG                = 'AsfMsg.dll';       // dynamic libary Name
  DYN_LIB_ID_ASFMSG               = 6000000;            // dynamic libary ID
    PLUGIN_ID_MSGSERVICE          = 6000001;            // PlugIn ID

// dll

//    PLUGIN_ID_

// dll
  DYN_LIB_ASFLANGUAGE           = 'AsfLanguage.dll';  // dynamic libary Name
  DYN_LIB_ID_ASFLANGUAGE          = 8000000;            // dynamic libary ID



//  DYN_LIB_ASFSERVICE            = 'AsfService.dll';   // dynamic libary Name
//  DYN_LIB_ID_ASFSERVICE           = 10000000;           // dynamic libary ID
//    PLUGIN_ID_CLOUDSERVICE        = 10000001;           //


implementation

//{ TLibaryInfo }
//
//procedure TLibaryInfo.AddPlugInInfo(APPlugInInfo: PPlugInInfo);
//begin
//  if APPlugInInfo = nil then Exit;
//
//  FPlugInInfoCount := Length(FPlugInInfos) + 1;
//  SetLength(FPlugInInfos, FPlugInInfoCount);
//  FPlugInInfos[FPlugInInfoCount - 1] := APPlugInInfo;
//end;

end.
