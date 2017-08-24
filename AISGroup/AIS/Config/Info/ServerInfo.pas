unit ServerInfo;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-7-21
// Comments��
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
    // ��ʼ����Ҫ����Դ
    procedure Initialize(AContext: IAppContext); safecall;
    // �ͷŲ���Ҫ����Դ
    procedure UnInitialize; safecall;
    // ��������
    procedure SaveCache; safecall;
    // ͨ��Ini�������
    procedure LoadByIniFile(AFile: TIniFile); safecall;
    // ͨ��Json�������
    procedure LoadByJsonObject(AObject: TJSONObject); safecall;
    // ��һ������
    procedure NextServer; safecall;
    // ��һ������
    procedure FirstServer; safecall;
    // �ǲ��ǽ���
    function IsEOF: boolean; safecall;
    // ��ȡȥ������±�
    function GetServerIndex: Integer; safecall;
    // ��ȡ����Url
    function GetServerUrl: WideString; safecall;
    // ��ȡȥ���������
    function GetServerName: WideString; safecall;
  end;

implementation

end.
