unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ExtDlgs, JPeg, Menus;

type
  TForm2 = class(TForm)
    ListBox1: TListBox;
    ListBox2: TListBox;
    Panel2: TPanel;
    Image1: TImage;
    Image3: TImage;
    Image2: TImage;
    procedure listarMusica(caminho:String);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Image1Click(Sender: TObject);
    procedure Image2Click(Sender: TObject);
    procedure Image3Click(Sender: TObject);
    function RemoveExtensao(filename:TFilename):string;
  private
    { Private declarations }
  public
    { Public declarations }
    caminhoNomeMusica: string;
  end;

var
  Form2: TForm2;
  quantidade: Boolean = false;

implementation

uses Unit1;
{$R *.dfm}

// percorre o caminho do album para encontrar os arquivos que estiverem com a iniciais '.m'(mp3)
procedure TForm2.listarMusica(caminho: String);
var
  SR: TSearchRec;
  I: Integer;
  extensao,aux,nome: String;
begin
  I := FindFirst(caminho+'*.m*', faAnyFile, SR);
while I = 0 do
  begin
    if (SR.Attr and faDirectory) <> faDirectory then
      begin
        nome :=  ChangeFileExt(Sr.Name,'');
        ListBox1.Items.Add(nome);
        I := FindNext(SR);
      end;
  end;
end;

procedure TForm2.FormShow(Sender: TObject);
begin
  listarMusica(caminhoNomeMusica);
end;

procedure TForm2.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   ListBox1.Clear;
   if quantidade = True then
   begin
    Form1.ListBox1.Selected[0] := true;
    Form1.ListBox2.Selected[0] := true;
    form1.posicaoAberto := False;
    form1.estado := true;
    form1.executarMusica;

   end
   else
   begin
     // caso nao a quantidade esteja false, nao vai selecionar nada no form1
   end;

end;

procedure TForm2.Image1Click(Sender: TObject);
var
   i : integer;
begin
   for i:= 0 to ListBox1.Items.Count-1 do
   begin
      if ListBox1.Selected[I] then
      begin
         Form1.ListBox1.Items.Add(ListBox1.Items[I]);
         Form1.ListBox2.Items.Add(caminhoNomeMusica);
         quantidade := true;//se for verdadeiro vai retornar os valores do listbox no form1
      end
   end;
end;

procedure TForm2.Image2Click(Sender: TObject);
begin
  keybd_event(VK_UP, 0, 0, 0);// Pressiona para esquerda
end;

procedure TForm2.Image3Click(Sender: TObject);
begin
  keybd_event(VK_DOWN, 0, 0, 0);// Pressiona para direita
end;

function TForm2.RemoveExtensao(filename: TFilename): string;
begin
    result:= ChangeFileExt(filename,'.mp3');
end;

end.
