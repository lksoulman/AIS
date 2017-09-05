{ -------------------------------------------------------------------- }

{$DEFINE NO_DEFLATE}

{$DEFINE MAX_MATCH_IS_258}

{ Compile with -DMAXSEG_64K if the alloc function cannot allocate more
  than 64k bytes at a time (needed on systems with 16-bit int). }


{$UNDEF DYNAMIC_CRC_TABLE}
{$UNDEF FASTEST}
{$define patch112}        { apply patch from the zlib home page }
{ -------------------------------------------------------------------- }
{$IFDEF WIN32}
  {$DEFINE Delphi32}
  {- $DEFINE Delphi5}  { keep compiler quiet }
{$ENDIF}


