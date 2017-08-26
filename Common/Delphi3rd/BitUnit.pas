unit BitUnit;

interface

uses SysUtils;

const
 Digits : string = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';

function IsBitSet(const i, Nth: integer): boolean;
function BitToOn(const i, Nth: integer): integer;
function BitToOff(const i, Nth: integer): integer;
function BitSwitch(const i, Nth: integer): integer;
function ReverseAllBits(const i: integer): integer;


function TextToValue (Text : string; Base : Integer) : Integer;
function ValueToText (Value, Base : Integer) : string;
function NumberToBits(Value,NumOfBits:integer):string;
function DigitToValue (Digit : Char) : Integer;
function PlaceToValue (Place, Base : Integer) : Integer;

function BintoInt(Value: String): LongInt; //二进制转化为十进制
Function DecTobin(Value :int64) : string;//十进制转化二进制
function reverse(s:String):String;//取反串
function mod_num(n1,n2:integer):integer;//取余数

function SwitchEndian(src : Integer; base : Integer=16):Integer;
function DeSwitchEndian(src : int64; base : Integer=2):Integer;
implementation


function SwitchEndian(src : Integer; base : Integer):Integer;
var
  des, ret : string;
  i : Integer;
begin
  des := NumberToBits(src, base);
  ret :=Copy(des, 9, 8)+ Copy(des, 1, 8)+'0000000000000000';
  for I := 1 to Length(ret) do
  Result := Result * 2 + ORD(ret[i]) - 48;
end;

function DeSwitchEndian(src : int64; base : Integer=2):Integer;
var
  des, ret : string;
  i : Integer;
begin
  des := DecTobin(src);
  if Length(des) < 32 then
  begin
    for I := 1 to 32 - Length(des) do
      des := '0' + des;
  end;
  //'1010010000011000'
  ret := Copy(des, 9, 8)+ Copy(des, 1, 8);
  Result := TextToValue(ret, base)
end;


//十进制转二进制
function mod_num(n1,n2:integer):integer;//取余数
begin
     result:=n1-n1 div n2*n2
end;
function reverse(s:String):String;//取反串
Var
i,num:Integer;
st:String;
begin
  num:=Length(s);
  st:='';
  For i:=num DownTo 1 do
  Begin
    st:=st+s[i];
  End;
  Result:=st;
end;

Function DecTobin(Value :int64) : string;//十进制转化二进制
Var
   ST:String;
   N:int64;
Begin
  ST:='';
  n:=value;
  While n>=2 Do
  Begin
    st:=st+IntToStr(mod_num(n,2));
    n:=n div 2;
  End;
  st:=st+IntToStr(n);
  Result:=reverse(st);
End;

function BintoInt(Value: String): LongInt;
var
  i,Size: Integer;
begin
  Result:=0;
  Size:=Length(Value);
  for i:=Size downto 1 do
  begin
    if Copy(Value,i,1)='1' then
      Result:=Result+(1 shl (Size-i));
  end;
end;

{------------------------------IsBitSet------------------------------------------
  returns True if a bit is ON (1)
  Nth can have any bit order value in [0..31]
----------------------------------------------------------------------------------}
function IsBitSet(const i, Nth: integer): boolean;
begin
  Result:= (i and (1 shl Nth)) <> 0;
end; { IsBitSet }
{----------------------------BitToOn-----------------------------------------------}
function BitToOn(const i, Nth: integer): integer;
begin
  if not IsBitSet(i, Nth)
  then Result := i or (1 shl Nth)
  else Result:=i;
end;  { BitToOn }
{-------------------------BitToOff------------------------------------------------}
function BitToOff(const i, Nth: integer): integer;
begin
  if IsBitSet(i, Nth)
  then Result := i and ((1 shl Nth) xor $FFFFFFFF)
  else Result:=i;
end;  { BitToOff }
{---------------------------BitSwitch---------------------------------------------
 reverse the state of a bit
----------------------------------------------------------------------------------}
function BitSwitch(const i, Nth: integer): integer;
begin
  Result := i xor (1 shl Nth);
end;  { BitSwitch }


{-----------------------ReverseAllBits--------------------------------------------
 has the same effect as the ~ (one's complement) operator in C
----------------------------------------------------------------------------------}
function ReverseAllBits(const i: integer): integer;
var
 N:integer;
begin
  Result:= i;
  for N:=0 to 31 do  Result:= Result xor (1 shl N);
end;  { ReverseAllBits }


{----------------------------------------------------------------------------------}
function TextToValue (Text : string; Base : Integer) : Integer;
var V, I, S : Integer;
begin
  V := 0;
  S := Length (Text);
  for I := 1 to S do
    Inc (V, DigitToValue(Text[I]) * PlaceToValue (S - I + 1, Base));
  Result := V;
end;

function ValueToText (Value, Base : Integer) : string;
var T : string;
begin
  if Value = 0 then Result := Digits [1] else
  begin
    T := '';
    while Value > 0 do
    begin
      T := Digits [(Value mod Base) + 1] + T;
      Value := Value div Base;
    end;
    Result := T;
  end;
end;

function DigitToValue (Digit : Char) : Integer;
var I : Integer;
begin
  Digit := UpCase (Digit);
  I := Length (Digits);
  while (I > 1) and (Digit <> Digits[I]) do Dec (I);
  Result := I - 1;
end;

function PlaceToValue (Place, Base : Integer) : Integer;
var V, I : Integer;
begin
  V := 1;
  for I := 2 to Place do V := V * Base;
  Result := V;
end;

function NumberToBits(Value,NumOfBits:integer):string;
var i:integer;
begin
  Result:='';
  for i:=NumOfBits - 1 downto 0 do
    if IsBitSet(Value, i) then Result := Result +'1' else Result:=Result+ '0';
end;

end.
