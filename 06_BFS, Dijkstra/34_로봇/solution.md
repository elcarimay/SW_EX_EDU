```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
/*
34_로봇
BFS
1. [row][col][dir](위치 + 방향) 을 확인할 필요가 있다.
2. 이동 방향은 문제에서 제시한 동(1), 서(2), 남(3), 북(4)을 일치시켜야 한다.
*/
#include <cstdio>

enum{ LM = 105, QLM = LM * LM * 4 };
int M, N, Map[LM][LM];  // 행크기, 열크기, 맵
int visited[LM][LM][5]; // 만들어본 상태라면 1로 표시
int dr[] = { 0, 0, 0, 1, -1 }, dc[] = {0, 1, -1, 0, 0}; // 문제의 제시사항과 같은 방향
struct Data {
	int r, c, d, lev;  // 행번호, 열번호, 방향번호, 명령수
	bool operator==(const Data&t)const {
		return r == t.r && c == t.c && d == t.d;
	}
}que[QLM], source, dest;
int fr, re;  // front, rear

void input() {
	scanf("%d %d", &M, &N);
	// 맵 입력, 상태를 반전 (0 <-> 1) : 경계체크를 단순하게 하기 위하여
	for (int i = 1; i <= M; ++i) {
		for (int j = 1; j <= N; ++j) {
			scanf("%d", Map[i] + j);
			// 1 => 0으로, 0 => 1로 반전시키기
			Map[i][j] = !Map[i][j];  // Map[i][j] = 1 - Map[i][j];
		}
	}
	scanf("%d %d %d", &source.r, &source.c, &source.d);  // 출발위치와 방향
	scanf("%d %d %d", &dest.r, &dest.c, &dest.d);        // 도착위치와 방향
}

int push(int nr, int nc, int nd, int nlev) {
	if (Map[nr][nc] == 0) return 1;    // 벽으로 막혀 더이상 진행할 수 없는 경우 => 다음 위치를 검토하는것이 불가능하다.
	if (visited[nr][nc][nd]) return 0; // 만들어본 상태인 경우 => 다음 위치도 검토해봐야 한다.
	// 새로만들어지는 상태
	visited[nr][nc][nd] = 1;
	que[re++] = { nr, nc, nd, nlev };
	return 0;                          // 새로 만든 상태 => 다음 위치도 검토해봐야 한다.
}

int BFS() {
	push(source.r, source.c, source.d, 0);  // 초기상태를 큐에 추가

	while (fr < re) {                // 큐가 비어있지 않은 동안
		Data t = que[fr++];          // 큐에 남아 있는 자료중에 가장 먼저 추가된 자료를 꺼내기
		if (t == dest) return t.lev; // 종료조건
		// 1. Go K(1, 2, 3)
		for (int i = 1; i < 4; ++i) {
			// 막힌 경우라면 더이상 진행할수 없으므로 진행을 종료한다.
			if (push(t.r + dr[t.d] * i, t.c + dc[t.d] * i, t.d, t.lev + 1))
				break;
		}
		// 2. turn dir : 왼쪽, 오른쪽 양쪽 모두 방향전환해 본다.
		int nd = t.d < 3 ? 3 : 1;
		push(t.r, t.c, nd, t.lev + 1);    
		push(t.r, t.c, nd + 1, t.lev + 1);
		//if (t.d < 3) {
		//	push(t.r, t.c, 3, t.lev + 1);
		//	push(t.r, t.c, 4, t.lev + 1);
		//}
		//else {
		//	push(t.r, t.c, 1, t.lev + 1);
		//	push(t.r, t.c, 2, t.lev + 1);
		//}
	}
}

int main() {
#ifndef ONLINE_JUDGE
	freopen("34.txt", "r", stdin);
#endif // ONLINE_JUDGE
	input();
	printf("%d\n", BFS());

	return 0;
}

```
