```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
/*
22_냉장고
*/
#include <cstdio>

enum { LM = 1005 };  // LiMit 의 약자
struct Data {
	int s, e;
	bool operator<(const Data&t)const {
		return s < t.s;
	}
}A[LM], trr[LM]; // trr: temporary array
int N, ans;

void mergeSort(Data*arr, int s, int e) { // [s, e] 폐구간
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
	freopen("22.txt", "r", stdin);
#endif // ONLINE_JUDGE
	scanf("%d", &N);
	for (int i = 1; i <= N; ++i) scanf("%d %d", &A[i].s, &A[i].e);
	mergeSort(A, 1, N);

	int et = - LM;
	for (int i = 1; i <= N; ++i) {
		if (A[i].s > et)                // 새로운 냉장고가 필요한 경우
			ans++, et = A[i].e;
		if (et > A[i].e) et = A[i].e;   // et는 더 작아지는 쪽으로 업데이트 한다.
	}

	printf("%d\n", ans);

	return 0;
}

```
