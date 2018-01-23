unit uSetup;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TfrmSetup }

  TfrmSetup = class(TForm)
    btnSaveConf: TButton;
    btnClose: TButton;
    btnQuit: TButton;
    btnSelDirSaveTo: TButton;
    btnSelDirBin: TButton;
    eBackupTimeH: TEdit;
    eBinLoc: TEdit;
    eDBName: TEdit;
    eBackupTimeM: TEdit;
    eBackupTimeS: TEdit;
    eDBUser: TEdit;
    eDBPass: TEdit;
    ePrefix: TEdit;
    eMaxFile: TEdit;
    eSaveTo: TEdit;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Minute: TLabel;
    selDir: TSelectDirectoryDialog;
    procedure btnCloseClick(Sender: TObject);
    procedure btnQuitClick(Sender: TObject);
    procedure btnSaveConfClick(Sender: TObject);
    procedure btnSelDirBinClick(Sender: TObject);
    procedure btnSelDirSaveToClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  frmSetup: TfrmSetup;

const
  C_SECTION = 'INICONFIG';
  DES_KEY = '%tgtRftk%6!jkyEr74rt*$jO0p';
implementation

{$R *.lfm}
uses INIFiles, uDes;

{ TfrmSetup }

procedure TfrmSetup.FormCreate(Sender: TObject);
var
  INI:TINIFile;
  BackupTime, dbUser, dbPass: string;
  sl :TStringList;
begin
  INI := TINIFile.Create('config.ini');
   sl := TStringList.create;
  try
     eSaveTo.Text := INI.ReadString(C_SECTION,'SaveTo','');
     BackupTime := INI.ReadString(C_SECTION,'BackupTime','');

     eMaxFile.Text := INI.ReadString(C_SECTION,'maxFile','');
     eBinLoc.Text := INI.ReadString(C_SECTION,'mySQLBinLocation','');
     ePrefix.Text := INI.ReadString(C_SECTION,'FilePrefix','');
     eDBName.Text := INI.ReadString(C_SECTION,'dbName','');
     dbUser := INI.ReadString(C_SECTION,'dbUser','');
     dbPass := INI.ReadString(C_SECTION,'dbPass','');

      eDBUser.Text:= udes.DecryStr(dbUser,DES_KEY);
      eDBPass.Text:= udes.DecryStr(dbPass,DES_KEY);

     sl.Delimiter:=':';
     sl.DelimitedText:=BackupTime;
     eBackupTimeH.text:= sl[0];
     eBackupTimeM.text:= sl[1];
     eBackupTimeS.text:= sl[2];


  finally
    INI.free;
    sl.Free;
  end;

end;

procedure TfrmSetup.btnSaveConfClick(Sender: TObject);
var
  INI : TINIFile;
  BackupTime, DBUserEnc, DBPassEnc : string;
begin
  INI := TINIFile.Create('config.ini');
  try
     BackupTime := eBackupTimeH.Text + ':' + eBackupTimeM.Text + ':' + eBackupTimeS.Text;
     DBUserEnc:= udes.EncryStr(eDBUser.Text,DES_KEY);
     DBPassEnc:= udes.EncryStr(eDBPass.Text,DES_KEY);

     INI.WriteString(C_SECTION,'SaveTo',eSaveTo.Text);
     INI.WriteString(C_SECTION,'FinishedConfig','1');
     INI.WriteString(C_SECTION,'BackupTime',BackupTime);
     INI.WriteString(C_SECTION,'maxFile',eMaxFile.Text);
     INI.WriteString(C_SECTION,'mySQLBinLocation',eBinLoc.Text);
     INI.WriteString(C_SECTION,'FilePrefix',ePrefix.Text);
     INI.WriteString(C_SECTION,'dbName',eDBName.Text);
     INI.WriteString(C_SECTION,'dbUser',DBUserEnc);
     INI.WriteString(C_SECTION,'dbPass',DBPassEnc);
     ShowMessage('Configuration saved!');
     self.hide;
     //frmMain.Destroy;
     //Application.CreateForm(TfrmMain, frmMain);
     //frmMain.Show;
  except
    ShowMessage('Fail saved!');
  end;
end;

procedure TfrmSetup.btnSelDirBinClick(Sender: TObject);
begin
  if selDir.Execute then
     eBinLoc.Text := selDir.FileName;
end;

procedure TfrmSetup.btnSelDirSaveToClick(Sender: TObject);
begin
  if selDir.Execute then
     eSaveTo.Text := selDir.FileName;

end;


procedure TfrmSetup.btnCloseClick(Sender: TObject);
begin
  self.hide;
end;

procedure TfrmSetup.btnQuitClick(Sender: TObject);
begin
  Application.Terminate;
end;

end.

