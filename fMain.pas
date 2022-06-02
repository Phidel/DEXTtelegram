unit fMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls,
  Vcl.Forms, Vcl.Dialogs, acFontStore, PropFilerEh, PropStorageEh, Vcl.StdCtrls, sEdit, Vcl.ComCtrls, acProgressBar,
  sButton, Cromis.SimpleLog, dea.Status, Vcl.ExtCtrls, sPanel, sStatusBar, sSkinManager, sSkinProvider, sgcBase_Classes,
  sgcLib_Telegram_Client, sgcLibs, sPageControl, sMemo, sCheckBox, sGroupBox;

type
  TMainForm = class(TForm)
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
    tsMain: TsTabSheet;
    tsSettings: TsTabSheet;
    MessagesMemo: TsMemo;
    TestTelegramButton: TsButton;
    FilterGroup: TsGroupBox;
    FilterGreenCheckBox: TsCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SaveButtonClick(Sender: TObject);
    procedure StartButtonClick(Sender: TObject);
    procedure StopButtonClick(Sender: TObject);
    procedure mTelegramAuthenticationCode(Sender: TObject; var Code: string);
    procedure mTelegramAuthenticationPassword(Sender: TObject; var Password: string);
    procedure mTelegramAuthorizationStatus(Sender: TObject; const Status: string);
    procedure mTelegramConnectionStatus(Sender: TObject; const Status: string);
    procedure mTelegramException(Sender: TObject; E: Exception);
    procedure mTelegramMessageDocument(Sender: TObject; MessageDocument: TsgcTelegramMessageDocument);
    procedure mTelegramMessagePhoto(Sender: TObject; MessagePhoto: TsgcTelegramMessagePhoto);
    procedure mTelegramMessageText(Sender: TObject; MessageText: TsgcTelegramMessageText);
    procedure mTelegramEvent(Sender: TObject; const Event, Text: string);
    procedure TestTelegramButtonClick(Sender: TObject);
    procedure mTelegramMessageVideo(Sender: TObject; MessageVideo: TsgcTelegramMessageVideo);
  private
    FLoading: Boolean; // загрузка истории за сутки
    procedure EnableButtons(AEnable: Boolean);
    procedure xLog(s: string);
    procedure ProcessMessage(Text, ChatId: string; MessageId: Int64);
  public
    tStatus: string; // статус соединения с телеграммом, можно визуализировать
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  dea.tools, uConst;

const
  InputChannel1ID = '-1001179431786'; // DEXT Live New Pairs Bot [BSC / Binance Smart Chain]
  InputChannel2ID = '-1001298556816'; // DEXT Live New Pairs Bot [Ethereum Blockchain]

  // OutputChannel1ID = '-1001797168211'; // мой тестовый канал
  // OutputChannel2ID = '-1001797168211';

  OutputChannel1ID = '-1001388749434'; // BSC Liquidity Pairs
  OutputChannel2ID = '-1001601187141'; // ETH Liquidity Pairs

  AnalyzerBotID = '1990154044'; // SAFE Analyzer Bot

function GetChatName(ChatId: string): string;
begin
  if ChatId = InputChannel1ID then
    Result := 'DEXT New Pairs BSC'
  else if ChatId = InputChannel2ID then
    Result := 'DEXT New Pairs ETH'
  else if ChatId = AnalyzerBotID then
    Result := 'Analyzer Bot'
  else if ChatId = OutputChannel1ID then
    Result := 'BSC'
  else if ChatId = OutputChannel2ID then
    Result := 'ETH'
  else
    Result := '?';
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Application.UpdateFormatSettings := False;
  FormatSettings.DecimalSeparator := '.';
  utc_offset := OffsetUTC2;
  FLoading := true;

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

procedure TMainForm.mTelegramAuthenticationCode(Sender: TObject; var Code: string);
begin
  Code := InputBox('Telegram', 'Introduce Telegram Code', '');
end;

procedure TMainForm.mTelegramAuthenticationPassword(Sender: TObject; var Password: string);
begin
  Password := InputBox('Telegram', 'Introduce Telegram Password', '');
end;

procedure TMainForm.mTelegramAuthorizationStatus(Sender: TObject; const Status: string);
begin
  xLog('- ' + Status);
  if Status = 'authorizationStateReady' then begin
    xLog('- pass');
    // mTelegram.GetChats(MaxInt, 0, 100);
  end;
end;

procedure TMainForm.mTelegramConnectionStatus(Sender: TObject; const Status: string);
begin
  tStatus := Status;
  xLog('* ' + tStatus);
  // dea.status.Status.Update(tStatus);
  if tStatus = 'connectionStateReady' then begin
    xLog('ok');
    FLoading := False;
    mTelegram.GetChats(MaxInt, 0, 100);

    mTelegram.GetChat(InputChannel1ID); // ?
    mTelegram.GetChat(InputChannel2ID);
    // mTelegram.GetChat('-1001393193695');
    // mTelegram.SendTextMessage('me', 'Hi');
  end;
end;

