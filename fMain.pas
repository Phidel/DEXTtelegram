unit fMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, acFontStore, PropFilerEh, PropStorageEh, Vcl.StdCtrls,
  sEdit, Vcl.ComCtrls, acProgressBar, sButton,
  Cromis.SimpleLog, dea.Status,
  Vcl.ExtCtrls, sPanel, sStatusBar, sSkinManager, sSkinProvider, sgcBase_Classes, sgcLib_Telegram_Client, sgcLibs, sPageControl;

type
  TMainForm = class(TForm)
    sFontStore1: TsFontStore;
    PropStorageEh1: TPropStorageEh;
    TopPanel: TsPanel;
    StartButton: TsButton;
    StopButton: TsButton;
    ProgressBar2: TsProgressBar;
    PhoneEdit: TsEdit;
    SaveButton: TsButton;
    StatusBar1: TsStatusBar;
    sSkinProvider1: TsSkinProvider;
    sSkinManager1: TsSkinManager;
    mTelegram: TsgcTDLib_Telegram;
    sPageControl1: TsPageControl;
    sTabSheet1: TsTabSheet;
    sTabSheet2: TsTabSheet;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SaveButtonClick(Sender: TObject);
    procedure StartButtonClick(Sender: TObject);
    procedure StopButtonClick(Sender: TObject);
  private
    procedure EnableButtons(AEnable: Boolean);
  public
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  dea.tools, uConst;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Application.UpdateFormatSettings := False;
  FormatSettings.DecimalSeparator := '.';
  utc_offset := OffsetUTC2;
//  FLoading := true;

  MainForm.Caption := AppName;

  SimpleLog.RegisterLog('log', WorkingPath + main_log, 3000, 4, [lpTimestamp, lpType]);
  SimpleLog.LockType := ltProcess; // ltMachine, ltNone;
  Log('start ' + AppName + ' - - - - - - - - - - -');
  Log(WorkingPath);

  StopButton.Visible := False;
  ProgressBar2.Position := 0;
  ProgressBar2.Step := 1;
  Status.Bind(StatusBar1, StopButton, 1);
  Status.Bind(StatusBar1, ProgressBar2, 2);
{$WARN SYMBOL_PLATFORM OFF}
  // SaveStringOn := DebugHook <> 0;
{$WARN SYMBOL_PLATFORM ON}
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  Log('finish');
end;

procedure TMainForm.SaveButtonClick(Sender: TObject);
begin
  PropStorageEh1.SaveProperties;
end;

procedure TMainForm.StartButtonClick(Sender: TObject);
begin
  EnableButtons(False);
  mTelegram.Telegram.PhoneNumber := PhoneEdit.Text;
  mTelegram.Active := true;
  Status.Stopped := False;
  StopButton.Visible := true;
  sPageControl1.ActivePageIndex := 0;
end;

procedure TMainForm.StopButtonClick(Sender: TObject);
begin
  mTelegram.Active := False;
  Status.Stopped := true;
  StopButton.Visible := False;
  EnableButtons(true);
end;

procedure TMainForm.EnableButtons(AEnable: Boolean);
begin
  StartButton.Enabled := AEnable;
end;

initialization

SetDefStorage;

end.
