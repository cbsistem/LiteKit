{
    LiteKit  -  Free Pascal GUI Toolkit

    Copyright (C) 2006 - 2010 See the file AUTHORS.txt, included in this
    distribution, for details of the copyright.

    See the file COPYING.modifiedLGPL, included in this distribution,
    for details about redistributing LiteKit.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

    Description:
      Defines a File Grid and String Grid. Both are decendants of Custom Grid.
}

unit lq_grid;

{$mode objfpc}{$H+}

{
  TODO:
    * TCustomStringGrid: Col[] and Row[] properties need to be implemented,
      returning a TStrings with all related text inserted.
    * File Grid: Introduce support for images based on file types. User must
      be able to override the default images with their own.
}

interface

uses
  Classes,
  SysUtils,
  lq_base,
  lq_main,
  lq_basegrid,
  lq_customgrid;
  
type

  TlqFileGrid = class(TlqCustomGrid)
  private
    FFileList: TlqFileList;
    FFixedFont: TlqFont;
  protected
    function    GetRowCount: Integer; override;
    procedure   DrawCell(ARow, ACol: Integer; ARect: TlqRect; AFlags: TlqGridDrawState); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    function    CurrentEntry: TFileEntry;
    property    FixedFont: TlqFont read FFixedFont;
    property    FileList: TlqFileList read FFileList;
    property    DefaultRowHeight;
    property    Font;
    property    HeaderFont;
  published
    property    Align;
    property    BorderStyle;
    property    ColumnCount;
    property    Columns;
    property    FocusRow;
    property    FontDesc;
    property    HeaderFontDesc;
    property    Options;
    property    RowCount;
    property    ScrollBarStyle;
    property    TabOrder;
    property    TopRow;
    property    OnRowChange;
    property    OnDoubleClick;
    property    OnShowHint;
  end;


  TlqStringColumn = class(TlqGridColumn)
  private
    FCells: TStringList;
  public
	  constructor Create; override;
	  destructor  Destroy; override;
    property    Cells: TStringList read FCells write FCells;
  end;


  TlqCustomStringGrid = class(TlqCustomGrid)
  private
    function    GetCell(ACol, ARow: Integer): string;
    function    GetColumnAlignment(ACol: Integer): TAlignment;
    function    GetColumnTitle(ACol: Integer): string;
    function    GetObjects(ACol, ARow: Integer): TObject;
    procedure   SetCell(ACol, ARow: Integer; const AValue: string);
    procedure   SetColumnAlignment(ACol: Integer; const AValue: TAlignment);
    procedure   SetColumnTitle(ACol: Integer; const AValue: string);
    procedure   SetObjects(ACol, ARow: Integer; const AValue: TObject);
  protected
    function    GetColumnWidth(ACol: Integer): integer; override;
    procedure   SetColumnWidth(ACol: Integer; const AValue: integer); override;
    function    GetColumns(AIndex: Integer): TlqStringColumn; reintroduce;
    procedure   DoDeleteColumn(ACol: integer); override;
    procedure   DoSetRowCount(AValue: integer); override;
    procedure   DoAfterAddColumn(ACol: integer); override;
    function    DoCreateColumnClass: TlqStringColumn; reintroduce; override;
    procedure   DrawCell(ARow, ACol: Integer; ARect: TlqRect; AFlags: TlqGridDrawState); override;
    property    Columns[AIndex: Integer]: TlqStringColumn read GetColumns;
  public
    constructor Create(AOwner: TComponent); override;
    function    AddColumn(ATitle: string; AWidth: integer; AAlignment: TAlignment = taLeftJustify;
        AbackgroundColor: TlqColor = clDefault; ATextColor: TlqColor = clDefault): TlqStringColumn; overload;
    procedure   DeleteRow(AIndex: integer); override;
    property    Cells[ACol, ARow: Integer]: string read GetCell write SetCell;
    property    Objects[ACol, ARow: Integer]: TObject read GetObjects write SetObjects;
    property    ColumnTitle[ACol: Integer]: string read GetColumnTitle write SetColumnTitle;
    property    ColumnWidth[ACol: Integer]: integer read GetColumnWidth write SetColumnWidth;
    property    ColumnAlignment[ACol: Integer]: TAlignment read GetColumnAlignment write SetColumnAlignment;
    property    ColumnBackgroundColor;
    property    ColumnTextColor;
