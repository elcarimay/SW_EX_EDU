```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
/*
12_구간업데이트2D
차분배열테크닉(Difference Array Technique)
*/
#include <cstdio>

using LL = long long;
constexpr int LM = 1002;
int N, Q;
LL A[LM][LM], S[LM][LM];

int main() {
#ifndef ONLINE_JUDGE
	freopen("12.txt", "r", stdin);
#endif // ONLINE_JUDGE
	scanf("%d %d", &N, &Q);
	int sr, sc, er, ec, val;
	for (int q = 0; q < Q; ++q) {
		scanf("%d %d %d %d %d", &sr, &sc, &er, &ec, &val);
		++er, ++ec;
		A[sr][sc] += val, A[sr][ec] -= val;
		A[er][sc] -= val, A[er][ec] += val;
	}

	// get prefixSum & output
	for (int i = 1; i <= N; ++i) {
		for (int j = 1; j <= N; ++j) {
			S[i][j] = S[i][j - 1] + S[i - 1][j] - S[i - 1][j - 1] + A[i][j];
			printf("%lld ", S[i][j]);
		}
		puts("");
	}

	return 0;
}


```
