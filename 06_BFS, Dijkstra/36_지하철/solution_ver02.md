```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
/*
36_지하철_ver02
Dijkstra : O(N^2)
*/
#include <cstdio>

enum { LM = 105, INF = 1 << 20};
int N, tg;
int Mat[LM][LM]; // 인접 행렬
int dist[LM];    // 1번 노드로부터 나머지 노드까지 최단거리를 저장
int visited[LM]; // 1번 노드로부터 최단거리가 확정되노드에 1로 표시
int path[LM];    // 1번 노드로부터 각노드까지 경로

int Dijkstra(int source, int dest) {
	// init
	for (int i = 1; i <= N; ++i) dist[i] = INF;
	dist[source] = 0;
	path[source] = -1;

	// Dijkstra main process
	for (int i = 1; i <= N; ++i) {
		// 1. extract minNode, minDist
		int minNode = -1, minDist = INF;
		for (int j = 1; j <= N; ++j) {
			if (visited[j] == 0 && dist[j] < minDist)
				minNode = j, minDist = dist[j];
		}

		if (minNode == tg) return minDist;  // 종료조건

		// 2. check minNode
		visited[minNode] = 1;

		// 3. relaxation
		for (int j = 1; j <= N; ++j) {
			if (dist[j] > minDist + Mat[minNode][j]) {
				dist[j] = minDist + Mat[minNode][j];
				path[j] = minNode;
			}
		}
	}
	return INF;  // 현재 문제에서 이 경우는 나오지 않지만 함수의 형식을 맞추기 위한 반환
}

void trace(int u) {
	if (u < 0) return;
	trace(path[u]);
	printf("%d ", u);
}

int main() {
#ifndef ONLINE_JUDGE
	freopen("36.txt", "r", stdin);
#endif // ONLINE_JUDGE
	scanf("%d %d", &N, &tg);
	for (int i = 1; i <= N; ++i) {
		for (int j = 1; j <= N; ++j) scanf("%d", Mat[i] + j);
	}

	printf("%d\n", Dijkstra(1, tg));
	trace(tg);

	return 0;
}

```
