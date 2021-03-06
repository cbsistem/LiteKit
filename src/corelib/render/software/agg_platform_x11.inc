{%mainunit Agg2D.pas}

{$ifdef uses_interface}
  Xlib,
{$endif}


{$ifdef agg_platform_interface}
  protected
//    m_ximg_window : PXImage;
//    m_buf_window: pointer;
//    m_buf_alloc: unsigned;
//    m_bpp: unsigned;
//    m_byte_order: int;
//    m_gc: TGC;
{$endif}


{$ifdef uses_implementation}
  lq_x11,
{$endif}


{$ifdef agg_platform_implementation}

type
  // to get access to protected methods (seeing that FPC doesn't support Friend-classes)
  TImageHack = class(TlqImage);

procedure TAgg2D.DoPutBufferToScreen(x, y, w, h: TlqCoord);
var
  drawgc: Tgc;
  GcValues: TXGcValues;
begin
  if TlqWindow(FWindow).WinHandle <= 0 then
  begin
    debugln('    no winhandle available');
    exit;
  end;

  FImg.UpdateImage;
  drawgc := XCreateGc(lqApplication.Display, TlqWindow(FWindow).WinHandle, 0, @GcValues);

  // finally dump the image to screen!
  XPutImage(lqApplication.Display, TlqWindow(FWindow).WinHandle,
      drawgc, TImageHack(FImg).XImage, 0, 0, 0, 0,
      FWindow.Width, FWindow.Height);

  XFreeGc(lqApplication.Display, drawgc);
end;


{$endif}

