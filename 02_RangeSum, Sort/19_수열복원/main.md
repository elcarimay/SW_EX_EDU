```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif

#include <stdio.h>
#define MAXSIZE 100000

static int org[MAXSIZE], dat[MAXSIZE];
static int N, QueryCount;

extern void array_restore(int N, int dat[]);

// ISO9899
static unsigned long int next = 1;
int rand(void) // RAND_MAX assumed to be 65535
{
	next = next * 1103515245 + 12345;
	return (unsigned int)(next >> 16) & 65535;
}

int orderCheck(int left, int right)
{
	QueryCount++;
	if (left < 0 || left >= N) return 1;
	if (right < 0 || right >= N) return 1;
	if (org[left] < org[right]) return 1;
	else return 0;
}

inline void Swap(int&a, int&b) {
	int t = a; a = b; b = t;
}

static void init(int t)
{
	int i, j;
	QueryCount = 0;
	N = (t * 2000 - 1000) + rand() % 1000;
	for (i = 0; i < N; i++) {
		org[i] = i + 1;
		dat[i] = 0;
	}
	for (i = 0; i < N; i++) {
		j = (int)((long long)rand() * rand() % N);
		Swap(org[i], org[j]);
	}
}

static int arr_comp()
{
	if (QueryCount >= N * 20) return MAXSIZE * 100;
	for (int i = 0; i < N; i++) {
		if (org[i] != dat[i]) return MAXSIZE * 100;
	}
	return QueryCount;
}

int main(void)
{
	for (int tc = 1; tc <= 50; tc++)
	{
		init(tc);
		array_restore(N, dat);
		printf("#%d %d %d\n", tc, N, arr_comp());
	}

	return 0;
}
```
