unit ExecutorPool;

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
  Classes,
  SysUtils,
  ExecutorService;

type

  IExecutorPool = Interface(IExecutorService)
    ['{8629F89D-4A93-4857-9746-043A1FA3D61D}']
    // ���ó����߳������С�̸߳���
    procedure SetPoolThread(AMaxPoolSize, AMinPoolSize: Integer); safecall;
  end;

implementation

end.
