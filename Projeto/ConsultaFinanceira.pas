unit ConsultaFinanceira;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, System.Rtti,
  FMX.Grid.Style, REST.Types, FMX.Grid, REST.Client, Data.Bind.Components,
  Data.Bind.ObjectScope, FMX.ScrollBox, FMX.Controls.Presentation, FMX.StdCtrls,
  FMX.Objects, FMX.Effects, FMX.Filter.Effects, System.JSON, FireDAC.Stan.Param,
  System.Math.Vectors, FMX.Layouts, FMX.DialogService, Data.Bind.EngExt,
  Fmx.Bind.DBEngExt, System.Bindings.Outputs, Fmx.Bind.Editors, Data.Bind.DBScope,
  FMX.textlayout, Fmx.Bind.Grid, Data.Bind.Grid, FMX.Memo;

type
  TFrm_ConsultaFinanceira = class(TForm)
    RESTCliente: TRESTClient;
    RESTSolicitante: TRESTRequest;
    RESTResposta: TRESTResponse;
    OpenArquivo: TOpenDialog;
    Lyt_MovimentoBancario: TLayout;
    Lbl_TituloMovimentacaoBancaria: TLabel;
    Btn_ImportaOFX: TButton;
    Lbl_Saldo: TLabel;
    Shp_Area: TLine;
    StrG_Movimentacao: TStringGrid;
    BindSourceDB: TBindSourceDB;
    BindingsLista: TBindingsList;
    Lbl_CotacaoDia: TLabel;
    Btn_AtualizaCotacao: TButton;
    LinkGridToDataSourceBindSourceDB: TLinkGridToDataSource;
    Scl_Cotacao: THorzScrollBox;
    Rtg_Dolar: TRectangle;
    Lbl_TituloDolar: TLabel;
    Lbl_USDVenda: TLabel;
    Lbl_USDCompra: TLabel;
    Lbl_USDVariacao: TLabel;
    Rtg_Euro: TRectangle;
    Lbl_TituloEuro: TLabel;
    Lbl_EURCompra: TLabel;
    Lbl_EURVenda: TLabel;
    Lbl_EURVariacao: TLabel;
    Rtg_Bitcoin: TRectangle;
    Lbl_TituloBitcoin: TLabel;
    Lbl_BTCVenda: TLabel;
    Lbl_BTCCompra: TLabel;
    Lbl_BTCVariacao: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure Btn_ImportaOFXClick(Sender: TObject);
    procedure Btn_AtualizaCotacaoClick(Sender: TObject);
    procedure FormataTelaCotacao(ID_Moeda: String; VL_Compra, VL_Venda, VL_Variacao: Currency; DT_Cotacao: TDateTime);
    procedure ConfigureBrazilRegion;
    procedure LimpaCotacao;
    procedure RetornaDadosBancoDados;
    procedure MessageModal(const Mensagem: String);
    procedure StrG_MovimentacaoDrawColumnCell(Sender: TObject;
      const Canvas: TCanvas; const Column: TColumn; const Bounds: TRectF;
      const Row: Integer; const Value: TValue; const State: TGridDrawStates);
    procedure StrG_MovimentacaoDrawColumnHeader(Sender: TObject;
      const Canvas: TCanvas; const Column: TColumn; const Bounds: TRectF);
    Procedure ConectaBancoDados;
    Procedure IncluiCotacao(ID_Moeda: String; Data_Cotacao: TDateTime; Valor_Compra, Valor_Venda, Valor_Variacao: Currency);
    procedure FormShow(Sender: TObject);
    procedure ImportaArquivoOFX;
    Procedure IncluiMovimentacao(ID_Cliente: Integer; Banco, Conta, Documento,
              Descricao, Flag_Movimento: String; Valor_Movimento: Currency; Data_Movimento: TDateTime);
    Procedure IncluiSaldo(ID_Cliente: integer; Banco, Conta: String; Valor_Saldo: Currency; Data_Saldo: TDateTime);
    Procedure AtualizaSaldo(ID_Cliente: integer; Banco, Conta: String; Valor_Saldo: Currency; Data_Saldo: TDateTime);
  private
    { Private declarations }
    PathAplicacao : String;
    SaldoAnterior : Currency;

    function VerificaExisteMovimento(ID_Cliente: Integer; Banco, Conta, Documento: String; Data_Movimento: TDateTime) : integer;
    function VerificaExisteSaldo(ID_Cliente: Integer; Banco, Conta: String) : integer;
  public
    { Public declarations }
  end;

