unit ExecutorThreadHttp;

interface

uses
  HttpExecutor,
  ExecutorThread;

type

  //
  TExecutorThreadHttp = class(TExecutorThread)
  private
    FHttpExecutor: IHttpExecutor;
  protected
  public

    property HttpExecutor: IHttpExecutor read FHttpExecutor write FHttpExecutor;
  end;

implementation

end.
