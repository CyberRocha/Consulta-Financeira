object DM_BancoDados: TDM_BancoDados
  OldCreateOrder = False
  Height = 233
  Width = 479
  object FD_Conexao: TFDConnection
    Params.Strings = (
      'Database=C:\Delphi_Projeto\Alterdata\Projeto\Alterdata.db'
      'DriverID=SQLite')
    LoginPrompt = False
    Left = 40
    Top = 32
  end
  object FDQry_Manutencao: TFDQuery
    Connection = FD_Conexao
    Left = 48
    Top = 88
  end
  object FDQry_ConsultaMovimento: TFDQuery
    Connection = FD_Conexao
    SQL.Strings = (
      'SELECT DT_Movimento, Descricao, VL_Movimento, Flag_Movimento'
      'FROM MovimentoContaBancaria'
      'ORDER BY DT_Movimento')
    Left = 144
    Top = 16
    object FDQry_ConsultaMovimentoDT_Movimento: TDateTimeField
      DisplayLabel = ' Data '
      FieldName = 'DT_Movimento'
      Origin = 'DT_Movimento'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      ReadOnly = True
      Required = True
    end
    object FDQry_ConsultaMovimentoDescricao: TStringField
      DisplayLabel = ' Descri'#231#227'o '
      FieldName = 'Descricao'
      Origin = 'Descricao'
      ReadOnly = True
      Required = True
      Size = 80
    end
    object FDQry_ConsultaMovimentoVL_Movimento: TCurrencyField
      Alignment = taLeftJustify
      DisplayLabel = ' Valor '
      DisplayWidth = 20
      FieldName = 'VL_Movimento'
      Origin = 'VL_Movimento'
      ReadOnly = True
      Required = True
      OnGetText = FDQry_ConsultaMovimentoVL_MovimentoGetText
      currency = False
    end
    object FDQry_ConsultaMovimentoFlag_Movimento: TStringField
      FieldName = 'Flag_Movimento'
      Origin = 'Flag_Movimento'
      ReadOnly = True
      Required = True
      Visible = False
      FixedChar = True
      Size = 1
    end
  end
  object FDQry_IncluiMovimentacao: TFDQuery
    Connection = FD_Conexao
    SQL.Strings = (
      'INSERT INTO MovimentoContaBancaria '
      '(ID_Cliente, Banco, Conta, DT_Movimento, VL_Movimento,'
      ' Flag_Movimento, ID_Documento, Descricao)'
      
        'SELECT :ID_Cliente, :Banco, :Conta, :DT_Movimento, :VL_Movimento' +
        ','
      ' :Flag_Movimento, :ID_Documento, :Descricao'
      '')
    Left = 136
    Top = 72
    ParamData = <
      item
        Name = 'ID_CLIENTE'
        DataType = ftInteger
        ParamType = ptInput
        Value = Null
      end
      item
        Name = 'BANCO'
        DataType = ftString
        ParamType = ptInput
        Size = 10
        Value = Null
      end
      item
        Name = 'CONTA'
        DataType = ftString
        ParamType = ptInput
        Size = 50
        Value = Null
      end
      item
        Name = 'DT_MOVIMENTO'
        DataType = ftDateTime
        ParamType = ptInput
        Value = Null
      end
      item
        Name = 'VL_MOVIMENTO'
        DataType = ftCurrency
        ParamType = ptInput
        Value = Null
      end
      item
        Name = 'FLAG_MOVIMENTO'
        DataType = ftString
        ParamType = ptInput
        Size = 1
        Value = Null
      end
      item
        Name = 'ID_DOCUMENTO'
        DataType = ftString
        ParamType = ptInput
        Size = 30
        Value = Null
      end
      item
        Name = 'DESCRICAO'
        DataType = ftString
        ParamType = ptInput
        Size = 80
        Value = Null
      end>
  end
  object FDQry_VerificaExisteMovimento: TFDQuery
    Connection = FD_Conexao
    SQL.Strings = (
      'SELECT ID_Cliente, ID_Documento, DT_Movimento,'
      'VL_Movimento, Flag_Movimento, Descricao'
      'FROM MovimentoContaBancaria'
      
        'WHERE ID_Cliente = :ID_Cliente and Banco = :Banco and Conta = :C' +
        'onta AND ID_Documento = :ID_Documento and DT_Movimento = :DT_Mov' +
        'imento'
      'ORDER BY ID_Documento')
    Left = 136
    Top = 120
    ParamData = <
      item
        Name = 'ID_CLIENTE'
        DataType = ftInteger
        ParamType = ptInput
        Value = Null
      end
      item
        Name = 'BANCO'
        DataType = ftString
        ParamType = ptInput
        Size = 6
        Value = Null
      end
      item
        Name = 'CONTA'
        DataType = ftString
        ParamType = ptInput
        Size = 50
        Value = Null
      end
      item
        Name = 'ID_DOCUMENTO'
        DataType = ftString
        ParamType = ptInput
        Size = 30
        Value = Null
      end
      item
        Name = 'DT_MOVIMENTO'
        DataType = ftDateTime
        ParamType = ptInput
        Value = Null
      end>
    object FDQry_VerificaExisteMovimentoID_Cliente: TIntegerField
      FieldName = 'ID_Cliente'
      Origin = 'ID_Cliente'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
    end
    object FDQry_VerificaExisteMovimentoID_Documento: TStringField
      FieldName = 'ID_Documento'
      Origin = 'ID_Documento'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
      Size = 30
    end
    object FDQry_VerificaExisteMovimentoDT_Movimento: TDateTimeField
      FieldName = 'DT_Movimento'
      Origin = 'DT_Movimento'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
    end
    object FDQry_VerificaExisteMovimentoVL_Movimento: TCurrencyField
      FieldName = 'VL_Movimento'
      Origin = 'VL_Movimento'
      Required = True
    end
    object FDQry_VerificaExisteMovimentoFlag_Movimento: TStringField
      FieldName = 'Flag_Movimento'
      Origin = 'Flag_Movimento'
      Required = True
      FixedChar = True
      Size = 1
    end
    object FDQry_VerificaExisteMovimentoDescricao: TStringField
      FieldName = 'Descricao'
      Origin = 'Descricao'
      Required = True
      Size = 80
    end
  end
  object FDQry_VerificaSaldo: TFDQuery
    Connection = FD_Conexao
    SQL.Strings = (
      'SELECT ID_Cliente, Banco, Conta, VL_Saldo, DT_Saldo'
      'FROM ContaBancaria'
      
        'WHERE ID_Cliente = :ID_Cliente AND Banco = :Banco AND Conta = :C' +
        'onta '
      '')
    Left = 280
    Top = 168
    ParamData = <
      item
        Name = 'ID_CLIENTE'
        DataType = ftInteger
        ParamType = ptInput
        Value = Null
      end
      item
        Name = 'BANCO'
        DataType = ftString
        ParamType = ptInput
        Size = 10
        Value = Null
      end
      item
        Name = 'CONTA'
        DataType = ftString
        ParamType = ptInput
        Size = 30
        Value = Null
      end>
    object IntegerField1: TIntegerField
      FieldName = 'ID_Cliente'
      Origin = 'ID_Cliente'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
    end
    object StringField1: TStringField
      FieldName = 'Banco'
      Origin = 'Banco'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
      Size = 10
    end
    object StringField2: TStringField
      FieldName = 'Conta'
      Origin = 'Conta'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
      Size = 50
    end
    object CurrencyField1: TCurrencyField
      FieldName = 'VL_Saldo'
      Origin = 'VL_Saldo'
      Required = True
    end
  end
  object FDQry_AtualizaSaldo: TFDQuery
    Connection = FD_Conexao
    SQL.Strings = (
      'UPDATE ContaBancaria '
      'SET VL_Saldo = :VL_Saldo,'
      '    DT_Saldo = :DT_Saldo'
      'WHERE ID_Cliente = :ID_Cliente'
      'AND Banco = :Banco'
      'AND Conta = :Conta ')
    Left = 280
    Top = 113
    ParamData = <
      item
        Name = 'VL_SALDO'
        DataType = ftCurrency
        ParamType = ptInput
        Value = Null
      end
      item
        Name = 'DT_SALDO'
        DataType = ftDateTime
        ParamType = ptInput
        Value = Null
      end
      item
        Name = 'ID_CLIENTE'
        DataType = ftInteger
        ParamType = ptInput
        Value = Null
      end
      item
        Name = 'BANCO'
        DataType = ftString
        ParamType = ptInput
        Size = 10
        Value = Null
      end
      item
        Name = 'CONTA'
        DataType = ftString
        ParamType = ptInput
        Size = 50
        Value = Null
      end>
  end
  object FDQry_IncluiSaldo: TFDQuery
    Connection = FD_Conexao
    SQL.Strings = (
      'INSERT INTO ContaBancaria'
      '(ID_Cliente, Banco, Conta, VL_Saldo, DT_Saldo)'
      'SELECT :ID_Cliente, :Banco, :Conta, :VL_Saldo, :DT_Saldo')
    Left = 280
    Top = 62
    ParamData = <
      item
        Name = 'ID_CLIENTE'
        DataType = ftInteger
        ParamType = ptInput
        Value = Null
      end
      item
        Name = 'BANCO'
        DataType = ftString
        ParamType = ptInput
        Size = 10
        Value = Null
      end
      item
        Name = 'CONTA'
        DataType = ftString
        ParamType = ptInput
        Size = 50
        Value = Null
      end
      item
        Name = 'VL_SALDO'
        DataType = ftCurrency
        ParamType = ptInput
        Value = Null
      end
      item
        Name = 'DT_SALDO'
        DataType = ftDateTime
        ParamType = ptInput
        Value = Null
      end>
  end
  object FDQry_ConsultaSaldo: TFDQuery
    Connection = FD_Conexao
    SQL.Strings = (
      'SELECT ID_Cliente, Banco, Conta, VL_Saldo, DT_Saldo'
      'FROM ContaBancaria'
      'ORDER BY DT_Saldo Desc'
      '')
    Left = 280
    Top = 8
    object FDQry_ConsultaSaldoID_Cliente: TIntegerField
      FieldName = 'ID_Cliente'
      Origin = 'ID_Cliente'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
    end
    object FDQry_ConsultaSaldoBanco: TStringField
      DisplayWidth = 10
      FieldName = 'Banco'
      Origin = 'Banco'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
      Size = 10
    end
    object FDQry_ConsultaSaldoConta: TStringField
      DisplayWidth = 50
      FieldName = 'Conta'
      Origin = 'Conta'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
      Size = 50
    end
    object FDQry_ConsultaSaldoVL_Saldo: TCurrencyField
      FieldName = 'VL_Saldo'
      Origin = 'VL_Saldo'
      Required = True
    end
  end
  object FDQry_ConsultaCotacao: TFDQuery
    Connection = FD_Conexao
    SQL.Strings = (
      'SELECT ID_Moeda, DT_Cotacao, '
      '       VL_Compra, VL_Venda, VL_Variacao'
      'FROM CotacaoMoeda'
      'ORDER BY DT_Cotacao DESC, ID_Moeda')
    Left = 384
    Top = 32
    object FDQry_ConsultaCotacaoID_Moeda: TStringField
      FieldName = 'ID_Moeda'
      Origin = 'ID_Moeda'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
      FixedChar = True
      Size = 3
    end
    object FDQry_ConsultaCotacaoDT_Cotacao: TDateTimeField
      FieldName = 'DT_Cotacao'
      Origin = 'DT_Cotacao'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
    end
    object FDQry_ConsultaCotacaoVL_Compra: TCurrencyField
      FieldName = 'VL_Compra'
      Origin = 'VL_Compra'
      Required = True
    end
    object FDQry_ConsultaCotacaoVL_Venda: TCurrencyField
      FieldName = 'VL_Venda'
      Origin = 'VL_Venda'
      Required = True
    end
    object FDQry_ConsultaCotacaoVL_Variacao: TCurrencyField
      FieldName = 'VL_Variacao'
      Origin = 'VL_Variacao'
      Required = True
    end
  end
  object FDQry_IncluiCotacao: TFDQuery
    Connection = FD_Conexao
    SQL.Strings = (
      'INSERT INTO CotacaoMoeda '
      '(ID_Moeda, DT_Cotacao, VL_Compra, VL_Venda, VL_Variacao)'
      
        'SELECT :ID_Moeda, :DT_Cotacao, :VL_Compra, :VL_Venda, :VL_Variac' +
        'ao'
      
        'WHERE NOT EXISTS(SELECT * FROM CotacaoMoeda WHERE ID_Moeda = :ID' +
        '_Moeda AND VL_Compra = :VL_Compra AND VL_Venda = :VL_Venda AND V' +
        'L_Variacao = :VL_Variacao)'
      '')
    Left = 384
    Top = 88
    ParamData = <
      item
        Name = 'ID_MOEDA'
        DataType = ftString
        ParamType = ptInput
        Size = 3
        Value = Null
      end
      item
        Name = 'DT_COTACAO'
        DataType = ftDateTime
        ParamType = ptInput
        Value = Null
      end
      item
        Name = 'VL_COMPRA'
        DataType = ftCurrency
        ParamType = ptInput
        Value = Null
      end
      item
        Name = 'VL_VENDA'
        DataType = ftCurrency
        ParamType = ptInput
        Value = Null
      end
      item
        Name = 'VL_VARIACAO'
        DataType = ftCurrency
        ParamType = ptInput
        Value = Null
      end>
  end
end
