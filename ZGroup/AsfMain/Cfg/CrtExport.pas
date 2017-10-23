unit CrtExport;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º crtdll export function
// Author£º      lksoulman
// Date£º        2017-8-25
// Comments£º    crtdll.dll is standard C libary.
//
////////////////////////////////////////////////////////////////////////////////

interface

  // Is Space
  function IsSpace(ACh: AnsiChar): Boolean;
  // Is Alpha
  function IsAlpha(ACh: AnsiChar): Boolean;
  // To Lower
  function ToLower(ACh: AnsiChar): AnsiChar;
  // Is Print
  function IsPrint(ACh: AnsiChar): Boolean;
  // Is Alpha or Number
  function IsAlnum(ACh: AnsiChar): Boolean;

implementation

  function Crt_IsSpace(ch: Integer): Integer; cdecl; external 'crtdll.dll' name 'isspace';
  function Crt_IsAlpha(ch: Integer): Integer; cdecl; external 'crtdll.dll' name 'isalpha';
  function Crt_ToLower(ch: Integer): Integer; cdecl; external 'crtdll.dll' name 'tolower';
  function Crt_IsPrint(ch: Integer): Integer; cdecl; external 'crtdll.dll' name 'isprint';
  function Crt_IsAlnum(ch: Integer): Integer; cdecl; external 'crtdll.dll' name 'isalnum';

  // Is Space
  function IsSpace(ACh: AnsiChar): Boolean;
  begin
    Result := Crt_IsSpace(Ord(ACh)) <> 0;
  end;

  // Is Alpha
  function IsAlpha(ACh: AnsiChar): Boolean;
  begin
    Result := Crt_IsAlpha(Ord(ACh)) <> 0;
  end;

  // To Lower
  function ToLower(ACh: AnsiChar): AnsiChar;
  begin
    Result := AnsiChar(Chr(Crt_ToLower(Ord(ACh))));
  end;

  // Is Print
  function IsPrint(ACh: AnsiChar): Boolean;
  begin
    Result := Crt_IsPrint(Ord(ACh)) <> 0;
  end;

  // Is Alpha or Number
  function IsAlnum(ACh: AnsiChar): Boolean;
  begin
    Result := Crt_IsAlnum(Ord(ACh)) <> 0;
  end;

end.
