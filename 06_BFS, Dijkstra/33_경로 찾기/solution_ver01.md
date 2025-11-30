```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
/*
33_경로찾기_ver01

BFS응용문제

[해결 전략 1]
1. 코드를 문자열로 처리
2. 해밍거리구하기 O(K)
3. 역추적 : 선형 재귀
*/
#include <cstdio>

enum { LM = 1005 };
int N, K, source, dest;
char code[LM][32];
int que[LM], path[LM], fr, re;

void input() {
	scanf("%d %d", &N, &K);
	for (int i = 1; i <= N; ++i) scanf("%s", code[i]);
	scanf("%d %d", &source, &dest);
}

bool isHamming(int u, int v) {
	int diff = 0;
	for (int i = 0; i < K; ++i) {
		diff += (code[u][i] != code[v][i]);
	}
	return diff == 1;  // 해밍거리가 1이라면 = 해밍경로라면
}

void BFS() {
	que[re++] = source;
	path[source] = -1; // 1. 역추적, 2. 방문체크
	while (fr < re) {
		int u = que[fr++];
		for (int v = 1; v <= N; ++v) {
			// v노드가 방문적이 없고 u와 해밍경로라면
			if (path[v] == 0 && isHamming(u, v)) {
				que[re++] = v; // 큐에 추가
				path[v] = u;   // 부모노드 저장 겸 방문체크
			}
		}
	}
}

void trace(int u) {
	if (u < 0) return;
	trace(path[u]);
	printf("%d ", u);
}

int main() {
#ifndef ONLINE_JUDGE
	freopen("33.txt", "r", stdin);
#endif // ONLINE_JUDGE
	input();
	BFS();
	if (path[dest] == 0) puts("-1");
	else trace(dest);

	return 0;
}


```
