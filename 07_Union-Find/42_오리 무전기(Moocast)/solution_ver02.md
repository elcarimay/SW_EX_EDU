```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
/*
42_오리무전기_ver02
UnionFind + minHeap
*/
#include <cstdio>

enum { LM = 1005, ELM = LM * LM };
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
};

void Swap(Edge&a, Edge&b) {
	Edge t = a; a = b; b = t;
}

struct PQ {
	Edge heap[ELM];
	int hn;
	bool empty() { return hn == 0; }
	int size() { return hn; }
	Edge top() { return heap[1]; }
	void push(const Edge nd) {
		heap[++hn] = nd;
		for (int c = hn; c > 1; c >>= 1) {
			if (heap[c] < heap[c >> 1]) Swap(heap[c], heap[c >> 1]);
			else break;
		}
	}
	void pop() {
		Swap(heap[1], heap[hn--]);
		for (int c = 2; c <= hn; c <<= 1) {
			if (c < hn && heap[c + 1] < heap[c]) ++c;
			if (heap[c] < heap[c >> 1]) Swap(heap[c], heap[c >> 1]);
			else break;
		}
	}
}pq;

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
			pq.push({ i, j, getCost(r[i] - r[j], c[i] - c[j]) });
		}
	}

	while(!pq.empty()) {
		Edge t = pq.top(); pq.pop();
		Union(t.s, t.e);
		if (gcnt == 1) {
			ans = t.cost;
			break;
		}
	}

	printf("%d\n", ans);

	return 0;
}
```