//    property    Cols[index: Integer]: TStrings read GetCols write SetCols;
//    property    Rows[index: Integer]: TStrings read GetRows write SetRows;
    procedure   Clear;
  end;


  TlqStringGrid = class(TlqCustomStringGrid)
  public
    property    Font;
  published
    property    Align;
    property    AlternateBGColor;
    property    BackgroundColor;
    property    BorderStyle;
//    property    ColResizing;
    property    ColumnCount;
    property    Columns;
    property    ColumnWidth;
    property    DefaultColWidth;
    property    DefaultRowHeight;
    property    Enabled;
    property    FocusCol;
    property    FocusRow;
    property    FontDesc;
    property    HeaderFontDesc;
    property    HeaderHeight;
    property    HeaderStyle;
    property    Hint;
    property    Options;
    property    ParentShowHint;
    property    PopupMenu;
    property    RowCount;
    property    RowSelect;
    property    ScrollBarStyle;
    property    ShowGrid;
    property    ShowHeader;
    property    ShowHint;
    property    TabOrder;
    property    TopRow;
    property    VisibleRows;
    property    OnCanSelectCell;
    property    OnClick;
    property    OnDoubleClick;
    property    OnDrawCell;
    property    OnFocusChange;
    property    OnKeyPress;
    property    OnMouseDown;
    property    OnMouseEnter;
    property    OnMouseExit;
    property    OnMouseMove;
    property    OnMouseUp;
    property    OnRowChange;
    property    OnShowHint;
  end;

function CreateStringGrid(AOwner: TComponent; x, y, w, h: TlqCoord; AColumnCount: integer = 0): TlqStringGrid;


implementation

uses
  lq_constants;

function CreateStringGrid(AOwner: TComponent; x, y, w, h: TlqCoord; AColumnCount: integer = 0): TlqStringGrid;
begin
  Result  := TlqStringGrid.Create(AOwner);
  Result.Left         := x;
  Result.Top          := y;
  Result.Width        := w;
  Result.Height       := h;
  Result.ColumnCount  := AColumnCount;
end;

{ TlqFileGrid }

function TlqFileGrid.GetRowCount: Integer;
begin
  Result := FFileList.Count;
end;

procedure TlqFileGrid.DrawCell(ARow, ACol: Integer; ARect: TlqRect; AFlags: TlqGridDrawState);
const
  picture_width = 20;
var
  e: TFileEntry;
  x: integer;
  y: integer;
  s: Tlqstring;
  img: TlqImage;
begin
  e := FFileList.Entry[ARow];
  if e = nil then
    Exit; //==>

  x := ARect.Left + 2;
  y := ARect.Top;// + 1;
  s := '';

  if (e.EntryType = etDir) and (ACol = 0) then
    Canvas.SetFont(HeaderFont)
  else
    Canvas.SetFont(Font);

  case ACol of
    0:  begin
          if e.EntryType = etDir then
            img := lqImages.GetImage('stdimg.folder')          // Do NOT localize
          else if e.IsExecutable then
            img := lqImages.GetImage('stdimg.executable')      // Do NOT localize
          else
            img := lqImages.GetImage('stdimg.document');       // Do NOT localize

          if img <> nil then
            Canvas.DrawImage(ARect.Left + (picture_width - img.Width) div 2,
               y + (ARect.Height - img.Height) div 2, img);
          if e.IsLink then  // paint shortcut link symbol over existing image
            Canvas.DrawImage(ARect.Left+1, ARect.Top+1, lqImages.GetImage('stdimg.link'));
          x := ARect.Left + picture_width;
          s := e.Name;
        end;
        
    1:  begin
          if e.EntryType = etDir then
            s := ''
          else
            s := FormatFloat('### ### ### ##0', e.Size);
          x := ARect.Right - Font.TextWidth(s) - 1;
          if x < (ARect.Left + 2) then
            x := ARect.Left + 2;
        end;

    2:  s := FormatDateTime('yyyy-mm-dd hh:nn', e.ModTime);

    3:  begin
          if FFileList.HasFileMode then // on unix
            s := e.Mode
          else                          // on windows
            s := e.Attributes;

          Canvas.SetFont(FixedFont);
        end;
  end;
  
  if FFileList.HasFileMode then // unix
    case ACol of
      4:  s := e.Owner;
      5:  s := e.Group;
    end;
  
  // centre text in row height
  y := y + ((DefaultRowHeight - Canvas.Font.Height) div 2);
  Canvas.DrawString(x, y, s);
end;

