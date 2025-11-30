```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
/*
44_비용_ver01
Query Optimization(가중치정렬 idea):mergeSort + UnionFind
*/
#include <cstdio>

using LL = long long;
enum{ LM = 100005, MOD = (int)1e9 };
int N, M;
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

struct Data {
	int x, y, w;
	bool operator<(const Data&t)const {
		return w > t.w;
	}
}edges[LM], trr[LM];

void mergeSort(Data*arr, int s, int e) {
	if (s >= e) return;
	int m = (s + e) / 2, i = s, j = m + 1, k = s;
	mergeSort(arr, s, m), mergeSort(arr, m + 1, e);
	while (i <= m && j <= e) {
		if (arr[j] < arr[i]) trr[k++] = arr[j++];
		else trr[k++] = arr[i++];
	}
	while (i <= m) trr[k++] = arr[i++];
	while (j <= e) trr[k++] = arr[j++];
	for (i = s; i <= e; ++i) arr[i] = trr[i];
}

int main() {
#ifndef ONLINE_JUDGE
	freopen("44.txt", "r", stdin);
#endif // ONLINE_JUDGE
	scanf("%d %d", &N, &M);
	for (int i = 1; i <= N; ++i) G[i] = i, gcnt[i] = 1; // *****

	for (int i = 1, x, y, w; i <= M; ++i) {
		scanf("%d %d %d", &x, &y, &w);
		sum += w;
		edges[i] = { x, y, w };
	}
	mergeSort(edges, 1, M);

	for (int i = 1; i <= M; ++i) {
		Union(edges[i].x, edges[i].y);
		sum -= edges[i].w;              // #####
	}

	printf("%lld\n", ans);

	return 0;
}
```