procedure TMainForm.mTelegramEvent(Sender: TObject; const Event, Text: string);
begin
  if Event = 'error' then begin
    Status.Update(Event + ' ' + Text);
    xLog(Event + ' ' + Text + CR);
    exit;
  end;

  Status.Update(Event + ' ' + Copy(Text, 1, 20));

  (* if (Event <> 'updateChatLastMessage') and (Event <> 'updateUserStatus') and (Event <> 'updateChatLastMessage') and
    (Event <> 'updateChatReadInbox') and (Event <> 'updateDeleteMessages') and (Event <> 'updateUser') and
    (Event <> 'updateUnreadChatCount') and (Event <> 'updateChatReadOutbox') and (Event <> 'updateUserChatAction') and
    (Event <> 'updateChatOrder') and (Event <> 'updateHavePendingNotifications') and (Event <> 'updateMessageEdited')
    and (Event <> 'updateChatTitle') and
    // (Event <> 'chats') and
    // mTelegram.GetChat(MessageText.ChatId); // приходит Event = 'chat'
    (Event <> 'updateSupergroupFullInfo') and (Event <> 'updateChatPhoto') and (Event <> 'updateChatPermissions') and
    (Event <> 'updateChatPinnedMessage') and
    // (Event <> 'updateNewMessage') and
    (Event <> 'updateScopeNotificationSettings') and (Event <> 'updateChatChatList') and
    // признак: чат в архиве или в главном списке
    (Event <> 'updateOption') // примеры опций см в !readme
    // and (Event <> 'updateUnreadMessageCount')
    then begin

    Status.Update(Event + ' ' + Text);

    // Log('&&& ' + Event + CR + Text);
    // if Event = 'messages' then begin // пришел ответ на запрос GetChatHistory
    end;
  *)
end;

procedure TMainForm.mTelegramException(Sender: TObject; E: Exception);
begin
  xLog('! Exception: ' + E.Message + ' : ' + Sender.ClassName);
end;

procedure TMainForm.mTelegramMessageDocument(Sender: TObject; MessageDocument: TsgcTelegramMessageDocument);
begin
  ProcessMessage(MessageDocument.CaptionText, MessageDocument.ChatId, MessageDocument.MessageId);
end;

procedure TMainForm.mTelegramMessagePhoto(Sender: TObject; MessagePhoto: TsgcTelegramMessagePhoto);
begin
  ProcessMessage(MessagePhoto.CaptionText, MessagePhoto.ChatId, MessagePhoto.MessageId);
end;

procedure TMainForm.mTelegramMessageText(Sender: TObject; MessageText: TsgcTelegramMessageText);
begin
  ProcessMessage(MessageText.Text, MessageText.ChatId, MessageText.MessageId);
end;

procedure TMainForm.mTelegramMessageVideo(Sender: TObject; MessageVideo: TsgcTelegramMessageVideo);
begin
  ProcessMessage(MessageVideo.CaptionText, MessageVideo.ChatId, MessageVideo.MessageId);
end;

procedure TMainForm.xLog(s: string);
begin
  Log(s);
  if MessagesMemo.Lines.Count > 3000 then
    MessagesMemo.Lines.Clear;
  MessagesMemo.Lines.Add(s);
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

procedure TMainForm.TestTelegramButtonClick(Sender: TObject);
begin
  if not mTelegram.Active then
    raise Exception.Create('Телеграм не запущен. Сначала нажмите кнопку Старт');

  mTelegram.SendTextMessage(OutputChannel1ID, MainForm.Caption + CR + 'test');
  mTelegram.SendTextMessage(AnalyzerBotID, '0xb376814c6b28201fd0b0c77a0fc4cbd2101fa14c');
end;

procedure TMainForm.EnableButtons(AEnable: Boolean);
begin
  StartButton.Enabled := AEnable;
end;

function ShortMessageId(MessageId: Int64): string; // не исп
begin
  Result := MessageId.ToHexString;
  Result := Copy(Result, 1, Length(Result) - 5);
  // отсечь последние 5 цифр (20 битов)
  Result := IntToStr(StrToInt('$' + Result));
end;

procedure TMainForm.ProcessMessage(Text, ChatId: string; MessageId: Int64);
var
  s, token, subs, channel: string;
  CheckGreen, Flag: Boolean;
begin
  // if FLoading or (Text = '') then
  // exit;

  if (ChatId <> InputChannel1ID) and (ChatId <> InputChannel2ID) and (ChatId <> AnalyzerBotID) then begin
    Log('* ' + ChatId + ' ' + Copy(Text, 1, 30));
    exit;
  end;

  xLog('-> ' + ChatId + ': ' + GetChatName(ChatId) + CR + Copy(Text, 1, 280));

  if ChatId = AnalyzerBotID then begin // пришел ответ от бота с анализом
    if (Length(Text) > 80) { послали токен на запрос - как отличать запрос от ответа, по длине } and
      (Pos('Report is being generated...', Text) = 0) then begin

      subs := reprep(Text, 'SafeAnalyzerbot ', 'Owner:'); // отсекаем ненужное
      if subs = '' then
        subs := Text;

      Flag := true;
      CheckGreen := FilterGreenCheckBox.Checked;
      if CheckGreen then begin
        Flag := Pos('🟢', subs) > 0; // зеленый кружок в заголовке сообщения
      end;

      if Pos('BINANCE:', subs) > 0 then begin // BSC в первый канал
        channel := OutputChannel1ID;
        s := 'ch.1';
      end
      else begin
        channel := OutputChannel2ID;
        s := 'ch.2';
      end;

      if Flag then begin
        xLog('отправлено в ' + s + ' ' + GetChatName(channel));
        mTelegram.SendTextMessage(channel, Text);
      end
      else
        xLog('не прошел фильтр');
    end;
  end
  else begin // пришло сообщение в один из входных каналов. Выделям токен и делаем запрос на анализ
    token := Trim(reprep(Text, 'Token contract:', 'DEXToo'));
    xLog('--> analyzer -> ' + ChatId[6] + ': ' + token + CR);

    if token = '' then begin
      xLog('пустой токен ');
      exit;
    end;

    mTelegram.SendTextMessage(AnalyzerBotID, token);
  end;

end;

initialization

SetDefStorage;

end.
