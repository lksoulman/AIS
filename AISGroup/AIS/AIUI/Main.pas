unit Main;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-14
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  AppContext,
  PlugInMgr;

type
  TfrmMain = class(TForm)
    // ���ڴ���
    procedure FormCreate(Sender: TObject);
    // �����ͷ�
    procedure FormDestroy(Sender: TObject);
  private
    // ����Ļ����ڸı��ʱ��
    procedure ActiveFormChange(Sender: TObject);
  protected
    // ����������
    FPlugInMgr: TPlugInMgr;
    // Ӧ�ó��������Ľӿ�
    FAppContext: IAppContext;


    // ��ʼ���¼�
    procedure InitEvent;
    // ��ʼ�������ļ�
    procedure InitConfig;
  public
  end;

var
  frmMain: TfrmMain;

implementation

uses
  AppContextImpl;

{$R *.dfm}

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  FPlugInMgr := TPlugInMgr.Create;
  FAppContext := TAppContextImpl.Create as IAppContext;
  FPlugInMgr.Initialize(FAppContext);
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  FPlugInMgr.UnInitialize;
  FAppContext := nil;
  FPlugInMgr.Free;
end;

procedure TfrmMain.ActiveFormChange(Sender: TObject);
begin

end;

procedure TfrmMain.InitEvent;
begin
  Screen.OnActiveFormChange := ActiveFormChange;
end;

procedure TfrmMain.InitConfig;
begin


end;

end.
