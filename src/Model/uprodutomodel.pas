unit uProdutoModel;

{$mode ObjFPC}{$H+}

interface

uses
  SysUtils,
  uProduto;

type
  TProdutoModel = class
  public
    procedure Validar(const Produto: TProduto);
  end;

implementation

procedure TProdutoModel.Validar(const Produto: TProduto);
begin
  if Produto = nil then
    raise Exception.Create('Produto não informado.');

  if Trim(Produto.Nome) = '' then
    raise Exception.Create('O nome do produto é obrigatório.');

  if Produto.Preco < 0 then
    raise Exception.Create('O preço do produto não pode ser negativo.');

  if Produto.Estoque < 0 then
    raise Exception.Create('O estoque do produto não pode ser negativo.');
end;

end.
