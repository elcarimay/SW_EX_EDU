```cpp
/*
19_수열복원_user_mergeSort_PASS
*/
extern int orderCheck(int left, int right);

constexpr int LM = 100005;
int idx[LM], trr[LM];

void mergeSort(int arr[], int s, int e) { // [s, e] 폐구간
	if (s >= e) return;
	int m = (s + e) / 2, i = s, j = m + 1, k = s;
	mergeSort(arr, s, m), mergeSort(arr, m + 1, e);
	while (i <= m && j <= e) {
		if (orderCheck(arr[j], arr[i])) trr[k++] = arr[j++];
		else trr[k++] = arr[i++];
	}
	while (i <= m) trr[k ++] = arr[i++];
	while (j <= e) trr[k++] = arr[j++];
	for (i = s; i <= e; ++i) arr[i] = trr[i];
}

void array_restore(int N, int dat[]) {
	// implement here
	for (int i = 1; i <= N; ++i) // 카드번호를 인덱스로
		idx[i] = i - 1;          // 학생번호를 값을 저장
	mergeSort(idx, 1, N);
	// 복원하기
	for (int i = 1; i <= N; ++i) dat[idx[i]] = i;
}
```
