{+}
// ---
{$IFNDEF VER80}
  {$IFNDEF VER90}
    {$IFNDEF VER93}
      {$DEFINE D3_UP} { Delphi 3.0 or higher }
      {$IFNDEF VER110}
        {$DEFINE D4_UP} { Delphi 4.0 or higher }
        {$IFNDEF VER120}
          {$DEFINE D5_UP}
          {$IFNDEF VER130}
            {$DEFINE D6_UP}   { Delphi 6.0 or higher }
            {$IFNDEF VER140}
              {$DEFINE D7_UP}   { Delphi 7.0 or higher }
              {$IFNDEF VER150}
                {$DEFINE D9_UP}   { BDS 2005 (9) or higher }
                {$IFNDEF VER170}
                  {$DEFINE D10_UP}   { BDS 2006 (10) or higher }
                  {$IFDEF VER185}
                    {$DEFINE D11_UP}   { RAD Studio 2007 (11) or higher }
                  {$ELSE}
                    {$IFNDEF VER180}
                       {$DEFINE D11_UP}   { RAD Studio 2007 (11) or higher }
                       {$DEFINE D12_UP}   { RAD Studio 2009 (12) or higher }
                       {$IFNDEF VER200}
                          {$DEFINE D14_UP}   { RAD Studio 2010 (14) or higher }
                          {$IFNDEF VER210}
                            {$DEFINE D15_UP}   { RAD Studio XE 2011 (15) or higher }
                            {$DEFINE DXE_UP}   { RAD Studio XE or higher }
                            {$IFNDEF VER220}
                              {$DEFINE D16_UP}   { RAD Studio XE2 2012 (16) or higher }
                              {$DEFINE DXE2_UP}  { RAD Studio XE2 or higher }
                              {$IFNDEF VER230}
                                {$DEFINE D17_UP}   { RAD Studio XE3 2013 (17) or higher }
                                {$DEFINE DXE3_UP}  { RAD Studio XE3 or higher }
                                {$IFNDEF VER240}
                                  {$DEFINE D18_UP}
                                  {$DEFINE DXE4_UP}  { RAD Studio XE4 or higher }
                                  {$IFNDEF VER250}
                                    {$DEFINE D19_UP}
                                    {$DEFINE DXE5_UP}  { RAD Studio XE5 or higher }
                                    {$IFNDEF VER260}
                                      {$DEFINE D20_UP}
                                      {$DEFINE DXE6_UP}  { RAD Studio XE6 or higher }
                                      {$IFNDEF VER270}
                                        {$DEFINE D21_UP}
                                        {$DEFINE DXE7_UP}  { RAD Studio XE7 or higher }
{$IFNDEF VER280}
  {$DEFINE D22_UP}
  {$DEFINE DXE8_UP}  { RAD Studio XE8 or higher }
  {$IFNDEF VER290}
    {$DEFINE D23_UP}
    {$DEFINE DX10_UP}  { RAD Studio 10 Seattle or higher }
    {$IFNDEF VER300}
      {$DEFINE D24_UP}
      {$DEFINE DX11_UP}  { RAD Studio 11 or higher }
    {$ENDIF}
  {$ENDIF}
{$ENDIF}
                                      {$ENDIF}
                                    {$ENDIF}
                                  {$ENDIF}
                                {$ENDIF}
                              {$ENDIF}
                            {$ENDIF}
                          {$ENDIF}
                       {$ENDIF}
                    {$ENDIF}
                  {$ENDIF}
                {$ENDIF}
              {$ENDIF}
            {$ENDIF}
          {$ENDIF}
        {$ENDIF}
      {$ENDIF}
    {$ENDIF}
  {$ENDIF}
{$ENDIF}
// ---

//{$IFDEF DXE3_UP}
//  {$LEGACYIFEND ON} // Allow old style mixed $endif $ifend
//{$ENDIF}

//{$IFDEF VER280}  //XE7
{$IFDEF DXE7_UP}
//{$IFDEF CONDITIONALEXPRESSIONS}
//{$IF CompilerVersion >= 28.00} // ERROR: not supported for *.dpk files
{+.}
  {$DEFINE Delphi21}
  {$DEFINE Delphi20}
  {$DEFINE Delphi19}
  {$DEFINE Delphi18}
  {$DEFINE Delphi2013} //XE3
  {$DEFINE ZLIB}
  {$DEFINE D2012}
  {$DEFINE D2011}
  {$DEFINE D2010}
  {$DEFINE D2009}
  {$DEFINE D2006}
  {$DEFINE D452005}
  {$DEFINE D7UP}
{+}
{$ENDIF}
//{$IFEND CompilerVersion}
//{$ENDIF CONDITIONALEXPRESSIONS}
{+.}

{$IFDEF VER270}  //XE6
  {$DEFINE Delphi20}
  {$DEFINE Delphi19}
  {$DEFINE Delphi18}
  {$DEFINE Delphi2013} //XE3
  {$DEFINE ZLIB}
  {$DEFINE D2012}
  {$DEFINE D2011}
  {$DEFINE D2010}
  {$DEFINE D2009}
  {$DEFINE D2006}
  {$DEFINE D452005}
  {$DEFINE D7UP}
{$ENDIF}

