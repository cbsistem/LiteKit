{
  A simple form with a memo to display text. Handle for debuging etc.
}
unit frm_text;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, lq_base, lq_main, lq_form, lq_button, lq_memo;

type

  TTextForm = class(TlqForm)
  private
    {@VFD_HEAD_BEGIN: TextForm}
    btnClose: TlqButton;
    Memo1: TlqMemo;
    btnCopy: TlqButton;
    {@VFD_HEAD_END: TextForm}
    procedure btnCopyClicked(Sender: TObject);
  public
    procedure AfterCreate; override;
  end;

{@VFD_NEWFORM_DECL}

procedure ShowText(const ATitle: TlqString; const AText: TlqString);


implementation


procedure ShowText(const ATitle: TlqString; const AText: TlqString);
var
  frm: TTextForm;
begin
  frm := TTextForm.Create(nil);
  try
    if ATitle = '' then
      frm.WindowTitle := 'Text Form'
    else
      frm.WindowTitle := ATitle;
    frm.Memo1.Lines.Text := AText;
    frm.ShowModal;
  finally
    frm.Free;
  end;
end;

{@VFD_NEWFORM_IMPL}

procedure TTextForm.btnCopyClicked(Sender: TObject);
begin
  lqClipboard.Text := Memo1.Lines.Text;
end;

procedure TTextForm.AfterCreate;
begin
  {%region 'Auto-generated GUI code' -fold}
  {@VFD_BODY_BEGIN: TextForm}
  Name := 'TextForm';
  SetPosition(405, 197, 496, 297);
  WindowTitle := 'Text Form';
  Hint := '';
  WindowPosition := wpScreenCenter;

  btnClose := TlqButton.Create(self);
  with btnClose do
  begin
    Name := 'btnClose';
    SetPosition(412, 268, 80, 24);
    Anchors := [anRight,anBottom];
    Text := 'Close';
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    ModalResult := mrOK;
    TabOrder := 1;
  end;

  Memo1 := TlqMemo.Create(self);
  with Memo1 do
  begin
    Name := 'Memo1';
    SetPosition(0, 0, 496, 260);
    Anchors := [anLeft,anRight,anTop,anBottom];
    FontDesc := '#Edit2';
    Hint := '';
    TabOrder := 2;
  end;

  btnCopy := TlqButton.Create(self);
  with btnCopy do
  begin
    Name := 'btnCopy';
    SetPosition(4, 268, 128, 24);
    Anchors := [anLeft,anBottom];
    Text := 'Copy to Clipboard';
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 3;
    OnClick := @btnCopyClicked;
  end;

  {@VFD_BODY_END: TextForm}
  {%endregion}
end;


end.
