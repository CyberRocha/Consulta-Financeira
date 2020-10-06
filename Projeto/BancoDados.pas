unit BancoDados;

interface

uses
  System.SysUtils, System.Classes, System.StrUtils, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.FMXUI.Wait, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TDM_BancoDados = class(TDataModule)
    FD_Conexao: TFDConnection;
    FDQry_Manutencao: TFDQuery;
    FDQry_ConsultaMovimento: TFDQuery;
    FDQry_ConsultaMovimentoDT_Movimento: TDateTimeField;
    FDQry_ConsultaMovimentoVL_Movimento: TCurrencyField;
    FDQry_ConsultaMovimentoDescricao: TStringField;
    FDQry_IncluiMovimentacao: TFDQuery;
    FDQry_VerificaExisteMovimento: TFDQuery;
    FDQry_VerificaExisteMovimentoID_Cliente: TIntegerField;
    FDQry_VerificaExisteMovimentoID_Documento: TStringField;
    FDQry_VerificaExisteMovimentoDT_Movimento: TDateTimeField;
    FDQry_VerificaExisteMovimentoVL_Movimento: TCurrencyField;
    FDQry_VerificaExisteMovimentoFlag_Movimento: TStringField;
    FDQry_VerificaExisteMovimentoDescricao: TStringField;
    FDQry_VerificaSaldo: TFDQuery;
    IntegerField1: TIntegerField;
    StringField1: TStringField;
    StringField2: TStringField;
    CurrencyField1: TCurrencyField;
    FDQry_AtualizaSaldo: TFDQuery;
    FDQry_IncluiSaldo: TFDQuery;
    FDQry_ConsultaSaldo: TFDQuery;
    FDQry_ConsultaSaldoID_Cliente: TIntegerField;
    FDQry_ConsultaSaldoBanco: TStringField;
    FDQry_ConsultaSaldoConta: TStringField;
    FDQry_ConsultaSaldoVL_Saldo: TCurrencyField;
    FDQry_ConsultaCotacao: TFDQuery;
    FDQry_ConsultaCotacaoID_Moeda: TStringField;
    FDQry_ConsultaCotacaoDT_Cotacao: TDateTimeField;
    FDQry_ConsultaCotacaoVL_Compra: TCurrencyField;
    FDQry_ConsultaCotacaoVL_Venda: TCurrencyField;
    FDQry_ConsultaCotacaoVL_Variacao: TCurrencyField;
    FDQry_IncluiCotacao: TFDQuery;
    FDQry_ConsultaMovimentoFlag_Movimento: TStringField;
    procedure FDQry_ConsultaMovimentoVL_MovimentoGetText(Sender: TField;
      var Text: string; DisplayText: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DM_BancoDados: TDM_BancoDados;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

procedure TDM_BancoDados.FDQry_ConsultaMovimentoVL_MovimentoGetText(
  Sender: TField; var Text: string; DisplayText: Boolean);
begin
  // Formata a coluna de valores
  case AnsiIndexStr(FDQry_ConsultaMovimentoFlag_Movimento.AsString, ['C','D']) of
     0 : Text := 'R$ ' + FormatCurr('###,###,##0.00', Abs(StrToCurrDef(Sender.AsString,0)));
     1 : Text := 'R$ ' + FormatCurr('###,###,##0.00', Abs(StrToCurrDef(Sender.AsString,0))) + ' (-)';
  else
     Text := '';
  end;
end;

end.