constructor TlqFileGrid.Create(AOwner: TComponent);
begin
  FFileList := TlqFileList.Create;
  inherited Create(AOwner);
  ColumnCount := 0;
  RowCount := 0;
  FFixedFont := lqGetFont('Courier New-9');
  
  if FFileList.HasFileMode then
    AddColumn(rsName, 220)  // save space for file mode, owner and group
  else
    AddColumn(rsName, 320); // more space to filename

  AddColumn(rsSize, 80);
  AddColumn(rsFileModifiedTime, 108);
  
  if FFileList.HasFileMode then
  begin
    AddColumn(rsFileRights, 78);
    AddColumn(rsFileOwner, 54);
    AddColumn(rsFileGroup, 54);
  end
  else
    AddColumn(rsFileAttributes, 78);
    
  RowSelect := True;
  DefaultRowHeight := lqImages.GetImage('stdimg.document').Height + 2;
end;

destructor TlqFileGrid.Destroy;
begin
  OnRowChange := nil;
  FFixedFont.Free;
  FFileList.Free;
  inherited Destroy;
end;

function TlqFileGrid.CurrentEntry: TFileEntry;
begin
  Result := FFileList.Entry[FocusRow];
end;

{ TlqStringColumn }

constructor TlqStringColumn.Create;
begin
  inherited Create;
  FCells := TStringList.Create;
end;

destructor TlqStringColumn.Destroy;
begin
  FCells.Free;
  inherited Destroy;
end;

{ TlqCustomStringGrid }

function TlqCustomStringGrid.GetCell(ACol, ARow: Integer): string;
begin
  if ACol > ColumnCount-1 then
    Exit; //==>
  if ARow > RowCount-1 then
    Exit; //==>
  Result := TlqStringColumn(FColumns.Items[ACol]).Cells[ARow];
end;

function TlqCustomStringGrid.GetColumnAlignment(ACol: Integer): TAlignment;
begin
  if ACol > ColumnCount-1 then
    Exit; //==>
  Result := TlqStringColumn(FColumns.Items[ACol]).Alignment;
end;

function TlqCustomStringGrid.GetColumnTitle(ACol: Integer): string;
begin
  if ACol > ColumnCount-1 then
    Exit; //==>
  Result := TlqStringColumn(FColumns.Items[ACol]).Title;
end;

function TlqCustomStringGrid.GetObjects(ACol, ARow: Integer): TObject;
begin
  if ACol > ColumnCount-1 then
    Exit; //==>
  if ARow > RowCount-1 then
    Exit; //==>
  Result := TlqStringColumn(FColumns.Items[ACol]).Cells.Objects[ARow];
end;

function TlqCustomStringGrid.GetColumnWidth(ACol: Integer): integer;
begin
  if ACol > ColumnCount-1 then
    Exit; //==>
  Result := TlqStringColumn(FColumns.Items[ACol]).Width;
end;

procedure TlqCustomStringGrid.SetCell(ACol, ARow: Integer; const AValue: string);
begin
  if ACol > ColumnCount-1 then
    Exit; //==>
  if ARow > RowCount-1 then
    Exit; //==>
  if TlqStringColumn(FColumns.Items[ACol]).Cells[ARow] <> AValue then
  begin
    BeginUpdate;
    try
      TlqStringColumn(FColumns.Items[ACol]).Cells[ARow] := AValue;
    finally
      EndUpdate;
    end;
  end;
end;

procedure TlqCustomStringGrid.SetColumnAlignment(ACol: Integer; const AValue: TAlignment);
begin
  if ACol > ColumnCount-1 then
    Exit; //==>
  BeginUpdate;
  try
    TlqStringColumn(FColumns.Items[ACol]).Alignment := AValue;
  finally
    EndUpdate;
  end;
end;

procedure TlqCustomStringGrid.SetColumnTitle(ACol: Integer; const AValue: string);
begin
  if ACol > ColumnCount-1 then
    Exit; //==>
  BeginUpdate;
  try
    TlqStringColumn(FColumns.Items[ACol]).Title := AValue;
  finally
    EndUpdate;
  end;
end;

procedure TlqCustomStringGrid.SetObjects(ACol, ARow: Integer; const AValue: TObject);
begin
  if ACol > ColumnCount-1 then
    Exit; //==>
  if ARow > RowCount-1 then
    Exit; //==>
  TlqStringColumn(FColumns.Items[ACol]).Cells.Objects[ARow] := AValue;
end;

