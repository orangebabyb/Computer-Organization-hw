#include <stdio.h>

int mod_inverse(int a, int b) {
	// TODO
    int b0 = b, t, q;
    int x0 = 0, x1 = 1;

    if (b == 1)
        return 1;

    while (a > 1) {
        q = a / b;
        t = b;
        b = a % b;
        a = t;

        t = x0;
        x0 = x1 - q * x0;
        x1 = t;
    }

    if (a != 1) return -1;
    
    if (x1 < 0)
        x1 += b0;

    return x1;
}

int main() {
    int a, b;
    printf("Enter the number: ");
    scanf("%d", &a);
    printf("Enter the modulo: ");
    scanf("%d", &b);

    int inv = mod_inverse(a, b);
    if (inv == -1) {
        printf("Inverse not exist.\n");
    } else {
        printf("Result: %d\n", inv);
    }

    return 0;
}
