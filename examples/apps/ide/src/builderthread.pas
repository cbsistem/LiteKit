{
    LiteKit IDE - Maximus

    Copyright (C) 2012 - 2013 Graeme Geldenhuys

    See the file COPYING.modifiedLGPL, included in this distribution,
    for details about redistributing LiteKit.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

    Description:
      ---
}

unit BuilderThread;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  TOutputLineEvent = procedure(Sender: TObject; const ALine: string) of object;

  TBuilderThread = class(TThread)
  private
    FBuildMode: integer;
    FOnAvailableOutput: TOutputLineEvent;
    OutputLine: string;
    procedure DoOutputLine;
  protected
    procedure Execute; override;
  public
    procedure AfterConstruction; override;
    property  BuildMode: integer read FBuildMode write FBuildMode;
    property  OnAvailableOutput: TOutputLineEvent read FOnAvailableOutput write FOnAvailableOutput;
  end;

implementation

uses
  project
  ,process
  ,lq_base
  ,lq_iniutils
  ,lq_utils
  ,ideconst
  ,idemacros
  ;

{ TBuilderThread }

procedure TBuilderThread.AfterConstruction;
begin
  inherited AfterConstruction;
  FBuildMode := -1;  // signals use of project's default build mode
  FreeOnTerminate := True;
end;

procedure TBuilderThread.Execute;
const
  BufSize = 1024; //4096;
var
  p: TProcess;
  c: TlqString;
  unitdir: TlqString;
  Buf: string;
  Count: integer;
  i: integer;
  LineStart: integer;
begin
  unitdir := GProject.ProjectDir + GProject.UnitOutputDir;
  unitdir := GMacroList.ExpandMacro(unitdir);
  if not lqDirectoryExists(unitdir) then
  begin
    {$IFDEF DEBUG}
    writeln('DEBUG:  TBuilderThread.Execute - Creating dir: ' + unitdir);
    {$ENDIF}
    lqForceDirectories(unitDir);
  end;

  p := TProcess.Create(nil);
  p.Options := [poUsePipes, poStdErrToOutPut];
  p.ShowWindow := swoShowNormal;
  p.CurrentDirectory := GProject.ProjectDir;

  // build compilation string
  c := gINI.ReadString(cEnvironment, 'Compiler', '');
  c := c + GProject.GenerateCmdLine(False, BuildMode);
  c := GMacroList.ExpandMacro(c);

//  AddMessage('Compile command: ' + c);
  p.CommandLine := c;
  try
    p.Execute;

    { Now process the output }
    OutputLine:='';
    SetLength(Buf,BufSize);
    repeat
      if (p.Output<>nil) then
      begin
        Count:=p.Output.Read(Buf[1],Length(Buf));
      end
      else
        Count:=0;
      LineStart:=1;
      i:=1;
      while i<=Count do
      begin
        if Buf[i] in [#10,#13] then
        begin
          OutputLine:=OutputLine+Copy(Buf,LineStart,i-LineStart);
          Synchronize(@DoOutputLine);
          OutputLine:='';
          if (i<Count) and (Buf[i+1] in [#10,#13]) and (Buf[i]<>Buf[i+1]) then
            inc(i);
          LineStart:=i+1;
        end;
        inc(i);
      end;
      OutputLine:=Copy(Buf,LineStart,Count-LineStart+1);
    until Count=0;
    if OutputLine <> '' then
      Synchronize(@DoOutputLine);
    p.WaitOnExit;
  finally
    FreeAndNil(p);
  end;

end;

procedure TBuilderThread.DoOutputLine;
begin
  if Assigned(FOnAvailableOutput) then
    FOnAvailableOutput(self, OutputLine);
end;

end.

