```cpp
/*
45_TS경유지운송(py)_user
*/
enum{ LM = 1005, ELM = 3405 };  // 도시수 최대, 도로수 최대
int N;
struct Edge {
	int s, e, w; // s, e:두 도시, w: 도로의 제한 중량
	bool operator<(const Edge&t)const {
		return w > t.w;  // desc정렬을 위하여
	}
}edges[ELM], trr[ELM];
int ecnt;
int G[LM];

int Find(int r) {
	if (G[r] == r) return r;
	return G[r] = Find(G[r]);
}

int Union(int s, int e) {
	s = Find(s), e = Find(e);
	if (s == e) return 0;
	G[e] = s;
	return 1;
}

void mergeSort(Edge*arr, int s, int e) { // [s, e) : 반개구간
	if (s + 1 >= e) return;
	int m = (s + e) / 2, i = s, j = m, k = s;
	mergeSort(arr, s, m), mergeSort(arr, m, e);
	while (i < m && j < e) {
		if (arr[j] < arr[i]) trr[k++] = arr[j++];
		else trr[k++] = arr[i++];
	}
	while (i < m) trr[k++] = arr[i++];
	while (j < e) trr[k++] = arr[j++];
	for (i = s; i < e; ++i) arr[i] = trr[i];
}

void init(int mN, int K, int sCity[], int eCity[], int mLimit[]) {  // 1회 호출
	::N = mN, ecnt = 0;
	for (int i = 0; i < K; ++i) // 최대 2000개
		edges[ecnt++] = {sCity[i], eCity[i], mLimit[i]}; // 양방향 간선
}

void add(int sCity, int eCity, int mLimit) {   // 최대 1400회 호출
	edges[ecnt++] = { sCity, eCity, mLimit };  // 양방향 간선
}

int calculate(int sCity, int eCity, int M, int mStopover[]) {  // 최대 100회 호출
	for (int i = 0; i < N; ++i) G[i] = i; // 각 도시별 그룹번호 초기화
	mergeSort(edges, 0, ecnt);            // 도로 제한중량의 내림 차순 정렬
	for (int i = 0; i < ecnt; ++i) {
		int s = edges[i].s, e = edges[i].e, w = edges[i].w; // i번 도로 정보
		if(Union(s, e) == 0) continue;
		int ns = Find(sCity), ne = Find(eCity); // 출발지 그룹번호와 도착지 그룹번호 구하기
		if (ns != ne) continue;                 // 출발지에서 도착지에 도착하지 못한경우
		int j = 0;
		for (; j < M && ns == Find(mStopover[j]); ++j); // 모든 경유지가 방문되었는가?
		if (j == M) return w;  // 출발지, 경유지, 도착지가 모두 같은 그룹이라면(모두 방문하였다면)
	}

	return -1;
}
```
