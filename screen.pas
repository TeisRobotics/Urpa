unit Screen;

{$mode Delphi}{$H+}

interface

uses
  Classes, SysUtils,FrameBuffer,GlobalConst,Console,Threads,
  Comun,
  {Unidades para ASphyre }
  PXL.TypeDef,
  PXL.Types,
  PXL.Timing,
  PXL.Devices,
  PXL.ImageFormats,
  PXL.Canvas,
  PXL.SwapChains,
  PXL.Images,
  PXL.Fonts,
  PXL.Providers,
  PXL.Classes,
  PXL.Providers.GLES,  {Par usar OpenGL ES con Asphyre }
  PXL.ImageFormats.Auto,
  VC4;   {Incluir VC4 para que la PI tenga soporte OpenGL ES }
 Var
 //Variables del sistema de vídeo
   FrameBufferDevice: PFramebufferDevice=nil;
   FrameBufferProperties: TFramebufferProperties;
   //ScreenWidth : integer;
   //ScreenHeight : Integer;

//Variables  Asphyre
   Handle: THandle;
   ImageFormatManager : TImageFormatManager;
   ImageFormatHandler : TCustomImageFormatHandler;
   DeviceProvider : TGraphicsDeviceProvider;

   EngineDevice:TCustomSwapChainDevice;
   EngineCanvas : TCustomCanvas;
   EngineImages : TAtlasImages;
   EngineFonts : TBitmapFonts;

   FontTahona : Integer;

   ClientWidth:Integer;
   ClientHeight : integer;
   DisplaySize : TPoint2px;


//
procedure InicializaSistema;
procedure InicializaVideo;
implementation
 {
   Crear consola,
   Preparar Unidad C,
   Ir añadiendo otros requieriemiento anteriores a crear la pantalla
   }
