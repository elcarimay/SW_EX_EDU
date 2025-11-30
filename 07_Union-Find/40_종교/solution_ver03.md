```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
/*
40_종교_ver03
memory pool linkedlist를 이용한 Union Find
*/
#include <cstdio>

enum { LM = 50005, BLM = LM * 10 };
int N, M;
int ans;    // 종교의 수
int G[LM], gcnt[LM];  // 각 노드의 그룹번호
struct Node {
	int id;
	Node* next;
	Node*alloc(int nid, Node*nn) {
		id = nid, next = nn;
		return this;
	}
}buf[BLM], *adj[LM];
int bcnt;

void Union(int x, int y) {
	x = G[x], y = G[y];
	if (x == y) return;
	ans--;
	if (gcnt[x] < gcnt[y]) {
		int t = x; x = y; y = t;
	}
	// gcnt[x] > gcnt[y]
	Node*p = adj[y];
	gcnt[x] += gcnt[y];
	while (1) {
		G[p->id] = x;
		if (p->next == nullptr) break;
		p = p->next;   // *****
	}
	p->next = adj[x]->next;
	adj[x]->next = adj[y];
}

int main() {
#ifndef ONLINE_JUDGE
	freopen("40.txt", "r", stdin);
#endif // ONLINE_JUDGE
	scanf("%d %d", &N, &M);
	ans = N;  // 초기 종교수는 M개라고 가정
	for (int i = 1; i <= N; ++i) {
		G[i] = i, gcnt[i] = 1;
		adj[i] = buf[bcnt++].alloc(i, nullptr);
	}

	for (int i = 0, x, y; i < M; ++i) {
		scanf("%d %d", &x, &y);
		Union(x, y);
	}

	printf("%d\n", ans);
	return 0;
}

```