var
  Frm_ConsultaFinanceira: TFrm_ConsultaFinanceira;

implementation

{$R *.fmx}
{$R *.LgXhdpiPh.fmx ANDROID}
{$R *.LgXhdpiTb.fmx ANDROID}
{$R *.NmXhdpiPh.fmx ANDROID}
{$R *.iPhone4in.fmx IOS}
{$R *.XLgXhdpiTb.fmx ANDROID}
{$R *.iPhone55in.fmx IOS}
{$R *.Macintosh.fmx MACOS}
{$R *.Windows.fmx MSWINDOWS}

uses OFXLoader, BancoDados;


procedure TFrm_ConsultaFinanceira.AtualizaSaldo(ID_Cliente: integer; Banco,
  Conta: String; Valor_Saldo: Currency; Data_Saldo: TDateTime);
begin
  with DM_BancoDados.FDQry_AtualizaSaldo do
  begin
    Close;
    Params.ParamByName('ID_Cliente').AsInteger := ID_Cliente;
    Params.ParamByName('Banco').AsString := Banco;
    Params.ParamByName('Conta').AsString := Conta;
    Params.ParamByName('VL_Saldo').AsCurrency := Valor_Saldo;
    Params.ParamByName('DT_Saldo').AsDateTime := Data_Saldo;
    ExecSQL;
    Close;
  end;
end;

procedure TFrm_ConsultaFinanceira.Btn_AtualizaCotacaoClick(Sender: TObject);
var JSONValue : TJSONValue;
    USD_Compra : Currency;
    USD_Venda : Currency;
    USD_Variacao : Currency;

    EUR_Compra : Currency;
    EUR_Venda : Currency;
    EUR_Variacao : Currency;

    BTC_Compra : Currency;
    BTC_Venda : Currency;
    BTC_Variacao : Currency;
    DT_Cotacao : TDateTime;
begin
  DT_Cotacao := Now();
  RESTSolicitante.Execute;
  if RESTResposta.StatusCode = 200 then
  begin
    JSONValue := RESTResposta.JSONValue;

    // Recupera os Valores JSON
    USD_Compra := JSONValue.GetValue<currency>('results.currencies.USD.buy');
    USD_Venda := JSONValue.GetValue<currency>('results.currencies.USD.sell');
    USD_Variacao := JSONValue.GetValue<currency>('results.currencies.USD.variation');

    EUR_Compra := JSONValue.GetValue<currency>('results.currencies.EUR.buy');
    EUR_Venda := JSONValue.GetValue<currency>('results.currencies.EUR.sell');
    EUR_Variacao := JSONValue.GetValue<currency>('results.currencies.EUR.variation');

    BTC_Compra := JSONValue.GetValue<currency>('results.currencies.BTC.buy');
    BTC_Venda := JSONValue.GetValue<currency>('results.currencies.BTC.sell');
    BTC_Variacao := JSONValue.GetValue<currency>('results.currencies.BTC.variation');

    // Inclui as cotações no banco de dados
    IncluiCotacao('USD', DT_Cotacao, USD_Compra, USD_Venda, USD_Variacao);
    IncluiCotacao('EUR', DT_Cotacao, EUR_Compra, EUR_Venda, EUR_Variacao);
    IncluiCotacao('BTC', DT_Cotacao, BTC_Compra, BTC_Venda, BTC_Variacao);

    // Mostra resultado da pesquisa na tela
    FormataTelaCotacao('USD', USD_Compra, USD_Venda, USD_Variacao, DT_Cotacao);
    FormataTelaCotacao('EUR', EUR_Compra, EUR_Venda, EUR_Variacao, DT_Cotacao);
    FormataTelaCotacao('BTC', BTC_Compra, BTC_Venda, BTC_Variacao, DT_Cotacao);
  end;
end;

procedure TFrm_ConsultaFinanceira.Btn_ImportaOFXClick(Sender: TObject);
begin
  ImportaArquivoOFX;
end;

