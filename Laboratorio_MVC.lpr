{
program Laboratorio_MVC;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, uprincipal, uProduto, uProdutoModel, uProdutoRepository, uDM, uProdutoController, uProdutoForm;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  {$PUSH}{$WARN 5044 OFF}
  Application.MainFormOnTaskbar:=True;
  {$POP}
  Application.Initialize;
  Application.CreateForm(TDM, DM);
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.Run;
end.

}
program Laboratorio_MVC;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces,
  Forms, rxnew,
  uprincipal,
  uProduto,
  uProdutoModel,
  uProdutoRepository,
  uDM,
  uProdutoController,
  uProdutoForm, uAjuda, uNomeForm, uNomeController, uNomeRepository, uConfiguracaoApp;

{$R *.res}

var
  ProdutoController: IProdutoController;
  NomeController: INomeController;

begin
  RequireDerivedFormResource := True;
  Application.Scaled:=True;

  {$PUSH}{$WARN 5044 OFF}
  Application.MainFormOnTaskbar := True;
  {$POP}

  Application.Initialize;
  Application.CreateForm(TDM, DM);
  //Application.CreateForm(TfrmPrincipal, frmPrincipal);

  ProdutoController := TProdutoController.Create(DM);
  NomeController := TNomeController.Create(DM);

  frmPrincipal := TfrmPrincipal.Create(nil, ProdutoController, NomeController);
  frmPrincipal.Show;
  Application.Run;
end.

