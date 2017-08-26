unit gunzip;

{
  Pascal unit based on gzio.c -- IO on .gz files
  Copyright (C) 1995-1998 Jean-loup Gailly.

  Define NO_DEFLATE to compile this file without the compression code

  Pascal tranlastion based on code contributed by Francisco Javier Crespo
  Copyright (C) 1998 by Jacques Nomssi Nzali
  For conditions of distribution and use, see copyright notice in readme.txt
}

interface

{$I zconf.inc}

uses
  SysUtils, Classes,
  zutil, zlib7, crc, {zdeflate,} zinflate;

function gz_uncompress(input_ms: TMemoryStream; var output_ms: TMemoryStream):
  Integer;
function gz_uncompress_file(fn_in, fn_out: AnsiString): Integer;

implementation

type
  z_off_t = long;

type
  gz_stream = record
    stream: z_stream;
    z_err: Int;                         { error code for last stream operation }
    z_eof: Boolean;                     { set if end of input file }
    gzfile: TMemoryStream;              { .gz file }
    inbuf: pBytef;                      { input buffer }
    outbuf: pBytef;                     { output buffer }
    crc: uLong;                         { crc32 of uncompressed data }
    //msg         : AnsiString[79];{ error message - limit 79 chars }

    transparent: Boolean;               { true if input file is not a .gz file }
    startpos: long; { start of compressed data in file (header skipped) }
  end;

type
  gz_streamp = ^gz_stream;

const                                   //VERSION = '0.2.99';
  BUFLEN = 16384;
const
  Z_EOF = -1;                           { same value as in STDIO.H }
  Z_BUFSIZE = 16384;
  { Z_PRINTF_BUFSIZE = 4096; }

  gz_magic: array[0..1] of byte = ($1F, $8B); { gzip magic header }

  { gzip flag byte }
  ASCII_FLAG = $01;                     { bit 0 set: file probably ascii text }
  HEAD_CRC = $02;                       { bit 1 set: header CRC present }
  EXTRA_FIELD = $04;                    { bit 2 set: extra field present }
  ORIG_NAME = $08;                      { bit 3 set: original file name present }
  COMMENT = $10;                        { bit 4 set: file comment present }
  RESERVED = $E0;                       { bits 5..7: reserved }

function destroy(var s: gz_streamp): Int; forward;
procedure check_header(s: gz_streamp); forward;

{ GZOPEN ====================================================================

  Opens a gzip (.gz) file for reading or writing. As Pascal does not use
  file descriptors, the code has been changed to accept only path names.

  The mode parameter defaults to BINARY read or write operations ('r' or 'w')
  but can also include a compression level ('w9') or a strategy: Z_FILTERED
  as in 'w6f' or Z_HUFFMAN_ONLY as in 'w1h'. (See the description of
  deflateInit2 for more information about the strategy parameter.)

  gzopen can be used to open a file which is not in gzip format; in this
  case, gzread will directly read from the file without decompression.

  gzopen returns NIL if the file could not be opened (non-zero IOResult)
  or if there was insufficient memory to allocate the (de)compression state
  (zlib error is Z_MEM_ERROR).

  Vincent:
  Added argument 'flags' to the original Zlib files.
============================================================================}

function gzopenStream(ms: TMemoryStream; flags: uInt): gz_streamp;
var
  err: Int;
  //level    : int;        { compression level }
  //strategy : int;        { compression strategy }
  s: gz_streamp;
begin
  Result := nil;

  GetMem(s, SizeOf(gz_stream));

  //level := Z_DEFAULT_COMPRESSION;
  //strategy := Z_DEFAULT_STRATEGY;

  s^.stream.zalloc := nil;              { (alloc_func)0 }
  s^.stream.zfree := nil;               { (free_func)0 }
  s^.stream.opaque := nil;              { (voidpf)0 }
  s^.stream.next_in := Z_NULL;
  s^.stream.next_out := Z_NULL;
  s^.stream.avail_in := 0;
  s^.stream.avail_out := 0;
  s^.z_err := Z_OK;
  s^.z_eof := False;
  s^.inbuf := Z_NULL;
  s^.outbuf := Z_NULL;
  s^.crc := crc32(0, Z_NULL, 0);
  // s^.msg := '';
  s^.transparent := False;

  s^.gzfile := ms;

  //s^.mode := 'r';

  GetMem(s^.inbuf, Z_BUFSIZE);
  s^.stream.next_in := s^.inbuf;

  err := inflateInit2_(s^.stream, -MAX_WBITS, string(ZLIB_VERSION), SizeOf(z_stream));
  { windowBits is passed < 0 to tell that there is no zlib header }

  if (err <> Z_OK) or (s^.inbuf = Z_NULL) then begin
    destroy(s);
    //result := gzFile(Z_NULL);
    Exit;
  end;

  s^.stream.avail_out := Z_BUFSIZE;

  check_header(s);                      { skip the .gz header }
  {$WARNINGS OFF}                       { combining signed and unsigned types }
  s^.startpos := s^.gzfile.Position - s^.stream.avail_in;
  {$WARNINGS ON}

  Result := s;