procedure TFrm_ConsultaFinanceira.FormCreate(Sender: TObject);
begin
  ConfigureBrazilRegion;

  // Recupera a localização da Aplicacao em qualquer pasta onde ele esteja
  PathAplicacao := ExtractFileDir(ParamStr(0));
end;

procedure TFrm_ConsultaFinanceira.FormShow(Sender: TObject);
begin
  // Cria e ou conecta ao Banco de dados. (popula as tabelas se o banco estiver vazio)
  ConectaBancoDados;
end;

procedure TFrm_ConsultaFinanceira.ImportaArquivoOFX;
var OFXLoader : TOFXLoader;
    Indice : Integer;
    SaldoAtual : Currency;

    Banco : String;
    Conta : String;
    Documento : String;
    Data_Movimento : TDateTime;
    Valor_Movimento : Currency;
    Flag_Movimento : String;
    ID_Documento : String;
    Descricao : String;
begin
   try
      OFXLoader := TOFXLoader.Create(nil);
      if OpenArquivo.Execute() then
      begin
        OFXLoader.OFXArquivo := OpenArquivo.FileName;
        try
           OFXLoader.Decodifica;
        except on E: Exception do
           raise Exception.Create('Error Message: ' + E.Message);
        end;

        SaldoAtual := SaldoAnterior;
        with DM_BancoDados, DM_BancoDados.FDQry_IncluiMovimentacao.Params do
        begin
          FDQry_ConsultaMovimento.DisableControls;
          for Indice := 0 to OFXLoader.Contador -1 do
          begin
            // Recupera dados do arquivo OFX
            Banco := OFXLoader.BankID;
            Conta := OFXLoader.ACCTID;
            Documento := OFXLoader.RecuperaItem(Indice).Documento;
            Data_Movimento := OFXLoader.RecuperaItem(Indice).MovimentoData;
            Valor_Movimento := StrToCurrDef(OFXLoader.RecuperaItem(Indice).Valor, 0);
            ID_Documento := OFXLoader.RecuperaItem(Indice).Documento;
            Descricao := OFXLoader.RecuperaItem(Indice).Descricao;

            if (VerificaExisteMovimento(1, Banco, Conta, Documento, Data_Movimento) = 0) then  // Se movimento for vazio
            begin
              // Calcula o saldo atual
              SaldoAtual := SaldoAtual + StrToCurrDef(OFXLoader.RecuperaItem(Indice).Valor,0);

              Flag_Movimento := OFXLoader.RecuperaItem(Indice).MovimentoTipo;
              // Corrige Flag_Movimento
              if OFXLoader.RecuperaItem(Indice).MovimentoTipo = 'O' then
              begin
                if StrToCurrDef(OFXLoader.RecuperaItem(Indice).Valor,0) >= 0  then
                   Flag_Movimento := 'C' // Flag Crédito
                else
                   Flag_Movimento := 'D'; // Flag Débito
              end;

              // Inclui Movimentação
              IncluiMovimentacao(1, Banco, Conta, Documento, Descricao, Flag_Movimento, Valor_Movimento, Data_Movimento);
            end;
          end;

          // Verifica se banco/conta já existe
          SaldoAnterior := SaldoAtual;
          if (VerificaExisteSaldo(1, Banco, Conta) = 0) then
          begin
            // Inclui saldo caso ele não exista no banco de dados
            IncluiSaldo(1, Banco, Conta, SaldoAtual, Now());
          end else
          begin
            // Atualiza o saldo/data
            AtualizaSaldo(1, Banco, Conta, SaldoAtual, Now());
          end;

          // Atualiza informação na Grid
          FDQry_ConsultaMovimento.Refresh;
          FDQry_ConsultaMovimento.EnableControls;
        end;
        Lbl_Saldo.Text := 'Saldo: R$ ' + FormatCurr('#,###,##0.00', SaldoAtual);

      end;
   finally
      FreeAndNil(OFXLoader);
   end;
end;

procedure TFrm_ConsultaFinanceira.IncluiCotacao(ID_Moeda: String;
  Data_Cotacao: TDateTime; Valor_Compra, Valor_Venda, Valor_Variacao: Currency);
