
public set_video
public set_text
public blur_asm_impl
CODE   segment public
assume CS:CODE
set_video proc near
        mov ax,13h
        int 10h
        ret
set_video endp

set_text proc near
        mov ax,03h
        int 10h
        ret
set_text endp        

; ax : start offset
; bx : cnt_row
; cx : cnt_col
; dx : decay
blur_asm_impl proc near
          push bp
          mov bp,sp
          push ds
          mov bx,0a000h
          mov ds,bx          
          mov ax,[bp]+10
          mov bx,[bp]+8
          mov cx,[bp]+6
          mov dx,[bp]+4
          mov si,ax
          mov al,02fh
loop_row:
          push cx
          push si

          call loop_col
          inc al
          pop si
          pop cx ; reset col counter
          
          sub si,140h
          dec bx
          jne loop_row
          pop ds
          pop bp
          ret

loop_col2:          
          mov byte [ds:si],02fh
          inc si
          dec cx
          jne  loop_col2
          ret          

loop_col:
          mov dh,0
          ;e := e + (c shr 3) + (c shr 5);
          mov al,byte [ds:si]
          mov ah,al
          shr ah,3
          add dh,ah
          mov ah,al
          shr ah,5
          add dh,ah
          ;e := e + (l shr 3) + (l shr 5);
          mov al,byte [ds:si+319]
          mov ah,al
          shr ah,3
          add dh,ah
          mov ah,al
          shr ah,5
          add dh,ah          
          ;e := (m shr 1) + (m shr 4);
          mov al,byte [ds:si+320]
          mov ah,al
          shr ah,1
          add dh,ah
          mov ah,al
          shr ah,4
          add dh,ah          
          ;e := e + (r shr 3) + (r shr 5);
          mov al,byte [ds:si+321]
          mov ah,al
          shr ah,3
          add dh,ah
          mov ah,al
          shr ah,5
          add dh,ah
          mov al,dh
          ;e := abs(e-decay);
          sub al,dl
          jnb _no_neg
          xor al,al
_no_neg:
          mov byte [ds:si],al
          inc si
          dec cx
          jne  loop_col
          ret          
blur_asm_impl endp
CODE ends
end
