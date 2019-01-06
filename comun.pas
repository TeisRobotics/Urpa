unit Comun;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;
CONST
  //Código de error
  ERROR_SYSTEM_INIT : integer = 1;
  ERROR_SCREEN_INIT : integer = 2;
  ERROR_ASPHYRE_INIT : integer = 3;
  UrpaDir : string ='Urpa\';
Var
//Variable de la pantalla de estándar para URPA.
//Definidas como variables por si hay que sobreescribirlas en futuras evoluciones
  UrpaScreenWidth  : integer = 800;
  UrpaScreenHeight : integer = 480;
//Ratón
  CursorX,CursorY: integer;
  MaxCursorX,MaxCursorY:Integer;
  MinCursorX,MinCursorY:Integer;
implementation

end.

