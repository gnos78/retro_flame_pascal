
program flame;
uses crt;

{
     simple flame
}

{$L fl_mod}

procedure set_video;
external; {fl_mod}
procedure set_text;
external; {fl_mod}
procedure blur_asm_impl(st_offset:Word;cnt_row:Word;cnt_col:Word;decay:Word);
external; {fl_mod}

const VID_SEG : WORD = $0a000;
const COLM : Integer = 320;
const ROWS : Integer = 200;

procedure set_flame_palette;
var
   i : Integer;
   r,g,b : Integer;
begin
     r := 255;
     g := 255;
     b := 255;
     for i:=0 to 255 do
     begin
          port[$03c8] := Byte(255-i);
          port[$03c9] := Byte(r shr 2);
          port[$03c9] := Byte(g shr 2);
          port[$03c9] := Byte(b shr 2);
          r := r - 1;
          g := g - 2;
          b := b - 3;
          if g < 0 then g := 0;
          if b < 0 then b := 0;

     end;
end;

procedure emit_range(st,cnt:Integer);
var
   offset , i : Integer;
   e : Integer;
const
   row : Integer = 199;
begin
     offset := st + row * 320;
     for i:=0 to cnt do
     begin
          e := Random(105)+150;
          Mem[VID_SEG:offset] := e;
          inc(offset);
     end;
end;

procedure blur(st_row,st_col,cnt_col,decay:Integer);
var
   i,j:Integer;
   cnt_row : Integer;
   offset , offset_below, offset_row : Integer;
   e : Integer;
   l,m,r,c : Byte;
begin
     cnt_row:= 198 - st_row;
     offset_row := COLM * (ROWS-2) + st_col;
     for j:=0 to cnt_row do
     begin
         offset := offset_row;
         offset_below := offset_row + COLM;
         for i:=0 to cnt_col do
         begin
              l := Mem[VID_SEG:offset_below-1];
              m := Mem[VID_SEG:offset_below];
              r := Mem[VID_SEG:offset_below+1];
              c := Mem[VID_SEG:offset];
              e := (m shr 1) + (m shr 4);

              e := e + (l shr 3) + (l shr 5);
              e := e + (r shr 3) + (r shr 5);
              e := e + (c shr 3) + (c shr 5);
              e := abs(e-decay);

              Mem[VID_SEG:offset] := e;
              inc(offset);
              inc(offset_below);
         end;
         offset_row := offset_row - COLM;
     end;
end;

procedure blur_asm(st_row,st_col,cnt_col,decay:Integer);
var
   cnt_row : Integer;
   offset : Integer;
begin
     cnt_row:= 198 - st_row;
     offset := COLM * (ROWS-2) + st_col;
     blur_asm_impl(offset,cnt_row,cnt_col,decay);
end;

procedure run_loop;
begin
     while (KeyPressed = False) do
     begin
          blur_asm(160,150,50,5);
          emit_range(150,50);
     end;
end;

begin
     set_video;
     set_flame_palette;
     
     run_loop;

     set_text;
end.