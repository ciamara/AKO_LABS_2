.686
.model flat

public _ustaw_zmienna

extern _SetEnvironmentVariableW@8 : PROC
extern _getenv : PROC

.data

.code

_ustaw_zmienna PROC
	push ebp
	mov ebp, esp

	; sprawdzenie czy zmienna istnieje
	push [ebp+8]
	call _getenv			; cdecl
	add esp, 4

	cmp eax, 0
	jne error

	; zmienna nie istnieje -> moza stworzyc
	push [ebp+12]
	push [ebp+8]
	call _SetEnvironmentVariableW@8		; winapi

	cmp eax, 0
    je error       ; ustawianie zmiennej nie powiodlo sie

	; poprawne ustawienie zmiennej
	mov eax, 1
    mov edx, 0
	jmp finish


error:
	mov eax, 0
    mov edx, 0

finish:

	mov esp, ebp
	pop ebp
	ret
_ustaw_zmienna ENDP

END