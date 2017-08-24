unit FastLogLevel;

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
  SysUtils;

type

  // ��־����
  TLogLevel = (llDEBUG,               // Debug �����Ϣ
               llINFO,                // ��Ϣ��ʾ
               llWARN,                // ����
               llERROR,               // ����
               llFATAL,               // ����
               llSLOW                 // ��
               );

  // ��־��������
  TArrayLogLevel = array [TLogLevel] of string;

  // ������־����
  procedure AppSetLogLevel(ALevel: TLogLevel);
  // ������־���
  procedure FastHQLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0);
  // ��ҳ��־���
  procedure FastWebLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0);
  // Ӧ��ϵͳ��־���
  procedure FastAppLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0);
  // ָ����־���
  procedure FastIndicatorLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0);

implementation

uses
  FastLogMgr,
  FastLogMgrImpl;

procedure AppSetLogLevel(ALevel: TLogLevel);
begin
  if G_FastLogMgr = nil then Exit;

  G_FastLogMgr.SetLogLevel(ALevel);
end;

procedure FastHQLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0);
begin
  if G_FastLogMgr = nil then Exit;

  G_FastLogMgr.HQLog(ALevel, ALog, AUseTime);
end;

procedure FastWebLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0);
begin
  if G_FastLogMgr = nil then Exit;

  G_FastLogMgr.WebLog(ALevel, ALog, AUseTime);
end;

procedure FastAppLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0);
begin
  if G_FastLogMgr = nil then Exit;

  G_FastLogMgr.AppLog(ALevel, ALog, AUseTime);
end;

procedure FastIndicatorLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0);
begin
  if G_FastLogMgr = nil then Exit;

  G_FastLogMgr.IndicatorLog(ALevel, ALog, AUseTime);
end;

end.
