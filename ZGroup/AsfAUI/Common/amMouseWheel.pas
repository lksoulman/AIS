unit amMouseWheel;

// -----------------------------------------------------------------------------
// The original author is Anders Melander, anders@melander.dk, http://melander.dk
// Copyright ? 2008 Anders Melander
// -----------------------------------------------------------------------------
// License:
// Creative Commons Attribution-Share Alike 3.0 Unported
// http://creativecommons.org/licenses/by-sa/3.0/
// -----------------------------------------------------------------------------

interface

uses
  Forms,
  Messages,
  Classes,
  Controls,
  Windows;

// ------------------------------------------------------------------------------
//
// TForm work around for mouse wheel messages
//
// ------------------------------------------------------------------------------
// The purpose of this class is to enable mouse wheel messages on controls
// that doesn't have the focus.
//
// To scroll with the mouse just hover the mouse over the target control and
// scroll the mouse wheel.
// ------------------------------------------------------------------------------
type
  TamForm = class(Forms.TForm)
  public
    procedure MouseWheelHandler(var Msg: TMessage); override;
  end;

  // ------------------------------------------------------------------------------
  //
  // Generic control work around for mouse wheel messages
  //
  // ------------------------------------------------------------------------------
  // Call this function from a control's (e.g. a TFrame) DoMouseWheel method like
  // this:
  //
  // function TMyFrame.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
  // MousePos: TPoint): Boolean;
  // begin
  // Result := ControlDoMouseWheel(Self, Shift, WheelDelta, MousePos) or inherited;
  // end;
  //
  // ------------------------------------------------------------------------------
function ControlDoMouseWheel(Control: TControl; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean;

implementation

uses
  Types;

procedure TamForm.MouseWheelHandler(var Msg: TMessage);
var
  Target: TControl;
begin
  // Find the control under the mouse
  Target := FindDragTarget(SmallPointToPoint(TCMMouseWheel(Msg).Pos), False);
  while (Target <> nil) do
  begin
    // If the target control is the focused control then we abort as the focused
    // control is the originator of the call to this method.
    if (Target = Self) or ((Target is TWinControl) and (TWinControl(Target).Focused)) then
    begin
      Target := nil;
      break;
    end;

    // Let the target control process the scroll. If the control doesn't handle
    // the scroll then...
    Msg.Result := Target.Perform(CM_MOUSEWHEEL, Msg.WParam, Msg.LParam);
    if (Msg.Result <> 0) then
      break;

    // ...let the target's parent give it a go instead.
    Target := Target.Parent;
  end;

  // Fall back to the default processing if none of the controls under the mouse
  // could handle the scroll.
  if (Target = nil) then
    inherited;
end;

type
  TControlCracker = class(TControl);

function ControlDoMouseWheel(Control: TControl; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean;
var
  Target: TControl;
begin
  (*
    ** The purpose of this method is to enable mouse wheel messages on controls
    ** that doesn't have the focus.
    **
    ** To scroll with the mouse just hover the mouse over the target control and
    ** scroll the mouse wheel.
  *)
  Result := False;

  // Find the control under the mouse
  Target := FindDragTarget(MousePos, False);

  while (not Result) and (Target <> nil) do
  begin
    // If the target control is the focused control then we abort as the focused
    // control is the originator of the call to this method.
    if (Target = Control) or ((Target is TWinControl) and (TWinControl(Target).Focused)) then
      break;

    // Let the target control process the scroll. If the control doesn't handle
    // the scroll then...
    Result := TControlCracker(Target).DoMouseWheel(Shift, WheelDelta, MousePos);

    // ...let the target's parent give it a go instead.
    Target := Target.Parent;
  end;
end;

end.
