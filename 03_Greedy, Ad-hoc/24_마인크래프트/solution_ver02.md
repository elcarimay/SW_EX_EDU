```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
/*
24_마인크래프트_ver02
input  : O(N*M = 500*500)
getAns : O(257*257 = 666049)
*/
#include <cstdio>

enum { LM = 260 };
int N, M, B, NM, cnt[LM];
int ansTime = 1 << 30, ansHeight;

int test(int tgH) {  // O(257)
	int inven = B;
	int cost = 0;
	for (int i = 0; i < tgH; ++i) {
		int diff = (tgH - i) * cnt[i];
		inven -= diff;
		cost += diff;
	}

	for (int i = tgH; i < 257; ++i) {
		int diff = (i - tgH) * cnt[i];
		inven += diff;
		cost += diff * 2;
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
	for (int i = 0, h; i < NM; ++i) {
		scanf("%d", &h);
		cnt[h]++;
	}

	for (int h = 0; h < 257; ++h) {
		if (test(h) == 0)
			break;
	}

	printf("%d %d\n", ansTime, ansHeight);

	return 0;
}

```
