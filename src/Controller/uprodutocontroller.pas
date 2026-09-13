unit uProdutoController;

{$mode ObjFPC}{$H+}

interface

uses
  uProduto,
  uProdutoModel,
  uProdutoRepository;

type

  IProdutoController = interface
    ['{6967F884-3F7C-41FC-A3FF-5AFB4934D442}']
    //['{D6A3E5C2-7B91-4F08-9C34-2E8A6B51D7F0}']

    function Inserir(const Produto: TProduto): Integer;
    procedure Atualizar(const Produto: TProduto);
    procedure Excluir(ID: Integer);
    procedure ConsultarProdutos(const Valor: string);
    procedure LimparConsulta;
    procedure OrdenarProdutos(const Campo: string; Ascendente: Boolean);
  end;

  { TProdutoController }

  TProdutoController = class(TInterfacedObject, IProdutoController)
  private
    FModel: TProdutoModel;
    FRepository: IProdutoRepository;
  public
    constructor Create(const Repository: IProdutoRepository);
    destructor Destroy; override;

    function Inserir(const Produto: TProduto): Integer;
    procedure Atualizar(const Produto: TProduto);
    procedure Excluir(ID: Integer);
    procedure ConsultarProdutos(const Valor: string);
    procedure LimparConsulta;
    procedure OrdenarProdutos(const Campo: string; Ascendente: Boolean);

  end;

implementation

constructor TProdutoController.Create(
  const Repository: IProdutoRepository);
begin
  FModel := TProdutoModel.Create;
  FRepository := Repository;
end;

destructor TProdutoController.Destroy;
begin
  FModel.Free;
  inherited Destroy;
end;

function TProdutoController.Inserir(const Produto: TProduto): Integer;
begin
  FModel.Validar(Produto);
  Result := FRepository.Inserir(Produto);
end;

procedure TProdutoController.Atualizar(const Produto: TProduto);
begin
  FModel.Validar(Produto);
  FRepository.Atualizar(Produto);
end;

procedure TProdutoController.Excluir(ID: Integer);
begin
  FRepository.Excluir(ID);
end;

procedure TProdutoController.ConsultarProdutos(const Valor: string);
begin
  FRepository.ConsultarProdutos(Valor);
end;

procedure TProdutoController.LimparConsulta;
begin
  FRepository.LimparConsulta;
end;

procedure TProdutoController.OrdenarProdutos(const Campo: string; Ascendente: Boolean);
begin
  FRepository.OrdenarProdutos(Campo, Ascendente);
end;



end.
