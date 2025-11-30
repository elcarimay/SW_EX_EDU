```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
/*
38_Festival_ver02
[해결전략]
: ArrayLinkedList + O(E*lov(V)) Dijkstra
1. X축제마을로 가기       : 역방향 그래프를 이용하여 구하기 => idea
2. 자신의 마을로 돌아가기 : 순방향 그래프 이용
*/
#include <cstdio>
#define Max(a, b) ((a) > (b)? (a):(b))

enum { LM = 1005, ELM = 10005, INF = 1 << 20 };
int N, E, X, ans;
int fwDist[LM], bwDist[LM];
struct Adj {
	int np, next[ELM], child[ELM], cost[ELM], start[LM];
	void setG(int s, int e, int w) {
		next[++np] = start[s], child[np] = e, cost[np] = w, start[s] = np;
	}
}fw, bw;  // Array Linked List obejct

struct Data {
	int node, curDist;
	bool operator<(const Data&t)const {
		return curDist < t.curDist;
	}
};

void Swap(Data&a, Data&b) {
	Data t = a; a = b; b = t;
}
struct PQ {
	Data heap[ELM];
	int hn;
	void init() { hn = 0; }
	bool empty() { return hn == 0; }
	int size() { return hn; }
	Data top() { return heap[1]; }
	void push(const Data nd) {
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

void input() {
	scanf("%d %d %d", &N, &E, &X);
	for (int i = 0, s, e, w; i < E; ++i) {
		scanf("%d %d %d", &s, &e, &w);
		fw.setG(s, e, w), bw.setG(e, s, w);
	}
}

void Dijkstra(Adj&adj, int dist[]) {
	// init
	pq.init();
	for (int i = 1; i <= N; ++i) dist[i] = INF;
	dist[X] = 0;
	pq.push({ X, 0 });

	// Dijkstra main process
	while (!pq.empty()) {
		Data t = pq.top(); pq.pop();
		if (dist[t.node] < t.curDist) continue;
		for (int j = adj.start[t.node]; j; j = adj.next[j]) {
			int nextNode = adj.child[j];
			int nextDist = t.curDist + adj.cost[j];
			if (dist[nextNode] > nextDist) {
				dist[nextNode] = nextDist;
				pq.push({ nextNode, nextDist });
			}
		}
	}
}

int main() {
#ifndef ONLINE_JUDGE
	freopen("38.txt", "r", stdin);
#endif // ONLINE_JUDGE
	input();

	Dijkstra(bw, bwDist);  // 축제마을 X로 가기
	Dijkstra(fw, fwDist);  // 자신의 마을로 돌아오기

	for (int i = 1; i <= N; ++i) {
		ans = Max(ans, bwDist[i] + fwDist[i]);
	}
	printf("%d\n", ans);

	return 0;
}
```
