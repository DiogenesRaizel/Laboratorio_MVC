unit uProduto;

{$mode ObjFPC}{$H+}

interface

type
  TProduto = class
  private
    FID: Integer;
    FNome: string;
    FPreco: Currency;
    FEstoque: Double;

  public
    property ID: Integer read FID write FID;
    property Nome: string read FNome write FNome;
    property Preco: Currency read FPreco write FPreco;
    property Estoque: Double read FEstoque write FEstoque;
  end;

implementation

end.

