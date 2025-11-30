```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
/*
39_모이기_ver02_code
ArrayLinkedList + Dijkstra : O( P * C * log(P))
custom priority_queue

[해결 전략]
모든 가능한 장소를 모임 장소로 할 때 이동시간의 합을 구하고
그중 최소를 출력하는 것으로 문제를 해결할 수 있다.
*/
#include <cstdio>

enum { LM = 805, ELM = 3000, INF = 1 << 20 };
int N, P, C;
int studPos[LM];  // 위치별 학생수
int ans = INF;
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
void setG(int s, int e, int w) {
	next[++np] = start[s], child[np] = e, cost[np] = w, start[s] = np;
}

void input() {
	scanf("%d %d %d", &N, &P, &C);
	for (int i = 0, s, e, w; i < C; ++i) {
		scanf("%d %d %d", &s, &e, &w);
		setG(s, e, w), setG(e, s, w);
	}
	for (int i = 1; i <= N; ++i) {
		scanf("%d", &studPos[i]);
	}
}

void Dijkstra(int src) {
	// init
	pq.init();
	for (int i = 1; i <= P; ++i) dist[i] = INF;
	dist[src] = 0;
	pq.push({ src, 0 });

	// main process
	while(!pq.empty()) {
		// 1. extract minNode & minDist
		Data t = pq.top(); pq.pop();
		// 2. check minNode
		if (dist[t.node] < t.curDist) continue;
		// 3. relaxation
		for (int j = start[t.node]; j;j = next[j]) {
			int nextNode = child[j];
			int nextDist = t.curDist + cost[j];
			if (dist[nextNode] > nextDist) {     // 더 짧은 거리라면
				dist[nextNode] = nextDist;       // 업데이트하고
				pq.push({ nextNode, nextDist }); // pq에 추가
			}
		}
	}
	int distSum = 0;
	for (int i = 1; i <= N; ++i)  // 학생별 이동거리의 합 구하기
		distSum += dist[studPos[i]];

	if (distSum < ans)            // 더 좋은 거리합이라면 답을 업데이트
		ans = distSum;
}

int main() {
#ifndef ONLINE_JUDGE
	freopen("39.txt", "r", stdin);
#endif // ONLINE_JUDGE
	input();
	for (int i = 1; i <= P; ++i)
		Dijkstra(i);

	printf("%d\n", ans);
	return 0;
}

```
