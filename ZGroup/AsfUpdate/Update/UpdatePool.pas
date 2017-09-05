unit UpdatePool;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-6-10
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface
uses
  Windows,
  Classes,
  SysUtils,
  Update,
  CommonLock,
  Generics.Collections;

type

  // ��Ϊ�����
  TUpdatePool = class
  private
    // �߳���
    FLock: TCSLock;
    // ���Ӵ�С
    FPoolSize: Integer;
    // ��Ϊ�������
    FUpdateQueue: TQueue<TUpdate>;
  protected
    // ��պ��ͷŶ����ж���
    procedure DoClearQueue;
  public
    // ���췽��
    constructor Create;
    // ��������
    destructor Destroy; override;
    // ����һ����Ϊ����
    function Allocate: TUpdate;
    // ����һ����Ϊ����
    procedure DeAllocate(AUpdate: TUpdate);
  end;

implementation

{ TUpdatePool }

constructor TUpdatePool.Create;
begin
  inherited;
  FPoolSize := 10;
  FLock := TCSLock.Create;
  FUpdateQueue := TQueue<TUpdate>.Create;
end;

destructor TUpdatePool.Destroy;
begin
  DoClearQueue;
  FUpdateQueue.Free;
  FLock.Free;
  inherited;
end;

procedure TUpdatePool.DoClearQueue;
var
  LUpdate: TUpdate;
begin
  while self.FUpdateQueue.Count > 0 do begin
    LUpdate := FUpdateQueue.Dequeue;
    if LUpdate <> nil then begin
      LUpdate.Free;
    end;
  end;
end;

function TUpdatePool.Allocate: TUpdate;
begin
  FLock.Lock;
  try
    if FUpdateQueue.Count > 0 then begin
      Result := FUpdateQueue.Dequeue;
    end else begin
      Result := TUpdate.Create;
    end;
  finally
    FLock.UnLock;
  end;
end;

procedure TUpdatePool.DeAllocate(AUpdate: TUpdate);
begin
  FLock.Lock;
  try
    if AUpdate = nil then Exit;
    if FUpdateQueue.Count < self.FPoolSize then begin
      FUpdateQueue.Enqueue(AUpdate);
    end else begin
      AUpdate.Free;
    end;
  finally
    FLock.UnLock;
  end;
end;

end.
