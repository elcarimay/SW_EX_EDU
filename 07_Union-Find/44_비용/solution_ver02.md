```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
/*
44_비용_ver02
Query Optimization(가중치정렬 idea):countingSort응용 + UnionFind
*/
#include <cstdio>

using LL = long long;
enum { LM = 100005, MOD = (int)1e9 };
int N, M, xrr[LM], yrr[LM], maxW;
int G[LM], gcnt[LM];
LL ans, sum;

int Find(int r) {
	if (G[r] != r) G[r] = Find(G[r]);
	return G[r];
}

void Union(int x, int y) {
	x = Find(x), y = Find(y);
	if (x == y) return;
	ans = (ans + sum * gcnt[x] * gcnt[y]) % MOD;  // #####
	G[y] = x;
	gcnt[x] += gcnt[y];
}

int main() {
#ifndef ONLINE_JUDGE
	freopen("44.txt", "r", stdin);
#endif // ONLINE_JUDGE
	scanf("%d %d", &N, &M);
	for (int i = 1; i <= N; ++i)   // 그룹번호와 그룹의 원소수 초기화
		G[i] = i, gcnt[i] = 1;

	for (int i = 1, x, y, w; i <= M; ++i) {
		scanf("%d %d %d", &x, &y, &w);
		sum += w;
		xrr[w] = x, yrr[w] = y;     // 1. w는 유일하다. 2. w (1 ~ 100000)
		if (maxW < w) maxW = w;
	}

	for (int w = maxW; w > 0; --w) { // 높은 가중치를 갖는 간선부터 처리하기
		if (xrr[w] == 0) continue;
		Union(xrr[w], yrr[w]);
		sum -= w;                    // #####
	}

	printf("%lld\n", ans);

	return 0;
}
```
