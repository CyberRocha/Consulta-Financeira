unit ofxloader;

interface

uses System.Classes, System.SysUtils;

type
  TOFXItem = class
    MovimentoTipo: String;
    MovimentoData: TDateTime;
    Valor: String;
    ID: String;
    Documento: String;
    Descricao: String;
  end;

  TOFXLoader = class(TComponent)
  public
    BANKID: String;
    ACCTID: String;
    DTSTART: String;
    DTEND: String;
    BALAMT: String;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Decodifica: boolean;
    function RecuperaItem(Indice: integer): TOFXItem;
    function Contador: integer;
  private
    ArquivoPath: String;
    Arquivo : TList;
    procedure Limpar;
    procedure Apagar(Indice: integer);
    function Adiciona: TOFXItem;
    function ConteudoCampo(Campo: String): String;
    function ChecaTag(Tag, StringLida: String): boolean;
  protected
  published
    property OFXArquivo: String read ArquivoPath write ArquivoPath;
  end;

implementation

constructor TOFXLoader.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Arquivo := TList.Create;
end;

destructor TOFXLoader.Destroy;
begin
  Limpar;
  Arquivo.Free;
  inherited Destroy;
end;

procedure TOFXLoader.Apagar(Indice: integer);
begin
  TOFXItem(Arquivo.Items[Indice]).Free;
  Arquivo.Delete(Indice);
end;

procedure TOFXLoader.Limpar;
begin
  while Arquivo.Count > 0 do Apagar(0);
  Arquivo.Clear;
end;

function TOFXLoader.Contador: integer;
begin
  Result := Arquivo.Count;
end;

function TOFXLoader.RecuperaItem(Indice: integer): TOFXItem;
begin
  Result := TOFXItem(Arquivo.Items[Indice]);
end;

function TOFXLoader.Decodifica: boolean;
var
  OFXArquivo: TStringList;
  Indice: integer;
  ChecaArquivo: boolean;
  OFXItem: TOFXItem;
  LinhaLida: String;
begin
  Limpar;
  DTStart := '';
  DTEnd := '';
  ChecaArquivo := false;
  if not FileExists(ArquivoPath) then
     raise Exception.Create('Arquivo OFX não encontrado!');
  OFXArquivo := TStringList.Create;
  try
    // Carrega o arquivo
    OFXArquivo.LoadFromFile(ArquivoPath);
    Indice := 0;

    while Indice < OFXArquivo.Count do
    begin
      // Recupera a linha do arquivo
      LinhaLida := OFXArquivo.Strings[Indice];

      // Verifica se o arquivo é do tipo OFX
      if ChecaTag('<OFX>', LinhaLida) then
         ChecaArquivo := true;

      if ChecaArquivo then
      begin
        // Recupera o Banco
        if ChecaTag('<BANKID>', LinhaLida) then
           BankID := ConteudoCampo(LinhaLida);

        // Recupera Agencia/Conta
        if ChecaTag('<ACCTID>', LinhaLida) then
           ACCTID := ConteudoCampo(LinhaLida);

        // Recupera período do arquivo
        if ChecaTag('<DTSTART>', LinhaLida) then
        begin
          if Trim(LinhaLida) <> '' then
             DTStart := copy(ConteudoCampo(LinhaLida), 7, 2) + '/' +
                        copy(ConteudoCampo(LinhaLida), 5, 2) + '/' +
                        copy(ConteudoCampo(LinhaLida), 1, 4);
        end;
        if ChecaTag('<DTEND>', LinhaLida) then
        begin
          if Trim(LinhaLida) <> '' then
             DTEnd := copy(ConteudoCampo(LinhaLida), 7, 2) + '/' +
                      copy(ConteudoCampo(LinhaLida), 5, 2) + '/' +
                      copy(ConteudoCampo(LinhaLida), 1, 4);
        end;

        // Recupera dados do movimento
        if ChecaTag('<STMTTRN>', LinhaLida) then
        begin
          OFXItem := Adiciona;
          while not ChecaTag('</STMTTRN>', LinhaLida) do
          begin
            Inc(Indice);
            // Recupera a linha do arquivo
            LinhaLida := OFXArquivo.Strings[Indice];

            // Recupera tipo de movimento da transação
            if ChecaTag('<TRNTYPE>', LinhaLida) then
            begin
              if (ConteudoCampo(LinhaLida) = '0') or (ConteudoCampo(LinhaLida) = 'CREDIT') OR (ConteudoCampo(LinhaLida) = 'DEP') then
                 OFXItem.MovimentoTipo := 'C'
              else
              if (ConteudoCampo(LinhaLida) = '1') or (ConteudoCampo(LinhaLida) = 'DEBIT') OR (ConteudoCampo(LinhaLida) = 'XFER') then
                 OFXItem.MovimentoTipo := 'D'
              else
                OFXItem.MovimentoTipo := 'O';
            end;

            // Recupera data da postagem da transação
            if ChecaTag('<DTPOSTED>', LinhaLida) then
               OFXItem.MovimentoData := StrToDateTime(copy(ConteudoCampo(LinhaLida), 7, 2) + '/' +
                                        copy(ConteudoCampo(LinhaLida), 5, 2) + '/' +
                                        copy(ConteudoCampo(LinhaLida), 1, 4));

            // Recupera valor da transação
            if ChecaTag('<TRNAMT>', LinhaLida) then
            begin
              OFXItem.Valor := StringReplace(ConteudoCampo(LinhaLida), '.', ',', [rfReplaceAll]);
            end;

            // Recupera identificador da transação
            if ChecaTag('<FITID>', LinhaLida) then
               OFXItem.ID := ConteudoCampo(LinhaLida);

            // Recupera verificador da transação
            if ChecaTag('<CHKNUM>', LinhaLida) or ChecaTag('<CHECKNUM>', LinhaLida) then
               OFXItem.Documento := ConteudoCampo(LinhaLida);

            // Recupera descrição da transação
            if ChecaTag('<MEMO>', LinhaLida) then
               OFXItem.Descricao := ConteudoCampo(LinhaLida);


          end;
        end;

        // Recupera saldo final
        if ChecaTag('<LEDGERBAL>', LinhaLida) or ChecaTag('<BALAMT>', LinhaLida) then
           BALAMT := StringReplace(ConteudoCampo(LinhaLida), '.', ',', [rfReplaceAll]);

      end;
      Inc(Indice);
    end;
    Result := ChecaArquivo;
  finally
    OFXArquivo.Free;
  end;
end;

function TOFXLoader.ConteudoCampo(Campo: String): String;
var
  Indice: integer;
begin
  Result := '';
  Campo := Trim(Campo);
  if ChecaTag('>', Campo) then
  begin
    Campo := Trim(Campo);
    Indice := Pos('>', Campo);
    if Pos('</', Campo) > 0 then
      Result := copy(Campo, Indice + 1, Pos('</', Campo) - Indice - 1)
    else
      Result := copy(Campo, Indice + 1, length(Campo));
  end;
end;

function TOFXLoader.Adiciona: TOFXItem;
var  OFXItem: TOFXItem;
begin
  OFXItem := TOFXItem.Create;
  Arquivo.Add(OFXItem);
  Result := OFXItem;
end;

// Checa se a Tag existe
function TOFXLoader.ChecaTag(Tag, StringLida: String): boolean;
begin
  Result := Pos(UpperCase(TAG), UpperCase(StringLida)) > 0;
end;

end.
