unit uPedidoController;

{$mode ObjFPC}{$H+}

interface

type

  IPedidoController = interface
    ['{5DB2B34E-7530-4610-9A03-16BDF8FBE687}']

    procedure ConsultarNomes(const Valor: string);
    procedure LimparConsulta;

  end;

implementation

end.
