unit Windows;

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils,Screen,Comun,
  PXL.Types;
 Type

 { TControl }

 TControl = Class
 private
   FHeight: integer;
   FLeft: integer;
   FTop: integer;
   FWidth: integer;
 public
   property Top:integer read FTop write FTop;
   property Left: integer read FLeft write FLeft;
   property Height : integer read FHeight write FHeight;
   property Width : integer read FWidth write FWidth;

 end;
 Type

 { TButton }

 TButton = class (Tcontrol)
 private
   FidImage: integer;
   FNombre: string;
 public
    property Nombre:string read FNombre write FNombre;
    property idImage: integer read FidImage write FidImage;
    procedure Show;
    Constructor Create (Image:String);
 end;

Type

{ TWindow }

 TWindow=Class
   FControles : TList;
   public
     procedure Show;
     Constructor Create;
     destructor Destroy; override;
 end;

implementation

{ TWindow }

procedure TWindow.Show;
begin

end;

constructor TWindow.Create;
begin
  FControles:=TList.Create;
end;

destructor TWindow.Destroy;
begin
  FControles.Free;
  inherited Destroy;
end;

{ TButton }

procedure TButton.Show;
begin
  //Pintar
  EngineCanvas.UseImage(EngineImages[FidImage]);
  EngineCanvas.TexQuad(FloatRect4(Ftop,FLeft,FWidth,FHeight),IntColorAlpha(255));
end;

constructor TButton.Create(Image: String);
begin
  FidImage:=EngineImages.AddFromFile(UrpaDir+Image);
  FWidth:=100;
  FHeight:=80;
end;

end.

