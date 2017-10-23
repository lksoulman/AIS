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
  DB,
  Uni,
  Windows,
  Classes,
  SysUtils,
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
        raise Exception.Create('[TSQLiteDataSet.Destroy] TUniQuery(DataSet).Connection.free, Exception is '
          + Ex.ToString);
      end;
    end;
  end;
  inherited;
end;

end.
