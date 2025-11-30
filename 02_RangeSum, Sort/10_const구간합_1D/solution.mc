```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
/*
10_const구간합1D
prefixSum
*/
#include <cstdio>

enum { LM = 1 << 20 }; // 1048576
using LL = long long;
int N, Q, A[LM];
LL ps[LM];

int main() {
#ifndef ONLINE_JUDGE
	freopen("10.txt", "r", stdin);
#endif // ONLINE_JUDGE
	scanf("%d", &N);
	for (int i = 1; i <= N; ++i) {
		scanf("%d", A + i);
		ps[i] = ps[i - 1] + A[i]; // get prefixSum
	}

	scanf("%d", &Q);
	int s, e;
	while (Q--) {
		scanf("%d %d", &s, &e);
		printf("%lld\n", ps[e] - ps[s - 1]);
	}

	return 0;
}

```
