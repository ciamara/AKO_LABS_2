#include <iomanip>
#include <iostream>
#include <cstdlib>
#include <cmath>

using namespace std;


float f(float x)
{
    return((x*x*x * sin(x)) - (5*x));
}


int main()
{
    const int N = 200;
    float xp, xk, s, st, dx, x;
    int i;

    xp = 0;

    xk = 5;

    s = 0; st = 0;
    dx = (xk - xp) / N;
    for (i = 1; i <= N; i++)
    {
        //cout << "st : " << setw(8) << st <<endl;
        //cout << "s : " << setw(8) << s <<endl;
        //cout << i << endl;
        x = xp + i * dx;
        st += f(x - dx / 2);
        if (i < N) s += f(x);
    }
    //cout << "st : " << setw(8) << st <<endl;
    //cout << "s : " << setw(8) << s <<endl;
    s = dx / 6 * (f(xp) + f(xk) + 2 * s + 4 * st);
    cout << "Wartosc calki wynosi : " << setw(8) << s
        << endl << endl;
    system("pause");
    return 0;
}