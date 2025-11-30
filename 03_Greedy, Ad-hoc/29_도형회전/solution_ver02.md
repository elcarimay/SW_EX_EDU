```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
/*
29_도형회전1_ver02
각각의 경우를 나누어 구현
*/
#include <cstdio>

enum { LM = 1005 };
int W, H, cmd;
char A[LM][LM], T[LM][LM];

void input() {
	scanf("%d %d", &W, &H);
	for (int i = 0; i < H; ++i) scanf("%s", A[i]);
	scanf("%d", &cmd);
}

void process() {
	for (int i = 0; i < H; ++i) {
		for (int j = 0; j < W; ++j) {
			if (cmd == 0)      T[j][H - i - 1] = A[i][j];         // cw  90도 회전
			else if (cmd == 1) T[H - i - 1][W - j - 1] = A[i][j]; // cw 180도 회전
			else if (cmd == 2) T[W - j - 1][i] = A[i][j];         // cw 270도 회전
			else if (cmd == 3) T[H - i - 1][j] = A[i][j];         // 상하 뒤집기
			else               T[i][W - j - 1] = A[i][j];         // 좌우 뒤집기
		}
	}
	if (cmd == 0 || cmd == 2) {  // 90도, 270도의 경우 높이와 너비가 바뀐다.
		int tmp = H; H = W; W = tmp; // *****
	}
	for (int i = 0; i < H; ++i) 
		T[i][W] = 0;  // 각 행의 끝을 알리는 sentinel value로 마감 처리
}

void output() {
	printf("%d %d\n", W, H);
	for (int i = 0; i < H; ++i) puts(T[i]);
}

int main() {
#ifndef ONLINE_JUDGE
	freopen("29.txt", "r", stdin);
#endif // ONLINE_JUDGE
	input();
	process();
	output();

	return 0;
}


```
