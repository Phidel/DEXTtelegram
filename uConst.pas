unit uConst;

interface

uses
  Windows, Classes, SysUtils, StrUtils,  // dea.Tools,
  Cromis.SimpleLog, PropFilerEh, PropStorageEh;

const
  AppTitle = 'DEXT Telegram';
  main_log = 'log.txt';
  arrow_down = char(8595); // '↓';
  arrow_up = char(8593);
  CR = #13#10;

const
  BuildNo = {$I BuildNo.inc};
function AppName: string;

var
  utc_offset: TDateTime = 2 / 24; // UTC минус локальное время (автоопределение OnCreate)
  eps: Double = 0.0000000001;

procedure Log(const s: string); overload;
procedure Log(Param: Integer); overload;
procedure Log(Param: Double); overload;
procedure Log(BoolParam: Boolean); overload;

procedure Log(const FormatStr: string; Args: array of const); overload;

procedure Log(const s: string; IntParam: Integer); overload;
procedure Log(const s: string; BoolParam: Boolean); overload;
procedure Log(const s: string; FloatParam: Double); overload;
procedure LogTime;  // запоминает текущее время
// выводит в лог истекшее время с момента запоминания, плюс указанная строка
procedure LogTimeEnd; overload;
procedure LogTimeEnd(const FormatStr: string; Args: array of const); overload;

procedure Err(s: string = '');

function ff(value: Double): string; // форматирование цен и объемов
function ffp(value: Double): string; // форматирование процентов

function WorkingPath: string;
function NormalDir(const DirName: string): string;

procedure SetDefStorage;

const
  _Italic = #1;
  _Bold = #2;
  _Highlight = #3;
  _AltFont = #4;
  _Underline = #21;

implementation


procedure Log(const s: string); overload;
begin
  SimpleLog.LogInfo('log', s);
end;

procedure Log(Param: Integer); overload;
begin
  SimpleLog.LogInfo('log', IntToStr(Param));
end;

procedure Log(Param: Double); overload;
begin
  SimpleLog.LogInfo('log', FormatFloat('0.########', Param));
end;

procedure Log(BoolParam: Boolean); overload;
begin
  SimpleLog.LogInfo('log', IfThen(BoolParam, 'Y', 'N'));
end;

procedure Log(const s: string; IntParam: Integer);
begin
  SimpleLog.LogInfo('log', s + ': ' + IntToStr(IntParam));
end;

procedure Log(const s: string; BoolParam: Boolean); overload;
begin
  SimpleLog.LogInfo('log', s + ': ' + IfThen(BoolParam, 'Y', 'N'));
end;

procedure Log(const s: string; FloatParam: Double); overload;
begin
  SimpleLog.LogInfo('log', s + ': ' + FloatToStr(FloatParam));
end;

procedure Log(const FormatStr: string; Args: array of const); overload;
var
  s: string;
begin
  s := Format(FormatStr, Args);
  SimpleLog.LogInfo('log', s);
end;

procedure Err(s: string = '');
begin
  SimpleLog.LogError('log', s);
end;

var
  _LogTime: Cardinal = 0;

procedure LogTime;  // запоминает текущее время
begin
  _LogTime := GettickCount;
end;

// выводит в лог истекшее время с момента запоминания, плюс указанная строка
procedure LogTimeEnd(const FormatStr: string; Args: array of const);
var
  s: string;
begin
  s := Format(FormatStr, Args);
  SimpleLog.LogInfo('log', s + ' : ticks = ' + (GettickCount-_LogTime).ToString);
  _LogTime := 0;
end;

procedure LogTimeEnd;
begin
  SimpleLog.LogInfo('log', ': ticks = ' + (GettickCount-_LogTime).ToString);
  _LogTime := 0;
end;

procedure SetDefStorage;
var
  IniPropStorageMan1: TIniPropStorageManEh;
begin
  IniPropStorageMan1 := TIniPropStorageManEh.Create(nil);
  IniPropStorageMan1.IniFileName := ExtractFilepath(GetModuleName(0)) + 'settings.ini';
  SetDefaultPropStorageManager(IniPropStorageMan1);
end;

function ff(value: Double): string;
begin
  Result := FormatFloat('0.########', value);
end;

function ffp(value: Double): string;
begin
  Result := FormatFloat('0.###', value) + ' %';
end;


function WorkingPath: string; // путь к программе (а не текущий путь)
begin
  Result := ExtractFilepath(GetModuleName(0));
end;

function NormalDir(const DirName: string): string;
begin
  Result := DirName;
  if Result = '' then
    exit;
  if (Result[Length(Result)] <> '\') and (Result[Length(Result)] <> '/') then
    Result := Result + '\';
end;

var
  BuildNoAsString: string = '';

function AppName: string;
begin
  if BuildNoAsString = '' then
    BuildNoAsString := FormatFloat('0.0#', BuildNo);
  Result := AppTitle + ', ' + BuildNoAsString;
end;


end.
