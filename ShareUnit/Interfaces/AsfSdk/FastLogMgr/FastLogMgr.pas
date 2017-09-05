unit FastLogMgr;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-7-1
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  FastLogLevel;

type

  IFastLogMgr = Interface(IInterface)
    ['{7A0EBA9F-BD2C-4CB5-9090-1CC9D1229818}']
    // ��ʼ������
    procedure Initialize; safecall;
    // ж�ط���
    procedure UnInitialize; safecall;
    // дһ��
    procedure ForceWriteDisk; safecall;
    // ������־����
    procedure SetLogLevel(ALevel: TLogLevel); safecall;
    // ������־���
    procedure HQLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0); safecall;
    // ��ҳ��־���
    procedure WebLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0); safecall;
    // Ӧ��ϵͳ��־���
    procedure SysLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0); safecall;
    // ָ����־���
    procedure IndicatorLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0); safecall;
  end;

implementation

end.