procedure TlqCustomStringGrid.SetColumnWidth(ACol: Integer; const AValue: integer);
begin
  if ACol > ColumnCount-1 then
    Exit; //==>
  BeginUpdate;
  try
    inherited SetColumnWidth(ACol, AValue);
  finally
    EndUpdate;
  end;
end;

function TlqCustomStringGrid.GetColumns(AIndex: Integer): TlqStringColumn;
begin
  if (AIndex < 0) or (AIndex > ColumnCount-1) then
    Result := nil
  else
    Result := TlqStringColumn(FColumns.Items[AIndex]);
end;

procedure TlqCustomStringGrid.DoDeleteColumn(ACol: integer);
begin
  TlqStringColumn(FColumns.Items[ACol]).Free;
  FColumns.Delete(ACol);
end;

procedure TlqCustomStringGrid.DoSetRowCount(AValue: integer);
var
  diff: integer;
  c: integer;
begin
  inherited DoSetRowCount(AValue);
  if FColumns.Count = 0 then
    Exit; //==>

  diff := AValue - TlqStringColumn(FColumns.Items[0]).Cells.Count;
  if diff > 0 then  // We need to add rows
  begin
    for c := 0 to FColumns.Count - 1 do
    begin
      while TlqStringColumn(FColumns[c]).Cells.Count <> AValue do
        TlqStringColumn(FColumns[c]).Cells.Append('');
    end;
  end;
end;

procedure TlqCustomStringGrid.DoAfterAddColumn(ACol: integer);
var
  r: integer;
begin
  inherited DoAfterAddColumn(ACol);
  // initialize cells for existing rows
  for r := 0 to RowCount-1 do
    TlqStringColumn(FColumns.Items[ACol]).Cells.Append('');
end;

function TlqCustomStringGrid.DoCreateColumnClass: TlqStringColumn;
begin
  Result := TlqStringColumn.Create;
end;

procedure TlqCustomStringGrid.DrawCell(ARow, ACol: Integer; ARect: TlqRect;
    AFlags: TlqGridDrawState);
var
  Flags: TlqTextFlags;
  txt: string;
  r: TlqRect;
begin
  if Cells[ACol, ARow] <> '' then
  begin
    txt := Cells[ACol, ARow];
    Flags:= [];
    if not Enabled then
      Include(Flags,txtDisabled);

    case Columns[ACol].Alignment of
      taLeftJustify:
          Include(Flags,txtLeft);
      taCenter:
          Include(Flags,txtHCenter);
      taRightJustify:
          Include(Flags,txtRight);
    end;  { case }
    
    case Columns[ACol].Layout of
      tlTop:
          Include(Flags,txtTop);
      tlCenter:
          Include(Flags,txtVCenter);
      tlBottom:
          Include(Flags,txtBottom);
    end;  { case }

    with ARect,Columns[ACol] do
    begin
      r := ARect;
      // make adjustment for margins
      r.Left := r.Left + HMargin;
      r.Width := r.Width - (HMargin*2);
      // finally paint the text
      Canvas.DrawText(r, txt, Flags);
    end;
  end;
end;

constructor TlqCustomStringGrid.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ColumnCount := 0;
  RowCount := 0;
end;

function TlqCustomStringGrid.AddColumn(ATitle: string; AWidth: integer;
    AAlignment: TAlignment; ABackgroundColor: TlqColor; ATextColor: TlqColor): TlqStringColumn;
begin
  Updating;
  Result := TlqStringColumn(inherited AddColumn(ATitle, AWidth));
  Result.Alignment := AAlignment;

  if ABackgroundColor = clDefault then
    Result.BackgroundColor := clBoxColor
  else
    Result.BackgroundColor:= ABackgroundColor;

  if ATextColor = clDefault then
    Result.TextColor := TextColor
  else
    Result.TextColor:= ATextColor;
    
  if UpdateCount = 0 then
    Updated;  // if we called .BeginUpdate then don't clear csUpdating here
end;

procedure TlqCustomStringGrid.DeleteRow(AIndex: integer);
var
  c: integer;
begin
  inherited DeleteRow(AIndex);  // does sanity checks
  for c := 0 to FColumns.Count-1 do
  begin
    TlqStringColumn(FColumns[c]).Cells.Delete(AIndex);
  end;
  FRowCount := FRowCount-1;
  if HasHandle then
    Update;
end;

procedure TlqCustomStringGrid.Clear;
var
  i: integer;
begin
  for i := FColumns.Count-1 downto 0 do
    TlqStringColumn(FColumns[i]).Free;
  FColumns.Clear;
  FRowCount := 0;
  Update;
end;

end.
