```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
/*
20_외양간
Greedy

[해결전략]
1. 소들의 위치를 입력후 정렬한다.
   판자가 하나일 때 최소 판자 길이 ans를 구한다.
2. 연속한 빈 공간을 구하여 내림차순 정렬한다.
3. M = min(연속한 빈공간수, M-1) 개의 연속한 빈공간을
   크기가 큰 것부터 ans에서 빼준다.
*/
#include <cstdio>

constexpr int LM = 205;
int M, S, C, cows[LM];
int emptys[LM], ecnt;
int ans;

void insertionSort(int arr[], int len) {
	int i, j;
	for (i = 1; i < len; ++i) {
		int tg = arr[i];
		for (j = i - 1; j >= 0; --j) {
			if (arr[j] > tg) arr[j + 1] = arr[j]; // 위치 이동
			else break;  // tg이 삽입될 위치를 찾은 경우
		}
		arr[j + 1] = tg; // tg을 삽입하기
	}
}

int main() {
#ifndef ONLINE_JUDGE
	freopen("20.txt", "r", stdin);
#endif // ONLINE_JUDGE
	scanf("%d %d %d", &M, &S, &C);
	for (int i = 0; i < C; ++i) scanf("%d", cows + i);
	insertionSort(cows, C);

	// 판자가 1개일때 답
	ans = cows[C - 1] - cows[0] + 1;
	
	// 빈 공간 구하기
	for (int i = 1; i < C; ++i) {
		int diff = cows[i] - cows[i - 1] - 1;
		if (diff) emptys[ecnt++] = diff;
	}
	insertionSort(emptys, ecnt);

	for (int i = ecnt - 1; i >= 0 && M > 1; --i) {
		ans -= emptys[i];
		M--;
	}
	printf("%d\n", ans);

	return 0;
}

```
