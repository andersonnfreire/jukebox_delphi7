unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Unit2,JPeg, ComCtrls, MPlayer, ImgList;

type
  TImageAlbum = class (TImage)

  private

  public
    caminhoDiretorio:String;//caso o clique for na imagem e passado o diretorio do album.
  end;
type
  TPanelAlbum = class(TPanel)

  private

  public
    caminhoDiretorioPanel: String;//caso o clique for no panel e passado o diretorio do album
  end;

type
  TForm1 = class(TForm)
    ScrollBox1: TScrollBox;
    ListBox1: TListBox;
    ListBox2: TListBox;
    MediaPlayer1: TMediaPlayer;
    Timer1: TTimer;
    ProgressBar1: TProgressBar;
    Panel8: TPanel;
    Panel2: TPanel;
    Panel4: TPanel;
    tempoTotal: TPanel;
    tempoInicial: TPanel;
    Image1: TImage;
    esquerda: TImage;
    direita: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Button1: TButton;
    procedure criarBotao(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure direitaClick(Sender: TObject);
    procedure esquerdaClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure MudancaDeFoco(Sender: TObject);
    procedure SemFoco(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure executarMusica;

  private
    { Private declarations }
  public
    { Public declarations }
     estado: Boolean;
     posicaoAberto:Boolean;
    procedure MapeiaDiretorio(Caminho: String);
    function MapeiaSubDiretorio(Caminho: String): Boolean;
    function MSecToTime(const intTime: integer):string;
    procedure executarImage(Sender:TObject);
    procedure salvarPrograma;
    procedure abrirPrograma;


  end;

var
  Form1: TForm1;
  count: Integer = 0;
  posTop: Integer = 0;
  posLeft : Integer = 0;
  num: Integer = 0;
  diretorio: String;
  valor: Boolean;
  FocoDiretorio: String;
  nomeDiretorioMusica: String;
  nomeDiretorioPasta: String;


  caminhoImagem : tstringlist;
  recuperandoDados: TStringList;
  tempoMusica: String;
  topTop: Integer;
  topLeft: Integer;

  numPrime :Integer = 0;
  tabOr : Integer;
  estadoPanel: Boolean = false;

  acabou: Boolean = false;

  procede: Boolean = false;
  terminou: Boolean = false;

implementation

uses Math;

{$R *.dfm}

// mapeando o diretorio atual e logo em seguida o seus subdiretorios para encontrar o a capa dos albuns
procedure TForm1.MapeiaDiretorio(Caminho: String);
var
  Search: TSearchRec;
  Retorno, I: Integer;
  Achou: Boolean;
begin
  Achou := False;
  Retorno := FindFirst(Caminho + '*.*', faDirectory, Search);

    repeat
    if Search.Name = '*.*' then
        begin
        Achou := True;
        end
    else if (Search.Name[1] <> '.') and ((Search.Attr and faDirectory) = faDirectory) then
      Achou := MapeiaSubDiretorio(Caminho + Search.Name + '\');

    if not(Achou) then
      Retorno := FindNext(Search);
    until (Retorno  <> 0) or Achou;
end;

function TForm1.MapeiaSubDiretorio(Caminho: String): Boolean;
var
  Search: TSearchRec;
  Retorno,i :Integer;
begin

  Retorno := FindFirst(Caminho + '*.*', faDirectory, Search);

  if (FindFirst(Caminho + '*.bmp*', faDirectory, Search) = 0)  then
     repeat
        caminhoImagem.Add(Caminho+Search.Name);
     Until FindNext(Search) <> 0
end;

procedure TForm1.criarBotao(Sender: TObject);
var
  P : TPanelAlbum;
    I : TImageAlbum;
  j: Integer;
begin

    for j := 0 to caminhoImagem.Count-1 do
    begin
      
      if count >= 3 then
      begin
       // caso o panel for maior ou 3 e feito o calculo para redirecionar para baixo.
        posTop    := posTop + 170;
        count     := 0;
        posLeft   := 0;
      end;
      Inc(num);
      P                 := TPanelAlbum.Create(ScrollBox1);
      P.Parent          := ScrollBox1;
      P.Top             := posTop + 5;
      P.Left            := posLeft +10;
      P.Height          := 137;
      P.Width           := 185;
      posLeft           := P.Left + P.Width+20;
      P.Name            := 'Album'+inttostr(num);
      P.TabOrder        := num;
      P.Tag             := num;
      P.TabStop         := true;
      P.OnEnter         := MudancaDeFoco;
      P.OnExit          := SemFoco;
      
      i                       := TImageAlbum.Create(p);
      i.Parent                := p;
      i.Top                   := 5;
      i.Height                := 125;
      i.Width                 := 170;
      i.Left                  := 5;
      i.Visible               := true;
      i.Picture.LoadFromFile(caminhoImagem[j]);
      i.caminhoDiretorio      := ExtractFilePath(caminhoImagem[j]);
      i.OnClick               := executarImage;
      
      P.caminhoDiretorioPanel := ExtractFilePath(caminhoImagem[j]);
      P.OnClick               := executarImage;
      i.Stretch               := True;
      i.Tag                   := num;
      i.Name                  := 'Image'+inttostr(num);
      Inc(count);
    end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
I:Integer;
begin
  caminhoImagem := TStringList.Create;
  recuperandoDados := TStringList.Create;

  //caminho do projeto
   diretorio := ExtractFilePath(Application.ExeName);

   //mapeando o diretorio do projeto em busca da imagem de capa
   MapeiaDiretorio(diretorio);
   //criar panel e imagem
   criarBotao(sender);

   

end;
procedure TForm1.ListBox1Click(Sender: TObject);
var
   i : integer;
begin
   for i:= 0 to ListBox1.Items.Count-1 do
   begin
      // selecionando o listbox 1, o listbox2 será selecionado tambem
      if ListBox1.Selected[I] then
      begin
        ListBox2.ItemIndex := I;
      end
   end;
end;

function TForm1.MSecToTime(const intTime: integer): string;
var intmsec :real;
//o equivalente a 1 ms
begin
  intMSec := 1 / 24 / 60 / 60 / 1000;
//define o retorno com o formato Time
  result := formatdatetime('tt', intTime * intmsec);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
i,valor,a: Integer;

begin
  if estado = false then
  begin
     tempoInicial.Caption := MSecToTime (MediaPlayer1.Position);// //Mostra o tempo correndo da musica selecionada dos albuns(caso nao tenha musica no arquivo txt)
  end
  else
  begin
    //Mostra o tempo correndo ao abrir o arquivo com musica
    tempoInicial.Caption := MSecToTime(MediaPlayer1.Position);
    acabou := true;
  end;
  
  if  ProgressBar1.Max <> 0 then
  begin
    //tocando a musica e recebendo a sua posicao. 
    ProgressBar1.Position := MediaPlayer1.Position;
    MediaPlayer1.Play;
  end;
    if (ProgressBar1.Position = MediaPlayer1.Length) then
       begin
          // fechando a musica e desmarcando a musica para excluir da lista.
          MediaPlayer1.Close;
          ListBox1.DeleteSelected;
          ListBox2.DeleteSelected;
          if(listbox1.Count > 0 ) then
          begin
           // passo feito depois de executar a primeira musica.
              ListBox1.Selected[0] := true;
              ListBox2.Selected[0] := true;
              nomeDiretorioMusica := ListBox1.Items.Strings[0];
              nomeDiretorioPasta := ListBox2.Items.Strings[0];
              MediaPlayer1.FileName := nomeDiretorioPasta + nomeDiretorioMusica+'.mp3';
              MediaPlayer1.Open;
              MediaPlayer1.Play;
              ProgressBar1.Max := MediaPlayer1.Length;
          end
          else
          begin
            // se caso a ultima musica encerre e não tem outra a seguir.
            Timer1.Enabled := false;
            ProgressBar1.CleanupInstance;
            MediaPlayer1.Close;
            ProgressBar1.Max := 0;
            ListBox1.Clear;
            ListBox2.Clear;
            terminou := true;
          end;
          if (acabou = true) or (terminou = true) then
           begin
             tempoInicial.Caption := '00:00:00';
             // zera o cronomentro da musica;
           end;
       end;

end;

procedure TForm1.direitaClick(Sender: TObject);
begin
  keybd_event(VK_TAB, 0, 0, 0);// simular o pressionamento da seta do teclado para direita
end;

procedure TForm1.esquerdaClick(Sender: TObject);
begin
   keybd_event(VK_LEFT, 0, 0, 0);// simular o pressionamento da seta do teclado para esquerda
end;

procedure TForm1.salvarPrograma;
var
  F: TextFile;
  i: Integer;
  cLinha: string;
  caminho: string;
begin
  caminho := extractFilepath(application.exename);
  AssignFile(F, caminho+'\'+'musicas.txt');
  cLinha := '';

  // salvando os dados da musica no arquivo txt
  if FileExists('musicas.txt') then
    begin
      Rewrite(F);
      for i := 0 to ListBox1.Count-1 do
      begin
        //nome da pasta
        Writeln(F, 'Pasta:'+ListBox2.Items[i]+';');
        //nome da musica
        Writeln(F, 'Musica:'+ListBox1.Items[i]+';');
        // salvando a posicao em que a musica parou
        Writeln(F, 'Tempo:'+IntToStr(MediaPlayer1.Position)+';');
      end;
    end;
  Closefile(F);
end;

procedure TForm1.abrirPrograma;
var
  Linhas, Ambiente:TStringList;
  caminho, nomeDiretorio: string;
  i,j,k,pasta,tempo,musica, tam:integer;
begin
  Linhas := TStringList.Create;
  Ambiente := TStringList.Create;
  try
    caminho := extractFilepath(application.exename);
    Linhas.LoadFromFile(caminho+'\'+'musicas.txt'); //Carregando arquivo
    for i := 0 to Pred(Linhas.Count) do
    begin
      {Transformando os dados das colunas em Linhas}
      Ambiente.text := StringReplace(Linhas.Strings[i],';',#13,[rfReplaceAll]);
      for j := 0 to Pred(Ambiente.Count) do
      begin
        // colocando os dados do arquivo na lista
        recuperandoDados.Add(Ambiente.Strings[j]);
      end;
    end;
    for k := 0 to recuperandoDados.Count-1 do
    begin
        // verificando cada linha e recuperando os dados da musica (Pasta, Nome da musica e Tempo)
        pasta := POS(UPPERCASE('Pasta'), UPPERCASE(recuperandoDados[k]));
        if pasta <> 0 then
        begin
          tam := length(recuperandoDados[k]);
          ListBox2.Items.Add(copy(recuperandoDados[k],7,tam));
          tam:=0;
        end;

        tempo := POS(UPPERCASE('Tempo'), UPPERCASE(recuperandoDados[k]));
        if tempo <> 0 then
        begin
           tam := length(recuperandoDados[k]);
           tempoMusica := copy(recuperandoDados[k],7,tam);
           estado := True;
           posicaoAberto:= true;
           tam:=0;
        end;

        musica := POS(UPPERCASE('Musica'), UPPERCASE(recuperandoDados[k]));
        if musica <>0 then
        begin
          tam := length(recuperandoDados[k]);
          ListBox1.Items.Add(copy(recuperandoDados[k],8,tam));
          tam:=0;
        end;
    end;
  finally
    Linhas.Free;
    Ambiente.Free;
  end;
end;


procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    // ao fechar o programa e salvo os dados da musica
    salvarPrograma;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
   //recuperando os dados da musica
    abrirPrograma;
    executarMusica;
end;

procedure TForm1.MudancaDeFoco(Sender: TObject);
begin
  // mudando o foco do panel
  TPanelAlbum(Sender).Color:= $000080FF;
  // armazenando o foco
  valor := TPanelAlbum(Sender).Focused;
  // armazenando o top e left para fazer o calculo e assim direcionar a posicao do mouse
  topTop := TPanelAlbum(sender).Top;
  topLeft := TPanelAlbum(sender).Left;
  FocoDiretorio := TPanelAlbum(sender).caminhoDiretorioPanel;
end;

procedure TForm1.SemFoco(Sender: TObject);
begin
   // sem foco
   TPanelAlbum(Sender).Color:= clWhite;
end;

procedure TForm1.executarImage(Sender: TObject);
begin
   // se clicar na imagem ou no panel e passado o diretorio do album 
   if Sender is TPanelAlbum then
   begin
      Form2.caminhoNomeMusica :=  TPanelAlbum(sender).caminhoDiretorioPanel;
      Form2.Show;
   end
   else if Sender is TImageAlbum then
   begin
      Form2.caminhoNomeMusica :=  TImageAlbum(sender).caminhoDiretorio;
      Form2.Show;
   end;
end;

procedure TForm1.Image1Click(Sender: TObject);
begin
  if valor = true then
  begin
    Form2.caminhoNomeMusica :=  FocoDiretorio;
    Form2.Show;
  end;
end;
procedure TForm1.executarMusica;
begin
    if estado = true then
    begin
      ProgressBar1.Max := 0;
      MediaPlayer1.Close;
      //antes de executar a musica, e passado do listbox 1 e 2 o diretorio da musica e nome da pasta
      ListBox1.Selected[0] := true;
      ListBox2.Selected[0] := true;
      nomeDiretorioMusica := ListBox1.Items.Strings[ListBox1.ItemIndex];
      nomeDiretorioPasta := ListBox2.Items.Strings[ListBox2.ItemIndex];
      //acrescenta o .mp3 para executar a musica, pois esta sem extensao
      MediaPlayer1.FileName := nomeDiretorioPasta+nomeDiretorioMusica+'.mp3';
      MediaPlayer1.Open;
      // tamanho da musica;
      ProgressBar1.Max := MediaPlayer1.Length;
      tempoTotal.Caption := MSecToTime (MediaPlayer1.Length); //Mostra o tempo total da Música
      if posicaoAberto = true then
      begin
        MediaPlayer1.Position   := StrToInt(tempoMusica);
      //se abrir a jukebox e estiver com estado = true e porque tem musica no arquivo txt
      end;
      Timer1.Enabled := True;
    end;
end;
end.
