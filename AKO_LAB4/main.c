#include <stdio.h>
#include <stdlib.h>


extern float simpson(float a, float b, float n);

extern float f(float x);


int main()
{
	float result = 0;
	float a = 100;
	float b = 15;
	float n = 200;

	//float value = f(10);
	//printf("wartosc funkcji wynosi: %f", value);

	result = simpson(a, b, n);

	printf("Wartosc przyblizona calki wynosi: %f", result);
	printf("\n");


	return 0;
}