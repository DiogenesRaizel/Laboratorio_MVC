unit uProdutoForm;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, DB, Forms, Controls, Dialogs,
  StdCtrls, ComCtrls, DBGrids, MaskEdit, ExtCtrls, rxcurredit, LCLType,
  uProdutoController, LMessages,
  uProduto,
  uAjuda;

type

  { TfrmProduto }

  TfrmProduto = class(TForm)
    btnAlterar: TButton;
    btnCancelar: TButton;
    btnExcluir: TButton;
    btnLimpar: TButton;
    btnNovo: TButton;
    btnSalvar: TButton;
    edtConsulta: TEdit;

    edtEstoque: TCurrencyEdit;
    edtPreco: TCurrencyEdit;

    DataSource1: TDataSource;
    DBGrid1: TDBGrid;

    edtNome: TEdit;

    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;


    PageControl1: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    StatusBar1: TStatusBar;

    tsTabela: TTabSheet;
    tsCadastro: TTabSheet;

    procedure btnAlterarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure btnNovoClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure btnLimparClick(Sender: TObject);
    procedure DBGrid1TitleClick(Column: TColumn);
    procedure edtConsultaChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShortCut(var Msg: TLMKey; var Handled: Boolean);
  private
    FController: IProdutoController;
    FModoCadastro: (mcNavegando, mcInclusao, mcEdicao);
    FIdEdicao: Integer;
    FfrmAjuda: TfrmAjuda;
    FColunaOrdenacao: string;
    FOrdemAscendente: Boolean;

    FTitulosColunas: TStringList;


    procedure AtualizarEstadoBotoes;
    procedure AtualizarStatus(const Texto: string);
    procedure ExecutarConsulta;

    procedure AtualizarTitulosOrdenacao;

  public
    constructor Create(AOwner: TComponent; const Controller: IProdutoController ); reintroduce;
    function PodeFechar: Boolean;

  end;

var
  frmProduto: TfrmProduto;

implementation

{$R *.lfm}

{ TfrmProduto }

procedure TfrmProduto.btnSalvarClick(Sender: TObject);
var
  Produto: TProduto;
begin
  Produto := TProduto.Create;
  try
    Produto.Nome := edtNome.Text;
    Produto.Preco := edtPreco.Value;
    Produto.Estoque := edtEstoque.Value;

    case FModoCadastro of

      mcInclusao:
        begin
          Produto.ID := FController.Inserir(Produto);

          AtualizarStatus(
            'Produto inserido com sucesso. ID: ' +
            IntToStr(Produto.ID)
          );
        end;

      mcEdicao:
        begin
          Produto.ID := FIdEdicao;

          FController.Atualizar(Produto);

          AtualizarStatus(
            'Produto ID ' + IntToStr(Produto.ID) +
            ' atualizado com sucesso.'
          );
        end;

    end;

    FModoCadastro := mcNavegando;
    PageControl1.ActivePage := tsTabela;

  finally
    Produto.Free;

  end;
end;

procedure TfrmProduto.btnLimparClick(Sender: TObject);
begin
  edtConsulta.Clear;

  FController.LimparConsulta;
  AtualizarTitulosOrdenacao;

  AtualizarStatus('Navegando.');
  AtualizarEstadoBotoes;
end;

procedure TfrmProduto.DBGrid1TitleClick(Column: TColumn);
begin
if FColunaOrdenacao = Column.FieldName then
  FOrdemAscendente := not FOrdemAscendente
else
begin
  FColunaOrdenacao := Column.FieldName;
  FOrdemAscendente := True;
end;

FController.OrdenarProdutos(
  FColunaOrdenacao,
  FOrdemAscendente
);

AtualizarTitulosOrdenacao;
end;

procedure TfrmProduto.edtConsultaChange(Sender: TObject);
begin
  if Trim(edtConsulta.Text) = '' then
  begin
    FController.LimparConsulta;
    AtualizarTitulosOrdenacao;
    AtualizarStatus('Navegando.');
    AtualizarEstadoBotoes;
    Exit;
  end;

  if Length(Trim(edtConsulta.Text)) < 2 then
    Exit;

  ExecutarConsulta;
end;

procedure TfrmProduto.FormDestroy(Sender: TObject);
begin
  FTitulosColunas.Free;
end;

procedure TfrmProduto.FormShortCut(var Msg: TLMKey; var Handled: Boolean);
begin
  Handled := False;

  { Atalhos com Ctrl }
  if ssCtrl in KeyDataToShiftState(Msg.KeyData) then
  begin
    case Msg.CharCode of

      Ord('L'):
        begin
          if PageControl1.ActivePage = tsTabela then
          begin
            btnLimparClick(btnLimpar);
            Handled := True;
          end;
        end;

      Ord('S'):
        begin
          if PageControl1.ActivePage = tsCadastro then
          begin
            btnSalvarClick(btnSalvar);
            Handled := True;
          end;
        end;

    end;

    Exit;
  end;

  { Atalhos sem Ctrl }
  case Msg.CharCode of

    VK_F1:
    begin
      if not Assigned(FfrmAjuda) then
        FfrmAjuda := TfrmAjuda.Create(Self);

      FfrmAjuda.ShowModal;
      Handled := True;
    end;

    VK_INSERT:
      begin
        if PageControl1.ActivePage = tsTabela then
        begin
          btnNovoClick(btnNovo);
          Handled := True;
        end;
      end;

    VK_F2:
      begin
        if PageControl1.ActivePage = tsTabela then
        begin
          btnAlterarClick(btnAlterar);
          Handled := True;
        end;
      end;

    VK_DELETE:
      begin
        if PageControl1.ActivePage <> tsTabela then
          Exit;

        if edtConsulta.Focused then
          Exit;

        btnExcluirClick(btnExcluir);
        Handled := True;
      end;

    VK_F3:
      begin
        if PageControl1.ActivePage = tsTabela then
        begin
          edtConsulta.SetFocus;
          Handled := True;
        end;
      end;

    VK_F4:
      begin
        if PageControl1.ActivePage = tsTabela then
        begin
          DBGrid1.SetFocus;
          Handled := True;
        end;
      end;


    VK_RETURN:
      begin
        if not DataSource1.DataSet.IsEmpty then
        begin
          DBGrid1.SetFocus;
          Handled := True;
        end;
      end;

    VK_ESCAPE:
      begin
        if PageControl1.ActivePage = tsCadastro then
        begin
          btnCancelarClick(btnCancelar);
          Handled := True;
        end
      end;

  end;