begin
  with DM_BancoDados.FDQry_IncluiCotacao do
  begin
    Close;
    Params.ParamByName('ID_Moeda').AsString := ID_Moeda;
    Params.ParamByName('DT_Cotacao').AsDateTime := Data_Cotacao;
    Params.ParamByName('VL_Compra').AsCurrency := Valor_Compra;
    Params.ParamByName('VL_Venda').AsCurrency := Valor_Venda;
    Params.ParamByName('VL_Variacao').AsCurrency := Valor_Variacao;
    ExecSQL;
    Close;
  end;
end;

procedure TFrm_ConsultaFinanceira.IncluiMovimentacao(ID_Cliente: Integer; Banco,
  Conta, Documento, Descricao, Flag_Movimento: String;
  Valor_Movimento: Currency; Data_Movimento: TDateTime);
begin
  with DM_BancoDados.FDQry_IncluiMovimentacao do
  begin
    Close;
    ParamByName('ID_Cliente').ASInteger := ID_Cliente;
    ParamByName('Banco').AsString := Banco;
    ParamByName('Conta').AsString := Conta;
    ParamByName('DT_Movimento').ASDateTime := Data_Movimento;
    ParamByName('VL_Movimento').ASCurrency := Valor_Movimento;
    ParamByName('Flag_Movimento').ASString := Flag_Movimento;
    ParamByName('ID_Documento').ASString := Documento;
    ParamByName('Descricao').ASString := Descricao;
    ExecSQL;
    Close;
  end;
end;

procedure TFrm_ConsultaFinanceira.IncluiSaldo(ID_Cliente: integer; Banco,
  Conta: String; Valor_Saldo: Currency; Data_Saldo: TDateTime);
begin
  with DM_BancoDados.FDQry_IncluiSaldo do
  begin
    Close;
    Params.ParamByName('ID_Cliente').AsInteger := ID_Cliente;
    Params.ParamByName('Banco').AsString := Banco;
    Params.ParamByName('Conta').AsString := Conta;
    Params.ParamByName('VL_Saldo').AsCurrency := Valor_Saldo;
    Params.ParamByName('DT_Saldo').AsDateTime := Data_Saldo;
    ExecSQL;
    Close;
  end;
end;

procedure TFrm_ConsultaFinanceira.FormataTelaCotacao(ID_Moeda: String; VL_Compra, VL_Venda, VL_Variacao: Currency; DT_Cotacao: TDateTime);
begin
  Lbl_CotacaoDia.Text := 'Cotações do dia (' + FormatDateTime('dd/mm/yyyy', DT_Cotacao) + ')';
  if ID_Moeda = 'USD' then
  begin
    Lbl_USDVenda.Text := 'Venda: R$ ' + FormatCurr('#,###,##0.00', VL_Venda);
    Lbl_USDCompra.Text := 'Compra: R$ ' + FormatCurr('#,###,##0.00', VL_Compra);
    Lbl_USDVariacao.Text := 'Variação: ' + FormatCurr('0.000', VL_Variacao) + '%';
  end;
  if ID_Moeda = 'EUR' then
  begin
    Lbl_EURVenda.Text := 'Venda: R$ ' + FormatCurr('#,###,##0.00', VL_Venda);
    Lbl_EURCompra.Text := 'Compra: R$ ' + FormatCurr('#,###,##0.00', VL_Compra);
    Lbl_EURVariacao.Text := 'Variação: ' + FormatCurr('0.000', VL_Variacao) + '%';
  end;
  if ID_Moeda = 'BTC' then
  begin
    Lbl_BTCVenda.Text := 'Venda: R$ ' + FormatCurr('#,###,##0.00', VL_Venda);
    Lbl_BTCCompra.Text := 'Compra: R$ ' + FormatCurr('#,###,##0.00', VL_Compra);
    Lbl_BTCVariacao.Text := 'Variação: ' + FormatCurr('0.000', VL_Variacao) + '%';
  end;
end;

