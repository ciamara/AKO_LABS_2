.686
.model flat

extern _MessageBoxA@16 : PROC

public _main



.data

   

.code


_main PROC
   
    mov eax, 00197584h

    OR eax, eax
    
    or eax, 300000h
    rcl eax, 9
    add eax, 40000000h
    
    nop
 
   

    ret
_main ENDP
END