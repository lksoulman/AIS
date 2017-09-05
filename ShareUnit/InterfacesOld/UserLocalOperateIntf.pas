unit UserLocalOperateIntf;

interface
type
   IUserSetting = interface
   ['{A22DFEEB-98C6-4905-AB21-78118145F134}']
     procedure SetUserConfig(const AKey:WideString;Const ADescribe:WideString;Const AContent:WideString);safecall;
     Function GetUserConfig(const AKey:WideString):WideString; safecall;
   end;

   ISelfRangeSetteing = interface
   ['{139CAF0B-853D-4025-BD87-837AA2ADA51C}']
     Function  AddRange(const ARangeName:WideString;const OrderNum:integer;const SelSecu:WideString):Integer;safecall;
     procedure UpdateRange(ARangeID:Integer;const ARangeName:WideString;const OrderNum:integer;const SelSecu:WideString);safecall;
     procedure DeleteRange(ARangeID:Integer);safecall;
     function GetRanges:WideString; safecall;
     procedure InitGilrang; safecall;
   end;
implementation

end.