procedure TFrm_ConsultaFinanceira.ConectaBancoDados;
begin
  with DM_BancoDados do
  begin
    // Recupera configuração do banco de dados
    FD_Conexao.Connected := False;
    FD_Conexao.Params.Clear;
    FD_Conexao.Params.Values['DriverID'] := 'SQLite';
    FD_Conexao.Params.Values['Database'] := PathAplicacao + '\Alterdata.db';
    FD_Conexao.Connected := True;

    if FileExists(PathAplicacao + '\CriaTabelas.SQL') and FileExists(PathAplicacao + '\PopulaClientes.SQL') then
    begin
      // Lê script e cria tabelas se não existirem
      FDQry_Manutencao.Active := False;
      FDQry_Manutencao.SQL.LoadFromFile(PathAplicacao + '\CriaTabelas.SQL');
      FDQry_Manutencao.ExecSQL;
      FDQry_Manutencao.SQL.Clear;

      // Lê script e popula tabela Clientes
      FDQry_Manutencao.SQL.LoadFromFile(PathAplicacao + '\PopulaClientes.SQL');
      FDQry_Manutencao.ExecSQL;

      // Abre a conulta na Grid
      FDQry_ConsultaMovimento.DisableControls;
      FDQry_ConsultaMovimento.Open();
      FDQry_ConsultaMovimento.EnableControls;

      // Retorna os dado: saldo e contação anterior
      RetornaDadosBancoDados;
    end else
    begin
      MessageModal('Os arquivos CriaTabelas.SQL e PopulaClientes.SQL' + #13 +
                  'não foram encontrados juntos com a aplicação.' + #13#13 +
                  'A aplicação será encerrada!');
    end;
  end;
end;

procedure TFrm_ConsultaFinanceira.ConfigureBrazilRegion;
var
  FormatoBr: TFormatSettings;
begin
  // Configura todos os parâmetros regionais para BR
  FormatoBr                     := TFormatSettings.Create;
  FormatoBr.DecimalSeparator    := ',';
  FormatoBr.ThousandSeparator   := '.';
  FormatoBr.CurrencyDecimals    := 2;
  FormatoBr.DateSeparator       := '/';
  FormatoBr.ShortDateFormat     := 'dd/mm/yyyy';
  FormatoBr.LongDateFormat      := 'dd/mm/yyyy';
  FormatoBr.TimeSeparator       := ':';
  FormatoBr.TimeAMString        := 'AM';
  FormatoBr.TimePMString        := 'PM';
  FormatoBr.ShortTimeFormat     := 'hh:nn';
  FormatoBr.LongTimeFormat      := 'hh:nn:ss';
  FormatoBr.CurrencyString      := 'R$';
  System.SysUtils.FormatSettings := FormatoBr;
end;

procedure TFrm_ConsultaFinanceira.LimpaCotacao;
begin
  FormataTelaCotacao('USD', 0, 0, 0, Now());
  FormataTelaCotacao('EUR', 0, 0, 0, Now());
  FormataTelaCotacao('BTC', 0, 0, 0, Now());
end;

procedure TFrm_ConsultaFinanceira.RetornaDadosBancoDados;
VAR ID_Moeda : String;
    ID_MoedaAnterior : String;
begin
  // Retorna os últimos dados sobre cotação e atualiza a tela
  with DM_BancoDados do
  begin
    FDQry_ConsultaSaldo.Close;
    FDQry_ConsultaSaldo.Open();
    Lbl_Saldo.Text := 'Saldo: R$ ' + FormatCurr('#,###,##0.00', FDQry_ConsultaSaldoVL_Saldo.Value);
    SaldoAnterior := FDQry_ConsultaSaldoVL_Saldo.Value;

    FDQry_ConsultaSaldo.Close;

    FDQry_ConsultaCotacao.Close;
    FDQry_ConsultaCotacao.Open();
    while not(FDQry_ConsultaCotacao.Eof) do
    begin
      ID_Moeda := FDQry_ConsultaCotacaoID_Moeda.AsString;
      if ID_Moeda <> ID_MoedaAnterior then
      begin
        FormataTelaCotacao(FDQry_ConsultaCotacaoID_Moeda.AsString,
                           FDQry_ConsultaCotacaoVL_Compra.ASCurrency,
                           FDQry_ConsultaCotacaoVL_Venda.ASCurrency,
                           FDQry_ConsultaCotacaoVL_Variacao.ASCurrency,
                           FDQry_ConsultaCotacaoDT_Cotacao.ASDateTime);
      end;
      ID_MoedaAnterior := ID_Moeda;
      FDQry_ConsultaCotacao.Next;
      if ID_MoedaAnterior = 'USD' then break;
    end;
    FDQry_ConsultaCotacao.Close;
    StrG_Movimentacao.SetFocus;
  end;
end;