end;

{ GET_BYTE ==================================================================
  Read a byte from a gz_stream. Updates next_in and avail_in.
  Returns EOF for end of file.
  IN assertion: the stream s has been sucessfully opened for reading.

============================================================================}

function get_byte(s: gz_streamp): Int;
begin
  if (s^.z_eof = True) then begin
    Result := Z_EOF;
    Exit;
  end;

  if (s^.stream.avail_in = 0) then begin
    s^.stream.avail_in := s^.gzfile.Read(s^.inbuf^, Z_BUFSIZE);

    if (s^.stream.avail_in = 0) then begin
      s^.z_eof := True;
      if (IOResult <> 0) then s^.z_err := Z_ERRNO;
      Result := Z_EOF;
      Exit;
    end;
    s^.stream.next_in := s^.inbuf;
  end;

  Dec(s^.stream.avail_in);
  Result := s^.stream.next_in^;
  Inc(s^.stream.next_in);
end;

function getLong(s: gz_streamp): uLong;
var
  x: packed array[0..3] of byte;
  c: Int;
begin
  { x := uLong(get_byte(s));  - you can't do this with TP, no unsigned long }
  { the following assumes a little endian machine and TP }
  x[0] := Byte(get_byte(s));
  x[1] := Byte(get_byte(s));
  x[2] := Byte(get_byte(s));
  c := get_byte(s);
  x[3] := Byte(c);
  if (c = Z_EOF) then
    s^.z_err := Z_DATA_ERROR;
  Result := uLong(longint(x));
end;

{ CHECK_HEADER ==============================================================

  Check the gzip header of a gz_stream opened for reading.
  Set the stream mode to transparent if the gzip magic header is not present.
  Set s^.err  to Z_DATA_ERROR if the magic header is present but the rest of
  the header is incorrect.

  IN assertion: the stream s has already been created sucessfully;
  s^.stream.avail_in is zero for the first time, but may be non-zero
  for concatenated .gz files

============================================================================}

procedure check_header(s: gz_streamp);
var
  method: Int;                          { method byte }
  flags: Int;                           { flags byte }
  len: uInt;
  c: Int;
begin

  { Check the gzip magic header }
  for len := 0 to 1 do begin
    c := get_byte(s);
    if (c <> gz_magic[len]) then begin
      if (len <> 0) then begin
        Inc(s^.stream.avail_in);
        Dec(s^.stream.next_in);
      end;
      if (c <> Z_EOF) then begin
        Inc(s^.stream.avail_in);
        Dec(s^.stream.next_in);
        s^.transparent := True;
      end;
      if (s^.stream.avail_in <> 0) then s^.z_err := Z_OK
      else s^.z_err := Z_STREAM_END;
      Exit;
    end;
  end;

  method := get_byte(s);
  flags := get_byte(s);
  if (method <> Z_DEFLATED) or ((flags and RESERVED) <> 0) then begin
    s^.z_err := Z_DATA_ERROR;
    Exit;
  end;

  for len := 0 to 5 do get_byte(s);     { Discard time, xflags and OS code }

  if ((flags and EXTRA_FIELD) <> 0) then begin { skip the extra field }
    len := uInt(get_byte(s));
    len := len + (uInt(get_byte(s)) shr 8);
    { len is garbage if EOF but the loop below will quit anyway }
    while (len <> 0) and (get_byte(s) <> Z_EOF) do Dec(len);
  end;

  if ((flags and ORIG_NAME) <> 0) then begin { skip the original file name }
    repeat
      c := get_byte(s);
    until (c = 0) or (c = Z_EOF);
  end;

  if ((flags and COMMENT) <> 0) then begin { skip the .gz file comment }
    repeat
      c := get_byte(s);
    until (c = 0) or (c = Z_EOF);
  end;

  if ((flags and HEAD_CRC) <> 0) then begin { skip the header crc }
    get_byte(s);
    get_byte(s);
  end;

  if (s^.z_eof = True) then
    s^.z_err := Z_DATA_ERROR
  else
    s^.z_err := Z_OK;

end;

{ DESTROY ===================================================================

  Cleanup then free the given gz_stream. Return a zlib error code.
  Try freeing in the reverse order of allocations.

============================================================================}

function destroy(var s: gz_streamp): Int;
begin
  Result := Z_OK;

  if not Assigned(s) then begin
    Result := Z_STREAM_ERROR;
    Exit;
  end;

  if (s^.stream.State <> nil) then
    Result := inflateEnd(s^.stream);

  s^.gzfile.Free;

  if (s^.z_err < 0) then Result := s^.z_err;

  if Assigned(s^.inbuf) then
    FreeMem(s^.inbuf, Z_BUFSIZE);
  if Assigned(s^.outbuf) then
    FreeMem(s^.outbuf, Z_BUFSIZE);
  FreeMem(s, SizeOf(gz_stream));

end;

{ GZREAD ====================================================================

  Reads the given number of uncompressed bytes from the compressed file.
  If the input file was not in gzip format, gzread copies the given number
  of bytes into the buffer.

  gzread returns the number of uncompressed bytes actually read
  (0 for end of file, -1 for error).

============================================================================}

function gzread(f: gz_streamp; buf: voidp; len: uInt): Int;
var
  s: gz_streamp;
  start: pBytef;
  next_out: pBytef;
  N: uInt;
  crclen: uInt;                         { Buffer length to update CRC32 }
  filecrc: uLong;                       { CRC32 stored in GZIP'ed file }
  filelen: uLong;                       { Total lenght of uncompressed file }
  bytes: Integer;                       { bytes actually read in I/O blockread }
  total_in: uLong;
  total_out: uLong;

begin

  s := gz_streamp(f);
  start := pBytef(buf);                 { starting point for crc computation }

  if (s^.z_err = Z_DATA_ERROR) or (s^.z_err = Z_ERRNO) then begin
    Result := -1;
    Exit;
  end;

  if (s^.z_err = Z_STREAM_END) then begin
    Result := 0;                        { EOF }
    Exit;
  end;

  s^.stream.next_out := pBytef(buf);
  s^.stream.avail_out := len;

  while (s^.stream.avail_out <> 0) do begin

    if (s^.transparent = True) then begin
      { Copy first the lookahead bytes: }
      N := s^.stream.avail_in;
      if (N > s^.stream.avail_out) then N := s^.stream.avail_out;
      if (N > 0) then begin
        zmemcpy(s^.stream.next_out, s^.stream.next_in, N);
        Inc(s^.stream.next_out, N);
        Inc(s^.stream.next_in, N);
        Dec(s^.stream.avail_out, N);
        Dec(s^.stream.avail_in, N);
      end;
      if (s^.stream.avail_out > 0) then begin
        //blockread (s^.gzfile, s^.stream.next_out^, s^.stream.avail_out, bytes);
        bytes := s^.gzfile.Read(s^.stream.next_out^, s^.stream.avail_out);
        Dec(s^.stream.avail_out, uInt(bytes));
      end;
      Dec(len, s^.stream.avail_out);
      Inc(s^.stream.total_in, uLong(len));
      Inc(s^.stream.total_out, uLong(len));
      Result := Int(len);
      Exit;
    end;                                { IF transparent }

    if (s^.stream.avail_in = 0) and (s^.z_eof = False) then begin
      //blockread (s^.gzfile, s^.inbuf^, Z_BUFSIZE, s^.stream.avail_in);
      s^.stream.avail_in := s^.gzfile.Read(s^.inbuf^, Z_BUFSIZE);

      if (s^.stream.avail_in = 0) then begin
        s^.z_eof := True;
      end;
      s^.stream.next_in := s^.inbuf;
    end;

    s^.z_err := inflate(s^.stream, Z_NO_FLUSH);

    if (s^.z_err = Z_STREAM_END) then begin
      crclen := 0;
      next_out := s^.stream.next_out;
      while (next_out <> start) do begin
        Dec(next_out);
        Inc(crclen); { Hack because Pascal cannot substract pointers }
      end;

      { Check CRC and original size }
      s^.crc := crc32(s^.crc, start, crclen);
      start := s^.stream.next_out;

      filecrc := getLong(s);
      filelen := getLong(s);

      if (s^.crc <> filecrc) or (s^.stream.total_out <> filelen)
        then s^.z_err := Z_DATA_ERROR
      else begin
        { Check for concatenated .gz files: }
        check_header(s);
        if (s^.z_err = Z_OK) then begin
          total_in := s^.stream.total_in;
          total_out := s^.stream.total_out;

          inflateReset(s^.stream);
          s^.stream.total_in := total_in;
          s^.stream.total_out := total_out;
          s^.crc := crc32(0, Z_NULL, 0);
        end;
      end;                              {IF-THEN-ELSE}
    end;

    if (s^.z_err <> Z_OK) or (s^.z_eof = True) then
      Break;

  end;                                  {WHILE}

  crclen := 0;
  next_out := s^.stream.next_out;
  while (next_out <> start) do begin
    Dec(next_out);
    Inc(crclen); { Hack because Pascal cannot substract pointers }
  end;
  s^.crc := crc32(s^.crc, start, crclen);

  Result := Int(len - s^.stream.avail_out);

end;

{ GZERROR ===================================================================

  Returns the error message for the last error which occured on the
   given compressed file. errnum is set to zlib error number. If an
   error occured in the file system and not in the compression library,
   errnum is set to Z_ERRNO and the application may consult errno
   to get the exact error code.

============================================================================}

function gzerror(f: gz_streamp; var errnum: Int): AnsiString;
var
  M: AnsiString;
  s: gz_streamp;
begin
  s := gz_streamp(f);
  if (s = nil) then begin
    errnum := Z_STREAM_ERROR;
    Result := AnsiString(zError(Z_STREAM_ERROR));
  end;

  errnum := s^.z_err;
  if (errnum = Z_OK) then begin
    Result := AnsiString(zError(Z_OK));
    Exit;
  end;

  M := s^.stream.msg;
  if (errnum = Z_ERRNO) then M := '';
  if (M = '') then M := AnsiString(zError(s^.z_err));

  // s^.msg := {s^.path+}': '+m;
  // result := s^.msg;
end;

function gz_uncompress(input_ms: TMemoryStream; var output_ms: TMemoryStream):
  Integer;
var
  len: Integer;
  buf: packed array[0..BUFLEN - 1] of byte; { Global uses BSS instead of stack }
  errorcode: byte;
  f: gz_streamp;
begin
  errorcode := 0;

  f := gzopenStream(input_ms, 0);

  output_ms := TMemoryStream.Create;
  repeat
    len := gzread(f, @buf, BUFLEN);
    if (len < 0) then begin
      errorcode := 1;
      Break
    end;
    if (len = 0) then
      Break;

    output_ms.Write(buf, len);
  until False;

//  if (f^.stream.State <> nil) then
//    Result := inflateEnd(f^.stream);

  //f^.gzfile.Free;
  if Assigned(f^.inbuf) then
    FreeMem(f^.inbuf, Z_BUFSIZE);
  if Assigned(f^.outbuf) then
    FreeMem(f^.outbuf, Z_BUFSIZE);
  FreeMem(f, SizeOf(gz_stream));

  //destroy(f);
  Result := errorcode
end;

function gz_uncompress_file(fn_in, fn_out: AnsiString): Integer;
var
  input_ms: TMemoryStream;
  output_ms: TMemoryStream;
  input_fs: TFileStream;
begin
  input_ms := TMemoryStream.create;
  input_fs := TFileStream.create(string(fn_in), fmOpenRead);
  input_fs.Position := 0;
  input_ms.LoadFromStream(input_fs);
  input_fs.free;

  Result := gz_uncompress(input_ms, output_ms);

  input_ms.free;

  output_ms.Position := 0;
  output_ms.SaveToFile(string(fn_out));
  output_ms.Free;
end;

end.

