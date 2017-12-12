unit frm1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Menus, UniqueInstance, Process
  {$IFDEF MSWINDOWS}
      ,comobj
  {$ENDIF};

type

  { TForm1 }

  TForm1 = class(TForm)
    Label1: TLabel;
    MenuItem1: TMenuItem;
    PopSHIELD: TPopupMenu;
    Timer1: TTimer;
    MyTray: TTrayIcon;
    UniqSHIELD: TUniqueInstance;
    procedure FormClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MyTrayClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);

  private
    procedure drawDigit(digit: string; X, Y: Integer);
    procedure drawDigits(digits: String);
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;

  digitsBitmap: TBitmap;
  clockBitmap: TBitmap;

  digitWidth: Integer = 30;
  digitHeight: Integer = 50;

  digitCount: Integer = 15;
  digitPositions: array[1..15] of String = (
      '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
      '-', ':', 'A', 'P', ' '
  );
  s : string;
  OurProcess: TProcess;


implementation
uses INIFiles;
{$R *.lfm}

{ TForm1 }

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if Assigned(digitsBitmap) then digitsBitmap.Free;
  if Assigned(clockBitmap) then clockBitmap.Free;
end;

procedure TForm1.FormClick(Sender: TObject);
//var
 // SavedCW: Word;
 // SpVoice: Variant;
 // TimeString: String;
  //TextToBeSpoken:Variant;
begin
  {$IFDEF MSWINDOWS}
 //   TimeString := FormatDateTime('h:n am/pm', Now);
  //  TextToBeSpoken := 'The time is: '+TimeString;

  //  SpVoice := CreateOleObject('SAPI.SpVoice');
    // Change FPU interrupt mask to avoid SIGFPE exceptions
  //  SavedCW := Get8087CW;
  //  try
  //    Set8087CW(SavedCW or $4);
  //    SpVoice.Speak(TextToBeSpoken, 0);
  //  finally
      // Restore FPU mask
   //   Set8087CW(SavedCW);
   //   SpVoice:=Unassigned;
  //  end;
  {$ENDIF}
end;



procedure TForm1.FormCreate(Sender: TObject);
begin
  clockBitmap := TBitmap.Create;
  clockBitmap.SetSize(Width, Height);

  digitsBitmap := TBitmap.Create;
  digitsBitmap.LoadFromFile('digits.bmp');

  drawDigits('--:-- ');

  Left := Screen.Width - Width - 30;
  Top := Screen.Height - Height - 90;
  width := 180;
  height := 50;

   MyTray.Visible:=true;
   myTray.Hint:=label1.Caption;
end;

procedure TForm1.FormPaint(Sender: TObject);
begin
  if Assigned(clockBitmap) then
    Canvas.Draw(0,0,clockBitmap);
end;

procedure TForm1.MenuItem1Click(Sender: TObject);
var
  UserString: string;
begin
  if InputQuery('Password', 'Masukkan password untuk menghentikan aplikasi', TRUE, UserString) then
       begin
          if(UserString='628247') then Application.Terminate;
       end
  else;
end;

procedure TForm1.MyTrayClick(Sender: TObject);
begin
  if WindowState = wsMinimized then begin
     WindowState:=wsNormal;
    Show;
  end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  INI:TINIFile;
  TimeString, TimeString2, saveTo, backupTime: String;
begin
  INI := TINIFile.Create('config.ini');
  TimeString := FormatDateTime('hh:nna/p', Now);
  drawDigits(TimeString);
 // label1.Caption:=TimeString;

  s := FormatDateTime('dd-mm-yy-hh-nn-ss', now);
  TimeString2 := FormatDateTime('hh:nn:ss', now);
  backupTime := INI.ReadString('INICONFIG','BackupTime','');
  if TimeString2=backupTime THEN
    begin
    saveTo := INI.ReadString('INICONFIG','SaveTo','');
    //Timer.Enabled:= true;
    OurProcess := TProcess.Create(Application);
    OurProcess.CommandLine := 'B:\SIMAKAD-SRV\bin\mysqldump -uroot -hlocalhost -pswu --databases simakad --result-file=' + saveTo + 'simakad-' + s + '.sql';
    //OurProcess.Parameters.Add('-uroot -hlocalhost -pswu --databases simakad > B:\simakad-d.sql');
    OurProcess.Options := [poUsePipes, poNoConsole];
    OurProcess.Execute;
    end;

end;



procedure TForm1.drawDigits(digits:String);
var
  c: Char;
  x: Integer;
begin
  x := 0;
  for c in digits do begin
    drawDigit(c, x, 0);
    Inc(x, digitWidth);
  end;
end;

procedure TForm1.drawDigit(digit:string; X, Y: Integer);
var
  rectDest, rectSrc: TRect;
  digitNumber: Integer;
  i: Integer;
begin
  // if the bitmaps have not been initialized (Create'd)
  // then we can't work with them!!
  if (Assigned(digitsBitmap)=false)
  or (Assigned(clockBitmap)=false) then
       exit;

  digitNumber:=15; // the default digit position
  for i := 1 to digitCount do begin
    if digitPositions[i] = UpperCase(digit) then begin
       digitNumber:=i;
       Break;
    end;
  end;

  with rectDest do begin
    Left:=X;
    Top:=Y;
    Right:=Left+30;
    Bottom:=Top+digitHeight;
  end;

  with rectSrc do begin
    Left:=digitWidth * (digitNumber-1);
    Top:=0;
    Right:=Left+digitWidth;
    Bottom:=Top+digitHeight;
  end;

  clockBitmap.Canvas.CopyRect(rectDest, digitsBitmap.Canvas, rectSrc);
  FormPaint(Form1);
end;

end.

