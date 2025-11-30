```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
/*
11_const구간합2D_ver02

get prefix sum
ps[i][j] = ps[i][j-1] + ps[i-1][j] - ps[i-1][j-1] + A[i][j]
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
	// input & get prefixSum 2D
	scanf("%d", &N);
	for (int i = 1; i <= N; ++i) {
		for (int j = 1; j <= N; ++j) {
			scanf("%d", A[i] + j);
			ps[i][j] = ps[i][j - 1] + ps[i - 1][j] - ps[i - 1][j - 1] + A[i][j];
		}
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
