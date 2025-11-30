```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
/*
38_Festival_ver01
[해결전략]
: O(N * N) Dijkstra
1. X축제마을로 가기       : 역방향 그래프를 이용하여 구하기 => idea
2. 자신의 마을로 돌아가기 : 순방향 그래프 이용
*/
#include <cstdio>
#define Max(a, b) ((a) > (b)? (a):(b))

enum{LM = 1005, ELM = 10005, INF = 1 << 20};
int N, E, X, ans;
int fwDist[LM], bwDist[LM];
int visited[LM];

struct Data {
	int node, curDist;
	bool operator<(const Data&t)const {
		return curDist < t.curDist;
	}
}fwAdj[LM][LM], bwAdj[LM][LM];  // 인접 배열
int flen[LM], blen[LM];
void setG(int s, int e, int w) {
	fwAdj[s][flen[s]++] = { e, w };
	bwAdj[e][blen[e]++] = { s, w };
}

void input() {
	scanf("%d %d %d", &N, &E, &X);
	for (int i = 0, s, e, w; i < E; ++i) {
		scanf("%d %d %d", &s, &e, &w);
		setG(s, e, w);
	}
}

void Dijkstra(Data adj[][LM], int len[], int dist[]) {
	// init
	for (int i = 1; i <= N; ++i) dist[i] = INF, visited[i] = 0;
	dist[X] = 0;

	// Dijkstra main process
	for (int i = 1; i <= N; ++i) {
		// 1. extract minNode & minDist
		int minNode = -1, minDist = INF;
		for (int j = 1; j <= N; ++j) {
			if (visited[j] == 0 && dist[j] < minDist)
				minNode = j, minDist = dist[j];
		}
		// 2. check minNode
		visited[minNode] = 1;
		// 3. relaxation
		for (int j = 0; j < len[minNode]; ++j) {
			int nextNode = adj[minNode][j].node;
			int nextDist = minDist + adj[minNode][j].curDist;
			if (dist[nextNode] > nextDist)
				dist[nextNode] = nextDist;
		}
	}
}

int main() {
#ifndef ONLINE_JUDGE
	freopen("38.txt", "r", stdin);
#endif // ONLINE_JUDGE
	input();

	Dijkstra(bwAdj, blen, bwDist);  // 축제마을 X로 가기
	Dijkstra(fwAdj, flen, fwDist);  // 자신의 마을로 돌아오기

	for (int i = 1; i <= N; ++i) {
		ans = Max(ans, bwDist[i] + fwDist[i]);
	}
	printf("%d\n", ans);

	return 0;
}
```
