unit uNomeController;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils,
  uNomeRepository;

type

  INomeController = interface
    ['{C76EA2B7-F815-49EC-87C4-D61268447329}']

    function ConsultarNomes(const Valor: string): TStringList;
  end;

  { TNomeController }

  TNomeController = class(TInterfacedObject, INomeController)
  private
    FRepository: INomeRepository;
  public
    constructor Create(const Repository: INomeRepository);

    function ConsultarNomes(const Valor: string): TStringList;
  end;

implementation

constructor TNomeController.Create(
  const Repository: INomeRepository);
begin
  inherited Create;
  FRepository := Repository;
end;

function TNomeController.ConsultarNomes(
  const Valor: string): TStringList;
begin
  Result := FRepository.ConsultarNomes(Valor);
end;

end.