procedure InicializaSistema;
begin
  ConsoleWindowCreate(ConsoleDeviceGetDefault,CONSOLE_POSITION_FULLSCREEN,true);
  ConsoleWriteLn(Format('Ultibo : %s %s %s',[ULTIBO_RELEASE_NAME,ULTIBO_RELEASE_VERSION,ULTIBO_RELEASE_DATE]));
  ConsoleWrite('Inicializando disco C.');
  {Todo: Versiones posteriores arrancar en otras unidades que no sea C}
  While not DirectoryExists('c:\') do
  begin
   Sleep(1000);
   ConsoleWrite('.');
  end;
  ConsoleWriteLn('');
  ConsoleWriteln('Disco C listo!');
  UrpaDir := 'C:\'+UrpaDir;
  ConsoleWriteLn('Directorio del sistema: '+UrpaDir);
  if Not DirectoryExists(UrpaDir) then
  begin
   ConsoleWriteLn('No encuentro el directorio del sistema!!!');
   ThreadHalt(ERROR_SYSTEM_INIT);
  end;
end;

Procedure InicializaVideo;
var
  WindowX, WindowY: Integer;
Begin
  if FrameBufferDevice = nil then
  Begin
    FrameBufferDevice := FramebufferDeviceGetDefault;
  end;
  if FrameBufferDevice = nil then
  begin
    ConsoleWriteLn('Fallo en la inicialización FrameBuffer');
    ThreadHalt(ERROR_SCREEN_INIT);
  end;
  ConsoleWriteln ('FrameBuffer Inicializado');
  if FramebufferDeviceGetProperties(FrameBufferDevice,@FrameBufferProperties) <> ERROR_SUCCESS then
  begin
    ConsoleWriteln('Fallo obteniendo las propiedades del FrameBuffer');
    ThreadHalt(ERROR_SCREEN_INIT);
  end;
  ConsoleWriteln ('Propiedades de framebuffer listas');
  Handle := THandle (FramebufferDevice);
  //Ancho de la pantlla
  ClientHeight:=FrameBufferProperties.PhysicalHeight;
  ClientWidth:=FrameBufferProperties.PhysicalWidth;
  ConsoleWriteLn(Format('Formato de pantalla: %d*%d',[ClientWidth,ClientHeight]));
  //La pantalla no puede ser muy pequeña. Esto produce que no se pueda continuar
  if (ClientWidth < UrpaScreenWidth) or (ClientHeight < UrpaScreenHeight) then
  begin
    ConsoleWriteLn('La pantalla no tiene la medidas mínimas requeridas');
    ConsoleWriteLn(Format('Formato actual: %d,%d',[ClientWidth,ClientHeight]));
    ConsoleWriteLn(Format('Formato esperado: %d*%d',[UrpaScreenWidth,UrpaScreenHeight]));
    ThreadHalt(ERROR_SCREEN_INIT);
  end;
  //Ratón
  MinCursorX:=0;
  MinCursorY:=0;
  MaxCursorX:=ClientWidth;
  MaxCursorY:=ClientHeight;
  CursorX:=ClientWidth div 2;
  CursorY:=ClientHeight div 2;
  //Ajustar ancho a las propiedades de la pantalla estándard
  if ClientWidth > UrpaScreenWidth then
  begin
    MinCursorX:=(ClientWidth-UrpaScreenWidth) div 2;
    MaxCursorX:=MinCursorX+UrpaScreenWidth;
    ClientWidth:=UrpaScreenWidth;
  end;
  if ClientHeight>UrpaScreenHeight then
  begin
    MinCursorY:=(ClientHeight-UrpaScreenHeight) div 2;
    MaxCursorY:=MinCursorY+UrpaScreenHeight;
    ClientHeight:=UrpaScreenHeight;
  end;
  //Inicizalizar el cursor
  if FramebufferDeviceSetCursor(FrameBufferDevice,0,0,0,0,nil,0) = ERROR_SUCCESS then
  begin
   ConsoleWriteLn('Inicializando el ratón');
   //Todavía no mostramos el cursor del ratón
   FramebufferDeviceUpdateCursor(FrameBufferDevice,FALSE,CursorX,CursorY,True);
  end
  Else
  begin
   ConsoleWriteLn('Fallo inicializando el ratón');
   ThreadHalt(ERROR_SCREEN_INIT);
  end;
  ImageFormatManager := TImageFormatManager.Create;
  ImageFormatHandler:=CreateDefaultImageFormatHandler(ImageFormatManager);

  DeviceProvider := TGLESProvider.Create(ImageFormatManager);
  EngineDevice := DeviceProvider.CreateDevice as TCustomSwapChainDevice;

  DisplaySize := Point2px(ClientWidth,ClientHeight);
  EngineDevice.SwapChains.Add(Handle,DisplaySize);

  if ClientWidth<FrameBufferProperties.PhysicalWidth then
  begin
   WindowX:= (FrameBufferProperties.PhysicalWidth-ClientWidth) div 2;
  end;
  if ClientHeight<FrameBufferProperties.PhysicalHeight then
  begin
   WindowY := (FrameBufferProperties.PhysicalHeight-ClientHeight);
  end;
  if (WindowX<>0) or (WindowY<>0) then
  begin
   EngineDevice.Move(0,Point2px(WindowX,WindowY));
  end;

  if Not EngineDevice.Initialize then
  begin
   ConsoleWriteLn('Fallo inicializando PXL!');
   ThreadHalt(ERROR_ASPHYRE_INIT);
  end;
  ConsoleWriteLn('PXL Inicializado');

  EngineCanvas := DeviceProvider.CreateCanvas(EngineDevice);
  if Not EngineCanvas.Initialize then
  begin
   ConsoleWriteLn('Fallo inicializando PXL Canvas');
   ThreadHalt(ERROR_ASPHYRE_INIT);
  end;

  EngineImages := TAtlasImages.Create(EngineDevice);
  EngineFonts := TBitmapFonts.Create(EngineDevice);

  FontTahona:=EngineFonts.AddFromBinaryFile(CrossFixFileName(UrpaDir+'Tahoma9b.font'));
  if FontTahona = -1 then
  begin
   ConsoleWriteLn('No puedo cargar las fuentes');
   ThreadHalt(ERROR_ASPHYRE_INIT);
  end;
end;

initialization
end.

