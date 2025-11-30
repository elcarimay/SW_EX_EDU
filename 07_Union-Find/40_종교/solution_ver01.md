```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
/*
40_종교_ver01
UnionFind with Rank
*/
#include <cstdio>

enum{ LM = 50005 };
int N, M;
int ans;    // 종교의 수
int G[LM];  // 각 노드의 그룹번호
int rk[LM];

int Find(int r) {
	if (G[r] == r) return r;
	return G[r] = Find(G[r]);   // 경로 압축
}

void Union(int x, int y) {
	x = Find(x), y = Find(y);
	if (x == y) return; // 이미 같은 그룹
	ans--;   // x그룹과 y그룹이 같은 종교이므로 종교 수 감소
	if (rk[x] > rk[y]) G[y] = x;
	else {
		G[x] = y;
		if (rk[x] == rk[y])
			rk[y]++;
	}
}

int main() {
#ifndef ONLINE_JUDGE
	freopen("40.txt", "r", stdin);
#endif // ONLINE_JUDGE
	scanf("%d %d", &N, &M);
	ans = N;  // 초기 종교수는 M개라고 가정
	for (int i = 1; i <= N; ++i) G[i] = i;

	for (int i = 0, x, y; i < M; ++i) {
		scanf("%d %d", &x, &y);
		Union(x, y);
	}

	printf("%d\n", ans);
	return 0;
}

```
