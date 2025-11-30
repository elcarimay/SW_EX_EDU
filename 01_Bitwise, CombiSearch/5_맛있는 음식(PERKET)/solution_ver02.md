```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
/*
05_맛있는음식_ver02
binary 이용한 조합
*/
#include <cstdio>

#define Abs(a) ((a) < 0? -(a):(a))
#define Min(a, b) ((a) < (b) ? (a):(b))
#define Max(a, b) ((a) > (b) ? (a):(b))

int N, sour[12], bitter[12];
int ans = 1 << 30; // 1 * 2의 30제곱

void loop() {      // #####
	int cnt = 1 << N;
	for (int i = 1; i < cnt; ++i) {
		int sProd = 1, bSum = 0;
		for (int j = 0; j < N; ++j) {
			if ((i >> j) & 1) {  // i라는 수의 j번째 비트가 1이라면
				sProd *= sour[j];
				bSum += bitter[j];
			}
		}
		ans = Min(ans, Abs(sProd - bSum));
	}
}

int main() {
#ifndef ONLINE_JUDGE
	freopen("05.txt", "r", stdin);
#endif // ONLINE_JUDGE
	scanf("%d", &N);
	for (int i = 0; i < N; ++i) { // #####
		scanf("%d %d", sour + i, bitter + i); // &sour[i]
	}

	loop();

	printf("%d\n", ans);
	return 0;
}
```
