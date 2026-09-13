unit uAjuda;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls, LMessages, LCLType;

type

  { TfrmAjuda }

  TfrmAjuda = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    Panel1: TPanel;
    procedure Button1Click(Sender: TObject);
    procedure FormShortCut(var Msg: TLMKey; var Handled: Boolean);
    procedure Memo1Change(Sender: TObject);
  private

  public

  end;

var
  frmAjuda: TfrmAjuda;

implementation

{$R *.lfm}

{ TfrmAjuda }

procedure TfrmAjuda.Button1Click(Sender: TObject);
begin

end;

procedure TfrmAjuda.FormShortCut(var Msg: TLMKey; var Handled: Boolean);
begin
  Handled := False;

  if Msg.CharCode = VK_ESCAPE then
  begin
    ModalResult := mrCancel;
    Handled := True;
  end;

end;

procedure TfrmAjuda.Memo1Change(Sender: TObject);
begin

end;

end.

