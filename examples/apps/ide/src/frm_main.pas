{
    LiteKit IDE - Maximus

    Copyright (C) 2012 - 2013 Graeme Geldenhuys

    See the file COPYING.modifiedLGPL, included in this distribution,
    for details about redistributing LiteKit.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

    Description:
      Maximus IDE is an example application, to showcase a bit more of
      what LiteKit can do in a larger project. It also ties in a lot of
      various LiteKit widgets and framework functionality.
}

unit frm_main;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, lq_base, lq_main, lq_form, lq_menu, lq_panel,
  lq_button, lq_splitter, lq_tab, lq_memo, lq_label, lq_grid,
  lq_tree, lq_textedit, lq_mru, synregexpr,
  filemonitor;

type

  TMainForm = class(TlqForm)
  private
    {@VFD_HEAD_BEGIN: MainForm}
    pnlMenu: TlqBevel;
    mainmenu: TlqMenuBar;
    Toolbar: TlqBevel;
    btnQuit: TlqButton;
    btnOpen: TlqButton;
    btnSave: TlqButton;
    btnSaveAll: TlqButton;
    pnlStatusBar: TlqBevel;
    lblStatus: TlqLabel;
    pnlClientArea: TlqBevel;
    pnlWindow: TlqPageControl;
    tsMessages: TlqTabSheet;
    grdMessages: TlqStringGrid;
    tsScribble: TlqTabSheet;
    memScribble: TlqMemo;
    tsTerminal: TlqTabSheet;
    Splitter1: TlqSplitter;
    pnlTool: TlqPageControl;
    tsProject: TlqTabSheet;
    tvProject: TlqTreeView;
    tsFiles: TlqTabSheet;
    grdFiles: TlqFileGrid;
    Splitter2: TlqSplitter;
    pcEditor: TlqPageControl;
    tseditor: TlqTabSheet;
    TextEditor: TlqTextEdit;
    mnuFile: TlqPopupMenu;
    mnuEdit: TlqPopupMenu;
    mnuSearch: TlqPopupMenu;
    mnuView: TlqPopupMenu;
    mnuProject: TlqPopupMenu;
    mnuRun: TlqPopupMenu;
    mnuTools: TlqPopupMenu;
    mnuSettings: TlqPopupMenu;
    mnuHelp: TlqPopupMenu;
    {@VFD_HEAD_END: MainForm}
    {$ifdef DEBUGSVR}
    btnTest: TlqButton;
    {$endif}
    pmOpenRecentMenu: TlqPopupMenu;
    miFile: TlqMenuItem;
    miRecentProjects: TlqMenuItem;
    FRecentFiles: TlqMRU;
    FRegex: TRegExpr;
    FKeywordFont: TlqFont;
    FFileMonitor: TFileMonitor;
    FLastSearchText: TlqString;
    FLastFindOptions: TlqFindOptions;
    FLastFindBackward: Boolean;
    procedure   MonitoredFileChanged(Sender: TObject; AData: TFileMonitorEventData);
    procedure   FormShow(Sender: TObject);
    procedure   FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure   btnQuitClicked(Sender: TObject);
    procedure   btnOpenFileClicked(Sender: TObject);
    procedure   miFileNewUnit(Sender: TObject);
    procedure   miFileSave(Sender: TObject);
    procedure   miFileSaveAs(Sender: TObject);
    procedure   miEditCutClicked(Sender: TObject);
    procedure   miEditCopyClicked(Sender: TObject);
    procedure   miEditPasteClicked(Sender: TObject);
    procedure   miFindClicked(Sender: TObject);
    procedure   miFindNextClicked(Sender: TObject);
    procedure   miFindPrevClicked(Sender: TObject);
    procedure   miGoToLineClick(Sender: TObject);
    procedure   miSearchProcedureList(Sender: TObject);
    procedure   miAbouTlquiClicked(Sender: TObject);
    procedure   miAboutIDE(Sender: TObject);
    procedure   miRunMake(Sender: TObject);
    procedure   miRunBuild(Sender: TObject);
    procedure   miRunMake1(Sender: TObject);
    procedure   miRunMake2(Sender: TObject);
    procedure   miRunMake3(Sender: TObject);
    procedure   miRunMake4(Sender: TObject);
    procedure   miConfigureIDE(Sender: TObject);
    procedure   miViewDebug(Sender: TObject);
    procedure   miProjectNew(Sender: TObject);
    procedure   miProjectNewFromTemplate(Sender: TObject);
    procedure   miProjectOptions(Sender: TObject);
    procedure   miProjectOpen(Sender: TObject);
    procedure   miRecentProjectsClick(Sender: TObject; const FileName: String);
    procedure   miProjectSave(Sender: TObject);
    procedure   miProjectSaveAs(Sender: TObject);
    procedure   AddUnitToProject(const AUnitName: TlqString);
    procedure   miProjectAddUnitToProject(Sender: TObject);
    procedure   tvProjectDoubleClick(Sender: TObject; AButton: TMouseButton; AShift: TShiftState; const AMousePos: TPoint);
    procedure   grdMessageKeyPressed(Sender: TObject; var KeyCode: Word; var ShiftState: TShiftState; var Consumed: Boolean);
    procedure   TabSheetClosing(Sender: TObject; ATabSheet: TlqTabSheet);
    procedure   BuildTerminated(Sender: TObject);
    procedure   BuildOutput(Sender: TObject; const ALine: string);
    procedure   UpdateStatus(const AText: TlqString);
    procedure   SetupProjectTree;
    procedure   PopuplateProjectTree;
    procedure   SetupFilesGrid;
    procedure   AddMessage(const AMsg: TlqString);
    procedure   ClearMessagesWindow;
    procedure   CloseAllTabs;
    procedure   LoadProject(const AFilename: TlqString);
    function    CreateNewEditorTab(const ATitle: TlqString): TlqTabSheet;
    function    OpenEditorPage(const AFilename: TlqString): TlqTabSheet;
    procedure   miTest(Sender: TObject);
    function    GetUnitsNode: TlqTreeNode;
    procedure   UpdateWindowTitle;
    procedure   HighlightObjectPascal(Sender: TObject; ALineText: TlqString; ALineIndex: Integer; ACanvas: TlqCanvas; ATextRect: TlqRect; var AllowSelfDraw: Boolean);
    procedure   HighlightPatch(Sender: TObject; ALineText: TlqString; ALineIndex: Integer; ACanvas: TlqCanvas; ATextRect: TlqRect; var AllowSelfDraw: Boolean);
    procedure   SetupEditorPreference;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure   AfterCreate; override;
  end;

{@VFD_NEWFORM_DECL}

implementation

uses
  process
  ,lq_iniutils
  ,lq_dialogs
  ,lq_utils
  ,lq_stringutils
  ,lq_constants
  ,lq_widget
  ,frm_configureide
  ,frm_projectoptions
  ,frm_debug
  ,frm_procedurelist
  ,frm_find
  ,lq_basegrid
  ,ideconst
  ,idemacros
  ,Project
  ,UnitList
  ,BuilderThread
  {$IFDEF DEBUGSVR}
  ,dbugintf
  {$ENDIF}
  ,ideutils
  ;


const
  cTitle = 'Maximus IDE - %s';
  cFileFilterTemplate  = '%s (%s)|%s';
  cSourceFiles = '*.pas;*.pp;*.lpr;*.dpr;*.inc';
  cProjectFiles = '*.project';


{@VFD_NEWFORM_IMPL}

