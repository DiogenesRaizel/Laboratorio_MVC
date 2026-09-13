unit uNomeRepository;

{$mode ObjFPC}{$H+}

interface

uses
  Classes;

type

  INomeRepository = interface
    ['{DDE7F171-9C9A-429F-A754-9F4C4E12E55D}']

    function ConsultarNomes(const Valor: string): TStringList;

  end;

implementation

end.
