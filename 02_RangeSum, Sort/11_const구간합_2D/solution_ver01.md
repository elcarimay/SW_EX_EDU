```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
/*
11_const구간합2D_ver01

get prefix sum
1) 가로방향 누적합
2) 세로방향 누적합
*/
#include <cstdio>
#define LM 1002

using LL = long long;
int N, Q, A[LM][LM];
LL ps[LM][LM];

int main() {
#ifndef ONLINE_JUDGE
	freopen("11.txt", "r", stdin);
#endif // ONLINE_JUDGE
	scanf("%d", &N);
	for (int i = 1; i <= N; ++i) {
		for (int j = 1; j <= N; ++j) scanf("%d", A[i] + j);
	}

	// get prefixSum 2D
	for (int i = 1; i <= N; ++i) {  // 가로 방향 누적합
		for (int j = 1; j <= N; ++j)
			ps[i][j] = ps[i][j - 1] + A[i][j];
	}
	for (int j = 1; j <= N; ++j) {  // 세로 방향 누적합
		for (int i = 1; i <= N; ++i)
			ps[i][j] += ps[i - 1][j];
	}

	// query process
	int sr, sc, er, ec;
	scanf("%d", &Q);
	for (int q = 0; q < Q; ++q) {
		scanf("%d %d %d %d", &sr, &sc, &er, &ec);
		--sr, --sc;
		printf("%lld\n", ps[er][ec] - ps[er][sc] - ps[sr][ec] + ps[sr][sc]);
	}

	return 0;
}

```
