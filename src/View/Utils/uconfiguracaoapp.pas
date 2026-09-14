unit uConfiguracaoApp;

{$mode ObjFPC}{$H+}

interface

function ArquivoConfiguracao: string;
procedure SalvarLarguraColuna(const NomeCampo: string; Largura: Integer);
function CarregarLarguraColuna(const NomeCampo: string;
  LarguraPadrao: Integer): Integer;

implementation

uses
  SysUtils,
  IniFiles,
  LazFileUtils;

function ArquivoConfiguracao: string;
begin
  Result := IncludeTrailingPathDelimiter(
    GetAppConfigDirUTF8(False, True)
  ) + 'Laboratorio_MVC.ini';
end;

procedure SalvarLarguraColuna(const NomeCampo: string; Largura: Integer);
var
  Config: TIniFile;
begin
  Config := TIniFile.Create(ArquivoConfiguracao);
  try
    Config.WriteInteger('Produto.Grid', NomeCampo, Largura);
  finally
    Config.Free;
  end;
end;

function CarregarLarguraColuna(const NomeCampo: string;
  LarguraPadrao: Integer): Integer;
var
  Config: TIniFile;
begin
  Config := TIniFile.Create(ArquivoConfiguracao);
  try
    Result := Config.ReadInteger(
      'Produto.Grid',
      NomeCampo,
      LarguraPadrao
    );
  finally
    Config.Free;
  end;
end;

end.
