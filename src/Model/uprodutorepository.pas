unit uProdutoRepository;

{$mode ObjFPC}{$H+}

interface

uses
  uProduto;

type

  IProdutoRepository = interface
  ['{B6CC65AD-183E-4F90-AE59-C562104E993E}']

    function Inserir(const Produto: TProduto): Integer;
    procedure Atualizar(const Produto: TProduto);
    procedure Excluir(ID: Integer);
    procedure ConsultarProdutos(const Valor: string);
    procedure LimparConsulta;
    procedure OrdenarProdutos(const Campo: string; Ascendente: Boolean);

  end;

implementation

end.
