unit FutureInfo;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-28
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

type

  // �ڻ�����ת��CODE
  IFutureInfo = Interface(IInterface)
    ['{4C410229-A9D0-46C6-9E74-CA4F86F527C3}']
    // ��ʼ����Ҫ����Դ
    procedure Initialize(AContext: IInterface); safecall;
    // �ͷŲ���Ҫ����Դ
    procedure UnInitialize; safecall;
    // ��������
    procedure LoadXmlNodes(ANodeList: TList); safecall;
    // �ڻ� Code �ĸ���
//    function GetFutureCodeCount: Integer; safecall;
//    // ��ȡ InnerCode
//    function GetInnerCode(AIndex: Integer): Integer; safecall;
//    // ��ȡ AgentCode
//    function GetAgentCode(AIndex: Integer): WideString; safecall;
    // ��ȡ�ǲ��Ǵ��� InnerCode
    function GetFutureCode(AInnerCode: Integer; var ACodeAgent: WideString): Boolean; safecall;
  end;

implementation

end.
