unit uDM;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, SQLite3Conn, SQLDB, DB,
  uProduto,
  uProdutoRepository,
  uNomeRepository;

type

  { TDM }

  TDM = class(TDataModule, IProdutoRepository, INomeRepository)
    qryProdutosestoque: TLargeintField;
    qryProdutosid: TLongintField;
    qryProdutosnome: TStringField;
    qryProdutospreco: TFloatField;

    SQLite3Connection1: TSQLite3Connection;
    qryExec: TSQLQuery;
    qryProdutos: TSQLQuery;
    SQLTransaction1: TSQLTransaction;
    procedure DataModuleCreate(Sender: TObject);
  private
    FUltimoValor: string;
    FCampoOrdenacao: string;
    FOrdemAscendente: Boolean;
    function SepararValores(const Texto: string): TStringList;

  public
    function Inserir(const Produto: TProduto): Integer;
    procedure Atualizar(const Produto: TProduto);
    procedure Excluir(ID: Integer);
    procedure ConsultarProdutos(const Valor: string);
    procedure LimparConsulta;
    procedure OrdenarProdutos(const Campo: string; Ascendente: Boolean);

    function ConsultarNomes(const Valor: string): TStringList;

  end;

var
  DM: TDM;

implementation

{$R *.lfm}

{ TDM }

procedure TDM.DataModuleCreate(Sender: TObject);
begin
  FCampoOrdenacao := 'id';
  FOrdemAscendente := True;
  FUltimoValor := '';

  if SQLTransaction1.Active then
    SQLTransaction1.Commit;

  SQLTransaction1.StartTransaction;
  try
    qryExec.SQL.Text :=
      'CREATE TABLE IF NOT EXISTS produtos (' +
      'id INTEGER PRIMARY KEY AUTOINCREMENT, ' +
      'nome VARCHAR(60) NOT NULL, ' +
      'preco NUMERIC NOT NULL, ' +
      'estoque NUMERIC NOT NULL' +
      ')';

    qryExec.ExecSQL;

    SQLTransaction1.Commit;
  except
    SQLTransaction1.Rollback;
    raise;
  end;

  qryProdutos.Close;
  qryProdutos.Open;


end;

function TDM.SepararValores(const Texto: string): TStringList;
var
  I: Integer;
begin
  Result := TStringList.Create;

  Result.Delimiter := ',';
  Result.StrictDelimiter := True;
  Result.DelimitedText := Texto;

  for I := Result.Count - 1 downto 0 do
  begin
    Result[I] := Trim(Result[I]);

    if Result[I] = '' then
      Result.Delete(I);
  end;
end;

function TDM.Inserir(const Produto: TProduto): Integer;
begin
  if SQLTransaction1.Active then
    SQLTransaction1.Commit;

  SQLTransaction1.StartTransaction;
  try
    qryExec.SQL.Text :=
      'INSERT INTO produtos (nome, preco, estoque) ' +
      'VALUES (:nome, :preco, :estoque)';

    qryExec.Params.ParamByName('nome').AsString := Produto.Nome;
    qryExec.Params.ParamByName('preco').AsCurrency := Produto.Preco;
    qryExec.Params.ParamByName('estoque').AsFloat := Produto.Estoque;

    qryExec.ExecSQL;

    qryExec.SQL.Text :=
      'SELECT last_insert_rowid() AS id';

    qryExec.Open;

    Result := qryExec.FieldByName('id').AsInteger;

    qryExec.Close;

    SQLTransaction1.Commit;

    qryProdutos.Close;
    qryProdutos.Open;

    qryProdutos.Locate('id', Result, []);
  except
    SQLTransaction1.Rollback;
    raise;
  end;
end;

procedure TDM.Atualizar(const Produto: TProduto);
begin
  if SQLTransaction1.Active then
    SQLTransaction1.Commit;

  SQLTransaction1.StartTransaction;
  try
    qryExec.SQL.Text :=
      'UPDATE produtos ' +
      'SET nome = :nome, preco = :preco, estoque = :estoque ' +
      'WHERE id = :id';

    qryExec.Params.ParamByName('id').AsInteger := Produto.ID;
    qryExec.Params.ParamByName('nome').AsString := Produto.Nome;
    qryExec.Params.ParamByName('preco').AsCurrency := Produto.Preco;
    qryExec.Params.ParamByName('estoque').AsFloat := Produto.Estoque;

    qryExec.ExecSQL;

    if qryExec.RowsAffected = 0 then
      raise Exception.Create('Produto não encontrado.');

    SQLTransaction1.Commit;

    qryProdutos.Close;
    qryProdutos.Open;

    qryProdutos.Locate('id', Produto.ID, []);
  except
    SQLTransaction1.Rollback;
    raise;
  end;
