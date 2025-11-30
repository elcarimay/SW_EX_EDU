```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
/*
02_진법변환

1. Horner's method
2. Look Up Table을 사용할 수 있으면 사용한다.
*/
#include <cstdio>

using LL = long long;
int A, B;
char str[70], lut[] = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";

void dToB(LL d) {
	// 1. base condition
	if (d < B) {
		printf("%c", lut[d]);  // use lut
		return;
	}
	// 2. normal condition
	dToB(d / B);
	printf("%c", lut[d % B]);
}

int main() {
#ifndef ONLINE_JUDGE
	freopen("02.txt", "r", stdin);
#endif // ONLINE_JUDGE
	while (scanf("%d %s %d", &A, str, &B) && A) {
		// 1. to decimal
		LL d = 0;
		for (int i = 0; str[i]; ++i) {  // Horner's rule
			if (str[i] < 'A') d = d * A + (str[i] - '0');
			else d = d * A + (str[i] - 'A' + 10);
		}
		// 2. to B_system
		dToB(d);
		puts("");  // printf("\n");
	}

	return 0;
}

```
