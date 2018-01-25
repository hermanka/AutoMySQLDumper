unit uSetup;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls, Registry;

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
  C_SECTION = '\Software\MyAutoDump\';
  DES_KEY = '%tgtRftk%6!jkyEr74rt*$jO0p';

implementation

{$R *.lfm}
uses uDes, INIFiles;

{ TfrmSetup }

procedure TfrmSetup.FormCreate(Sender: TObject);
var
  BackupTime, dbUser, dbPass: string;
  sl :TStringList;
  Registry: TRegistry;
begin

   sl := TStringList.create;

  Registry := TRegistry.Create;
  Registry.RootKey := HKEY_CURRENT_USER;
  Registry.OpenKey(C_SECTION, false);

  try
     BackupTime := Registry.ReadString('BackupTime');
     eMaxFile.Text := Registry.ReadString('maxFile');
     ePrefix.Text := Registry.ReadString('FilePrefix');
     eDBName.Text := Registry.ReadString('dbName');
     dbUser := Registry.ReadString('dbUser');
     dbPass := Registry.ReadString('dbPass');
     eSaveTo.Text  := Registry.ReadString('SaveTo');
     eBinLoc.Text := Registry.ReadString('mySQLBinLocation');
     eDBUser.Text:= udes.DecryStr(dbUser,DES_KEY);
     eDBPass.Text:= udes.DecryStr(dbPass,DES_KEY);

     sl.Delimiter:=':';
     sl.DelimitedText:=BackupTime;
     eBackupTimeH.text:= sl[0];
     eBackupTimeM.text:= sl[1];
     eBackupTimeS.text:= sl[2];
  finally
    Registry.free;
    sl.Free;
  end;

end;

procedure TfrmSetup.btnSaveConfClick(Sender: TObject);
var
   Registry: TRegistry;
   BackupTime, DBUserEnc, DBPassEnc : string;
begin
  Registry := TRegistry.Create;
  Registry.RootKey := HKEY_CURRENT_USER;




  try
     Registry.OpenKey(C_SECTION, true);
     BackupTime := eBackupTimeH.Text + ':' + eBackupTimeM.Text + ':' + eBackupTimeS.Text;
     DBUserEnc:= udes.EncryStr(eDBUser.Text,DES_KEY);
     DBPassEnc:= udes.EncryStr(eDBPass.Text,DES_KEY);

     Registry.WriteString('SaveTo',eSaveTo.Text);
     Registry.WriteString('FinishedConfig',inttostr(1));
     Registry.WriteString('BackupTime',BackupTime);
     Registry.WriteString('maxFile',eMaxFile.Text);
     Registry.WriteString('mySQLBinLocation',eBinLoc.Text);
     Registry.WriteString('FilePrefix',ePrefix.Text);
     Registry.WriteString('dbUser',DBUserEnc);
     Registry.WriteString('dbPass',DBPassEnc);
     Registry.WriteString('dbName',eDBName.Text);

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

