```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
/*
16_countingSort_ver02
stable counting sort
*/
enum { LM = 1 << 20, BIAS = 1 << 15, CLM = 1 << 16 };
int N, sortedA[LM], cnt[CLM];

void countingSort(int arraySize, int *arr) {
	// preprocess
	N = arraySize;
	for (int i = 0; i < N; ++i) arr[i] += BIAS;          // 0 ~ 65535범위로 수정

	// counting sort
	for (int i = 0; i < CLM; ++i) cnt[i] = 0;            // init
	for (int i = 0; i < N; ++i) cnt[arr[i]]++;           // counting
	for (int i = 1; i < CLM; ++i) cnt[i] += cnt[i - 1];  // prefixSum : accumulate
	for (int i = N - 1; i >= 0; --i) {
		sortedA[--cnt[arr[i]]] = arr[i] - BIAS;
	}
}

int query(int idx) {
	return sortedA[idx];
}
```
