```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
/*
05_맛있는음식_ver01
dfs를 이용한 조합
*/
#include <cstdio>

#define Abs(a) ((a) < 0? -(a):(a))
#define Min(a, b) ((a) < (b) ? (a):(b))
#define Max(a, b) ((a) > (b) ? (a):(b))

int N, sour[12], bitter[12];
int ans = 1 << 30; // 1 * 2의 30제곱

// implement here
void dfs(int step, int sProd, int bSum) {
	if (bSum > 0) { // ans update
		ans = Min(ans, Abs(sProd - bSum));
	}
	// base condition
	if (step > N) return;

	// normal condition
	// 0. 선택하지 않는 경우
	dfs(step + 1, sProd, bSum);
	// 1. 선택하는 경우
	dfs(step + 1, sProd * sour[step], bSum + bitter[step]);
}

int main() {
#ifndef ONLINE_JUDGE
	freopen("05.txt", "r", stdin);
#endif // ONLINE_JUDGE
	scanf("%d", &N);
	for (int i = 1; i <= N; ++i) {
		scanf("%d %d", sour + i, bitter + i); // &sour[i]
	}

	dfs(1, 1, 0); // step, sProd, bSum

	printf("%d\n", ans);
	return 0;
}
```
