.686
.model flat

public _simpson
public _f


.data

.code

; funkcja liczaca f(x) wartosc
_f PROC	
	push ebp
	mov ebp,esp

	fld dword ptr [ebp+8]       ; ST(0) = x
    fmul st(0), st(0)           ; ST(0) = x^2
    fmul dword ptr [ebp+8]      ; ST(0) = x^3

    fld dword ptr [ebp+8]       ; ST(0) = x,    ST(1) = x^3
    fsin                        ; ST(0) = sinx, ST(1) = x^3

    fmulp st(1), st(0)          

    ; ST(0) -> [x^3 * sinx]

    fld dword ptr [ebp+8]       ; ST(0) = x,   ST(1) = [x^3 * sinx]
    
    push 5
    fild dword ptr [esp]
    add esp, 4
    
    ; ST(0) = 5.0, ST(1) = x, ST(2) = [x^3 * sinx]
    fmulp st(1), st(0)          ; ST(0) = 5x,  ST(1) = wynik_cz1

    fsubp st(1), st(0)
	
	;wynik w ST(0)
	mov esp, ebp
	pop ebp
	ret
_f ENDP

_simpson PROC
	push ebp
	mov ebp,esp

	sub esp, 20

	finit

	; -4 -> przyblizona wartosc calki -> s
	; -8 -> suma wartosci funkcji w punktach srodkowych -> st
	; -12 -> odleglosc miedzy dwoma sasiednimi punktami podzialowymi -> dx
	; -16 -> placeholder na przenoszenie z eax po call f

	; +8 -> a -> xp
	; +12 -> b -> xk
	; +16 -> n -> liczba punktow przedzialowych

	; INICJALIZACJA ZMIENNYCH 


	; ZAMIANA MIEJSCAMI GDY a >= b

	xor ecx, ecx
	xor edx, edx

	mov ecx, dword ptr [ebp+8]		; ecx=a
	mov edx, dword ptr [ebp+12]		; edx=b

	fld dword ptr [ebp+12]	; ST(1)=b
	fld dword ptr [ebp+8]		; ST(0)=a
	fcomi ST(0), ST(1)		; porownuje a z b
	; usuwanie ze stosu
	fstp ST(1)
	fstp ST(1)

	jbe skip_swap
	; a > b
	; zamiana
	mov dword ptr [ebp+8], edx
	mov dword ptr [ebp+12], ecx


skip_swap:

	mov [ebp-4], dword ptr 0		; s=0
	mov [ebp-8], dword ptr 0		; st=0

	xor esi, esi		; licznik punktow przedzialowych -> i
	inc esi
	xor ebx, ebx		; pozycja punktu przedzialowego -> x

	xor eax, eax

	; INICJALIZACJA dx

	fld dword ptr [ebp+12]
	fld dword ptr [ebp+8]		; ST(0) = xp, ST(1) = xk

	fsubp	; ST(0) = xk-xp

	fld dword ptr [ebp+16]	;ST(0)= n, ST(1)=xk-xp

	fdivp	;ST(0) = (xk-xp)/n

	sub esp, 4
	fstp dword ptr [esp]
	mov eax, [esp]	; eax = (xk-xp)/n


	mov [ebp-12], eax
	
	; KONIEC INICJALIZACJI ZMIENNYCH	


main_loop:

	fld dword ptr [ebp+16]
	push esi
	fild dword ptr [esp]
	add esp, 4

	fcomi ST(0), ST(1)

	fstp ST(1)
	fstp ST(1)

	;cmp esi, [ebp+16]
	ja endbruh
	
	mov ebx, [ebp+8]	; x = xp

	fld dword ptr [ebp-12]
	push esi
	fild dword ptr [esp]
	add esp, 4
	fmulp		; ST(0) = dx*i

	fld dword ptr [ebp+8]    ; ebx = x = xp + i*dx
	faddp		; ST(0) = i*dx + xp

	sub esp, 4
	fstp dword ptr [esp]

	mov ebx, [esp]	; x = i*dx + xp

	add esp, 4

	; POCZATEK LICZENIA  ST I S

	fld dword ptr [ebp-12]		; dx
	push 2
	fild dword ptr [esp]		; ST(0) = 2, ST(1) = dx
	add esp, 4
	fdivp		; ST(0) = dx/2

	push ebx	
	fld dword ptr [esp]		; ST(0) = x, ST(1) = dx/2
	add esp, 4

	fsub ST(0), ST(1)		; ST(0) = x - dx/2
	fstp ST(1)
	
	sub esp, 4
	fstp dword ptr [esp]
	mov eax, [esp]	; eax = x - dx/2
	add esp, 4

	push eax
	call _f
	add esp, 4
	; ST(0) = f( x - dx/2 )

	fld dword ptr [ebp-8]		; ST(0) = st, ST(1) = f( x - dx/2 )
	faddp		; ST(0) = st + f( x - dx/2 )

	sub esp, 4
	fstp dword ptr [esp]
	mov eax, [esp]
	add esp, 4
	mov [ebp-8], eax	; st = st + f( x - dx/2 )

	fld dword ptr [ebp+16]
	push esi
	fild dword ptr [esp]
	add esp, 4

	fcomi ST(0), ST(1)

	fstp ST(1)
	fstp ST(1)

	;cmp esi, [ebp+16]
	jae continue

	push ebx	; x argument
	call _f
	add esp, 4
	; ST(0) = f(x)

	fld dword ptr [ebp-4]		; ST(0) = s, ST(1) = f(x)
	faddp		; ST(0) = s + f(x)

	sub esp, 4
	fstp dword ptr [esp]
	mov eax, [esp]		; eax = s + f(x)
	add esp, 4
	mov [ebp-4], eax		; s = s + f(x)

continue:

	inc esi

	jmp main_loop
	


endbruh:	; obliczenie koncowej wartosci przyblizonej calki
	
	fld dword ptr [ebp-12]
	push 6
	fild dword ptr [esp]
	add esp, 4
	fdivp
	
	; ST(0) = dx/6

	fld dword ptr [ebp-8]	; st
	fadd ST(0), ST(0)       ; st * 4
    fadd ST(0), ST(0)
	fld dword ptr [ebp-4]	; s
	fadd ST(0), ST(0)       ; s * 2


	push [ebp+12] ; xk (zeby policzyc f(xk))
	call _f
	add esp, 4

	push [ebp+8]	; xp (zeby policzyc f(xp))
	call _f
	add esp, 4

	faddp
	faddp
	faddp

	fmulp


	add esp, 20
	mov esp, ebp
	pop ebp
	ret
_simpson ENDP

END