```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
/*
39_모이기_ver01_code
인접배열 + O(P^2) Dijkstra : 전체 시간복잡도 O( P * P * P )

[해결 전략]
모든 가능한 장소를 모임 장소로 할 때 이동시간의 합을 구하고
그중 최소를 출력하는 것으로 문제를 해결할 수 있다.
*/
#include <cstdio>

enum { LM = 805, INF = 1 << 20};
int N, P, C;
int studCnt[LM];  // 위치별 학생수
struct Data {
	int node, curDist;
}adj[LM][LM];
int alen[LM], ans = INF;
int dist[LM];
bool visited[LM];

void setG(int s, int e, int w) {
	adj[s][alen[s]++] = { e, w };
	adj[e][alen[e]++] = { s, w };
}

void input() {
	scanf("%d %d %d", &N, &P, &C);
	for (int i = 0, s, e, w; i < C; ++i) {
		scanf("%d %d %d", &s, &e, &w);
		setG(s, e, w);
	}
	for (int i = 0, pos; i < N; ++i) {
		scanf("%d", &pos);
		studCnt[pos]++;
	}
}

void Dijkstra(int src) {
	int scnt = N, distSum = 0;
	for (int i = 1; i <= P; ++i) dist[i] = INF, visited[i] = false;
	dist[src] = 0;

	for (int i = 1; i <= P; ++i) {
		int minNode = -1, minDist = INF;
		for (int j = 1; j <= P; ++j) {
			if (!visited[j] && dist[j] < minDist)
				minNode = j, minDist = dist[j];
		}
		if (studCnt[minNode]) {
			distSum += minDist * studCnt[minNode];
			scnt -= studCnt[minNode];
			if (scnt == 0) break;   // 종료조건
		}
		visited[minNode] = true;

		for (int j = 0; j <alen[minNode]; ++j) {
			int nextNode = adj[minNode][j].node;
			int nextDist = minDist + adj[minNode][j].curDist;
			if (dist[nextNode] > nextDist)
				dist[nextNode] = nextDist;
		}
	}

	if (ans > distSum)
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
