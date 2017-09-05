unit ExecutorService;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-5-1
// Comments��    {Doug Lea thread}
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  ExecutorTask;

type

  IExecutorService = interface(IInterface)
    ['{31F8B49C-CB4A-434C-A7EE-D03486782ADC}']
    // ����
    procedure Start; safecall;
    // �ر�
    procedure ShutDown; safecall;
    // �ǲ����Ѿ�����
    function IsTerminated: boolean; safecall;
    // �ύ����
    function SubmitTask(ATask: IExecutorTask): Boolean; safecall;
  end;

implementation

end.