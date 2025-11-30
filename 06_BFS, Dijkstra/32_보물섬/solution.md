```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
/*
32_보물섬
BFS concept problem
!!! 인접한 노드사이 거리(비용, 가중치)가 일정한 경우
    BFS를 이용하여 최단거리(비용, 가중치)를 구할 수 있다. !!!
*/
#include <cstdio>

enum{ LM = 55, QLM = LM * LM }; // LiMit
int H, W, Map[LM][LM], ans;
int visited[LM][LM], vcnt;  // 기준을 높여가면서 방문체크
int dr[] = {-1, 0, 1, 0}, dc[] = {0, -1, 0, 1};
struct Data {
	int r, c, lev; // row, column, level
}que[QLM];
int fr, re;        // front, rear

void input() {
	scanf("%d %d", &H, &W);
	char ch;
	for (int i = 1; i <= H; ++i) {
		for (int j = 1; j <= W; ++j) {
			scanf(" %c", &ch); // %c앞에 공백(white char 를 입력후 버림 => enter값 삭제)에 유의
			Map[i][j] = (ch == 'L');
		}
	}
}

void push(int nr, int nc, int nlev) {
	// 경계를 벗어났거나 이미 방문한 경우 제외하고
	if (Map[nr][nc] == 0 || visited[nr][nc] >= vcnt) return;
	visited[nr][nc] = vcnt;
	que[re++] = { nr, nc, nlev };
}

void BFS(int r, int c) {
	// init
	fr = re = 0;            // 큐초기화
	visited[r][c] = ++vcnt; // 기준을 높여 방문체크
	que[re++] = { r, c, 0 };

	// BFS main process
	while (fr < re) {
		Data t = que[fr++];
		for (int i = 0; i < 4; ++i)
			push(t.r + dr[i], t.c + dc[i], t.lev + 1);
	}

	if (ans < que[re - 1].lev)
		ans = que[re - 1].lev;
}

int main() {
#ifndef ONLINE_JUDGE
	freopen("32.txt", "r", stdin);
#endif // ONLINE_JUDGE
	input();
	for (int i = 1; i <= H; ++i) {
		for (int j = 1; j <= W; ++j) {
			if (Map[i][j])  // 모든 땅을 시점으로 BFS진행
				BFS(i, j);
		}
	}

	printf("%d\n", ans);

	return 0;
}


```
