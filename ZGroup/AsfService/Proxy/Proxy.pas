unit Proxy;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Proxy Type
// Author£º      lksoulman
// Date£º        2017-9-12
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

type

  // Proxy Type
  TProxyType = (ptHttp,               // Http Proxy
                ptSocket4,            // Socket4 Proxy
                ptSocket5             // Socket5 Proxy
                );

  // Proxy Info Pointer
  PProxy = ^TProxy;
  // Proxy Info
  TProxy = packed record
    FType: TProxyType;                // Proxy Type
    FIP: string;                      // IP
    FPort: Word;                      // Port
    FUserName: string;                // UserName
    FPassword: string;                // Password
    FIsUseNTLM: Boolean;              // Is Use NTLM
    FNTLMDomain: string;              // NTLM Domain

    procedure Assign(APProxy: PProxy);
  end;

implementation

{ TProxy }

procedure TProxy.Assign(APProxy: PProxy);
begin
  if APProxy <> nil then begin
    FType := APProxy^.FType;
    FIP := APProxy^.FIP;
    FPort := APProxy^.FPort;
    FUserName := APProxy^.FUserName;
    FPassword := APProxy^.FPassword;
    FIsUseNTLM := APProxy^.FIsUseNTLM;
    FNTLMDomain := APProxy^.FNTLMDomain;
  end;
end;

end.
