unit uMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Dialogs, ExtCtrls,
  StdCtrls, Menus, UniqueInstance, Process
  {$IFDEF MSWINDOWS}
  ,comobj
  {$ENDIF};

type

  { TfrmMain }

  TfrmMain = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    Label2: TLabel;
    MenuConfig: TMenuItem;
    MenuStop: TMenuItem;
    MenuAbout: TMenuItem;
    PopSHIELD: TPopupMenu;
    Timer1: TTimer;
    MyTray: TTrayIcon;
    UniqSHIELD: TUniqueInstance;
    procedure FormCreate(Sender: TObject);
    procedure MenuAboutClick(Sender: TObject);
    procedure MenuConfigClick(Sender: TObject);
    procedure MenuStopClick(Sender: TObject);
    procedure MyTrayClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);

  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmMain: TfrmMain;
  s : string;
  OurProcess: TProcess;
  Info : TSearchRec;
  Count : Longint;
  firstFile : string;

implementation

uses uabout, INIFiles, uSetup, uDes;
{$R *.lfm}

{ TfrmMain }


procedure TfrmMain.FormCreate(Sender: TObject);
var
  INI:TINIFile;
  FinishedConfig:integer;
const
  C_SECTION = 'INICONFIG';
begin
  Left := Screen.Width - Width - 30;
  Top := Screen.Height - Height - 90;
  width := 180;
  height := 50;

  MyTray.Visible:=true;
  myTray.Hint:=label1.Caption;

  INI := TINIFile.Create('config.ini');
  try
     FinishedConfig := INI.ReadInteger(C_SECTION,'FinishedConfig',1);

     if FinishedConfig = 0 then
     begin
      Application.CreateForm(TfrmSetup, frmSetup);
      frmSetup.show;
     end;

  finally
    INI.free;
  end;
end;

procedure TfrmMain.MenuAboutClick(Sender: TObject);
begin
  frmAbout.show;
end;

procedure TfrmMain.MenuConfigClick(Sender: TObject);
begin
  frmSetup.show;
end;


procedure TfrmMain.MenuStopClick(Sender: TObject);
var
  UserString: string;
begin
  {if InputQuery('Password', 'Masukkan password untuk menghentikan aplikasi', TRUE, UserString) then
       begin
          if(UserString='628247') then Application.Terminate;
       end
  else;   }
  If MessageDlg('Do you want to stop the backup shield?', mtConfirmation,[mbYes,mbNo],0)=mrYES then
      Application.Terminate;


end;

procedure TfrmMain.MyTrayClick(Sender: TObject);
begin
  if WindowState = wsMinimized then begin
     WindowState:=wsNormal;
    Show;
  end;
end;

procedure TfrmMain.Timer1Timer(Sender: TObject);
var
  INI:TINIFile;
  TimeString, TimeString2, saveTo,
  backupTime, mySQLBinLocation, filePrefix,
  dbName, dbUser, dbPass, tmp, DBUserDec, DBPassDec : String;
  maxFile : Integer;
const
  C_SECTION = 'INICONFIG';
  DES_KEY = '%tgtRftk%6!jkyEr74rt*$jO0p';
begin

  INI := TINIFile.Create('config.ini');
  TimeString := FormatDateTime('hh:nna/p', Now);

  s := FormatDateTime('dd-mm-yy-hh-nn-ss', now);
  TimeString2 := FormatDateTime('hh:nn:ss', now);

  try
  backupTime := INI.ReadString(C_SECTION,'BackupTime','');
  maxFile := INI.ReadInteger(C_SECTION,'maxFile',1);
  filePrefix := INI.ReadString(C_SECTION,'filePrefix','');
  dbName := INI.ReadString(C_SECTION,'dbName','');
  dbUser := INI.ReadString(C_SECTION,'dbUser','');
  dbPass := INI.ReadString(C_SECTION,'dbPass','');
  saveTo := INI.ReadString(C_SECTION,'SaveTo','');
  mySQLBinLocation := INI.ReadString(C_SECTION,'mySQLBinLocation','');

  DBUserDec:= udes.DecryStr(dbUser,DES_KEY);
  DBPassDec:= udes.DecryStr(dbPass,DES_KEY);

  if TimeString2=backupTime THEN
    begin
      try
      Count:=0;
      if dbName = '--all-databases' Then tmp := dbName
      else tmp := '--databases '+ dbName;

      OurProcess := TProcess.Create(Application);
      //OurProcess.CommandLine := mySQLBinLocation + 'mysqldump -uroot -hlocalhost -pswu ' + tmp + ' --result-file="' + saveTo + filePrefix + s + '.sql"';
      OurProcess.Executable:= mySQLBinLocation + '/mysqldump -u' + DBUserDec + ' -hlocalhost -p' + DBPassDec + ' ' + tmp + ' --result-file="' + saveTo + filePrefix + s + '.sql"';
      OurProcess.Options := [poUsePipes, poNoConsole];
      OurProcess.Execute;

      If FindFirst (saveTo + filePrefix + '*.sql',faAnyFile and faDirectory,Info)=0 then
        begin
          repeat
            Inc(Count);
            with Info do
            begin
              if count=1 then firstFile := name;
            end;
          until FindNext(info)<>0;
        end;

      if Count>=maxFile then
        begin
           DeleteFile(saveTo + firstFile);
        end;
        // we are done with file list
        FindClose(Info);

      except
        ShowMessage('Oops, something went wrong!');
      end;
    end;
  finally
    INI.free;
  end;
end;

end.

