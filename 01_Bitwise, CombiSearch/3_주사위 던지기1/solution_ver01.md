```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
/*
03_주사위던지기1_ver01
3개의 함수
*/
#include <cstdio>

int N, type, A[7] = {1}, used[7];

void output() {
	for (int i = 1; i <= N; ++i) printf("%d ", A[i]);
	puts("");
}
void dfs1(int step) {  // 중복 순열
	// 1. base condition
	if (step > N) {
		output();
		return;
	}
	// 2. normal condition
	for (int i = 1; i < 7; ++i) {
		A[step] = i;
		dfs1(step + 1);
	}
}

void dfs2(int step) { // 중복 조합
	// 1. base condition
	if (step > N) {
		output();
		return;
	}
	// 2. normal condition
	for (int i = A[step - 1]; i < 7; ++i) {
		A[step] = i;
		dfs2(step + 1);
	}
}

void dfs3(int step) {
	// 1. base condition
	if (step > N) {
		output();
		return;
	}
	// 2. normal condition
	for (int i = 1; i < 7; ++i) {
		if (used[i]) continue;
		used[i] = 1;
		A[step] = i;
		dfs3(step + 1);
		used[i] = 0;
	}
}

int main() {
#ifndef ONLINE_JUDGE
	freopen("03.txt", "r", stdin);
	freopen("output.txt", "w", stdout);
#endif // ONLINE_JUDGE
	scanf("%d %d", &N, &type);
	if (type == 1) dfs1(1);
	else if (type == 2) dfs2(1);
	else dfs3(1);

	return 0;
}

```
