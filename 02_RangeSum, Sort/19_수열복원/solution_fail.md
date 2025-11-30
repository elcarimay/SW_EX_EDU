```cpp
/*
19_수열복원_user_heapSort_FAIL
*/
extern int orderCheck(int left, int right);

constexpr int LM = 100005;
int idx[LM];

static void Swap(int&a, int&b) {
	int tmp = a; a = b; b = tmp;
}
void heapSort(int heap[], int s, int N) {
	// buildHeap
	for (int hn = 2; hn <= N; ++hn) {
		for (int c = hn; c > 1; c >>= 1) {
			if (orderCheck(heap[c >> 1], heap[c]))
				Swap(heap[c >> 1], heap[c]);
			else break;
		}
	}
	// sort heap
	for (int hn = N; hn > 1;) {
		Swap(heap[1], heap[hn--]);
		for (int c = 2; c <= hn; c <<= 1) {
			if (c < hn && orderCheck(heap[c], heap[c + 1])) ++c;
			if (orderCheck(heap[c >> 1], heap[c]))
				Swap(heap[c >> 1], heap[c]);
			else break;
		}
	}
}

void array_restore(int N, int dat[]) {
	// implement here
	for (int i = 1; i <= N; ++i) // 카드번호를 인덱스로
		idx[i] = i - 1;          // 학생번호를 값을 저장
	heapSort(idx, 1, N);
	// 복원하기
	for (int i = 1; i <= N; ++i) dat[idx[i]] = i;
}
```
