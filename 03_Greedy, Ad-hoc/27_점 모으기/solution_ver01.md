```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
/*
27_점모으기_ver01
mergeSort + median
*/
#include <cstdio>
#define Abs(a) ((a) < 0? -(a):(a))
enum{LM = 100005};
int N, M;
int rows[LM], cols[LM], trr[LM];
int ans;

void mergeSort(int *arr, int s, int e) { // [s, e] 폐구간
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
	freopen("27.txt", "r", stdin);
#endif // ONLINE_JUDGE
	scanf("%d %d", &N, &M);
	for (int i = 1; i <= M; ++i) {
		scanf("%d %d", rows + i, cols + i);
	}
	mergeSort(rows, 1, M);
	mergeSort(cols, 1, M);

	int mr = rows[(M + 1) / 2], mc = cols[(M + 1) / 2];

	for (int i = 1; i <= M; ++i) {
		ans += Abs(mr - rows[i]) + Abs(mc - cols[i]);
	}

	printf("%d\n", ans);

	return 0;
}

```
