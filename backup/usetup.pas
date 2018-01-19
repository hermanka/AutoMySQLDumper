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
    eBackupTimeH: TEdit;
    eBinLoc: TEdit;
    eDBName: TEdit;
    eBackupTimeM: TEdit;
    eBackupTimeS: TEdit;
    ePrefix: TEdit;
    eMaxFile: TEdit;
    eSaveTo: TEdit;
    Label1: TLabel;
    Label10: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Minute: TLabel;
    procedure btnCloseClick(Sender: TObject);
    procedure btnSaveConfClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  frmSetup: TfrmSetup;

implementation

{$R *.lfm}
uses INIFiles, uMain;

{ TfrmSetup }

procedure TfrmSetup.FormCreate(Sender: TObject);
var
  INI:TINIFile;
  BackupTime: string;
  sl :TStringList;
const
  C_SECTION = 'INICONFIG';
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
  INI:TINIFile;
  BackupTime:string;
const
  C_SECTION = 'INICONFIG';
begin
  INI := TINIFile.Create('config.ini');
  try
     BackupTime := eBackupTimeH.Text + ':' + eBackupTimeM.Text + ':' + eBackupTimeS.Text;
     INI.WriteString(C_SECTION,'SaveTo',eSaveTo.Text);
     INI.WriteString(C_SECTION,'FinishedConfig','1');
     INI.WriteString(C_SECTION,'BackupTime',BackupTime);
     INI.WriteString(C_SECTION,'maxFile',eMaxFile.Text);
     INI.WriteString(C_SECTION,'mySQLBinLocation',eBinLoc.Text);
     INI.WriteString(C_SECTION,'FilePrefix',ePrefix.Text);
     INI.WriteString(C_SECTION,'dbName',eDBName.Text);
     ShowMessage('Configuration saved!');
     //frmMain.Destroy;
     //Application.CreateForm(TfrmMain, frmMain);
     //frmMain.Show;
  except
    ShowMessage('Fail saved!');
  end;
end;

procedure TfrmSetup.btnCloseClick(Sender: TObject);
begin
  self.hide;
end;

end.

