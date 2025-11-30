```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
/*
27_점모으기_ver02
countingSort응용 + median
*/
#include <cstdio>
#define Abs(a) ((a) < 0? -(a):(a))
enum { LM = 10001 };
int N, M;
int rowCnt[LM], colCnt[LM];
int ans;

int getMedian(int*cnt) {
	int hf = (M + 1) / 2;
	for (int i = 1; i < LM; ++i) {
		hf -= cnt[i];
		if (hf <= 0) return i;
	}
	return LM; // 이 경우는 나올수 없지만 함수 형식상 반환값이 있어야 한다.
}

int main() {
#ifndef ONLINE_JUDGE
	freopen("27.txt", "r", stdin);
#endif // ONLINE_JUDGE
	scanf("%d %d", &N, &M);
	for (int i = 1, r, c; i <= M; ++i) {
		scanf("%d %d", &r, &c);
		rowCnt[r] ++, colCnt[c]++;
	}

	int mr = getMedian(rowCnt), mc = getMedian(colCnt);

	for (int i = 1; i < LM; ++i) {
		ans += Abs(mr - i) * rowCnt[i];
		ans += Abs(mc - i) * colCnt[i];
	}

	printf("%d\n", ans);

	return 0;
}

```
