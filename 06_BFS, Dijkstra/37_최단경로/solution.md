```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
/*
37_최단경로2
Dijkstra: O(E*log(N)) concept problem
*/
#include <cstdio>

enum{ LM = 100005, ELM = 1 << 20, INF = (int)21e8 };
int N, E;
int dist[LM];

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

int np, next[ELM], child[ELM], cost[ELM], start[LM];
void setG(int s, int e, int curDist) {
	next[++np] = start[s], child[np] = e, cost[np] = curDist, start[s] = np;
}

void input() {
	scanf("%d %d", &N, &E);
	for (int i = 0, s, e, curDist; i < E; ++i) {
		scanf("%d %d %d", &s, &e, &curDist);
		setG(s, e, curDist);
	}
}

int Dijkstra(int src, int dest) {
	// init
	pq.init();
	for (int i = 1; i <= N; ++i) dist[i] = INF;
	dist[1] = 0;
	pq.push({ 1, 0 });

	// Dijkstra main process
	while (!pq.empty()) {
		// 1. extract minNode, minDist
		Data t = pq.top(); pq.pop();

		//if (t.node == dest) return t.curDist;  // 종료조건

		// 2. check minNode : pruning
		if (dist[t.node] < t.curDist) continue;
		// 3. relaxation
		for (int j = start[t.node]; j; j = next[j]) {
			int nextNode = child[j], nextDist = cost[j] + t.curDist;
			if (dist[nextNode] > nextDist) {
				dist[nextNode] = nextDist;
				pq.push({ nextNode, nextDist });
			}
		}
	}
	return dist[dest]; // 함수 형식을 맞추기 위한 반환
}

int main() {
#ifndef ONLINE_JUDGE
	freopen("37.txt", "r", stdin);
#endif // ONLINE_JUDGE
	input();
	printf("%d\n", Dijkstra(1, N));

	return 0;
}

```
