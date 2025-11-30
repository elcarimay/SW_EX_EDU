```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
/*
18_quickSort
*/
#include <cstdio>

enum { LM = 1005};
int N, A[LM];

void input() {
	scanf("%d", &N);
	for (int i = 1; i <= N; ++i) scanf("%d", A + i);
}
void output() {
	for (int i = 1; i <= N; ++i) printf("%d ", A[i]);
	puts("");
}

void Swap(int&a, int&b) {
	int tmp = a; a = b; b = tmp;
}
void quickSort(int arr[], int low, int high) { // [s, e] 폐구간
	if (low >= high) return;

	int&pivot = arr[low];
	int i = low + 1, j = high;
	while (i <= j) {
		while (i <= j && arr[i] <= pivot) ++i;
		while (i <= j && pivot <= arr[j]) --j;
		if (i < j) Swap(arr[i], arr[j]);
	}
	Swap(pivot, arr[j]);  // Swap(arr[low], arr[j]);
	output();
	quickSort(arr, low, j - 1);
	quickSort(arr, j + 1, high);
}

int main() {
#ifndef ONLINE_JUDGE
	freopen("18.txt", "r", stdin);
#endif // ONLINE_JUDGE
	input();
	quickSort(A, 1, N);
	return 0;
}

```
