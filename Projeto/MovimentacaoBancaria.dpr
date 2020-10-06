program MovimentacaoBancaria;

uses
  System.StartUpCopy,
  FMX.Forms,
  ConsultaFinanceira in 'ConsultaFinanceira.pas' {Frm_ConsultaFinanceira},
  ofxloader in 'ofxloader.pas',
  BancoDados in 'BancoDados.pas' {DM_BancoDados: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrm_ConsultaFinanceira, Frm_ConsultaFinanceira);
  Application.CreateForm(TDM_BancoDados, DM_BancoDados);
  Application.Run;
end.
