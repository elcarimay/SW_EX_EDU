```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
/*
24_마인크래프트_ver03_optional
input  : O(N*M = 500*500)
getAns : O(257)
*/
#include <cstdio>

enum { LM = 257 };
int N, M, B, NM;
int cnt[LM], sum[LM];

int main() {
#ifndef ONLINE_JUDGE
	freopen("24.txt", "r", stdin);
#endif // ONLINE_JUDGE
	scanf("%d %d %d", &N, &M, &B), NM = N * M;
	for (int i = 0, h; i < NM; ++i) {
		scanf("%d", &h);
		cnt[h]++;
		sum[h] += h;
	}

	for (int i = 1; i < LM; ++i) { // 개수와 합의 누적합
		cnt[i] += cnt[i - 1];
		sum[i] += sum[i - 1];
	}

	int ansTime = sum[256] * 2, ansHeight = 0;    // 보드판 높이를 0으로 할때
	for (int tgH = 1; tgH < 257; ++tgH) {         // O(257)
		int smallCnt = cnt[tgH] * tgH - sum[tgH]; // 인벤으로부터 가져올 블록의 양
		int bigCnt = (sum[256] - sum[tgH]) - (cnt[256] - cnt[tgH]) * tgH; // 인벤으로 가져갈 블록의 양
		int inven = B - smallCnt + bigCnt;
		if (inven < 0) break;
		int cost = smallCnt + bigCnt * 2;
		if (ansTime >= cost)
			ansTime = cost, ansHeight = tgH;
	}

	printf("%d %d\n", ansTime, ansHeight);

	return 0;
}

```
