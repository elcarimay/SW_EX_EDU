```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
/*
35_gridGame
BFS + custom_ArrayLinkedList + pruning

[해결전략]
1. 그래프문제로 전환한다.
2. 모든 노드를 시작으로 하는 BFS로 답을 구한다.
3. 가능성이 없는 노드는 BFS()를 실행하지 않는 전략을 추가한다.
*/
#include <cstdio>

enum { MLM = 105, LM = MLM * MLM, ELM = LM * 10 };
int M, N, Map[MLM][MLM]; // 행크기, 열크기, 지도정보=>renumbering
int idcnt, color, checked[LM], ans = LM;
int invalid[LM];
int dr[] = { -1, 1, 0, 0 }, dc[] = { 0, 0, -1, 1 };
//int dr[] = { -1, 0, 1, 0 }, dc[] = { 0, -1, 0, 1 };
int visited[LM], vcnt;   // 기준을 높여가면서 방문 체크
struct Data {
	int u, lev;
}que[LM];
int fr, re;

int np, next[ELM], child[ELM], start[LM];
void setG(int s, int e) {
	next[++np] = start[s], child[np] = e, start[s] = np;
}

void input() {
	scanf("%d %d", &M, &N);
	for (int i = 1; i <= M; ++i) {
		for (int j = 1; j <= N; ++j) {
			scanf("%d", Map[i] + j);  // &Map[i][j]
			Map[i][j] -= 2;  // 1 => -1, 0 => -2로 바꾸어 저장
		}
	}
}

void dfs(int r, int c) {
	int&tid = Map[r][c];  // 값을 변경하기위한 참조타입
	// 노드번호가 부여되었는데 idcnt와 그래프 구성이 안되어 있는 경우 
	if (tid > 0 && checked[tid] < idcnt) {  // 그래프 구성하기
		setG(tid, idcnt), setG(idcnt, tid); // 양방향 그래프 구성
		checked[tid] = idcnt;  // 다음에는 (tid, idcnt)간에 그래프 구성을 하지 않도록
		return;
	}
	if (tid != color) return; // 경계를 벗어낫거나 다른색이거나 이미 방문했거나
	tid = idcnt;  // 현재 영역은 idcnt노드임을 표시
	for (int i = 0; i < 4; ++i)
		dfs(r + dr[i], c + dc[i]);
}

void buildGraph() {
	for (int i = 1; i <= M; ++i) {
		for (int j = 1; j <= N; ++j) {
			if (Map[i][j] < 0) {
				color = Map[i][j];
				++idcnt, checked[idcnt] = idcnt;
				dfs(i, j);
			}
		}
	}
}

// for debug /////////////////
void output() {
	for (int i = 1; i <= M; ++i) {
		for (int j = 1; j <= N; ++j) printf("%d ", Map[i][j]);
		puts("");
	}
	for (int i = 1; i <= idcnt; ++i) {
		printf("%d : ", i);
		for (int j = start[i]; j; j = next[j]) {
			printf("%d ", child[j]);
		}
		puts("");
	}
}

void BFS(int source) {
	fr = re = 0;              // 큐를 초기화
	visited[source] = ++vcnt; // 방문배열 초기화
	que[re++] = { source, 0 };

	while (fr < re) {
		Data t = que[fr++];
		for (int j = start[t.u]; j; j = next[j]) {
			int v = child[j], nlev = t.lev + 1;
			if (visited[v] == vcnt) continue;
			visited[v] = vcnt;
			que[re++] = { v, nlev };
		}
	}

	int level = que[re - 1].lev;
	if (ans > level) ans = level;
	// 추가된 코드 : pruning ////////////////////////////
	// 현재까지 구해진 최적해가 ans라면 que[i].lev<= level - ans 인 경우는
	// BFS의 시작노드로 사용할 필요가 없다.
	for (int i = 0; i < re; ++i) {  // 
		if (que[i].lev <= level - ans) 
			invalid[que[i].u] = 1;  // ***** 
		else break;
	}

	// 현재까지 구해진 최적해가 ans라면 que[i].lev>= ans 인 경우는
	// BFS의 시작노드로 사용할 필요가 없다.
	for (int i = re - 1; i >= 0; --i) {
		if (que[i].lev >= ans) 
			invalid[que[i].u] = 1;
		else break;
	}
	/////////////////////////////////////////////////////
}

int main() {
#ifndef ONLINE_JUDGE
	freopen("35.txt", "r", stdin);
#endif // ONLINE_JUDGE
	input();
	buildGraph();
	//output();  // for debug
	for (int i = 1; i <= idcnt; ++i) {
		if (invalid[i]) continue;
		BFS(i);
	}
	printf("%d\n", ans);
	return 0;
}


```