{$IFDEF VER260}  //XE5
  {$DEFINE Delphi19}
  {$DEFINE Delphi18}
  {$DEFINE Delphi2013} //XE3
  {$DEFINE ZLIB}
  {$DEFINE D2012}
  {$DEFINE D2011}
  {$DEFINE D2010}
  {$DEFINE D2009}
  {$DEFINE D2006}
  {$DEFINE D452005}
  {$DEFINE D7UP}
{$ENDIF}

{$IFDEF VER250}  //XE4
  {$DEFINE Delphi18}
  {$DEFINE Delphi2013} //XE3
  {$DEFINE ZLIB}
  {$DEFINE D2012}
  {$DEFINE D2011}
  {$DEFINE D2010}
  {$DEFINE D2009}
  {$DEFINE D2006}
  {$DEFINE D452005}
  {$DEFINE D7UP}
{$ENDIF}

{$IFDEF VER240}
  {$DEFINE Delphi2013} //XE3
  {$DEFINE ZLIB}
  {$DEFINE D2012}
  {$DEFINE D2011}
  {$DEFINE D2010}
  {$DEFINE D2009}
  {$DEFINE D2006}
  {$DEFINE D452005}
  {$DEFINE D7UP}
{$ENDIF}

{$IFDEF VER230}  //XE2
  //{$Delphi2012}// (Pulsar)
  {$DEFINE ZLIB}
  {$DEFINE D2012}
  {$DEFINE D2011}
  {$DEFINE D2010}
  {$DEFINE D2009}
  {$DEFINE D2006}
  {$DEFINE D452005}
  {$DEFINE D7UP}
{$ENDIF}

{$IFDEF VER220} //XE
  //Delphi2011
  {$DEFINE ZLIB}
  {$DEFINE D2011}
  {$DEFINE D2010}
  {$DEFINE D2009}
  {$DEFINE D2006}
  {$DEFINE D452005}
  {$DEFINE D7UP}
{$ENDIF}

{$IFDEF VER210}
  //Delphi2010
  {$DEFINE ZLIB}
  {$DEFINE D2010}
  {$DEFINE D2009}
  {$DEFINE D2006}
  {$DEFINE D452005}
  {$DEFINE D7UP}
{$ENDIF}

{$IFDEF VER200}
  //Delphi2009
  {$DEFINE ZLIB}
  {$DEFINE D2009}
  {$DEFINE D2006}
  {$DEFINE D452005}
  {$DEFINE D7UP}
{$ENDIF}

{$IFDEF VER190}
  //Delphi2007
  {$DEFINE ZLIB}
  {$DEFINE D2007}
  {$DEFINE D7UP}
  {$DEFINE D452005}
{$ENDIF}

{$IFDEF VER180}
  //Delphi2006
  {$DEFINE ZLIB}
  {$DEFINE D2006}
  {$DEFINE D452005}
  {$DEFINE D7UP}
{$ENDIF}

{$IFDEF VER170}
  //Delphi2005
  {$DEFINE ZLIB}
  {$DEFINE D2005}
  {$DEFINE D452005}
  {$DEFINE D7UP}
{$ENDIF}

{$IFDEF VER150}
  //Delphi7
  {$DEFINE ZLIB}
  {$DEFINE D7}
  {$DEFINE D7UP}
{$ENDIF}

{$IFDEF VER140}
  //Delphi6
  {$DEFINE D6}
{$ENDIF}

{$IFDEF VER130}
  //Delphi5
  {$DEFINE D5}
  {$DEFINE D45}
  {$DEFINE D452005}
{$ENDIF}

{$IFDEF VER120}
  //Delphi4
  {$DEFINE D4}
  {$DEFINE D45}
  {$DEFINE D452005}
{$ENDIF}

{.$DEFINE ZLIB}

//////////////////////////////// IMPORTANT ///////////////////////////////////////
//
//   PngImage
//
//   To be able to convert and compress BMP to PNG image, WMF and EMF to PNG
//   and optimization of palette ,
//   you have to install TPNGImage from http://pngdelphi.sourceforge.net/
//   If you want to use TPNGImage, rename the "{.$DEFINE USEPNGLIB}" to  "{$DEFINE USEPNGLIB}"
///////////////////////////////////////////////////////////////////////////////////

{.$DEFINE USEPNGLIB}

{$IFDEF ZLIB}
  {$DEFINE OPEN_EMFWMF}
{$ENDIF}

{+}(*
{$IFDEF VER260}
{$MESSAGE 'Delphi XE5'}
{$ENDIF}

{$IFDEF VER270}
{$MESSAGE 'Delphi XE6'}
{$ENDIF}

{$IFDEF VER280}
{$MESSAGE 'Delphi XE7'}
{$ENDIF}

{$IFDEF VER290}
{$MESSAGE 'Delphi XE8'}
{$ENDIF}

{$IFDEF VER300}
{$MESSAGE 'Delphi DX10'}
{$ENDIF}
//*)
{+.}

{.$DEFINE USE_DevExpress}