procedure TFrm_ConsultaFinanceira.StrG_MovimentacaoDrawColumnCell(
  Sender: TObject; const Canvas: TCanvas; const Column: TColumn;
  const Bounds: TRectF; const Row: Integer; const Value: TValue;
  const State: TGridDrawStates);
var TextLayout : TTextLayout;
    RectF: TRectF;
begin
  // Configura o visual da Grid
  TextLayout := TTextLayoutManager.DefaultTextLayout.Create;
  try
      TextLayout.BeginUpdate;
      try
          RectF := Bounds;
          InflateRect(RectF, 0, 0);
          if (TGridDrawState.Selected in State) or
             (TGridDrawState.Focused in State) or
            (TGridDrawState.RowSelected in State)
          then
            Canvas.Fill.Color := TAlphaColors.LightBlue
          else
            Canvas.Fill.Color := TAlphaColors.White;
          Canvas.FillRect(RectF, 0, 0, [], 1);

          TextLayout.TopLeft := Bounds.TopLeft;
          TextLayout.MaxSize := PointF(Column.Width, Column.Height);
          TextLayout.Font.Family := 'Comic Sans MS';
          TextLayout.Font.Size := 12;
          TextLayout.Text := Value.AsString;

          // Ajusta a cores da coluna valor
          if Column.Index = 2 then
          begin
            if Pos('-', Value.AsString) > 0 then
               TextLayout.Color := TAlphaColors.Red
            else
               TextLayout.Color := TAlphaColors.Green;
           end;
       finally
        TextLayout.EndUpdate;
      end;
      TextLayout.RenderLayout(Canvas);
  finally
     TextLayout.Free;
  end;
end;

procedure TFrm_ConsultaFinanceira.StrG_MovimentacaoDrawColumnHeader(
  Sender: TObject; const Canvas: TCanvas; const Column: TColumn;
  const Bounds: TRectF);
begin
  // Ajusta o estilo do Header da Grid
  Canvas.Fill.Color := TAlphaColorRec.Lightgray;
  Canvas.FillRect(Bounds, 0, 0, [], 1);
  Canvas.Font.Size := 14;
  Canvas.Font.Family := 'Comic Sans MS';
  Canvas.Font.Style := [TFontStyle.fsBold];
  Canvas.Fill.Color := TAlphaColorRec.Black;
  Canvas.FillText(Bounds, Column.Header , False, 1, [] , TTextAlign.Leading);
end;

function TFrm_ConsultaFinanceira.VerificaExisteMovimento(ID_Cliente: Integer;
  Banco, Conta, Documento: String; Data_Movimento: TDateTime): integer;
var Resultado: Integer;
begin
  with DM_BancoDados.FDQry_VerificaExisteMovimento do
  begin
    Close;
    Params.ParamByName('ID_Cliente').ASInteger := ID_Cliente; // Cliente fixado no registro 1 porque o certo é fazer uma seleção prévia (somente foi informado como exemplo)
    Params.ParamByName('Banco').AsString := Banco;
    Params.ParamByName('Conta').AsString := Conta;
    Params.ParamByName('ID_Documento').ASString := Documento;
    Params.ParamByName('DT_Movimento').ASDateTime := Data_Movimento;
    Open();
    Resultado := RecordCount;
    Close;
    Result := Resultado;
  end;
end;

function TFrm_ConsultaFinanceira.VerificaExisteSaldo(ID_Cliente: Integer; Banco,
  Conta: String): integer;
var Resultado: Integer;
begin
  with DM_BancoDados.FDQry_VerificaSaldo do
  begin
    Close;
    Params.ParamByName('ID_Cliente').ASInteger := ID_Cliente;
    Params.ParamByName('Banco').AsString := Banco;
    Params.ParamByName('Conta').AsString := Conta;
    Open();
    Resultado := RecordCount;
    Close;
    Result := Resultado;
  end;
end;

// Procedure para mostrar mensagem modal em qualquer dispositivo
procedure TFrm_ConsultaFinanceira.MessageModal(const Mensagem: String);
begin
  TDialogService.PreferredMode := TDialogService.TPreferredMode.Platform;
  TDialogService.MessageDialog(Mensagem, TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOk], TMsgDlgBtn.mbOk, 0,
  procedure(const AResult: TModalResult)
  begin
    if AResult = mrok then Application.Terminate;
  end);
end;

end.




