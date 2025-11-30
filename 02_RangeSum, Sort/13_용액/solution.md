```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
/*
13_용액
tow pointer
*/
#include <cstdio>

#define Abs(a) ((a) < 0? -(a):(a))
constexpr int LM = 100005;

int N, A[LM];
int ans, ansA, ansB;

int main() {
#ifndef ONLINE_JUDGE
	freopen("13.txt", "r", stdin);
#endif // ONLINE_JUDGE

	// input
	scanf("%d", &N);
	for (int i = 1; i <= N; ++i) scanf("%d", A + i);

	ans = (int)21e8;
	int L = 1, R = N;
	while (L < R) {
		int sum = A[L] + A[R];
		if (Abs(sum) < ans) {
			ans = Abs(sum);
			ansA = A[L], ansB = A[R];
		}
		if (sum == 0) break; // 최적해
		if (sum < 0) ++L;
		else --R;
	}

	printf("%d %d\n", ansA, ansB);

	return 0;
}
```
