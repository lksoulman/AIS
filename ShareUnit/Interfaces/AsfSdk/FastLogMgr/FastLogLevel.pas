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
  TLogLevelArray = array [TLogLevel] of string;

implementation

end.
