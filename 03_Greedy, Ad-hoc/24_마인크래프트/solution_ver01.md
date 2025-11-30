```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
/*
24_마인크래프트_ver01
input  : O(N*M = 500*500)
getAns : O(N*M*257 = 64250000)
*/
#include <cstdio>

enum{ LM = 250005};
int N, M, B, NM, board[LM];
int ansTime = 1 << 30, ansHeight;

int test(int tgH) {
	int inven = B;
	int cost = 0;
	for (int i = 0; i < NM; ++i) {
		if (board[i] < tgH) {
			int diff = tgH - board[i];
			inven -= diff;
			cost += diff;
		}
		else {
			int diff = board[i] - tgH;
			inven += diff;    // 인벤게 쌓는 것은
			cost += diff * 2; // 1블록당 2의 시간이 필요하다.
		}
	}

	if (inven < 0) return 0; // 땅고르기에 실패했다고 알림

	if (ansTime >= cost)
		ansTime = cost, ansHeight = tgH;

	return 1;  // 땅고르기에 성공했다고 알림
}

int main() {
#ifndef ONLINE_JUDGE
	freopen("24.txt", "r", stdin);
#endif // ONLINE_JUDGE
	scanf("%d %d %d", &N, &M, &B), NM = N * M;
	for (int i = 0; i < NM; ++i) scanf("%d", board + i);

	for (int h = 0; h < 257; ++h) {
		if (test(h) == 0)
			break;
	}

	printf("%d %d\n", ansTime, ansHeight);

	return 0;
}

```