end;

procedure TDM.Excluir(ID: Integer);
begin
  if SQLTransaction1.Active then
    SQLTransaction1.Commit;

  SQLTransaction1.StartTransaction;
  try
    qryExec.SQL.Text :=
      'DELETE FROM produtos ' +
      'WHERE id = :id';

    qryExec.Params.ParamByName('id').AsInteger := ID;

    qryExec.ExecSQL;

    if qryExec.RowsAffected = 0 then
      raise Exception.Create('Produto não encontrado.');

    SQLTransaction1.Commit;

    qryProdutos.Close;
    qryProdutos.Open;
  except
    SQLTransaction1.Rollback;
    raise;
  end;
end;

procedure TDM.ConsultarProdutos( const Valor: string);
var
  Valores: TStringList;
  I: Integer;
  SQLWhere: string;
  OrdemSQL: string;
begin
  FUltimoValor := Valor;

  Valores := SepararValores(Valor);
  try
    SQLWhere := '';

    for I := 0 to Valores.Count - 1 do
    begin
      if SQLWhere <> '' then
        SQLWhere := SQLWhere + ' OR ';

      SQLWhere := SQLWhere +
        '(CAST(id AS TEXT) LIKE :p' + IntToStr(I) +
        ' OR nome LIKE :p' + IntToStr(I) + ')';
    end;

    case FCampoOrdenacao of
      'id':
        OrdemSQL := 'id';

      'nome':
        OrdemSQL := 'nome';

      'preco':
        OrdemSQL := 'preco';

      'estoque':
        OrdemSQL := 'estoque';

    else
      OrdemSQL := 'id';
    end;

    if FOrdemAscendente then
      OrdemSQL := OrdemSQL + ' ASC'
    else
      OrdemSQL := OrdemSQL + ' DESC';

    qryProdutos.Close;

    qryProdutos.SQL.Text :=
      'SELECT id, nome, ' +
      'CAST(preco AS REAL) AS preco, estoque ' +
      'FROM produtos';

    if SQLWhere <> '' then
      qryProdutos.SQL.Text :=
          qryProdutos.SQL.Text +
          ' WHERE ' + SQLWhere;

    qryProdutos.SQL.Text :=
      qryProdutos.SQL.Text +
      ' ORDER BY ' + OrdemSQL;

    for I := 0 to Valores.Count - 1 do
    begin
      qryProdutos.Params.ParamByName('p' + IntToStr(I)).AsString :=
        '%' + Valores[I] + '%';
    end;

    qryProdutos.Open;

  finally
    Valores.Free;
  end;

end;

procedure TDM.LimparConsulta;
var
  OrdemSQL: string;
begin
  case FCampoOrdenacao of
    'id':
      OrdemSQL := 'id';

    'nome':
      OrdemSQL := 'nome';

    'preco':
      OrdemSQL := 'preco';

    'estoque':
      OrdemSQL := 'estoque';

  else
    OrdemSQL := 'id';
  end;

  if FOrdemAscendente then
    OrdemSQL := OrdemSQL + ' ASC'
  else
    OrdemSQL := OrdemSQL + ' DESC';

  qryProdutos.Close;

  qryProdutos.SQL.Text :=
    'SELECT id, nome, ' +
    'CAST(preco AS REAL) AS preco, estoque ' +
    'FROM produtos ' +
    'ORDER BY ' + OrdemSQL;

  qryProdutos.Open;

  FUltimoValor := '';
end;

procedure TDM.OrdenarProdutos(const Campo: string; Ascendente: Boolean);
begin
  FCampoOrdenacao := Campo;
  FOrdemAscendente := Ascendente;

  ConsultarProdutos(FUltimoValor);
end;

function TDM.ConsultarNomes(const Valor: string): TStringList;
begin
  Result := TStringList.Create;

  qryExec.Close;

  qryExec.SQL.Text :=
    'SELECT id, nome, ' +
    '       printf(''%04d  %s'', id, nome) AS descricao ' +
    'FROM produtos ' +
    'WHERE nome LIKE :valor ' +
    'OR CAST(id AS TEXT) LIKE :valor ' +
    'OR printf(''%04d  %s'', id, nome) LIKE :valor ' +
    'ORDER BY nome ' +
    'LIMIT 3';

  qryExec.ParamByName('valor').AsString :=
    '%' + Trim(Valor) + '%';

  qryExec.Open;

  while not qryExec.EOF do
  begin
    Result.Add(Format('%.4d', [qryExec.FieldByName('id').AsInteger]) + '  ' + qryExec.FieldByName('nome').AsString);

    qryExec.Next;
  end;

  qryExec.Close;

end;

end.

