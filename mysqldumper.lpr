program mysqldumper;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  { you can add units after this }
  uniqueinstance_package, uMain, uAbout, uSetup, INIFiles, uDes;



{$R *.res}

begin


  Application.Title:='MySQLDumper';

  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.ShowMainForm := False;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmSetup, frmSetup);
  Application.CreateForm(TfrmAbout, frmAbout);
  Application.Run;



end.

