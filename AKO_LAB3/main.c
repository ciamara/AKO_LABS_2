#include <stdio.h>
#include <stdlib.h>

typedef unsigned long DWORD;

extern long long ustaw_zmienna(char* zmienna, char* wartosc);


extern __declspec(dllimport) DWORD __stdcall GetEnvironmentVariableW(
	const char* lpName,
	char* lpBuffer,
	DWORD nSize
);


int main()
{
	char bufor[256];
	DWORD wynik;

	long long status;
	wchar_t zmienna[] = L"test";
	wchar_t wartosc[] = L"hello";

	status = ustaw_zmienna(zmienna, wartosc);

	if (status == 0) {
		printf("Blad, zmienna istnieje lub SetEnvironmentVariable nie zadzialalo, zmienna nie ustawiona.");
	}
	else {
		printf("Zmienna ustawiona pomyslnie.\n");
	}

	wynik = GetEnvironmentVariableW(zmienna, bufor, sizeof(bufor));

	if (wynik > 0 && wynik < sizeof(bufor)) {
		printf("\nWERYFIKACJA PRAWIDLOWA:\n");
		printf("Zmienna %ls istnieje.\n", zmienna);
		printf("Wartosc zwrocona przez GetEnvironmentVariableA: %ls\n", bufor);
	}
	else {
		printf("\nWERYFIKACJA NIEPRAWIDLOWA:\n");
		printf("Zmienna %ls nie istnieje (return: %lu).\n", zmienna, wynik);
	}

	return 0;
}