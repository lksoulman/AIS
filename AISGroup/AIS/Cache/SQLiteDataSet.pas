unit SQLiteDataSet;

interface

uses
  Windows,
  Classes,
  SysUtils,
  WNComDataSet,
  DB,
  Uni;

type

  TSQLiteDataSet = class(TWNComDataSet)
  private
  protected
  public
    // 构造方法
    constructor Create(ADataSet: TDataSet);
    // 析构函数
    destructor Destroy; override;
  end;

implementation

uses
  FastLogLevel;

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
        FastAppLog(llError, '[TSQLiteDataSet.Destroy] TUniQuery(DataSet).Connection.free, Exception is '
          + Ex.ToString);
      end;
    end;
  end;
  inherited;
end;

end.
