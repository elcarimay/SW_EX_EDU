```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
/*
03_주사위던지기1_ver02
1개의 함수
*/
#include <cstdio>

int N, type, A[7] = { 1 }, used[7];

void output() {
	for (int i = 1; i <= N; ++i) printf("%d ", A[i]);
	puts("");
}
void dfs(int step) {  // 중복 순열
	// 1. base condition
	if (step > N) {
		output();
		return;
	}
	// 2. normal condition
	int stNum = type == 2 ? A[step - 1] : 1;
	for (int i = stNum; i < 7; ++i) {
		if (used[i]) continue;
		if (type == 3) used[i] = 1;
		A[step] = i;
		dfs(step + 1);
		used[i] = 0;
	}
}

int main() {
#ifndef ONLINE_JUDGE
	freopen("03.txt", "r", stdin);
	freopen("output.txt", "w", stdout);
#endif // ONLINE_JUDGE
	scanf("%d %d", &N, &type);
	dfs(1);
	return 0;
}

```
