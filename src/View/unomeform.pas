unit uNomeForm;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, LCLType,
  uNomeController;

type

  { TfrmNome }

  TfrmNome = class(TForm)
    edtNome: TEdit;
    Label1: TLabel;
    lbNomeAutoComplete: TListBox;
    procedure edtNomeChange(Sender: TObject);
    procedure edtNomeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lbNomeAutoCompleteClick(Sender: TObject);
  private
    FController: INomeController;
  public
    constructor Create(AOwner: TComponent;
      const Controller: INomeController); reintroduce;
  end;

var
  frmNome: TfrmNome;

implementation

{$R *.lfm}

{ TfrmNome }

procedure TfrmNome.edtNomeChange(Sender: TObject);
var
  Nomes: TStringList;
  I: Integer;
begin
  lbNomeAutoComplete.Items.Clear;

  if Trim(edtNome.Text) = '' then
  begin
    lbNomeAutoComplete.Visible := False;
    Exit;
  end;

  Nomes := FController.ConsultarNomes(edtNome.Text);
  try
    for I := 0 to Nomes.Count - 1 do
      lbNomeAutoComplete.Items.Add(Nomes[I]);
  finally
    Nomes.Free;
  end;

  lbNomeAutoComplete.Visible :=
    lbNomeAutoComplete.Count > 0;

  if lbNomeAutoComplete.Visible then
  begin
    lbNomeAutoComplete.Left := edtNome.Left;
    lbNomeAutoComplete.Top :=
      edtNome.Top + edtNome.Height;
    lbNomeAutoComplete.Width := edtNome.Width;
  end;
end;

procedure TfrmNome.edtNomeKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if not lbNomeAutoComplete.Visible then
    Exit;

  case Key of

    VK_DOWN:
      begin
        if lbNomeAutoComplete.ItemIndex <
           lbNomeAutoComplete.Count - 1 then
          lbNomeAutoComplete.ItemIndex :=
            lbNomeAutoComplete.ItemIndex + 1;

        Key := 0;
      end;

    VK_UP:
      begin
        if lbNomeAutoComplete.ItemIndex > 0 then
          lbNomeAutoComplete.ItemIndex :=
            lbNomeAutoComplete.ItemIndex - 1;

        Key := 0;
      end;

    VK_RETURN:
      begin
        if lbNomeAutoComplete.ItemIndex >= 0 then
        begin
          edtNome.Text :=
            lbNomeAutoComplete.Items[
              lbNomeAutoComplete.ItemIndex];

          lbNomeAutoComplete.Visible := False;
          Key := 0;

          edtNome.SelStart := Length(edtNome.Text);
          edtNome.SelLength := 0;
        end;
      end;

    VK_ESCAPE:
      begin
        lbNomeAutoComplete.Visible := False;
        Key := 0;
      end;

  end;
end;

procedure TfrmNome.lbNomeAutoCompleteClick(Sender: TObject);
begin
  if lbNomeAutoComplete.ItemIndex >= 0 then
  begin
    edtNome.Text :=
      lbNomeAutoComplete.Items[
        lbNomeAutoComplete.ItemIndex];

    lbNomeAutoComplete.Visible := False;
  end;
end;

constructor TfrmNome.Create(AOwner: TComponent;
  const Controller: INomeController);
begin
  inherited Create(AOwner);

  FController := Controller;

  lbNomeAutoComplete.Visible := False;
end;

end.
