unit ExecutorTask;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-5-1
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Messages,
  SysUtils,
  Classes;

type

  IExecutorTask = interface(IInterface)
    ['{31F8B49C-CB4A-434C-A7EE-D03486782ADC}']
    // ������ɻص�
    procedure CallBack;
    // ���� AObject �ǵ��õ��߳�
    procedure Run(AObject: TObject);
  end;

implementation

end.
