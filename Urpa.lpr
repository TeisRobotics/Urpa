program Urpa;

{$mode objfpc}{$H+}

{ Raspberry Pi 3 Application                                                   }
{  Add your program code below, add additional units to the "uses" section if  }
{  required and create new units by selecting File, New Unit from the menu.    }
{                                                                              }
{  To compile your program select Run, Compile (or Run, Build) from the menu.  }

uses
  RaspberryPi3,
  GlobalConfig,
  GlobalConst,
  GlobalTypes,
  Platform,
  Threads,
  SysUtils,
  Classes,
  Ultibo
  { Acceso remoto},
  Shell,
  ShellFileSystem,
  ShellUpdate,
  RemoteShell,
   {Unidades del sistema}
  Console,
  {Unidades de Urpa}
  Screen, Comun, Windows;

begin
  InicializaSistema;
  InicializaVideo;
//  ConsoleWriteLn('Sistema listo!');
 B:= TButton.Create();
  While True do
  begin
    Sleep(1000);
  end;
end.