procedure TMainForm.btnQuitClicked(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.btnOpenFileClicked(Sender: TObject);
var
  s: TlqString;
begin
  s := SelectFileDialog(sfdOpen, Format(cFileFilterTemplate, ['Source Files', cSourceFiles, cSourceFiles]));
  if s <> '' then
  begin
    OpenEditorPage(s);
  end;
end;

procedure TMainForm.miFileNewUnit(Sender: TObject);
var
  newunit: TlqString;
  sl: TStringList;
  FInternalMacroList: TIDEMacroList;
  i: integer;
begin
  if lqInputQuery('New Unit', 'Please give the new unit a file name', newunit) then
  begin
    if GProject.UnitList.FileExists(newunit) then
    begin
      ShowMessage(Format('The unit <%s> already exists in the project', [newunit]));
      Exit;
    end;
    sl := TStringList.Create;
    try
      sl.LoadFromFile(GMacroList.ExpandMacro('${TEMPLATEDIR}default/unit.pas'));
      sl.Text := StringReplace(sl.Text, '${UNITNAME}', lqChangeFileExt(lqExtractFileName(newunit), ''), [rfReplaceAll, rfIgnoreCase]);
      sl.SaveToFile(GProject.ProjectDir + newunit);
    finally
      sl.Free;
    end;
//    AddUnitToProject(newunit);

    OpenEditorPage(newunit);
  end;
end;

procedure TMainForm.miFileSave(Sender: TObject);
var
  s: TlqString;
begin
  s := pcEditor.ActivePage.Hint;
  if s <> '' then
    TlqTextEdit(pcEditor.ActivePage.Components[0]).SaveToFile(s);
  AddMessage('File saved');
end;

procedure TMainForm.miFileSaveAs(Sender: TObject);
var
  s: TlqString;
begin
  s := SelectFileDialog(sfdSave);
  if s <> '' then
    TlqTextEdit(pcEditor.ActivePage.Components[0]).SaveToFile(s);
end;

procedure TMainForm.miEditCutClicked(Sender: TObject);
var
  edt: TlqTextEdit;
begin
  edt := TlqTextEdit(pcEditor.ActivePage.Components[0]);
  edt.CutToClipboard;
end;

procedure TMainForm.miEditCopyClicked(Sender: TObject);
var
  edt: TlqTextEdit;
begin
  edt := TlqTextEdit(pcEditor.ActivePage.Components[0]);
  edt.CopyToClipboard;
end;

procedure TMainForm.miEditPasteClicked(Sender: TObject);
var
  edt: TlqTextEdit;
begin
  edt := TlqTextEdit(pcEditor.ActivePage.Components[0]);
  edt.PasteFromClipboard;
end;

procedure TMainForm.miFindClicked(Sender: TObject);
var
  s: TlqString;
  edt: TlqTextEdit;
begin
  FLastFindBackward := False;
  FLastFindOptions := [];
  DisplayFindForm(s, FLastFindOptions, FLastFindBackward);
  if s = '' then
    exit;
  FLastSearchText := s;
  edt := TlqTextEdit(pcEditor.ActivePage.Components[0]);
  edt.FindText(s, FLastFindOptions, FLastFindBackward);
  edt.SetFocus;
end;

procedure TMainForm.miFindNextClicked(Sender: TObject);
var
  edt: TlqTextEdit;
begin
  if FLastSearchText = '' then
    Exit;
  FLastFindBackward := False;
  edt := TlqTextEdit(pcEditor.ActivePage.Components[0]);
  if not Assigned(edt) then
    Exit;
  edt.FindText(FLastSearchText, FLastFindOptions, FLastFindBackward);
  edt.SetFocus;
end;

procedure TMainForm.miFindPrevClicked(Sender: TObject);
var
  edt: TlqTextEdit;
begin
  if FLastSearchText = '' then
    Exit;
  FLastFindBackward := True;
  edt := TlqTextEdit(pcEditor.ActivePage.Components[0]);
  if not Assigned(edt) then
    Exit;
  edt.FindText(FLastSearchText, FLastFindOptions, FLastFindBackward);
  edt.SetFocus;
end;

procedure TMainForm.miGoToLineClick(Sender: TObject);
var
  sValue: string;
  i: integer;
  edt: TlqTextEdit;
begin
  edt := TlqTextEdit(pcEditor.ActivePage.Components[0]);
  if not Assigned(edt) then
    Exit;
  if lqInputQuery('Go to line', 'Go to line number?', sValue) then
  begin
    try
      i := StrToInt(sValue);
      edt.GotoLine(i);
    except
      on E: Exception do
         ShowMessage('Invalid line number.' + LineEnding + E.Message);
    end;
  end;
end;

procedure TMainForm.miSearchProcedureList(Sender: TObject);
var
  s: TlqString;
  edt: TlqTextEdit;
begin
  s := pcEditor.ActivePage.Hint;
  if s <> '' then
  begin
    edt := TlqTextEdit(pcEditor.ActivePage.Components[0]);
    DisplayProcedureList(s, edt);
  end;
end;

procedure TMainForm.miAbouTlquiClicked(Sender: TObject);
begin
  TlqMessageDialog.AbouTlqui;
end;

procedure TMainForm.miAboutIDE(Sender: TObject);
begin
  TlqMessageDialog.Information('About LiteKit IDE',
      'LiteKit IDE version ' + FPGUI_VERSION + LineEnding + LineEnding
      + 'Created by Graeme Geldenhuys' + LineEnding
      + 'Compiled with FPC ' + FPCVersion);
end;

procedure TMainForm.miRunMake(Sender: TObject);
var
  thd: TBuilderThread;
begin
  ClearMessagesWindow;
  thd := TBuilderThread.Create(True);
  thd.OnTerminate := @BuildTerminated;
  thd.OnAvailableOutput := @BuildOutput;
  thd.Resume;
end;

procedure TMainForm.miRunBuild(Sender: TObject);
var
  thd: TBuilderThread;
begin
  ClearMessagesWindow;
  thd := TBuilderThread.Create(True);
  thd.BuildMode := 1;
  thd.OnTerminate := @BuildTerminated;
  thd.OnAvailableOutput := @BuildOutput;
  thd.Resume;
end;

procedure TMainForm.miRunMake1(Sender: TObject);
var
  thd: TBuilderThread;
begin
  ClearMessagesWindow;
  thd := TBuilderThread.Create(True);
  thd.BuildMode := 2;
  thd.OnTerminate := @BuildTerminated;
  thd.OnAvailableOutput := @BuildOutput;
  thd.Resume;
end;

procedure TMainForm.miRunMake2(Sender: TObject);
var
  thd: TBuilderThread;
begin
  ClearMessagesWindow;
  thd := TBuilderThread.Create(True);
  thd.BuildMode := 3;
  thd.OnTerminate := @BuildTerminated;
  thd.OnAvailableOutput := @BuildOutput;
  thd.Resume;
end;

procedure TMainForm.miRunMake3(Sender: TObject);
var
  thd: TBuilderThread;
begin
  ClearMessagesWindow;
  thd := TBuilderThread.Create(True);
  thd.BuildMode := 4;
  thd.OnTerminate := @BuildTerminated;
  thd.OnAvailableOutput := @BuildOutput;
  thd.Resume;
end;

procedure TMainForm.miRunMake4(Sender: TObject);
var
  thd: TBuilderThread;
begin
  ClearMessagesWindow;
  thd := TBuilderThread.Create(True);
  thd.BuildMode := 5;
  thd.OnTerminate := @BuildTerminated;
  thd.OnAvailableOutput := @BuildOutput;
  thd.Resume;
end;

procedure TMainForm.miConfigureIDE(Sender: TObject);
begin
  DisplayConfigureIDE;
  SetupEditorPreference;
end;

procedure TMainForm.miViewDebug(Sender: TObject);
begin
  if not Assigned(DebugForm) then
    lqApplication.CreateForm(TDebugForm, TlqWindowBase(DebugForm));
  DebugForm.Show;
end;

procedure TMainForm.miProjectNew(Sender: TObject);
begin
  CloseAllTabs;
  FreeProject;
  GProject.ProjectName := 'empty.project';
  GProject.MainUnit := 'empty.pas';
  OpenEditorPage(GProject.MainUnit);
  miProjectSaveAs(nil);
end;

procedure TMainForm.miProjectNewFromTemplate(Sender: TObject);
var
  dlg: TlqFileDialog;
  lFilename: TlqString;
begin
  CloseAllTabs;
  FreeProject;
  dlg := TlqFileDialog.Create(nil);
  try
    dlg.InitialDir := GMacroList.ExpandMacro(cMacro_TemplateDir);
    dlg.Filter := Format(cFileFilterTemplate, ['Project Files', cProjectFiles, cProjectFiles])
                  + '|' + rsAllFiles+' ('+AllFilesMask+')'+'|'+AllFilesMask;
    if dlg.RunOpenFile then
    begin
      lFilename := dlg.FileName;
      GProject.Load(lFilename);
    end;
  finally
    dlg.Free;
  end;
end;

procedure TMainForm.miProjectOptions(Sender: TObject);
begin
  DisplayProjectOptions;
end;

procedure TMainForm.miProjectOpen(Sender: TObject);
var
  s: TlqString;
begin
  s := SelectFileDialog(sfdOpen, Format(cFileFilterTemplate, ['Project Files', cProjectFiles, cProjectFiles]));
  if s <> '' then
  begin
    LoadProject(s);
  end;
end;

procedure TMainForm.miRecentProjectsClick(Sender: TObject; const FileName: String);
begin
  LoadProject(Filename);
end;

procedure TMainForm.miProjectSave(Sender: TObject);
begin
  try
    GProject.Save;
  except
    on E: Exception do
    begin
      TlqMessageDialog.Critical('', E.Message);
    end;
  end;
  AddMessage('Project saved.');
end;

procedure TMainForm.miProjectSaveAs(Sender: TObject);
var
  s: TlqString;
begin
  s := SelectFileDialog(sfdSave, Format(cFileFilterTemplate, ['Project Files', cProjectFiles, cProjectFiles]));
  if s <> '' then
  begin
    if lqExtractFileExt(s) = '' then
      s := s + cProjectExt;
    try
      GProject.Save(s);
      FRecentFiles.AddItem(s);
    except
      on E: Exception do
      begin
        TlqMessageDialog.Critical('', E.Message);
      end;
    end;
    UpdateWindowTitle;
    AddMessage(Format('Project saved as <%s>.', [s]));
  end;
end;

procedure TMainForm.AddUnitToProject(const AUnitName: TlqString);
var
  u: TUnit;
  s: TlqString;
  r: TlqTreeNode;
  n: TlqTreeNode;
begin
  u := TUnit.Create;
  u.FileName := AUnitName;
  u.Opened := True;
  GProject.UnitList.Add(u);
  // add reference to tabsheet
  pcEditor.ActivePage.TagPointer := u;
  s := lqExtractRelativepath(GProject.ProjectDir, u.FileName);
  r := GetUnitsNode;
  n := r.AppendText(s);
  // add reference to treenode
  n.Data := u;
  tvProject.Invalidate;
end;

procedure TMainForm.miProjectAddUnitToProject(Sender: TObject);
var
  s: TlqString;
begin
  s := pcEditor.ActivePage.Hint;
//  writeln('adding unit: ', s);
  if s = '' then
    Exit;
  if GProject.UnitList.FileExists(s) then
    Exit;
  AddUnitToProject(s);
end;

procedure TMainForm.tvProjectDoubleClick(Sender: TObject; AButton: TMouseButton; AShift: TShiftState; const AMousePos: TPoint);
var
  r: TlqTreeNode;
  n: TlqTreeNode;
  ts: TlqTabSheet;
  u: TUnit;
begin
  r := GetUnitsNode;
  n := tvProject.Selection;
  if n.Data <> nil then
    u := TUnit(n.Data);
  if u <> nil then
  begin
    ts := OpenEditorPage(u.FileName);
    u.Opened := True;
    ts.TagPointer := u; // add reference to tabsheet
  end;
end;

procedure TMainForm.grdMessageKeyPressed(Sender: TObject; var KeyCode: Word; var ShiftState: TShiftState; var Consumed: Boolean);
var
  cr: TClipboardKeyType;
  i: integer;
  s: TlqString;
begin
  cr := CheckClipboardKey(KeyCode, ShiftState);
  if cr = ckCopy then
  begin
    s := '';
    for i := 0 to grdMessages.RowCount-1 do
      s := s + grdMessages.Cells[0, i] + LineEnding;
    lqClipboard.Text := s;
  end;
end;

procedure TMainForm.TabSheetClosing(Sender: TObject; ATabSheet: TlqTabSheet);
var
  u: TUnit;
begin
  u := TUnit(ATabSheet.TagPointer);
  if Assigned(u) then
  begin
    FFileMonitor.RemoveFile(u.FileName);
    u.Opened := False;
  end;
end;

procedure TMainForm.BuildTerminated(Sender: TObject);
begin
  AddMessage('Compilation complete');
end;

procedure TMainForm.BuildOutput(Sender: TObject; const ALine: string);
begin
  AddMessage(ALine);
end;

procedure TMainForm.UpdateStatus(const AText: TlqString);
begin
  lblStatus.Text := AText;
end;

procedure TMainForm.SetupProjectTree;
begin
  tvProject.RootNode.Clear;
  tvProject.RootNode.AppendText('Units');
  tvProject.RootNode.AppendText('Images');
  tvProject.RootNode.AppendText('Help Files');
  tvProject.RootNode.AppendText('Text');
  tvProject.RootNode.AppendText('Other');
end;

procedure TMainForm.PopuplateProjectTree;
var
  r: TlqTreeNode;
  n: TlqTreeNode;
  i: integer;
  s: TlqString;
begin
  r := GetUnitsNode;
  tvProject.Selection := r;
  if Assigned(r) then // just to be safe, but 'Units' should always exist
  begin
    for i := 0 to GProject.UnitList.Count-1 do
    begin
      s := lqExtractRelativepath(GProject.ProjectDir, GProject.UnitList[i].FileName);
      n := r.AppendText(s);
      n.Data := GProject.UnitList[i];
    end;
  end;
  r.Expand;
  tvProject.Invalidate;
end;

procedure TMainForm.SetupFilesGrid;
begin
  grdFiles.FileList.FileMask := AllFilesMask;
  grdFiles.FileList.ShowHidden := False;
  grdFiles.FileList.ReadDirectory;
  grdFiles.FileList.Sort(soFileName);
  grdFiles.Invalidate;
end;

procedure TMainForm.AddMessage(const AMsg: TlqString);
begin
  grdMessages.BeginUpdate;
  grdMessages.RowCount := grdMessages.RowCount + 1;
  grdMessages.Cells[0,grdMessages.RowCount-1] := AMsg;
  grdMessages.FocusRow := grdMessages.RowCount;
  grdMessages.EndUpdate;
//  lqApplication.ProcessMessages;
end;

procedure TMainForm.ClearMessagesWindow;
begin
  grdMessages.RowCount := 0;
end;

procedure TMainForm.CloseAllTabs;
var
  ts: TlqTabSheet;
  i: integer;
begin
  pcEditor.BeginUpdate;
  try
    for i := 0 to pcEditor.PageCount-1 do
    begin
      ts := pcEditor.Pages[0];
      pcEditor.RemoveTabSheet(ts);
      ts.Free;
    end;
  finally
    pcEditor.EndUpdate;
  end;
end;

procedure TMainForm.LoadProject(const AFilename: TlqString);
var
  i: integer;
  ts: TlqTabSheet;
begin
  // remove all project info
  CloseAllTabs;
  SetupProjectTree;
  FreeProject;
  // now load new project info
  GProject.Load(AFilename);
  FRecentFiles.AddItem(AFilename);
  for i := 0 to GProject.UnitList.Count-1 do
  begin
    if GProject.UnitList[i].Opened then
    begin
      ts := OpenEditorPage(GProject.UnitList[i].FileName);
      ts.TagPointer := GProject.UnitList[i];
    end;
  end;
  PopuplateProjectTree;
  UpdateWindowTitle;
  AddMessage('Project loaded');
end;

function TMainForm.CreateNewEditorTab(const ATitle: TlqString): TlqTabSheet;
var
  m: TlqTextEdit;
begin
  Result := pcEditor.AppendTabSheet(ATitle);
  m := TlqTextEdit.Create(Result);
  m.SetPosition(1, 1, 200, 20);
  m.Align := alClient;
  m.FontDesc := gINI.ReadString(cEditor, 'Font', '#Edit2');
  m.GutterVisible := True;
  m.GutterShowLineNumbers := True;
  m.RightEdge := True;
end;

function TMainForm.OpenEditorPage(const AFilename: TlqString): TlqTabSheet;
var
  s: TlqString;
  f: TlqString;
  i: integer;
  found: Boolean;
  ts: TlqTabSheet;
  ext: TlqString;
  pos_h: integer;
  pos_v: integer;
  cur_pos_h: integer;
  cur_pos_v: integer;
  editor: TlqTextEdit;
begin
  s := AFilename;
  f := lqExtractFileName(s);
  found := False;
  for i := 0 to pcEditor.PageCount-1 do
  begin
    if pcEditor.Pages[i].Text = f then
      found := True;
    if found then
      break;
  end;
  if found then
  begin
    // reuse existing tab
    editor := TlqTextEdit(pcEditor.Pages[i].Components[0]);
    pos_h := editor.ScrollPos_H;
    pos_v := editor.ScrollPos_V;
    cur_pos_h := editor.CaretPos_H;
    cur_pos_v := editor.CaretPos_V;
    editor.Lines.BeginUpdate;
    editor.LoadFromFile(s);
    editor.ScrollPos_H := pos_h;
    editor.ScrollPos_V := pos_v;
    editor.CaretPos_H := cur_pos_h;
    editor.CaretPos_V := cur_pos_v;
    editor.UpdateScrollBars;
    editor.Lines.EndUpdate;
    pcEditor.ActivePageIndex := i;
    ts := pcEditor.ActivePage;
    AddMessage('File reloaded: ' + s);
  end
  else
  begin
    // we need a new tabsheet
    ts := CreateNewEditorTab(f);
    editor := ts.Components[0] as TlqTextEdit;
    editor.Lines.BeginUpdate;
    if lqFileExists(s) then
      editor.Lines.LoadFromFile(s);
    editor.Lines.EndUpdate;
    if gINI.ReadBool(cEditor, 'SyntaxHighlighting', True) then
    begin
      ext := lqExtractFileExt(AFilename);
      if (ext = '.pas') or (ext = '.pp') or (ext = '.inc') or (ext = '.lpr') or (ext = '.dpr') then
      begin
        TlqTextEdit(ts.Components[0]).OnDrawLine := @HighlightObjectPascal;
      end
      else if (ext = '.patch') or (ext = '.diff') then
      begin
        TlqTextEdit(ts.Components[0]).OnDrawLine := @HighlightPatch;
      end;
    end;
    ts.Realign;
    pcEditor.ActivePage := ts;
    FFileMonitor.AddFile(AFilename);
  end;
  ts.Hint := s;
  Result := ts;
  UpdateStatus(s);
end;

procedure TMainForm.miTest(Sender: TObject);
var
  s: TlqString;
  r: TlqString;
begin
  {$ifdef DEBUGSVR}
  TempHourGlassCursor(TlqWidget(self));
  s := cMacro_Compiler + ' -FU' +cMacro_Target+' -Fu' + cMacro_FPGuiLibDir;
  SendDebug('source string = ' + s);
  r := GMacroList.ExpandMacro(s);
  SendDebug('expanded string = ' + r);
  sleep(5000);
  {$endif}
end;

function TMainForm.GetUnitsNode: TlqTreeNode;
begin
  Result := tvProject.RootNode.FindSubNode('Units', True);
end;

procedure TMainForm.UpdateWindowTitle;
begin
  WindowTitle := Format(cTitle, [GProject.ProjectName]);
end;

procedure TMainForm.HighlightObjectPascal(Sender: TObject; ALineText: TlqString;
  ALineIndex: Integer; ACanvas: TlqCanvas; ATextRect: TlqRect;
  var AllowSelfDraw: Boolean);
const
  { nicely working so far }
  cKeywords1 = '\b(begin|end|read|write|with|try|finally|except|uses|interface'
    + '|implementation|procedure|function|constructor|destructor|property|operator'
    + '|private|protected|public|published|type|virtual|abstract|overload'
    + '|override|class|unit|program|library|set|of|if|then|for|downto|to|as|div|mod|shr|shl'
    + '|do|else|while|and|inherited|const|var|initialization|finalization'
    + '|on|or|in|raise|not|case|record|array|out|resourcestring|default'
    + '|xor|repeat|until|constref|stdcall|cdecl|external|generic|specialize)\b';

  cComments1 = '(\s*\/\/.*$)|(\{[^\{]*\})';
  cComments2 = '\{[^\{]*\}';

  cDefines1 = '\{\$[^\{]*\}';

  cString1 = '''.*''';

  cDecimal = '\b(([0-9]+)|([0-9]+\.[0-9]+([Ee][-]?[0-9]+)?))\b';
  cHexadecimal = '\$[0-9a-fA-F]+';
var
  oldfont: TlqFont;
  s: TlqString;  // copy of ALineText we work with
  i, j, c: integer;  // i = position of reserved word; c = last character pos
  iLength: integer; // length of reserved word
  w: integer;     // reserved word loop variable
  r: TlqRect;    // string rectangle to draw in
  edt: TlqTextEdit;
  lMatchPos, lOffset: integer; // user for regex
begin
//  writeln('syntax highlight line: ', ALineIndex);
  edt := TlqTextEdit(Sender);
  AllowSelfDraw := False;

  oldfont := TlqFont(ACanvas.Font);
  ACanvas.Color := clWhite;

  { draw the plain text first }
  ACanvas.TextColor := clBlack;
  ACanvas.DrawText(ATextRect, ALineText);

  lMatchPos := 0;
  lOffset := 0;

  { syntax highlighting for: keywords }
  if not Assigned(FKeywordFont) then
    FKeywordFont := lqGetFont(edt.FontDesc + ':bold');
  ACanvas.Font := FKeywordFont;
  FRegex.Expression := cKeywords1;
  FRegex.ModifierI := True;
  if FRegex.Exec(ALineText) then
  begin
    repeat { process results }
        lMatchPos := FRegex.MatchPos[1];
        lOffset := FRegex.MatchLen[1];
        s := FRegex.Match[1];
        j := Length(s);
        r.SetRect(ATextRect.Left + (edt.FontWidth * (lMatchPos-1)), ATextRect.Top,
            (edt.FontWidth * j), ATextRect.Height);
        ACanvas.FillRectangle(r);
        ACanvas.DrawText(r, s);
    until not FRegex.ExecNext;
  end;

  ACanvas.Font := oldfont;

  { syntax highlighting for: cDecimal }
  ACanvas.TextColor := clNavy;
  FRegex.Expression := cDecimal;
  if FRegex.Exec(ALineText) then
  begin
    repeat
      lMatchPos := FRegex.MatchPos[0];
      lOffset := FRegex.MatchLen[0];
      s := FRegex.Match[0];
      j := Length(s);
      r.SetRect(ATextRect.Left + (edt.FontWidth * (lMatchPos-1)), ATextRect.Top,
          (edt.FontWidth * j), ATextRect.Height);
      ACanvas.FillRectangle(r);
      ACanvas.DrawText(r, s);
    until not FRegex.ExecNext;
  end;

  { syntax highlighting for: cHexadecimal }
  ACanvas.TextColor := clMagenta;
  FRegex.Expression := cHexadecimal;
  if FRegex.Exec(ALineText) then
  begin
    repeat
      lMatchPos := FRegex.MatchPos[0];
      lOffset := FRegex.MatchLen[0];
      s := FRegex.Match[0];
      j := Length(s);
      r.SetRect(ATextRect.Left + (edt.FontWidth * (lMatchPos-1)), ATextRect.Top,
          (edt.FontWidth *j), ATextRect.Height);
      ACanvas.FillRectangle(r);
      ACanvas.DrawText(r, s);
    until not FRegex.ExecNext;
  end;

  { syntax highlighting for: comments2 }
  ACanvas.TextColor := clDarkCyan;
  FRegex.Expression := cComments2;
  if FRegex.Exec(ALineText) then
  begin
    repeat
      lMatchPos := FRegex.MatchPos[0];
      lOffset := FRegex.MatchLen[0];
      s := FRegex.Match[0];
      j := Length(s);
      r.SetRect(ATextRect.Left + (edt.FontWidth * (lMatchPos-1)), ATextRect.Top,
          (edt.FontWidth * j), ATextRect.Height);
      ACanvas.FillRectangle(r);
      ACanvas.DrawText(r, s);
    until not FRegex.ExecNext;
  end;

  { syntax highlighting for: cDefines1 }
  ACanvas.TextColor := clRed;
  FRegex.Expression := cDefines1;
  if FRegex.Exec(ALineText) then
  begin
    repeat
      lMatchPos := FRegex.MatchPos[0];
      lOffset := FRegex.MatchLen[0];
      s := FRegex.Match[0];
      j := Length(s);
      r.SetRect(ATextRect.Left + (edt.FontWidth * (lMatchPos-1)), ATextRect.Top,
          (edt.FontWidth * j), ATextRect.Height);
      ACanvas.FillRectangle(r);
      ACanvas.DrawText(r, s);
    until not FRegex.ExecNext;
  end;

  { syntax highlighting for: cString1 }
  ACanvas.TextColor := clOlive;
  FRegex.Expression := cString1;
  if FRegex.Exec(ALineText) then
  begin
    repeat
      lMatchPos := FRegex.MatchPos[0];
      lOffset := FRegex.MatchLen[0];
      s := FRegex.Match[0];
      j := Length(s);
      r.SetRect(ATextRect.Left + (edt.FontWidth * (lMatchPos-1)), ATextRect.Top,
          (edt.FontWidth * j), ATextRect.Height);
      ACanvas.FillRectangle(r);
      ACanvas.DrawText(r, s);
    until not FRegex.ExecNext;
  end;

  { syntax highlighting for: comments1 }
  ACanvas.TextColor := clDarkCyan;
  FRegex.Expression := cComments1;
  if FRegex.Exec(ALineText) then
  begin
    lMatchPos := FRegex.MatchPos[1];
    lOffset := FRegex.MatchLen[1];
    s := FRegex.Match[1];
    j := Length(s);
    r.SetRect(ATextRect.Left + (edt.FontWidth * (lMatchPos-1)), ATextRect.Top,
        (edt.FontWidth * j), ATextRect.Height);
    ACanvas.FillRectangle(r);
    ACanvas.DrawText(r, s);
  end;

  ACanvas.Font := oldfont;
//  writeln('------');
end;

procedure TMainForm.HighlightPatch(Sender: TObject; ALineText: TlqString;
  ALineIndex: Integer; ACanvas: TlqCanvas; ATextRect: TlqRect;
  var AllowSelfDraw: Boolean);
const
  cRemovedLines = '^(-[^-]|\<|!).*';        // starts with "-" or "<" or "!" symbols
  cAddedLines = '^(\+[^\+]|\>).*';          // starts with "+" or ">" symbols
  cLeftFile = '^--- .*';                    // starts with "--- " symbols
  cRightFile = '^(\+\+\+|\*\*\*) .*';       // starts with "+++ " or "*** " symbols
  cHunk = '^\@\@.*';                        // starts with "@@" symbols
  cStartOfFile = '^(diff|index) .*';        // starts with "diff " or "index " symbols
var
  oldfont: TlqFont;
  s: TlqString;  // copy of ALineText we work with
  i, j, c: integer;  // i = position of reserved word; c = last character pos
  iLength: integer; // length of reserved word
  w: integer;     // reserved word loop variable
  r: TlqRect;    // string rectangle to draw in
  edt: TlqTextEdit;
  lMatchPos, lOffset: integer; // user for regex
begin
  edt := TlqTextEdit(Sender);
  AllowSelfDraw := False;

  oldfont := TlqFont(ACanvas.Font);
  ACanvas.Color := clWhite;

  { draw the plain text first }
  ACanvas.TextColor := clBlack;
  ACanvas.DrawText(ATextRect, ALineText);

  lMatchPos := 0;
  lOffset := 0;

  { syntax highlighting for: cRemovedLines }
  ACanvas.TextColor := clRed;
  FRegex.Expression := cRemovedLines;
  if FRegex.Exec(ALineText) then
  begin
    repeat
      lMatchPos := FRegex.MatchPos[0];
      lOffset := FRegex.MatchLen[0];
      s := FRegex.Match[0];
      j := Length(s);
      r.SetRect(ATextRect.Left + (edt.FontWidth * (lMatchPos-1)), ATextRect.Top,
          (edt.FontWidth * j), ATextRect.Height);
      ACanvas.FillRectangle(r);
      ACanvas.DrawText(r, s);
    until not FRegex.ExecNext;
  end;

  { syntax highlighting for: cAddedLines }
  ACanvas.TextColor := clGreen;
  FRegex.Expression := cAddedLines;
  if FRegex.Exec(ALineText) then
  begin
    repeat
      lMatchPos := FRegex.MatchPos[0];
      lOffset := FRegex.MatchLen[0];
      s := FRegex.Match[0];
      j := Length(s);
      r.SetRect(ATextRect.Left + (edt.FontWidth * (lMatchPos-1)), ATextRect.Top,
          (edt.FontWidth * j), ATextRect.Height);
      ACanvas.FillRectangle(r);
      ACanvas.DrawText(r, s);
    until not FRegex.ExecNext;
  end;

  { syntax highlighting for: cLeftFile }
  ACanvas.TextColor := clMagenta;
  FRegex.Expression := cLeftFile;
  if FRegex.Exec(ALineText) then
  begin
    repeat
      lMatchPos := FRegex.MatchPos[0];
      lOffset := FRegex.MatchLen[0];
      s := FRegex.Match[0];
      j := Length(s);
      r.SetRect(ATextRect.Left + (edt.FontWidth * (lMatchPos-1)), ATextRect.Top,
          (edt.FontWidth * j), ATextRect.Height);
      ACanvas.FillRectangle(r);
      ACanvas.DrawText(r, s);
    until not FRegex.ExecNext;
  end;

  { syntax highlighting for: cRightFile }
  ACanvas.TextColor := clMagenta;
  FRegex.Expression := cRightFile;
  if FRegex.Exec(ALineText) then
  begin
    repeat
      lMatchPos := FRegex.MatchPos[0];
      lOffset := FRegex.MatchLen[0];
      s := FRegex.Match[0];
      j := Length(s);
      r.SetRect(ATextRect.Left + (edt.FontWidth * (lMatchPos-1)), ATextRect.Top,
          (edt.FontWidth * j), ATextRect.Height);
      ACanvas.FillRectangle(r);
      ACanvas.DrawText(r, s);
    until not FRegex.ExecNext;
  end;

  { syntax highlighting for: cHunk }
  ACanvas.TextColor := clBlue;
  FRegex.Expression := cHunk;
  if FRegex.Exec(ALineText) then
  begin
    repeat
      lMatchPos := FRegex.MatchPos[0];
      lOffset := FRegex.MatchLen[0];
      s := FRegex.Match[0];
      j := Length(s);
      r.SetRect(ATextRect.Left + (edt.FontWidth * (lMatchPos-1)), ATextRect.Top,
          (edt.FontWidth * j), ATextRect.Height);
      ACanvas.FillRectangle(r);
      ACanvas.DrawText(r, s);
    until not FRegex.ExecNext;
  end;

  { syntax highlighting for: cStartOfFile }
  ACanvas.TextColor := clBlack;
  ACanvas.Color := clSilver;
  FRegex.Expression := cStartOfFile;
  if FRegex.Exec(ALineText) then
  begin
    repeat
      lMatchPos := FRegex.MatchPos[0];
      lOffset := FRegex.MatchLen[0];
      s := FRegex.Match[0];
      j := Length(s);
      r.SetRect(ATextRect.Left + (edt.FontWidth * (lMatchPos-1)), ATextRect.Top,
          (edt.FontWidth * j), ATextRect.Height);
      ACanvas.FillRectangle(r);
      ACanvas.DrawText(r, s);
    until not FRegex.ExecNext;
  end;
  ACanvas.Color := clWhite;

  ACanvas.Font := oldfont;
end;

procedure TMainForm.SetupEditorPreference;
var
  i: integer;
begin
  pcEditor.TabPosition := TlqTabPosition(gINI.ReadInteger(cEditor, 'TabPosition', 0));
  pcEditor.ActiveTabColor := TlqColor(gINI.ReadInteger(cEditor, 'ActiveTabColor', pcEditor.BackgroundColor));
  FKeywordFont.Free;
  FKeywordFont := nil;
  for i := 0 to pcEditor.PageCount-1 do
    TlqTextEdit(pcEditor.Pages[i].Components[0]).FontDesc := gINI.ReadString(cEditor, 'Font', '#Edit2');
end;

procedure TMainForm.MonitoredFileChanged(Sender: TObject; AData: TFileMonitorEventData);
begin
  OpenEditorPage(AData.FileName);
end;

procedure TMainForm.FormShow(Sender: TObject);
var
  lErrPos: integer;
begin
  {$IFDEF DEBUGSVR}SendMethodEnter('TMainForm.FormShow');{$ENDIF}
  Left := gINI.ReadInteger(Name + 'State', 'Left', Left);
  Top := gINI.ReadInteger(Name + 'State', 'Top', Top);
  Width := gINI.ReadInteger(Name + 'State', 'Width', Width);
  Height := gINI.ReadInteger(Name + 'State', 'Height', Height);
  UpdateWindowPosition;

  SetupProjectTree;
  SetupFilesGrid;
  SetupEditorPreference;

  FRegex := TRegExpr.Create;

  TextEditor.Clear;
  TextEditor.SetFocus;

  FFileMonitor.Resume;
  {$IFDEF DEBUGSVR}SendMethodExit('TMainForm.FormShow');{$ENDIF}
end;

procedure TMainForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CloseAction := caFree;
  gINI.WriteInteger(Name + 'State', 'Left', Left);
  gINI.WriteInteger(Name + 'State', 'Top', Top);
  gINI.WriteInteger(Name + 'State', 'Width', Width);
  gINI.WriteInteger(Name + 'State', 'Height', Height);
end;

constructor TMainForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  OnShow  := @FormShow;
  OnClose := @FormClose;
  {$IFDEF DEBUGSVR}
  SendDebug('TMainForm.Create');
  {$ENDIF}
  FFileMonitor := TFileMonitor.CreateCustom;
  FFileMonitor.OnFileChanged  := @MonitoredFileChanged;
end;

destructor TMainForm.Destroy;
begin
  FFileMonitor.Terminate;
  FFileMonitor.Free;
  FRegex.Free;
  FKeywordFont.Free;
  inherited Destroy;
end;

procedure TMainForm.AfterCreate;
begin
  {$IFDEF DEBUGSVR}
  SendMethodEnter('TMainForm.AfterCreate');
  {$ENDIF}
  {%region 'Auto-generated GUI code' -fold}
  {@VFD_BODY_BEGIN: MainForm}
  Name := 'MainForm';
  SetPosition(310, 206, 638, 428);
  WindowTitle := 'LiteKit IDE - %s';
  Hint := '';
  WindowPosition := wpOneThirdDown;
  MinWidth := 580;
  MinHeight := 400;

  pnlMenu := TlqBevel.Create(self);
  with pnlMenu do
  begin
    Name := 'pnlMenu';
    SetPosition(0, 0, 638, 54);
    Align := alTop;
    Hint := '';
    Shape := bsSpacer;
  end;

  mainmenu := TlqMenuBar.Create(pnlMenu);
  with mainmenu do
  begin
    Name := 'mainmenu';
    SetPosition(0, 0, 638, 24);
    Anchors := [anLeft,anRight,anTop];
    Align := alTop;
  end;

  Toolbar := TlqBevel.Create(pnlMenu);
  with Toolbar do
  begin
    Name := 'Toolbar';
    SetPosition(2, 2, 634, 50);
    Anchors := [anLeft,anRight,anTop];
    Align := alClient;
    Hint := '';
    Shape := bsSpacer;
  end;

  btnQuit := TlqButton.Create(Toolbar);
  with btnQuit do
  begin
    Name := 'btnQuit';
    SetPosition(4, 2, 24, 24);
    Text := '';
    Down := False;
    Embedded := True;
    FontDesc := '#Label1';
    Hint := '';
    ImageMargin := 0;
    ImageName := 'stdimg.quit';
    TabOrder := 3;
    OnClick  := @btnQuitClicked;
  end;

  btnOpen := TlqButton.Create(Toolbar);
  with btnOpen do
  begin
    Name := 'btnOpen';
    SetPosition(28, 2, 24, 24);
    Text := '';
    Down := False;
    Embedded := True;
    FontDesc := '#Label1';
    Hint := '';
    ImageMargin := 0;
    ImageName := 'stdimg.open';
    TabOrder := 4;
    OnClick := @btnOpenFileClicked;
  end;

  btnSave := TlqButton.Create(Toolbar);
  with btnSave do
  begin
    Name := 'btnSave';
    SetPosition(56, 2, 24, 24);
    Text := '';
    Down := False;
    Embedded := True;
    FontDesc := '#Label1';
    Hint := '';
    ImageMargin := 0;
    ImageName := 'stdimg.save';
    TabOrder := 5;
    OnClick := @miFileSave;
  end;

  btnSaveAll := TlqButton.Create(Toolbar);
  with btnSaveAll do
  begin
    Name := 'btnSaveAll';
    SetPosition(80, 2, 24, 24);
    Text := '';
    Down := False;
    Embedded := True;
    Enabled := False;
    FontDesc := '#Label1';
    Hint := '';
    ImageMargin := 0;
    ImageName := 'stdimg.saveall';
    TabOrder := 6;
  end;

  pnlStatusBar := TlqBevel.Create(self);
  with pnlStatusBar do
  begin
    Name := 'pnlStatusBar';
    SetPosition(0, 408, 636, 20);
    Anchors := [anLeft,anRight,anBottom];
    Hint := '';
    Style := bsLowered;
  end;

  lblStatus := TlqLabel.Create(pnlStatusBar);
  with lblStatus do
  begin
    Name := 'lblStatus';
    SetPosition(2, 2, 632, 16);
    Anchors := [anLeft,anRight,anTop];
    Align := alBottom;
    FontDesc := '#Label1';
    Hint := '';
    Text := '';
  end;

  pnlClientArea := TlqBevel.Create(self);
  with pnlClientArea do
  begin
    Name := 'pnlClientArea';
    SetPosition(0, 54, 638, 374);
    Anchors := [anLeft,anRight,anTop,anBottom];
    Align := alClient;
    Hint := '';
    Shape := bsSpacer;
  end;

  pnlWindow := TlqPageControl.Create(pnlClientArea);
  with pnlWindow do
  begin
    Name := 'pnlWindow';
    SetPosition(2, 288, 634, 84);
    ActivePageIndex := 0;
    Align := alBottom;
    Hint := '';
    TabOrder := 11;
    TabPosition := tpRight;
  end;

  tsMessages := TlqTabSheet.Create(pnlWindow);
  with tsMessages do
  begin
    Name := 'tsMessages';
    SetPosition(73, 3, 558, 78);
    Text := 'Messages';
  end;

  grdMessages := TlqStringGrid.Create(tsMessages);
  with grdMessages do
  begin
    Name := 'grdMessages';
    SetPosition(0, 4, 558, 73);
    Anchors := [anLeft,anRight,anTop,anBottom];
    BackgroundColor := TlqColor($80000002);
    AddColumn('New', 2000, taLeftJustify);
    FontDesc := '#Grid';
    HeaderFontDesc := '#GridHeader';
    Hint := '';
    RowCount := 0;
    RowSelect := True;
    ShowHeader := False;
    TabOrder := 13;
    OnKeyPress := @grdMessageKeyPressed;
  end;

  tsScribble := TlqTabSheet.Create(pnlWindow);
  with tsScribble do
  begin
    Name := 'tsScribble';
    SetPosition(73, 3, 188, 78);
    Text := 'Scribble';
  end;

  memScribble := TlqMemo.Create(tsScribble);
  with memScribble do
  begin
    Name := 'memScribble';
    SetPosition(0, 4, 187, 73);
    Anchors := [anLeft,anRight,anTop,anBottom];
    FontDesc := '#Edit2';
    Hint := '';
    Lines.Add('Make notes, use it as a clipboard');
    Lines.Add('or type whatever you want...');
    TabOrder := 15;
  end;

  tsTerminal := TlqTabSheet.Create(pnlWindow);
  with tsTerminal do
  begin
    Name := 'tsTerminal';
    SetPosition(73, 3, 188, 78);
    Text := 'Terminal';
  end;

  Splitter1 := TlqSplitter.Create(pnlClientArea);
  with Splitter1 do
  begin
    Name := 'Splitter1';
    SetPosition(2, 281, 634, 7);
    Align := alBottom;
  end;

  pnlTool := TlqPageControl.Create(pnlClientArea);
  with pnlTool do
  begin
    Name := 'pnlTool';
    SetPosition(2, 2, 140, 279);
    ActivePageIndex := 0;
    Align := alLeft;
    Hint := '';
    TabOrder := 18;
  end;

  tsProject := TlqTabSheet.Create(pnlTool);
  with tsProject do
  begin
    Name := 'tsProject';
    SetPosition(3, 24, 134, 252);
    Text := 'Project';
  end;

  tvProject := TlqTreeView.Create(tsProject);
  with tvProject do
  begin
    Name := 'tvProject';
    SetPosition(1, 1, 132, 250);
    Anchors := [anLeft,anRight,anTop,anBottom];
    FontDesc := '#Label1';
    Hint := '';
    TabOrder := 20;
    OnDoubleClick := @tvProjectDoubleClick;
  end;

  tsFiles := TlqTabSheet.Create(pnlTool);
  with tsFiles do
  begin
    Name := 'tsFiles';
    SetPosition(3, 24, 134, 193);
    Text := 'Files';
  end;

  grdFiles := TlqFileGrid.Create(tsFiles);
  with grdFiles do
  begin
    Name := 'grdFiles';
    SetPosition(1, 1, 131, 190);
    Anchors := [anLeft,anRight,anTop,anBottom];
    Options := Options + [go_SmoothScroll];
  end;

  Splitter2 := TlqSplitter.Create(pnlClientArea);
  with Splitter2 do
  begin
    Name := 'Splitter2';
    SetPosition(142, 2, 8, 279);
    Align := alLeft;
  end;

  pcEditor := TlqPageControl.Create(pnlClientArea);
  with pcEditor do
  begin
    Name := 'pcEditor';
    SetPosition(150, 2, 358, 279);
    ActivePageIndex := 0;
    Align := alClient;
    Hint := '';
    TabOrder := 18;
    TabPosition := tpRight;
    Options := Options + [to_PMenuClose];
    OnClosingTabSheet := @TabSheetClosing;
  end;

  tseditor := TlqTabSheet.Create(pcEditor);
  with tseditor do
  begin
    Name := 'tseditor';
    SetPosition(3, 3, 282, 273);
    Text := 'Tabsheet1';
  end;

  TextEditor := TlqTextEdit.Create(tseditor);
  with TextEditor do
  begin
    Name := 'TextEditor';
    SetPosition(0, 0, 130, 200);
    Align := alClient;
    GutterVisible := True;
    GutterShowLineNumbers := True;
    FontDesc := '#Edit2';
  end;

  mnuFile := TlqPopupMenu.Create(self);
  with mnuFile do
  begin
    Name := 'mnuFile';
    SetPosition(476, 61, 172, 20);
    miFile := AddMenuItem('New...', rsKeyCtrl+'N', @miFileNewUnit);
    AddMenuItem('-', '', nil);
    AddMenuItem('Open...', rsKeyCtrl+'O', @btnOpenFileClicked);
    AddMenuItem('Open Recent', '', nil).Enabled := False;
    AddMenuItem('Save', rsKeyCtrl+'S', @miFileSave);
    AddMenuItem('Save As...', '', @miFileSaveAs);
    AddMenuItem('Save All', rsKeyCtrl+rsKeyShift+'S', nil).Enabled := False;
    AddMenuItem('-', '', nil);
    AddMenuItem('Quit', rsKeyCtrl+'Q', @btnQuitClicked);
  end;

  mnuEdit := TlqPopupMenu.Create(self);
  with mnuEdit do
  begin
    Name := 'mnuEdit';
    SetPosition(476, 80, 172, 20);
    AddMenuItem('Cut', rsKeyCtrl+'X', @miEditCutClicked);
    AddMenuItem('Copy', rsKeyCtrl+'C', @miEditCopyClicked);
    AddMenuItem('Paste', rsKeyCtrl+'V', @miEditPasteClicked);
    AddMenuItem('-', '', nil);
    AddMenuItem('Indent selection', rsKeyCtrl+'I', nil).Enabled := False;
    AddMenuItem('Unindent selection', rsKeyCtrl+'U', nil).Enabled := False;
    AddMenuItem('Insert $IFDEF...', rsKeyCtrl+rsKeyShift+'D', nil).Enabled := False;
  end;

  mnuSearch := TlqPopupMenu.Create(self);
  with mnuSearch do
  begin
    Name := 'mnuSearch';
    SetPosition(476, 98, 172, 20);
    AddMenuItem('Find...', rsKeyCtrl+'F', @miFindClicked);
    AddMenuItem('Find Next', 'F3', @miFindNextClicked);
    AddMenuItem('Find Previous', rsKeyShift+'F3', @miFindPrevClicked);
    AddMenuItem('Find in Files...', rsKeyCtrl+rsKeyShift+'F', nil).Enabled := False;
    AddMenuItem('Replace...', rsKeyCtrl+'R', nil).Enabled := False;
    AddMenuItem('-', '', nil);
    AddMenuItem('Procedure List...', rsKeyCtrl+'G', @miSearchProcedureList);
    AddMenuItem('Go to line...', rsKeyAlt+'G', @miGoToLineClick);
  end;

  mnuView := TlqPopupMenu.Create(self);
  with mnuView do
  begin
    Name := 'mnuView';
    SetPosition(476, 119, 172, 20);
    AddMenuItem('Todo List...', rsKeyCtrl+'F2', nil).Enabled := False;
    AddMenuItem('Debug Windows', '', @miViewDebug);
  end;

  mnuProject := TlqPopupMenu.Create(self);
  with mnuProject do
  begin
    Name := 'mnuProject';
    SetPosition(476, 140, 172, 20);
    AddMenuItem('Options...', rsKeyCtrl+rsKeyShift+'O', @miProjectOptions);
    AddMenuItem('-', '', nil);
    AddMenuItem('New (empty)...', '', @miProjectNew);
    AddMenuItem('New from Template...', '', @miProjectNewFromTemplate);
    AddMenuItem('Open...', '', @miProjectOpen);
    miRecentProjects := AddMenuItem('Open Recent', '', nil);
    AddMenuItem('Save', rsKeyCtrl+rsKeyAlt+'S', @miProjectSave);
    AddMenuItem('Save As...', '', @miProjectSaveAs);
    AddMenuItem('-', '', nil);
    AddMenuItem('View Source', '', nil);
    AddMenuItem('Add editor file to Project', rsKeyCtrl+rsKeyShift+'A', @miProjectAddUnitToProject);
  end;

  mnuRun := TlqPopupMenu.Create(self);
  with mnuRun do
  begin
    Name := 'mnuRun';
    SetPosition(476, 161, 172, 20);
    AddMenuItem('Make', rsKeyCtrl+'F9', @miRunMake);
    AddMenuItem('Build All', rsKeyCtrl+rsKeyShift+'F9', @miRunBuild);
    AddMenuItem('Make 1', rsKeyCtrl+rsKeyAlt+'1', @miRunMake1);
    AddMenuItem('Make 2', rsKeyCtrl+rsKeyAlt+'2', @miRunMake2);
    AddMenuItem('Make 3', rsKeyCtrl+rsKeyAlt+'3', @miRunMake3);
    AddMenuItem('Make 4', rsKeyCtrl+rsKeyAlt+'4', @miRunMake4);
    AddMenuItem('-', '', nil);
    AddMenuItem('Run', 'F9', nil);
    AddMenuItem('Run Parameters...', rsKeyShift+'F9', nil);
  end;

  mnuTools := TlqPopupMenu.Create(self);
  with mnuTools do
  begin
    Name := 'mnuTools';
    SetPosition(476, 182, 172, 20);
    AddMenuItem('LiteKit UI Designer...', 'F12', nil);
    AddMenuItem('LiteKit DocView...', rsKeyCtrl+'F1', nil);
  end;

  mnuSettings := TlqPopupMenu.Create(self);
  with mnuSettings do
  begin
    Name := 'mnuSettings';
    SetPosition(476, 203, 172, 20);
    AddMenuItem('Configure IDE...', '', @miConfigureIDE);
  end;

  mnuHelp := TlqPopupMenu.Create(self);
  with mnuHelp do
  begin
    Name := 'mnuHelp';
    SetPosition(476, 224, 172, 20);
    AddMenuItem('Contents...', '', nil);
    AddMenuItem('-', '', nil);
    AddMenuItem('About LiteKit Toolkit...', '', @miAbouTlquiClicked);
    AddMenuItem('About LiteKit IDE...', '', @miAboutIDE);
  end;

  {@VFD_BODY_END: MainForm}
  {%endregion}

{
  pcEditor.AppendTabSheet('Five');
  pcEditor.AppendTabSheet('Six');
  pcEditor.AppendTabSheet('Seven');
  pcEditor.AppendTabSheet('Eight');
  pcEditor.AppendTabSheet('Nine');
  pcEditor.AppendTabSheet('Ten');
  pcEditor.AppendTabSheet('11');
  pcEditor.AppendTabSheet('12');
  pcEditor.AppendTabSheet('13');
  pcEditor.AppendTabSheet('14');
  pcEditor.AppendTabSheet('15');
  pcEditor.AppendTabSheet('16');
  pcEditor.AppendTabSheet('17');
  pcEditor.AppendTabSheet('18');
  pcEditor.AppendTabSheet('19');
  pcEditor.AppendTabSheet('20');
}

  mainmenu.AddMenuItem('&File', nil).SubMenu := mnuFile;
  mainmenu.AddMenuItem('&Edit', nil).SubMenu := mnuEdit;
  mainmenu.AddMenuItem('&Search', nil).SubMenu := mnuSearch;
  mainmenu.AddMenuItem('&View', nil).SubMenu := mnuView;
  mainmenu.AddMenuItem('&Project', nil).SubMenu := mnuProject;
  mainmenu.AddMenuItem('&Run', nil).SubMenu := mnuRun;
  mainmenu.AddMenuItem('&Tools', nil).SubMenu := mnuTools;
  mainmenu.AddMenuItem('Sett&ings', nil).SubMenu := mnuSettings;
  mainmenu.AddMenuItem('&Help', nil).SubMenu := mnuHelp;

  pmOpenRecentMenu := TlqPopupMenu.Create(self);
  with pmOpenRecentMenu do
  begin
    Name := 'pmOpenRecentMenu';
    SetPosition(336, 68, 128, 20);
  end;

  miRecentProjects.SubMenu := pmOpenRecentMenu;

  FRecentFiles := TlqMRU.Create(self);
  FRecentFiles.ParentMenuItem := pmOpenRecentMenu;
  FRecentFiles.OnClick        := @miRecentProjectsClick;
  FRecentFiles.MaxItems       := gINI.ReadInteger('Options', 'MRUProjectCount', 10);
  FRecentFiles.ShowFullPath   := gINI.ReadBool('Options', 'ShowFullPath', True);
  FRecentFiles.LoadMRU;

  {$IFDEF DEBUGSVR}
  btnTest := TlqButton.Create(Toolbar);
  with btnTest do
  begin
    Name := 'btnTest';
    SetPosition(168, 2, 80, 24);
    Text := 'test';
    Down := False;
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 7;
    OnClick := @miTest;
  end;

  SendMethodExit('TMainForm.AfterCreate');
  {$ENDIF}
end;


end.
