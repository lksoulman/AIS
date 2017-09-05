unit SQLiteDataSet;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º SQLite DateSet
// Author£º      lksoulman
// Date£º        2017-6-6
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  DB,
  Uni,
  CommonDataSet;

type

  // SQLite DateSet
  TSQLiteDataSet = class(TWNComDataSet)
  private
  protected
  public
    // Constructor
    constructor Create(ADataSet: TDataSet);
    // Destructor
    destructor Destroy; override;
  end;

implementation

uses
  FastLogLevel,
  AsfSdkExport;

{ TSQLiteDataSet }

constructor TSQLiteDataSet.Create(ADataSet: TDataSet);
begin
  inherited Create(ADataSet, True);
end;

destructor TSQLiteDataSet.Destroy;
begin
  if Assigned(DataSet) and (DataSet is TUniQuery) then begin
    try
      if TUniQuery(DataSet).Connection <> nil then begin
        TUniQuery(DataSet).Connection.Free;
        TUniQuery(DataSet).Connection := nil;
      end;
    except
      on Ex: Exception do begin
        FastSysLog(llError, '[TSQLiteDataSet.Destroy] TUniQuery(DataSet).Connection.free, Exception is '
          + Ex.ToString);
      end;
    end;
  end;
  inherited;
end;

end.
