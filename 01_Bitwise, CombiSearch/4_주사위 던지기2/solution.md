```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
/*
04_주사위던지기2

주사위던지기1의 type1을 조금 변경하여 해결할 수 있다.
*/
#include <cstdio>

int N, M, A[10];                 // #####  !!!!!

void output() {
	for (int i = 1; i <= N; ++i) printf("%d ", A[i]);
	puts("");
}

void dfs(int step, int sum) {   // ##### 주사위던지기1의 type1과 다른 부분
	// 1. base condition
	if (step > N) {
		if (sum == M)           // #####
			output();
		return;
	}
	// 2. normal condition
	for (int i = 1; i < 7; ++i) {
		A[step] = i;
		dfs(step + 1, sum + i); // #####
	}

}
int main() {
#ifndef ONLINE_JUDGE
	freopen("04.txt", "r", stdin);
#endif // ONLINE_JUDGE
	scanf("%d %d", &N, &M);
	dfs(1, 0);                  // #####
	return 0;
}

```
