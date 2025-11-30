```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
/*
42_오리무전기_ver01
*/
#include <cstdio>

enum{LM = 1005, ELM = LM * LM};
int N, G[LM], gcnt;
int r[LM], c[LM], ans;
int getCost(int dr, int dc) {
	return dr * dr + dc * dc;
}
struct Edge {
	int s, e, cost;
	bool operator<(const Edge&t)const {
		return cost < t.cost;
	}
}edges[ELM], trr[ELM];
int ecnt;

void mergeSort(Edge*arr, int s, int e) {  // [s, e] : 폐구간
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

int Find(int r) {
	if (r == G[r]) return r;
	return G[r] = Find(G[r]);
}

void Union(int x, int y) {
	x = Find(x), y = Find(y);
	if (x == y) return;
	gcnt--;
	G[y] = x;
}

int main() {
#ifndef ONLINE_JUDGE
	freopen("42.txt", "r", stdin);
#endif // ONLINE_JUDGE
	scanf("%d", &N);
	gcnt = N;
	for (int i = 1; i <= N; ++i) {
		G[i] = i;
		scanf("%d %d", &r[i], &c[i]);
		for (int j = i - 1; j > 0; --j) {
			edges[++ecnt] = { i, j, getCost(r[i] - r[j], c[i] - c[j]) };
		}
	}

	mergeSort(edges, 1, ecnt);

	for (int i = 1; i <= ecnt; ++i) {
		Union(edges[i].s, edges[i].e);
		if (gcnt == 1) {
			ans = edges[i].cost;
			break;
		}
	}

	printf("%d\n", ans);

	return 0;
}
```
