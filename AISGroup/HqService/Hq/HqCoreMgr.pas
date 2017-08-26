unit HqCoreMgr;

interface

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-25
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

uses
  Windows,
  Classes,
  SysUtils,
  HqDataCenter,
  HqIndicatorMgr,
  HqSubcribeAdapter;

type

  // ������Ĺ���ӿ�
  IHqCoreMgr = Interface(IInterface)
    ['{C541F3C9-505D-4C1B-A742-9745434BAB2B}']
    // ��ȡ�������Ľӿ�
    function GetHqDataCenter: IHqDataCenter; safecall;
    // ��ȡָ�����ӿ�
    function GetHqIndicatorMgr: IHqIndicatorMgr; safecall;
    // ��ȡ�����������ӿ�
    function GetHqSubcribeAdapter: IHqSubcribeAdapter; safecall;
  end;

implementation

end.
