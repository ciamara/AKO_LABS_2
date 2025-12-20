.386
rozkazy SEGMENT use16
ASSUME cs:rozkazy

;============================================================
; podprogram pomocniczy do konwersji i wyswietlania wartosci w prawym dolnym rogu ekranu, wartosc do wypisania w al
konwertuj_i_wypisz PROC
    push ax
    push bx
    
    mov cl, 10      ; dzielnik
    mov ah, 0       ; czyszczenie ah przed dzieleniem
    
    div cl          ; al = dziesiatki, ah = jednosci
    
    add al, 30h     ; dziesiatki -> ascii
    add ah, 30h     ; jednosci -> ascii
    
    ; wyswietlenie dziesiatek
    mov es:[bx], al
    mov byte ptr es:[bx+1], 00001111B ; kolor
    
    ; wyswietlenie jednosci
    mov es:[bx+2], ah
    mov byte ptr es:[bx+3], 00001111B ; kolor
    
    pop bx
    pop ax
    ret
konwertuj_i_wypisz ENDP

;============================================================
; podprogram do wyswietlania zawartosci adresow 0040:0050h oraz 0040:0051h w prawym dolnym rogu ekranu, jest to kolumna i wiersz pozycji kursora
wyswietl_komorki PROC
    push ax
    push cx
    push dx
    push ds

    ; czyszczenie konsoli
    ;mov ax, 0B800h
    ;mov es, ax
    ;xor di, di          ; di = 0 pierwsza komorka
    
    ;mov al, ' '         ;
    ;mov ah, 07h         ; 
    
    ;mov cx, 2000        ; 80x25 = 2000 znakow
;clear_loop:
    ;mov es:[di], ax
    ;add di, 2
    ;loop clear_loop

    ; bios data area (pozycja kursora)
    mov ax, 0040h
    mov ds, ax

    ; WYSWIETLANIE KOLUMNY 0050h
    mov al, ds:[0050h]      ; adres przechowujacy pozycje kursora (kolumne)
    call konwertuj_i_wypisz     ; wywolanie funkcji do konwersji i wyswietlenia wartosci w al
    
    ; WYSWIETLANIE WIERSZA 0051h
    add bx, 6           ; przesuniecie o pierwsze cyfry i spacje
    mov al, ds:[0051h]      ; adres przechowujacy pozycje kursora (wiersz)
    call konwertuj_i_wypisz     ; wywolanie funkcji do konwersji i wyswietlenia wartosci w al

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

    mov ax, 0B800h ;adres pamieci ekranu
    mov es, ax
    
    ;wyswietlanie w rogu zawartosci adresow
    mov bx, 3988        ; adres rogu ekranu - tyle ile potrzebujemy na wyswietlanie cyfr
    call wyswietl_komorki

    pop es
    pop bx
    pop ax
    ; skok do oryginalnej procedury obslugi przerwania zegarowego
    jmp dword PTR cs:wektor8

    wektor8 dd ?
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
    cld     ; kierunek przetwarzania w przod
    rep stosw   ; wypelnienie calego ekranu

    mov al, 0       ; numer strony
    mov ah, 5       ; funkcja do przelaczania strony
    int 10      ; wywolanie uslugi biosu

    mov ax, 0
    mov ds,ax ; zerowanie rejestru DS
    ; odczytanie zawartosci wektora nr 8 i zapisanie go w zmiennej wektor8 
    mov eax,ds:[32] ; adres fizyczny 0*16 + 32 = 32, przerwanie nr 8
    mov cs:wektor8, eax     ; zapisanie starego adresu aby potem przywrocic

    ; wpisanie do wektora nr 8 adresu procedury 'obsluga_zegara'
    mov ax, SEG obsluga_zegara ; czesc segmentowa adresu
    mov bx, OFFSET obsluga_zegara ; offset adresu
    cli ; zablokowanie przerwan
    ; zapisanie adresu procedury do wektora nr 8
    mov ds:[32], bx ; OFFSET
    mov ds:[34], ax ; cz. segmentowa
    sti ;odblokowanie przerwan

    ; oczekiwanie na nacisniecie klawiszy 'k', 'w', 'a', 's', 'd'
aktywne_oczekiwanie:
    mov ah,1
    int 16H
    ; funkcja INT 16H (AH=1) BIOSu ustawia ZF=1 jesli
    ; nacisnieto jakis klawisz
    jz aktywne_oczekiwanie
    ; odczytanie kodu ASCII nacisnietego klawisza (INT 16H, AH=0)
    ; do rejestru AL
    mov ah, 0
    int 16H     ; pobranie znaku z bufora, al = ascii

    cmp al, 'a'     ; lewo
    je lewo
    cmp al, 's'     ; dol
    je dol
    cmp al, 'd'     ; prawo
    je prawo
    cmp al, 'w'     ; gora
    je gora

    cmp al, 'k'     ; wyjscie z programu
    je exit
    jne aktywne_oczekiwanie ; skok, gdy inny znak

lewo:
    ; kursor w lewo
    mov ax, 0040h       ; dane pozycji kursora
    mov ds, ax
    mov dl, ds:[0050h]   ; aktualna kolumna
    mov dh, ds:[0051h]   ; aktualny wiersz
    dec dl               ; ruch kursora w lewo
    cmp dl, 0FFh         ; sprawdzam czy powinno sie zawinac
    jne aktualizacja_kursora
    mov dl, 79           ; zawijanie do ostatniej (79) kolumny
    jmp aktualizacja_kursora
dol:
    ; kursor w dol
    mov ax, 0040h
    mov ds, ax
    mov dl, ds:[0050h]
    mov dh, ds:[0051h]
    inc dh               ; ruch kursora w dol
    cmp dh, 25           ; czy ostatni wiersz
    jne aktualizacja_kursora
    mov dh, 0            ; zawiniecie do pierwszego wiersza (0)
    jmp aktualizacja_kursora
prawo:
    ; kursor w prawo
    mov ax, 0040h
    mov ds, ax
    mov dl, ds:[0050h]
    mov dh, ds:[0051h]
    inc dl               ; ruch kursora w prawo
    cmp dl, 80           ; sprawdzam czy ostatnia kolumna
    jne aktualizacja_kursora
    mov dl, 0            ; zawijanie do pierwszej (0)
    jmp aktualizacja_kursora
gora:
    ; kursor w gore
    mov ax, 0040h
    mov ds, ax
    mov dl, ds:[0050h]
    mov dh, ds:[0051h]
    dec dh               ; ruch kursora w gore
    cmp dh, 0FFh         ; sprawdzam czy pierwszy wiersz
    jne aktualizacja_kursora
    mov dh, 24           ; zawiniecie do ostatniego wiersza (24)
    jmp aktualizacja_kursora

aktualizacja_kursora:
    mov ah, 02h          ; bios -> ustawienie kursora
    mov bh, 0            ; strona 0
    int 10h             ; ruch fizyczny kursora na ekranie
    jmp aktywne_oczekiwanie

exit:
    xor ax, ax
    mov ds, ax
    ; deinstalacja procedury obslugi przerwania zegarowego
    ; odtworzenie oryginalnej zawartosci wektora nr 8
    mov eax, cs:wektor8     ; pobranie starego oryginalnego adresu
    cli
    mov ds:[32], eax ; przeslanie wartosci oryginalnej
    ; do wektora 8 w tablicy wektorow
    ; przerwan
    sti

    mov al, 0
    mov ah, 4CH
    int 21H
rozkazy ENDS

nasz_stos SEGMENT stack
    db 128 dup (?)
nasz_stos ENDS

END zacznij