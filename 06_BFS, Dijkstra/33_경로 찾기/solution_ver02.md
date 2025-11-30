```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
/*
33_경로찾기_ver02

BFS응용문제

[해결 전략 2]
1. 코드를 정수로 처리
2. 해밍거리구하기 O(1)
3. 역추적 : 반복문과 배열
*/
#include <cstdio>

enum { LM = 1005 };
int N, K, source, dest;
int code[LM];
int que[LM], path[LM], fr, re;

void input() {
	scanf("%d %d", &N, &K);
	for (int i = 1; i <= N; ++i) {
		for (int j = 0, bit; j < K; ++j) {
			scanf("%1d", &bit);
			code[i] = code[i] * 2 + bit; // Horner's method
		}
	}
	scanf("%d %d", &source, &dest);
}

// bin이 2의 제곱수라면 1인 비트가 1개 뿐이므로 해밍거리가 1이다.
bool isHamming(int bin) {
	return (bin & (bin-1)) == 0;
}

void BFS() {
	que[re++] = source;
	path[source] = -1; // 1. 역추적, 2. 방문체크
	while (fr < re) {
		int u = que[fr++];
		for (int v = 1; v <= N; ++v) {
			// v노드가 방문적이 없고 u와 해밍경로라면
			if (path[v] == 0 && isHamming(code[u] ^ code[v])) {
				que[re++] = v; // 큐에 추가
				path[v] = u;   // 부모노드 저장 겸 방문체크
			}
		}
	}
}

int route[LM], rcnt;
void trace(int u) {  // 반복문과 배열을 이용한 역추적
	while (u > 0) {
		route[++rcnt] = u;
		u = path[u];
	}
	for (int i = rcnt; i > 0; --i)
		printf("%d ", route[i]);
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
