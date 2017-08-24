unit CommonLock;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-7-10
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows;

type

  TCSLock = class
  protected
    m_dBegin: DWORD;                           // 进入临界区时间
    m_LockName: String;                        // 临界区名称
    m_CriticalSection: TRTLCriticalSection;    // 临界区资源
  public
    // 构造函数
    constructor Create;
    // 析构函数
    destructor Destroy; override;
    // 设置临界区名称
    procedure SetLockName(m_sLockName: String);
    // 加锁临界区资源
    procedure Lock;
    // 解锁临界区资源
    procedure UnLock;
  end;

implementation

constructor TCSLock.Create;
begin
  inherited Create;
  InitializeCriticalSection(m_CriticalSection);
end;

destructor TCSLock.Destroy;
begin
  DeleteCriticalSection(m_CriticalSection);
  inherited Destroy;
end;

procedure TCSLock.SetLockName(m_sLockName: String);
begin
  m_LockName := m_sLockName;
end;

procedure TCSLock.Lock;
//var
//  tmpTemp: DWORD;
begin
  m_dBegin := GetTickCount;
  EnterCriticalSection(m_CriticalSection);
//  tmpTemp := GetTickCount - m_dBegin;
end;

procedure TCSLock.UnLock;
//var
//  tmpTemp: DWORD;
begin
  LeaveCriticalSection(m_CriticalSection);
//  tmpTemp := GetTickCount;
end;

end.
