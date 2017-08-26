unit SyscfgInfo;

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
  FastLogLevel,
  LanguageType;

type

  ISyscfgInfo = Interface(IInterface)
    ['{694C57FE-D4B2-416B-B33C-16CD955B4113}']
    // ��ʼ����Ҫ����Դ
    procedure Initialize(AContext: IInterface); safecall;
    // �ͷŲ���Ҫ����Դ
    procedure UnInitialize; safecall;
    // ͨ��Ini�������
    procedure LoadByIniFile(AFile: TIniFile); safecall;
    // ��������
    procedure SaveCache; safecall;
    // ���ػ���
    procedure LoadCache; safecall;
    // �����������
    procedure SetFontRatio(AFontRatio: WideString); safecall;
    // ��ȡ�������
    function GetFontRatio: WideString; safecall;
    // ����Ƥ����ʽ
    procedure SetSkinStyle(ASkinStyle: WideString); safecall;
    // ��ȡƤ����ʽ
    function GetSkinStyle: WideString; safecall;
    // ������־����
    procedure SetLogLevel(ALogLevel: TLogLevel); safecall;
    // ��ȡ��־����
    function GetLogLevel: TLogLevel; safecall;
    // ������������
    procedure SetLanguageType(ALanguageType: TLanguageType); safecall;
    // ��ȡ��������
    function GetLanguageType: TLanguageType; safecall;
  end;

implementation

end.
