Unit ZUtil;

{
  Copyright (C) 1998 by Jacques Nomssi Nzali
  For conditions of distribution and use, see copyright notice in readme.txt
}

interface

{$I zconf.inc}

{ Type declarations }

type
  {Byte   = usigned char;  8 bits}
  Bytef  = byte;
  charf  = byte;

  int    = integer;

  intf   = int;
  uInt   = cardinal;     { 16 bits or more }

  uIntf  = uInt;

  Long   = longint;
  //  uLong  = LongInt;      { 32 bits or more }
  uLong = LongWord;		   { DelphiGzip: LongInt is Signed, longword not }
  uLongf = uLong;

  voidp  = pointer;
  voidpf = voidp;
  pBytef = ^Bytef;
  pIntf  = ^intf;
  puIntf = ^uIntf;
  puLong = ^uLongf;

  ptr2int = uInt;
{ a pointer to integer casting is used to do pointer arithmetic.
  ptr2int must be an integer type and sizeof(ptr2int) must be less
  than sizeof(pointer) - Nomssi }

const
  MaxMemBlock = MaxInt;

type
  zByteArray = array[0..(MaxMemBlock div SizeOf(Bytef))-1] of Bytef;
  pzByteArray = ^zByteArray;
type
  zIntfArray = array[0..(MaxMemBlock div SizeOf(Intf))-1] of Intf;
  pzIntfArray = ^zIntfArray;
type
  zuIntArray = array[0..(MaxMemBlock div SizeOf(uInt))-1] of uInt;
  PuIntArray = ^zuIntArray;


procedure zmemcpy(destp : pBytef; sourcep : pBytef; len : uInt);
procedure zcfree(opaque : voidpf; ptr : voidpf);
function zcalloc (opaque : voidpf; items : uInt; size : uInt) : voidpf;

implementation

procedure zmemcpy(destp : pBytef; sourcep : pBytef; len : uInt);
begin
  Move(sourcep^, destp^, len);
end;

procedure zcfree(opaque : voidpf; ptr : voidpf);
begin
  FreeMem(ptr);  { Delphi 2,3,4 }
end;

function zcalloc (opaque : voidpf; items : uInt; size : uInt) : voidpf;
var
  p : voidpf;
  memsize : uLong;
begin
  memsize := uLong(items) * size;

  GetMem(p, memsize);  { Delphi: p := AllocMem(memsize); }

  zcalloc := p;
end;

{$WARNINGS OFF}
end.

{$WARNINGS ON}
