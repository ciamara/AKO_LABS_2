.386
rozkazy SEGMENT use16
ASSUME cs:rozkazy

;============================================================
wektor8 dd ?        ; stary wektor zegara
wektor9 dd ?        ; stary wektor klawiatury
klawisz_kod db 0    ; scan code

;============================================================
; int 9h obsluga klawiatury
obsluga_klawiatury PROC
    push ax
    push ds
    
    mov ax, cs
    mov ds, ax

    in al, 60h          ; odczyt klawiszu z portu
    
    ; make/break code
    test al, 80h        
    jnz koniec_int9     ; puszczenie klawisza

    mov klawisz_kod, al ; scan code do zmiennnej

koniec_int9:
    pop ds
    pop ax
    jmp dword PTR cs:wektor9
obsluga_klawiatury ENDP

;============================================================
; podprogram pomocniczy do konwersji i wyswietlania
konwertuj_i_wypisz PROC
    push ax
    push bx
    
    mov cl, 10      
    mov ah, 0       
    div cl          
    add al, 30h     
    add ah, 30h     
    
    mov es:[bx], al
    mov byte ptr es:[bx+1], 00001111B 
    mov es:[bx+2], ah
    mov byte ptr es:[bx+3], 00001111B 
    
    pop bx
    pop ax
    ret
konwertuj_i_wypisz ENDP

;============================================================
; podprogram do wyswietlania pozycji kursora
wyswietl_komorki PROC
    push ax
    push cx
    push dx
    push ds

    mov ax, 0040h
    mov ds, ax

    mov al, ds:[0050h]      
    call konwertuj_i_wypisz     
    
    add bx, 6           
    mov al, ds:[0051h]      
    call konwertuj_i_wypisz     

    pop ds
    pop dx
    pop cx
    pop ax
    ret
wyswietl_komorki ENDP

;============================================================
; procedura obslugi przerwania zegarowego
obsluga_zegara PROC
    push ax
    push bx
    push es

    mov ax, 0B800h 
    mov es, ax
    mov bx, 3988        
    call wyswietl_komorki

    pop es
    pop bx
    pop ax
    jmp dword PTR cs:wektor8
obsluga_zegara ENDP

;============================================================
; PROGRAM GLOWNY
zacznij:
    ; czyszczenie ekranu
    mov ax, 0B800h
    mov es, ax
    xor di, di
    mov ax, 0720h
    mov cx, 2000
    cld     
    rep stosw   

    mov al, 0       
    mov ah, 5       
    int 10      

    mov ax, 0
    mov ds, ax

    ; ---INT 8 ---
    mov eax, ds:[32] 
    mov cs:wektor8, eax     
    
    mov ax, SEG obsluga_zegara 
    mov bx, OFFSET obsluga_zegara 
    cli 
    mov ds:[32], bx 
    mov ds:[34], ax 
    sti 

    ; ---INT 9 ---
    ; 9 * 4 = 36
    mov eax, ds:[36]
    mov cs:wektor9, eax ; zapamietanie starego wektoru

    mov ax, SEG obsluga_klawiatury
    mov bx, OFFSET obsluga_klawiatury
    cli
    mov ds:[36], bx     ; offset nowej procedury
    mov ds:[38], ax     ; segment nowej procedury
    sti

aktywne_oczekiwanie:

    cmp cs:klawisz_kod, 0
    je aktywne_oczekiwanie ; 0 -> brak wcisniecia

    mov al, cs:klawisz_kod ; pobranie kodu
    mov cs:klawisz_kod, 0  ; wyzerowanie zmiennej

    ; porownanie make codow
    cmp al, 1Eh     ; a scan code 1Eh
    je lewo
    cmp al, 1Fh     ; s scan code 1Fh
    je dol
    cmp al, 20h     ; d scan code 20h
    je prawo
    cmp al, 11h     ; w scan code 11h
    je gora

    cmp al, 25h     ; k scan code 25h
    je exit
    
    jmp aktywne_oczekiwanie ; inny klawisz

lewo:
    mov ax, 0040h       
    mov ds, ax
    mov dl, ds:[0050h]   
    mov dh, ds:[0051h]   
    dec dl               
    cmp dl, 0FFh         
    jne aktualizacja_kursora
    mov dl, 79           
    jmp aktualizacja_kursora
dol:
    mov ax, 0040h
    mov ds, ax
    mov dl, ds:[0050h]
    mov dh, ds:[0051h]
    inc dh               
    cmp dh, 25           
    jne aktualizacja_kursora
    mov dh, 0            
    jmp aktualizacja_kursora
prawo:
    mov ax, 0040h
    mov ds, ax
    mov dl, ds:[0050h]
    mov dh, ds:[0051h]
    inc dl               
    cmp dl, 80           
    jne aktualizacja_kursora
    mov dl, 0            
    jmp aktualizacja_kursora
gora:
    mov ax, 0040h
    mov ds, ax
    mov dl, ds:[0050h]
    mov dh, ds:[0051h]
    dec dh               
    cmp dh, 0FFh         
    jne aktualizacja_kursora
    mov dh, 24           
    jmp aktualizacja_kursora

aktualizacja_kursora:
    ;bialy prostokat
    ;mov al, 0dbh
    ;mov bl, 00001111B
    ;mov ah, 09h
    ;int 10h
    mov ah, 02h          
    mov bh, 0            
    int 10h             
    jmp aktywne_oczekiwanie

exit:
    xor ax, ax
    mov ds, ax
    
    cli
    ; przywrocenie wektora 8 
    mov eax, cs:wektor8     
    mov ds:[32], eax 
    
    ; przywrocenie wektora 9
    mov eax, cs:wektor9
    mov ds:[36], eax
    sti

    mov al, 0
    mov ah, 4CH
    int 21H
rozkazy ENDS

nasz_stos SEGMENT stack
    db 128 dup (?)
nasz_stos ENDS

END zacznij