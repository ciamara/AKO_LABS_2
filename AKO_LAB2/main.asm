.686
.model flat

extern _ExitProcess@4 : PROC
extern __write : PROC
extern __read : PROC

public _main

.data

    komunikat db "Wprowadz liczbe 64 bitowa w hex: ",0
    rozmiar_komunikat = $-komunikat
    bufor db 16 dup(0)
    dziesiec8 dd 100000000

    wynik_prefix db '0.',0
    wynik db '00000000',0
    newline db 13,10,0

    digits db 0
    

.code

_main PROC

    ; komunikat o wpisaniu
    push rozmiar_komunikat
    push OFFSET komunikat
    push 1
    call __write
    add esp, 12

    ; zczytanie 64 bitowej liczby w hex (16znakow)
    push 16                     ;max liczba znakow
    push OFFSET bufor
    push 0
    call __read
    add esp, 12


    ; 16 znakow w hex do 64 bit edx:eax
    xor eax, eax
    xor edx, edx
    mov esi, OFFSET bufor       ;w esi adres bufora z hexem
    mov ecx, 16        ; 16 bajtow hex

convert_to_binary_loop:
    mov bl, [esi]   ; bajt hex do bl
    inc esi         ; nastepny bajt
    jb skip         ; niepoprawny znak hex
    cmp bl, '9'
    jbe decimal       ; '0' - '9'
    and bl, 0DFh   ; mala -> duza litera
    cmp bl, '0'     
    sub bl, 'A'
    add bl, 10      ; 'A'–'F' -> 10–15
    jmp got_decimal
decimal:
    sub bl, '0'     ;'0'–'9' -> 0–9
    ; w bl wartosc od 0-15
got_decimal:
    shld edx, eax, 4
    shl eax, 4
    or  al, bl
skip:
    loop convert_to_binary_loop

    ; 64 bity w edx:eax 
    ; zeby uzyskac wartosc koncowa pomijajac 0.
    ; edx:eax * 10^8, daje 96 bitow z ktorych interesuje nas tylko najstarsze 32 ktore sa naszymi cyframi po 0.
    mov ebx, dziesiec8       ;do ebx 10^8
    push edx        ; starsza czesc liczby edx:eax zachowana
    mul ebx         ; w edx:eax wynik eax(mlodsza czesc liczby) * 10^8
    mov ecx, edx       ; starsza czesc wyniku mnozenia w ecx 
    pop eax         ; starsza czesc oryginalnej liczby do eax
    mul ebx               ; w edx:eax wynik edx(starsza czesc oryginalnej liczby) * 10^8
    add eax, ecx
    ; 96 bitow -> EDX:EAX:utracone czyli 0.xxxxxxxx xxxxxxxx xxxxxxxx
    mov eax, edx
    ; w eax 8 cyfr po 0.

    mov esi, OFFSET wynik       ;adres miejsca na wynik do esi
    mov ecx, 8      ; osiem cyfr po przecinku
    mov ebx, 10     ; 10 do dzielenia


do_ascii:
    xor edx, edx        
    div ebx             ; eax/10 -> iloraz w eax, reszta w edx
    add dl, '0'         ; reszta do ascii
    dec ecx         ; liczba pozostalych cyfr
    mov [esi+ecx], dl       ; zapisanie cyfry do wyniku
    cmp ecx, 0
    jne do_ascii


    mov esi, OFFSET wynik 
    xor ebx, ebx    ; w ebx liczba zer do usuniecia z konca
    mov ecx, 7
    xor edx, edx
count_zeros_to_delete:
    mov dl, [wynik+ecx]
    cmp dl, '0'
    jne delete_zeros
    mov [wynik+ecx], byte ptr 0
    inc ebx
    dec ecx
    jnz count_zeros_to_delete

delete_zeros:
    xor edi, edi
    mov edi, 8
    sub edi, ebx

    ; wypisanie prefiksu "0."
    push 2      ; 2 bajty
    push OFFSET wynik_prefix
    push 1
    call __write
    add esp, 12

    ; wypisanie cyfr
    push edi
    push OFFSET wynik
    push 1
    call __write
    add esp, 12

	ret
_main ENDP
END