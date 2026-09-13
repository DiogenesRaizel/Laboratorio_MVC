unit uprincipal;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Dialogs, Menus, ComCtrls,
  uProdutoController,
  uProdutoForm,
  uAjuda,
  uNomeForm,
  uNomeController;

type

  { TfrmPrincipal }

  TfrmPrincipal = class(TForm)
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    miNome: TMenuItem;
    miProduto: TMenuItem;
    miAjuda: TMenuItem;
    miAtalhosTeclado: TMenuItem;
    PageControl1: TPageControl;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure miNomeClick(Sender: TObject);
    procedure miProdutoClick(Sender: TObject);
    procedure miAtalhosTecladoClick(Sender: TObject);
    procedure PageControl1CloseTabClicked(Sender: TObject);
  private
    FController: IProdutoController;
    FfrmAjuda: TfrmAjuda;
    FfrmProduto: TfrmProduto;
    FfrmNome: TfrmNome;
    FNomeController: INomeController;
    FProdutoAba: TTabSheet;
    FNomeAba: TTabSheet;

  public
    constructor Create(AOwner: TComponent;
      const Controller: IProdutoController;
      const NomeController: INomeController); reintroduce;
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.lfm}

procedure TfrmPrincipal.PageControl1CloseTabClicked(Sender: TObject);
var
  Aba: TTabSheet;
begin
  if not (Sender is TTabSheet) then
    Exit;

  Aba := TTabSheet(Sender);

  if Aba = FNomeAba then
  begin
    FfrmNome.Free;
    FfrmNome := nil;
    FNomeAba.Free;
    FNomeAba := nil;
  end
  else
  if Aba = FProdutoAba then
  begin
    if not FfrmProduto.PodeFechar then
      Exit;
    FfrmProduto.Free;
    FfrmProduto := nil;
    FProdutoAba.Free;
    FProdutoAba := nil;
  end;
end;

procedure TfrmPrincipal.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CloseAction := caFree;
  Application.Terminate;
end;

procedure TfrmPrincipal.miNomeClick(Sender: TObject);
begin
  if not Assigned(FfrmNome) then
  begin
    FNomeAba := TTabSheet.Create(PageControl1);
    FNomeAba.PageControl := PageControl1;
    FNomeAba.Caption := 'Nome';

    FfrmNome := TfrmNome.Create(Self, FNomeController);

    FfrmNome.BorderStyle := bsNone;
    FfrmNome.Parent := FNomeAba;
    FfrmNome.Align := alClient;
  end;

  PageControl1.ActivePage := FNomeAba;
  FfrmNome.Show;
end;

procedure TfrmPrincipal.miProdutoClick(Sender: TObject);
begin
  if not Assigned(FfrmProduto) then
  begin
    FProdutoAba := TTabSheet.Create(PageControl1);
    FProdutoAba.PageControl := PageControl1;
    FProdutoAba.Caption := 'Produto';

    FfrmProduto := TfrmProduto.Create(Self, FController);

    FfrmProduto.BorderStyle := bsNone;
    FfrmProduto.Parent := FProdutoAba;
    FfrmProduto.Align := alClient;

  end;

  PageControl1.ActivePage := FProdutoAba;
  FfrmProduto.Show;
end;

procedure TfrmPrincipal.miAtalhosTecladoClick(Sender: TObject);
begin
  if not Assigned(FfrmAjuda) then
    FfrmAjuda := TfrmAjuda.Create(Self);

  FfrmAjuda.ShowModal;
end;

constructor TfrmPrincipal.Create(AOwner: TComponent;
  const Controller: IProdutoController;
  const NomeController: INomeController);
begin
  inherited Create(AOwner);
  FController := Controller;
  FNomeController:= NomeController;
end;

end.
