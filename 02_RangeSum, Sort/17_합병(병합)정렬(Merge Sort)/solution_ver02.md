```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
/*
17_mergeSort_ver02
[s, e) 반폐구간
*/
#include <cstdio>

enum { LM = 1005 };
int N, A[LM], trr[LM];

void output() {
	for (int i = 0; i < N; ++i) printf("%d ", A[i]);
	puts("");
}

void mergeSort(int *arr, int s, int e) {  // [s, e) 반폐구간
	// 1. base condition
	if (s + 1 >= e) return;
	// 2. divide & conquer
	int m = (s + e + 1) / 2; // 문제의 출력 결과를 만족시키기 위한 코드
	mergeSort(arr, s, m);
	mergeSort(arr, m, e);
	// 3. merge
	int i = s, j = m, k = s;
	while (i < m && j < e) {
		if (arr[j] < arr[i]) trr[k++] = arr[j++];
		else trr[k++] = arr[i++];
	}
	while (i < m) trr[k++] = arr[i++];
	while (j < e) trr[k++] = arr[j++];
	// 4. copy
	for (i = s; i < e; ++i) arr[i] = trr[i];
	// 출력 하기
	output();
}

int main() {
#ifndef ONLINE_JUDGE
	freopen("17.txt", "r", stdin);
#endif // ONLINE_JUDGE
	scanf("%d", &N);
	for (int i = 0; i < N; ++i) scanf("%d", A + i);
	mergeSort(A, 0, N);

	return 0;
}

```
