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
    Label1: TLabel;
    MenuStop: TMenuItem;
    MenuAbout: TMenuItem;
    PopSHIELD: TPopupMenu;
    Timer1: TTimer;
    MyTray: TTrayIcon;
    UniqSHIELD: TUniqueInstance;
    procedure FormCreate(Sender: TObject);
    procedure MenuAboutClick(Sender: TObject);
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

uses uabout, INIFiles;
{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  Left := Screen.Width - Width - 30;
  Top := Screen.Height - Height - 90;
  width := 180;
  height := 50;

  MyTray.Visible:=true;
  myTray.Hint:=label1.Caption;
end;

procedure TfrmMain.MenuAboutClick(Sender: TObject);
begin
  frmAbout.show;
end;


procedure TfrmMain.MenuStopClick(Sender: TObject);
var
  UserString: string;
begin
  if InputQuery('Password', 'Masukkan password untuk menghentikan aplikasi', TRUE, UserString) then
       begin
          if(UserString='628247') then Application.Terminate;
       end
  else;
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
  TimeString, TimeString2, saveTo, backupTime, mySQLBinLocation, filePrefix, dbName, tmp : String;
  maxFile : Integer;
begin

  INI := TINIFile.Create('config.ini');
  TimeString := FormatDateTime('hh:nna/p', Now);

  s := FormatDateTime('dd-mm-yy-hh-nn-ss', now);
  TimeString2 := FormatDateTime('hh:nn:ss', now);
  backupTime := INI.ReadString('INICONFIG','BackupTime','');
  maxFile := INI.ReadInteger('INICONFIG','maxFile',1);

  if TimeString2=backupTime THEN
    begin
      Count:=0;

      filePrefix := INI.ReadString('INICONFIG','filePrefix','');
      dbName := INI.ReadString('INICONFIG','dbName','');
      saveTo := INI.ReadString('INICONFIG','SaveTo','');
      mySQLBinLocation := INI.ReadString('INICONFIG','mySQLBinLocation','');

      if dbName = '--all-databases' Then tmp := dbName
      else tmp := '--databases '+ dbName;

      OurProcess := TProcess.Create(Application);
      OurProcess.CommandLine := mySQLBinLocation + 'mysqldump -uroot -hlocalhost -pswu ' + tmp + ' --result-file="' + saveTo + filePrefix + s + '.sql"';
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

    end;

end;

end.

