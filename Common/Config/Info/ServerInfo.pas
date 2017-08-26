unit ServerInfo;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-7-21
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  IniFiles,
  Json,
  AppContext;

type

  IServerInfo = Interface(IInterface)
    ['{2BE2468A-C419-4BCB-9905-4B8CF5509689}']
    // 初始化需要的资源
    procedure Initialize(AContext: IAppContext); safecall;
    // 释放不需要的资源
    procedure UnInitialize; safecall;
    // 保存数据
    procedure SaveCache; safecall;
    // 通过Ini对象加载
    procedure LoadByIniFile(AFile: TIniFile); safecall;
    // 通过Json对象加载
    procedure LoadByJsonObject(AObject: TJSONObject); safecall;
    // 下一个服务
    procedure NextServer; safecall;
    // 第一个服务
    procedure FirstServer; safecall;
    // 是不是结束
    function IsEOF: boolean; safecall;
    // 获取去服务的下表
    function GetServerIndex: Integer; safecall;
    // 获取服务Url
    function GetServerUrl: WideString; safecall;
    // 获取去服务的名称
    function GetServerName: WideString; safecall;
  end;

implementation

end.
