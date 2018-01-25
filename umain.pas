unit uMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Dialogs, ExtCtrls,
  StdCtrls, Menus, UniqueInstance, Process, Registry
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

uses uabout, uSetup, uDes;
{$R *.lfm}

{ TfrmMain }
const
  C_SECTION = '\Software\MyAutoDump\';
  DES_KEY = '%tgtRftk%6!jkyEr74rt*$jO0p';

procedure TfrmMain.FormCreate(Sender: TObject);
var
  //INI:TINIFile;
  Registry: TRegistry;
  str : string;
  FinishedConfig:string;

begin
  Left := Screen.Width - Width - 30;
  Top := Screen.Height - Height - 90;
  width := 180;
  height := 50;

  MyTray.Visible:=true;
  myTray.Hint:=label1.Caption;

  Registry := TRegistry.Create;
  Registry.RootKey := HKEY_CURRENT_USER;

  //str := Registry.ReadInteger('FinishedConfig');
  //;
  if (Registry.KeyExists(C_SECTION)=false) then
     begin
       Registry.OpenKey(C_SECTION, true);
        Registry.WriteString('FinishedConfig',inttostr(0));
        Registry.WriteString('SaveTo','');
        Registry.WriteString('BackupTime','12:00:00');
        Registry.WriteString('maxFile',inttostr(100));
        Registry.WriteString('mySQLBinLocation','');
        Registry.WriteString('FilePrefix','backup-');
        Registry.WriteString('dbUser','');
        Registry.WriteString('dbPass','');
        Registry.WriteString('dbName','');
     end;


  try
     FinishedConfig := Registry.ReadString('FinishedConfig');

     if FinishedConfig = '0' then
     begin
      Application.CreateForm(TfrmSetup, frmSetup);
      frmSetup.show;
     end;

  finally
    Registry.free;
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
  Registry: TRegistry;
  TimeString, TimeString2, saveTo,
  backupTime, mySQLBinLocation, filePrefix,
  dbName, dbUser, dbPass, tmp, DBUserDec, DBPassDec, str, maxFile_str : String;
  maxFile : integer;
begin
  Registry := TRegistry.Create;
  Registry.RootKey := HKEY_CURRENT_USER;
  Registry.OpenKey(C_SECTION, false);
  str := Registry.ReadString('FinishedConfig');

  s := FormatDateTime('dd-mm-yy-hh-nn-ss', now);
  TimeString2 := FormatDateTime('hh:nn:ss', now);

  try
  backupTime := Registry.ReadString('BackupTime');
  maxFile_str := Registry.ReadString('maxFile');
  filePrefix := Registry.ReadString('FilePrefix');
  dbName := Registry.ReadString('dbName');
  dbUser := Registry.ReadString('dbUser');
  dbPass := Registry.ReadString('dbPass');
  saveTo := Registry.ReadString('SaveTo');
  mySQLBinLocation := Registry.ReadString('mySQLBinLocation');

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
      maxFile := strtoint(maxFile_str);
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
    Registry.free;
  end;
end;

end.

