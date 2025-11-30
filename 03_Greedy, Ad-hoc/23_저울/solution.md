```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
/*
23_저울
Greedy
[해결 전략]
: 양팔저울의 한쪽에만 추를 올려놓을 수 있다는 점을 이용한다.
*/
#include <cstdio>

enum{LM = 1005};
int N, A[LM], trr[LM], ans = 1;

void mergeSort(int*arr, int s, int e) { // [s, e] 폐구간
	if (s >= e) return;
	int m = (s + e) / 2, i = s, j = m + 1, k = s;
	mergeSort(arr, s, m), mergeSort(arr, m + 1, e);
	while (i <= m && j <= e) {
		if (arr[j] < arr[i]) trr[k++] = arr[j++];
		else trr[k++] = arr[i++];
	}
	while (i <= m) trr[k++] = arr[i++];
	while (j <= e) trr[k++] = arr[j++];
	for (i = s; i <= e; ++i) arr[i] = trr[i];
}

int main() {
#ifndef ONLINE_JUDGE
	freopen("23.txt", "r", stdin);
#endif // ONLINE_JUDGE
	scanf("%d", &N);
	for (int i = 1; i <= N; ++i) scanf("%d", A + i);
	mergeSort(A, 1, N);

	for (int i = 1; i <= N; ++i) {
		if (A[i] > ans) break;
		ans += A[i];
	}

	printf("%d\n", ans);

	return 0;
}

```
