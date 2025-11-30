```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif

#include <stdio.h>
#define MAX_SIZE (1000000)

static int N, Q, A[MAX_SIZE];

extern void countingSort(int, int*);
extern int query(int);

static void input() {
	scanf("%d", &N);
	for (int i = 0; i < N; ++i) {
		scanf("%d", A + i);
	}
	countingSort(N, A);
}

static void run() {
	int i, idx;
	scanf("%d", &Q);
	for (i = 0; i < Q; ++i) {
		scanf("%d", &idx);
		int userAns = query(idx);
		printf("%d\n", userAns);
	}
}

int main() {
	// freopen("input.txt", "r", stdin);
	input();
	run();
	return 0;
}
```
