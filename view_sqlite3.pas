unit view_sqlite3;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, model_sqlite,DB;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
begin
  TModelSQLite.New.CriarBancoDados('c:\temp\','teste.db').
  CriarTabela('c:\temp\','teste.db', 'teste').
  CriarCampo('CODIGO',ftInteger,0,0).
  CriarCampo('NOME',ftString,10,0).
  CriarCampo('DATA',ftDate,0,0).
  CriarCampo('VALOR',ftCurrency,15,2).
  &end;




end;

end.