end;

procedure TfrmProduto.AtualizarEstadoBotoes;
begin
  btnAlterar.Enabled :=
    not DataSource1.DataSet.IsEmpty;

  btnExcluir.Enabled :=
    not DataSource1.DataSet.IsEmpty;

  btnLimpar.Enabled :=
    Trim(edtConsulta.Text) <> '';
end;

procedure TfrmProduto.AtualizarStatus(
  const Texto: string
);
begin
  StatusBar1.SimpleText := Texto;
end;

procedure TfrmProduto.ExecutarConsulta;
begin
  FController.ConsultarProdutos(edtConsulta.Text);

  AtualizarTitulosOrdenacao;

  if DataSource1.DataSet.IsEmpty then
    AtualizarStatus('Nenhum produto encontrado.')
  else
    AtualizarStatus('Navegando.');

  AtualizarEstadoBotoes;
end;

procedure TfrmProduto.AtualizarTitulosOrdenacao;
var
  I: Integer;
begin
  for I := 0 to DBGrid1.Columns.Count - 1 do
  begin
    if DBGrid1.Columns[I].FieldName = FColunaOrdenacao then
    begin

      if FOrdemAscendente then
        DBGrid1.Columns[I].Title.Caption :=
          '↑ ' + FTitulosColunas[I]
      else
        DBGrid1.Columns[I].Title.Caption :=
          '↓ ' + FTitulosColunas[I];
    end
    else
      DBGrid1.Columns[I].Title.Caption :=
        FTitulosColunas[I];
  end;
end;

procedure TfrmProduto.btnExcluirClick(Sender: TObject);
var
  ID: Integer;
begin
  ID :=
    DataSource1.DataSet.FieldByName('id').AsInteger;

  if MessageDlg(
    'Deseja realmente excluir o produto selecionado?',
    mtConfirmation,
    [mbYes, mbNo],
    0
  ) <> mrYes then
    Exit;

  try
    FController.Excluir(ID);

    AtualizarStatus(
      'Produto ID ' + IntToStr(ID) +
      ' excluído com sucesso.'
    );

    AtualizarEstadoBotoes;

  except
    on E: Exception do
      MessageDlg(
        E.Message,
        mtWarning,
        [mbOK],
        0
      );
  end;
end;

procedure TfrmProduto.btnAlterarClick(Sender: TObject);
begin
  FModoCadastro := mcEdicao;

  FIdEdicao :=
    DataSource1.DataSet.FieldByName('id').AsInteger;


  edtNome.Text :=
    DataSource1.DataSet.FieldByName('nome').AsString;

  edtPreco.Text :=
    CurrToStr(
      DataSource1.DataSet.FieldByName('preco').AsCurrency
    );

  edtEstoque.Text :=
    FloatToStr(
      DataSource1.DataSet.FieldByName('estoque').AsFloat
    );

  PageControl1.ActivePage := tsCadastro;

  edtNome.SetFocus;

  AtualizarStatus('Editando');
end;

procedure TfrmProduto.btnCancelarClick(Sender: TObject);
begin
  PageControl1.ActivePage := tsTabela;
  FModoCadastro:= mcNavegando;

  AtualizarStatus('Navegando');
end;

procedure TfrmProduto.btnNovoClick(Sender: TObject);
begin
  FModoCadastro := mcInclusao;

  FIdEdicao := 0;


  edtNome.Clear;
  edtPreco.Clear;
  edtEstoque.Clear;

  PageControl1.ActivePage := tsCadastro;

  AtualizarStatus('Incluindo');

  edtNome.SetFocus;
end;

constructor TfrmProduto.Create(
  AOwner: TComponent;
  const Controller: IProdutoController
);
var
  I: Integer;
begin
  inherited Create(AOwner);

  FController := Controller;

  FTitulosColunas := TStringList.Create;

  for I := 0 to DBGrid1.Columns.Count - 1 do
    FTitulosColunas.Add(DBGrid1.Columns[I].Title.Caption);

  PageControl1.ShowTabs := False;
  PageControl1.ActivePage := tsTabela;

  DefaultFormatSettings.DecimalSeparator := ',';
  DefaultFormatSettings.ThousandSeparator := '.';

  AtualizarEstadoBotoes;

  FModoCadastro := mcNavegando;

  FColunaOrdenacao := 'id';
  FOrdemAscendente := True;

  edtPreco.DecimalPlaces := 2;
  edtPreco.DisplayFormat := 'R$ ,0.00';

  edtEstoque.DecimalPlaces := 0;
  edtEstoque.DisplayFormat := ',0';
end;

function TfrmProduto.PodeFechar: Boolean;
begin
  if FModoCadastro = mcNavegando then
    Exit(True);

  Result := MessageDlg(
    'Existem dados em edição. Deseja fechar?',
    mtConfirmation,
    [mbYes, mbNo],
    0
  ) = mrYes;
end;


end.


