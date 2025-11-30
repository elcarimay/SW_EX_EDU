```cpp
/*
19_수열복원_user_quickSort_FAIL
*/
extern int orderCheck(int left, int right);

constexpr int LM = 100005;
int idx[LM];

static void Swap(int&a, int&b) {
	int tmp = a; a = b; b = tmp;
}
void quickSort(int arr[], int low, int high) {
	if (low >= high) return;
	int&pivot = arr[low];
	int i = low + 1, j = high;
	while (i <= j) {
		while (i <= j && !orderCheck(pivot, arr[i])) ++i;
		while (i <= j && !orderCheck(arr[j], pivot)) --j;
		if (i < j) Swap(arr[i], arr[j]);
	}
	Swap(pivot, arr[j]);
	quickSort(arr, low, j - 1);
	quickSort(arr, j + 1, high);
}

void array_restore(int N, int dat[]) {
	// implement here
	for (int i = 1; i <= N; ++i) // 카드번호를 인덱스로
		idx[i] = i - 1;          // 학생번호를 값을 저장
	quickSort(idx, 1, N);
	// 복원하기
	for (int i = 1; i <= N; ++i) dat[idx[i]] = i;
}
```
