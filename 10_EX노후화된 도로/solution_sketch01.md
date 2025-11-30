```cpp
/*
48_EX노후화된도로_user_sketchCode01

1. 그래프 구성하기 : 인접배열 이용
2. 각 도시별 화물목록 구성하기
   무게의 오름차순으로 정렬한다. 무거운화물부터 운송하고 삭제하기에 유리하므로...
   무거운 화물부터 운송하는 이유는 수선이 필요할 때
   가벼운 화물의 수선비용이 무거운 화물보다 저렴하기 때문이다.
3. 배송하기 : move()
   1) 빈트럭이라면 가장 무거운 화물을 가진 도시를 단순 탐색하기 => 개선의 여지가 있다.
   2) 화물운송은 수선비용을 고려하여 최소비용을 소비하는 경로를 찾아 운송한다.
      : Dijkstra()를 이용하여
      : 우선순위는 비용만 생각한다.                             => 개선의 여지가 있다.
   3) 모든화물을 운송할때까지 1), 2)를 반복한다.

SCORE: 11'244'897
FAIL

[고찰]
1. 1st 우선순위는 기존대로 하고
   2nd 우선순위를 거쳐가는 도로 상태의 합으로 할 수 있다.
2. 빈트럭이 새로운 도시를 찾을 때 
   move()와 같은 우선순위로 찾을 수 있다.
*/
struct Road
{
	int city1;
	int city2;
	int status;
	int id;
};

struct Freight
{
	int pos;
	int dest;
	int weight;
};

extern bool move(int mRoadID, int repairNum);
extern bool load(int mFreightID);
extern bool unload();
extern void getRoadInfo(Road mRet[]);
extern void getFreightInfo(Freight mRet[]);

///////////////////////////////////////////////////////////////////
#define Max(a, b) ((a) > (b)? (a):(b))
#define Min(a, b) ((a) < (b)? (a):(b))

enum{LM = 10000, FLM = 2000, RLM = 3000, INF = 1 << 20};
Road roads[RLM];
Freight freights[RLM];
int status[RLM];
int truckPos;

struct Node {
	int city, rid;  // child도시번호, 도로(간선)번호
}adj[LM][100];      // 인접배열
int alen[LM];       // 길이
void setG(int s, int e, int rid) {
	adj[s][alen[s]++] = {e, rid};
}

struct Cargo {
	int id, dest, weight;  // 화물아이디, 목적지, 무게
}cityCargo[LM][100];// 출발도시별 화물 목록
int clen[LM];       // 화물수

void insertionSort(Cargo*arr, int len) { // 무게의 오름차순 정렬
	int i, j;
	for (i = 1; i < len; ++i) {
		auto tg = arr[i]; // Cargo tg = arr[i];
		for (j = i - 1; j >= 0; --j) {
			if (tg.weight < arr[j].weight) arr[j + 1] = arr[j];
			else break;
		}
		arr[j + 1] = tg;
	}
}

static void userInit() {
	truckPos = 0;
	for (int i = 0; i < LM; ++i) alen[i] = clen[i] = 0;

	getRoadInfo(roads);
	getFreightInfo(freights);

	// 그래프 구성하기
	for (int i = 0; i < RLM; ++i) {
		int s = roads[i].city1, e = roads[i].city2;
		int rid = roads[i].id;
		status[rid] = roads[i].status;
		setG(s, e, rid), setG(e, s, rid);
	}

	// 출발도시별 화물 목록 구성하기
	for (int i = 0; i < FLM; ++i) {
		int sCity = freights[i].pos, eCity = freights[i].dest;
		cityCargo[sCity][clen[sCity]++] = { i, eCity, freights[i].weight };
	}

	for (int i = 0; i < LM; ++i) {
		insertionSort(cityCargo[i], clen[i]);
	}
}

struct Data {
	int city, cost;
	bool operator<(const Data&t)const {   // *** 개선이 필요
		return cost < t.cost;
	}
};
int dist[LM];                             // *** 개선이 필요

void Swap(Data&a, Data&b) {
	Data t = a; a = b; b = t;
}

struct PQ {
	Data heap[RLM];
	int hn;
	void init() { hn = 0; }
	bool empty() { return hn == 0; }
	int size() { return hn; }
	Data top() { return heap[1]; }
	void push(const Data nd) {
		heap[++hn] = nd;
		for (int c = hn; c > 1; c >>= 1) {
			if (heap[c] < heap[c >> 1]) Swap(heap[c], heap[c >> 1]);
			else break;
		}
	}
	void pop() {
		Swap(heap[1], heap[hn--]);
		for (int c = 2; c <= hn; c <<= 1) {
			if (c < hn && heap[c + 1] < heap[c]) ++c;
			if (heap[c] < heap[c >> 1]) Swap(heap[c], heap[c >> 1]);
			else break;
		}
	}
}pq;


int pathCity[LM], pathRoad[LM];

// implement here
int route[LM], rcnt;
void Dijkstra(int src, int dest, int wei) {
	// init()
	int totWei = wei + 10;
	pq.init();
	for (int i = 0; i < LM; ++i) {
		dist[i] = INF;
		pathCity[i] = pathRoad[i] = 0;
	}
	dist[src] = 0;
	pathCity[src] = -1;
	pq.push({ src, 0 });   // *****

	// Dijkstra main process : 비용계산
	while (!pq.empty()) {
		// 1. extract min
		Data t = pq.top(); pq.pop();

		// 2. check node
		if (t.city == dest)	break;
		if (dist[t.city] < t.cost) continue;

		// 3. relaxation
		for (int i = 0; i < alen[t.city]; ++i) {
			Node nxt = adj[t.city][i];  // { city, roadID }
			int repair = totWei > status[nxt.rid] ? totWei - status[nxt.rid] : 0; // 필요한 수선값 구하기
			int nCost = t.cost + (10 + repair * totWei); // 비용계산하기
			if (dist[nxt.city] > nCost) {
				dist[nxt.city] = nCost;        // 최단거리(최소비용) 업데이트
				pathCity[nxt.city] = t.city;   // 도시 경로
				pathRoad[nxt.city] = nxt.rid;  // 사용된 간선번호
				pq.push({ nxt.city, nCost });
			}
		}
	}

	// 역추적하여 경로 저장하기
	int city = dest;
	rcnt = 0;
	for (; pathCity[city] >= 0; city = pathCity[city]) {
		route[++rcnt] = pathRoad[city];  // 사용된 간선번호 저장
	}

	// 도로 상태 업데이트 + main의 트럭이 경로를 따라 이동
	for (int i = rcnt; i > 0; --i) {    // 순방향으로 진행하면서
		int rid = route[i];             // 사용된 도로 아이디
		int repair = totWei > status[rid] ? totWei - status[rid] : 0;
		status[rid] += repair - totWei; // 도로 상태 업데이트
		move(rid, repair);              // main의 트럭이 경로를 따라 이동
	}
}

int findCity() { // *** 개선이 필요함.
	if (clen[truckPos]) return truckPos;  // 트럭의 현재위치에 화물이 있는 경우
	int city = -1, weight = 0;  // 가장 무거운 화물이 있는 도시 찾기
	for (int i = 0; i < LM; ++i) {
		if (clen[i] == 0) continue;
		if (weight < cityCargo[i][clen[i] - 1].weight)
			city = i, weight = cityCargo[i][clen[i] - 1].weight;
	}
	return city;
}

void process() {
	userInit();

	// 배송하기
	while (1) {
		int city = findCity();   // 찾은도시
		if (city < 0) return;    // 모든 배송이 끝난 경우
		if (city != truckPos) {
			Dijkstra(truckPos, city, 0);  // 빈트럭을 이동시키기
			truckPos = city;
		}

		// city있는 가장 무거운 화물 아이디를 꺼내고 목록에서 지우기
		Cargo tg = cityCargo[city][--clen[city]];
		load(tg.id);
		Dijkstra(truckPos, tg.dest, tg.weight);
		unload();
		truckPos = tg.dest;   // 아마타 트럭이동
	}
}
```
