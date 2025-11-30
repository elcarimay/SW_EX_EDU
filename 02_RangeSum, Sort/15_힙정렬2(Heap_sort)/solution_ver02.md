```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
/*
15_heapSort2_ver02
pq class
*/
#include <cstdio>

enum { LM = 1 << 19 }; // 524288
int N;

void swap(int&a, int&b) {
	int tmp = a; a = b; b = tmp;
}

struct PQ {
	int heap[LM], hn;
	void push(int nd) {
		heap[++hn] = nd;
		for (int c = hn; c > 1; c >>= 1) {
			if (heap[c] > heap[c >> 1])
				swap(heap[c], heap[c >> 1]);
			else break;
		}
	}
	void pop() {
		swap(heap[1], heap[hn--]);
		for (int c = 2; c <= hn; c <<= 1) {
			if (c < hn && heap[c + 1] > heap[c]) ++c;
			if (heap[c] > heap[c >> 1])
				swap(heap[c], heap[c >> 1]);
			else break;
		}
	}
}pq;

void buildHeap() {
	scanf("%d", &N);
	for (int i = 0, val; i < N; ++i) {
		scanf("%d", &val);
		pq.push(val);
	}
}

void sortHeap() {
	for (int i = 1; i < N; ++i) pq.pop();
}

void output() {
	for (int i = 1; i <= N; ++i) printf("%d ", pq.heap[i]);
	puts("");
}

int main() {
#ifndef ONLINE_JUDGE
	freopen("15.txt", "r", stdin);
#endif // ONLINE_JUDGE
	buildHeap();
	output();
	sortHeap();
	output();

	return 0;
}

```
