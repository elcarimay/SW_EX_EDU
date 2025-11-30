```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
/*
36_지하철_ver01
Floyd-Warshall
*/
#include <cstdio>

enum { LM = 105};
int N, tg, Mat[LM][LM];
int path[LM][LM];

void Floyd() {
	for (int k = 1; k <= N; ++k) {         // 경유지 !!!!!
		for (int i = 1; i <= N; ++i) {     // 출발지
			for (int j = 1; j <= N; ++j) { // 도착지
				if (Mat[i][j] > Mat[i][k] + Mat[k][j]) {
					Mat[i][j] = Mat[i][k] + Mat[k][j];
					path[i][j] = k;
				}
			}
		}
	}
}

void trace(int s, int e) {
	if (path[s][e] == 0) {
		printf("%d ", s);
		return;
	}
	trace(s, path[s][e]);
	trace(path[s][e], e);
}

int main() {
#ifndef ONLINE_JUDGE
	freopen("36.txt", "r", stdin);
#endif // ONLINE_JUDGE
	scanf("%d %d", &N, &tg);
	for (int i = 1; i <= N; ++i) {
		for (int j = 1; j <= N; ++j) scanf("%d", Mat[i] + j);
	}

	Floyd();

	printf("%d\n", Mat[1][tg]);
	trace(1, tg);
	printf("%d\n", tg);

	return 0;
}

```
