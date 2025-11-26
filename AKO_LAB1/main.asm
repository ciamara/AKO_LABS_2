.686
.model flat

extern _fopen: PROC
extern _fread : PROC
extern _fclose : PROC
extern _MessageBoxA@16 : PROC
extern _ExitProcess@4 : PROC

public _main

rozmiar_pliku equ 60

.data

    ; bufor ze znakami wejsciowymi w utf-8
    bufor db rozmiar_pliku dup (?)
    wynik dw rozmiar_pliku dup (0)
    mode db "r",0
    fname db "test3.txt",0

    msgTitleError    db 'Error',0,0
    msgTextError     db 'Invalid UTF8 encoding',0,0

    msgTitleValid    db 'Valid',0,0
    msgTextValid     db 'Valid UTF8 encoding',0,0

.code

read2buf PROC
    push offset mode
    push offset fname
    call _fopen
    add esp,8
    push eax
    push eax ; uchwyt do pliku
    push rozmiar_pliku ; liczba itemow
    push 1 ; rozmiar itema
    push offset bufor
    call _fread
    add esp,16
    call _fclose
    add esp,4
    ret
read2buf ENDP

funkcja PROC
    ;add esi, 3      ;skip bom
    ;sub ecx, 3
    xor eax, eax
main_loop:
    xor ebx, ebx
    mov al, [esi]   ;nastepny bajt do al
main_loop_skip_byte:
    mov dl, 7       ; maks liczba przeusniec szukajac jedynek w pierwszym bajcie

count_ones:
    test al, 80h       ; MSB
    jz done_counting   ; gdy na pierwszej pozycji 0
    inc bl             ; zliczamy jedynki
    shl al, 1          ; do msb nastepny bit
    dec dl
    jnz count_ones

done_counting:
    cmp bl, 0
    jne bl_not_zero
    inc esi     ;zwiekszam adres na nastepny bajt
    dec ecx     ;zmniejszam liczbe pozostalych bajtow
    cmp ecx, 0
    jne main_loop
    je correct_encoding
bl_not_zero:
    cmp bl, 1
    je invalid_encoding     ; pierwszy bajt nie moze byc 10xxxxxx
    cmp bl, 7
    jae fix_too_many_continuation_bytes
    ja invalid_encoding     ; pierwszy bajt nie moze byc 11111110 ani 11111111
    jb skip_fix
    ; FIX BAJTU 28h (11111110)
fix_too_many_continuation_bytes:
    mov al, [esi]
    btr eax, 1  ; usuwam przedostatnia jedynke ktora deklarowalaby niepoprawnie dodatkowy bajt
    xor ebx, ebx
    mov dl, 7   ;odswiezam iterator i bl do zliczania
    jmp count_ones
    ; w bl liczba jedynek (liczba bajtow znaku)
skip_fix:
    cmp ecx, ebx
    jb invalid_encoding     ;za malo pozostalych bajtow w pliku aby bylo poprawnie
    inc esi     ;zwiekszam adres na nastepny bajt
    xor dl, dl
    inc dl
validate_continuation_bytes:        ;sprawdzam ilosc nastepnych bajtow 10xxxxxx
    mov al, [esi]       ;kolejny bajt
try_again_after_fill:
    and al, 0C0h       ;maskujemy 2 gorne bity
    cmp al, 80h        ; czy format zgadza sie z 10xxxxxx
    je continuation_byte        ; bajt = 10xxxxxx
    ;not a continuation byte =/ 10xxxxxx
try_again_after_removal:
    cmp bl, dl      ; czy liczba zadeklarowana = liczbie dalszyc bajtow
    ja fill_continuation        ; uzupelnic bo bl > dl (zadeklarowane > faktyczne)
    je cont
    jb remove_continuations     ; usunac bo bl < dl ( zadeklarowane < faktyczne)
    jne invalid_encoding
    ; FIX BAJTU 8h (11110000)
fill_continuation:
    bts eax, 7
    btr eax, 6
    jmp try_again_after_fill    ;wracam do weryfikacji po poprawce
    ; FIX BAJTU 1Ch (11101000)
remove_continuations:
    sub esi, 5
    mov al, [esi]
    bts eax, 4
    xor ebx, ebx
    add ecx, 5
    jmp main_loop_skip_byte
    ;mov dl, bl  ;liczba kontynuacji = liczba zapowiedzanych kontynuacji
    ;jmp try_again_after_removal

cont:
    sub ecx, ebx
    cmp ecx, 0
    jne main_loop
    je correct_encoding

continuation_byte:
    inc dl      ;zwiekszam liczbe zliczonych bajtow 10xxxxxx
    inc esi     ;zwiekszam adres na nastepny bajt
    jmp validate_continuation_bytes
    
        
invalid_encoding:
    push 0
    push OFFSET msgTitleError
    push OFFSET msgTextError
    push 0
    call _MessageBoxA@16
    jmp finish

correct_encoding:
    push 0
    push OFFSET msgTitleValid
    push OFFSET msgTextValid
    push 0
    call _MessageBoxA@16

finish:
    
    ret
funkcja ENDP


_main PROC

    call read2buf ; odczyt danych z pliku do obszaru oznaczonego jako bufor
    mov esi,offset bufor
    mov ecx,rozmiar_pliku
    call funkcja ;;; tutaj wpisac kod rozwiazania
    push dword ptr 0 ; kod powrotu
    call _ExitProcess@4

    ret
_main ENDP

END