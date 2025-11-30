```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
/*
09_비숍_ver01
1번의 DFS
*/
#include <cstdio>

constexpr int LM = 12;
int N, B[LM][LM], used[LM * 2];
int ans;

// step:오른쪽위로 향하는 대각선 번호, cnt: 직전까지 놓은 비숍수
void bishop(int step, int cnt) {
	// pruning : 탐색공간 축소하여 필요없는 경우를 탐색하지 않기
	// 직전까지 놓은 비숍수 + 앞으로 놓을 최대 비숍수 <= 지금까지 구한 최대 비숍수 라면
	// 탐색할 필요가 없다.
	if (cnt + N * 2 - step <= ans) return;

	// base condition
	if (step >= N * 2) {
		if (ans < cnt) ans = cnt;  // 답 업데이트
		return;
	}
	// normal condition
	int r = step, c = 1, flag = 1;
	if (step > N) r = N, c = step - N + 1; // step>N인 경우 시작행, 열 번호 조정
	for (; r > 0 && c <= N; --r, ++c) {
		// 놓을수 없는 곳이거나, 서로 잡을 수 있는 상황이면 그냥 넘기기
		if (B[r][c] == 0 || used[N - r + c]) continue;  // 오른쪽 아래로 향하는 대각선 번호
		used[N - r + c] = 1;
		//B[r][c] = 2;   // for debug
		bishop(step + 1, cnt + 1);
		flag = 0;   // 다음행을 갔다가 온 적이 있음으로 표시
		//B[r][c] = 1;   // for debug
		used[N - r + c] = 0;
	}
	if (flag == 1) // 다음행을 가보지 못한 경우 강제로 다음행을 보내기
		bishop(step + 1, cnt);
}

int main() {
#ifndef ONLINE_JUDGE
	freopen("09.txt", "r", stdin);
#endif // ONLINE_JUDGE
	scanf("%d", &N);
	for (int i = 1; i <= N; ++i) {
		for (int j = 1; j <= N; ++j) scanf("%d", B[i] + j);
	}

	bishop(1, 0);  // step, cnt

	printf("%d\n", ans);

	return 0;
}
```
