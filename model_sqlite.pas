unit model_sqlite;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, SQLite3Conn, SQLDB, DB, Dialogs;

type


  IModelSQLite = interface
    function CriarBancoDados(pPastaBancoDados, pNomeBancoDados: string): IModelSQLite;
    function CriarTabela(pPastaBancoDados, pNomeBancoDados, pNomeTabela: string):
      IModelSQLite;
    function CriarCampo(pNomeCampo: string; pTipoCampo: TFieldType;
      pTamanho, pQtdCasasDecimais: integer): IModelSQLite;
    function &End: IModelSQLite;

    procedure SetNomeBancoDados(pPasta, pNomeBancoDados: string);
  end;




  { TDMModelSQLite3 }
  TDMModelSQLite3 = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    FSQL3Con: TSQLite3Connection;
    FSQLTrans: TSQLTransaction;
  public


  end;

  { TModelSQLite }
  TModelSQLite = class(TInterfacedObject, IModelSQLite)
  private
    fScriptCriacaoTabela: string;
    FDMModelSQLite3: TDMModelSQLite3;
    FPastaBancoDados: string;
    FNomeBancoDados: string;
    FNomeTabela: string;
  public

    function CriarBancoDados(pPastaBancoDados, pNomeBancoDados: string): IModelSQLite;
    function CriarTabela(pPastaBancoDados, pNomeBancoDados, pNomeTabela: string):
      IModelSQLite;
    function CriarCampo(pNomeCampo: string; pTipoCampo: TFieldType;
      pTamanho, pQtdCasasDecimais: integer): IModelSQLite;
    function &end: IModelSQLite;
    procedure SetNomeBancoDados(pPastaBancoDados, pNomeBancoDados: string);
    constructor Create;
    destructor Destroy; override;
    class function New: IModelSQLite;



  end;

var
  DMModelSQLite3: TDMModelSQLite3;

implementation

{$R *.lfm}

{ TDMModelSQLite3 }

procedure TDMModelSQLite3.DataModuleCreate(Sender: TObject);
begin
  FSQL3Con := TSQLite3Connection.Create(nil);
  FSQLTrans := TSQLTransaction.Create(nil);
end;

procedure TDMModelSQLite3.DataModuleDestroy(Sender: TObject);
begin
  FreeAndNil(FSQL3Con);
  FreeAndNil(FSQLTrans);
end;

{ TModelSQLite }
function TModelSQLite.CriarBancoDados(pPastaBancoDados, pNomeBancoDados: string):
IModelSQLite;
var
  LArquivo: string;
begin
  Result := self;
  LArquivo := StringReplace(pPastaBancoDados + '\' + pNomeBancoDados,
    '\\', '\', [rfReplaceAll]);
  // Criar arquivo do banco , caso ele não exista
  if not FileExists(LArquivo) then
  begin
    try
      FDMModelSQLite3.FSQL3Con.DatabaseName := LArquivo;
      // se banco não existir, cria.
      FDMModelSQLite3.FSQL3Con.Connected := True;
    except
      on e: Exception do
      begin
        raise Exception.Create(
          'Não foi possível criar o banco de dados. Método model_sqlite.TModelSQLite.CriarTabela. Mensagem: '
          +
          e.message);
      end;
    end;

  end;
end;

function TModelSQLite.CriarTabela(pPastaBancoDados, pNomeBancoDados,
  pNomeTabela: string): IModelSQLite;
begin
  Result := self;
  fScriptCriacaoTabela := '';
  FPastaBancoDados := pPastaBancoDados;
  FNomeBancoDados := pNomeBancoDados;
  fNomeTabela := pNomeTabela;

  fScriptCriacaoTabela := 'CREATE TABLE ' + pNomeTabela + '(';
end;

function TModelSQLite.CriarCampo(pNomeCampo: string; pTipoCampo: TFieldType;
  pTamanho, pQtdCasasDecimais: integer): IModelSQLite;
begin
  Result := self;
  fScriptCriacaoTabela := fScriptCriacaoTabela + pNomeCampo;
  case pTipoCampo of
    ftString: begin
      fScriptCriacaoTabela :=
        fScriptCriacaoTabela + ' VARCHAR(' + pTamanho.ToString + '),';
    end;
    ftInteger: begin
      fScriptCriacaoTabela := fScriptCriacaoTabela + ' INTEGER,';
    end;
    ftCurrency: begin
      fScriptCriacaoTabela := fScriptCriacaoTabela + ' NUMERIC(' +
        pTamanho.ToString + ',' + pQtdCasasDecimais.ToString + '),';
    end;
    ftDate: begin
      fScriptCriacaoTabela := fScriptCriacaoTabela + ' DATE,';
    end;
    else
    begin
      raise Exception.Create(
        'Campo não definido. Método model_sqlite.TModelSQLite.CriarTabela');
    end;
  end;

end;

function TModelSQLite.&End: IModelSQLite;
var
  LArquivo: string;
begin
  Result := self;
  fScriptCriacaoTabela := Copy(fScriptCriacaoTabela, 1, Length(
    fScriptCriacaoTabela) - 1) + ')';

  LArquivo := StringReplace(FPastaBancoDados + '\' + FNomeBancoDados,
    '\\', '\', [rfReplaceAll]);

  // Atribui o banco de dados para a conexao
  FDMModelSQLite3.FSQL3Con.DatabaseName := LArquivo;

  // Atribui o banco de dados para a transacao
  FDMModelSQLite3.FSQLTrans.DataBase := FDMModelSQLite3.FSQL3Con;

  // Ativa conexão atraves do Transaction
  FDMModelSQLite3.FSQLTrans.Active := True;
  try

    // Executa o scrip de criacao
    FDMModelSQLite3.FSQL3Con.ExecuteDirect(fScriptCriacaoTabela);

    // Comita a transacao
    FDMModelSQLite3.FSQLTrans.CommitRetaining;

  except
    on e: Exception do
    begin
      raise Exception.Create('Erro ao criar a tabela ' + FNomeTabela +
        '. Método model_sqlite.TModelSQLite.&End. Mensagem: ' + e.message);
    end;
  end;

end;

procedure TModelSQLite.SetNomeBancoDados(pPastaBancoDados, pNomeBancoDados: string);
begin
  FPastaBancoDados := pPastaBancoDados;
  FNomeBancoDados := pNomeBancoDados;

end;

constructor TModelSQLite.Create;
begin
  FDMModelSQLite3 := TDMModelSQLite3.Create(nil);
end;

destructor TModelSQLite.Destroy;
begin
  FreeAndNil(FDMModelSQLite3);
end;

class function TModelSQLite.New: IModelSQLite;
begin
  Result := Self.Create;
end;

end.
{
Colocar na mesma pasta do executavel as seguintes dll sqlite3.dll e sqlite3.def



}
