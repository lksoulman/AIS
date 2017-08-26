Unit infutil;

{ types and macros common to blocks and codes
  Copyright (C) 1995-1998 Mark Adler

   WARNING: this file should *not* be used by applications. It is
   part of the implementation of the compression library and is
   subject to change.

  Pascal tranlastion
  Copyright (C) 1998 by Jacques Nomssi Nzali
  For conditions of distribution and use, see copyright notice in readme.txt
}

interface

{$I zconf.inc}

uses
  zutil, zlib7;

{ copy as much as possible from the sliding window to the output area }
function inflate_flush(var s : inflate_blocks_state;
                       var z : z_stream;
                       r : int) : int;

{ And'ing with mask[n] masks the lower n bits }
const
  inflate_mask : array[0..17-1] of uInt = (
    $0000,
    $0001, $0003, $0007, $000f, $001f, $003f, $007f, $00ff,
    $01ff, $03ff, $07ff, $0fff, $1fff, $3fff, $7fff, $ffff);

implementation

{ copy as much as possible from the sliding window to the output area }
function inflate_flush(var s : inflate_blocks_state;
                       var z : z_stream;
                       r : int) : int;
var
  n : uInt;
  p : pBytef;
  q : pBytef;
begin
  { local copies of source and destination pointers }
  p := z.next_out;
  q := s.read;

  { compute number of bytes to copy as far as end of window }
  if ptr2int(q) <= ptr2int(s.write) then
    n := uInt(ptr2int(s.write) - ptr2int(q))
  else
    n := uInt(ptr2int(s.zend) - ptr2int(q));
  if (n > z.avail_out) then
    n := z.avail_out;
  if (n <> 0) and (r = Z_BUF_ERROR) then
    r := Z_OK;

  { update counters }
  Dec(z.avail_out, n);
  Inc(z.total_out, n);


  { update check information }
  if Assigned(s.checkfn) then
  begin
    s.check := s.checkfn(s.check, q, n);
    z.adler := s.check;
  end;

  { copy as far as end of window }
  zmemcpy(p, q, n);
  Inc(p, n);
  Inc(q, n);

  { see if more to copy at beginning of window }
  if (q = s.zend) then
  begin
    { wrap pointers }
    q := s.window;
    if (s.write = s.zend) then
      s.write := s.window;

    { compute bytes to copy }
    n := uInt(ptr2int(s.write) - ptr2int(q));
    if (n > z.avail_out) then
      n := z.avail_out;
    if (n <> 0) and (r = Z_BUF_ERROR) then
      r := Z_OK;

    { update counters }
    Dec( z.avail_out, n);
    Inc( z.total_out, n);

    { update check information }
    if Assigned(s.checkfn) then
    begin
      s.check := s.checkfn(s.check, q, n);
      z.adler := s.check;
    end;

    { copy }
    zmemcpy(p, q, n);
    Inc(p, n);
    Inc(q, n);
  end;


  { update pointers }
  z.next_out := p;
  s.read := q;

  { done }
  inflate_flush := r;
end;

end.
