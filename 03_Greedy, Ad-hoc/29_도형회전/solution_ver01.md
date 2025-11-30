```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
/*
29_도형회전1_ver01
cw90함수로 90도, 180도, 270도 처리하기
*/
#include <cstdio>

enum { LM = 1005 };
int W, H, cmd;
char A[LM][LM], T[LM][LM];

template<class T>
inline void Swap(T&a, T&b) {
	T tmp = a; a = b; b = tmp;
}

void cw90() {       // 시계방향으로 90도씩 회전하기
	for (int i = 0; i < H; ++i) {
		for (int j = 0; j < W; ++j) {
			T[j][H - i - 1] = A[i][j];  // 임시배열에 회전하여 저장
		}
	}
	Swap(H, W);     // *****
	for (int i = 0; i < H; ++i) {
		for (int j = 0; j < W; ++j) {   // 원래 배열에 복사
			A[i][j] = T[i][j];
		}
		A[i][W] = 0; // ***** : 현재 행의 끝을 알리는 sentinel value
	}
}

void flip() {
	if (cmd == 3) {
		for (int i = 0; i < H/2; ++i) {
			for (int j = 0; j < W; ++j)
				Swap(A[i][j], A[H - i - 1][j]);  // 상하 뒤집기
		}
	}
	else {
		for (int i = 0; i < H; ++i) {
			for (int j = 0; j < W / 2; ++j)
				Swap(A[i][j], A[i][W - j - 1]);  // 좌우 뒤집기
		}
	}
}

void input() {
	scanf("%d %d", &W, &H);
	for (int i = 0; i < H; ++i) scanf("%s", A[i]);
	scanf("%d", &cmd);
}

void output() {
	printf("%d %d\n", W, H);
	for (int i = 0; i < H; ++i) 
		puts(A[i]);  // printf("%s\n", A[i])
}

int main() {
#ifndef ONLINE_JUDGE
	freopen("29.txt", "r", stdin);
#endif // ONLINE_JUDGE
	input();
	if (cmd > 2) flip();
	else {
		for (int i = 0; i <= cmd; ++i) cw90();
	}
	output();

	return 0;
}



```
