```cpp
/*
48_EX노후화된도로_user_ver01

[해법 연구 01]
1. 그래프 구성하기 : 인접배열 이용
2. 각 도시별 화물목록 구성하기
   !!! 출발지==배송지인 경우는 제외한다. !!!
   무게의 오름차순으로 정렬한다. 무거운화물부터 운송하고 삭제하기에 유리하므로...
   무거운 화물부터 운송하는 이유는 수선이 필요할 때
   가벼운 화물의 수선비용이 무거운 화물보다 저렴하기 때문이다.
3. 배송하기 : move()
   1) 빈트럭이라면 가장 무거운 화물을 가진 도시를 단순 탐색하기 => 개선의 여지가 있다.
   2) 화물운송은 수선비용을 고려하여 최소비용을 소비하는 경로를 찾아 운송한다. : Dijkstra()를 이용
	  *** 우선순위 ***
	  1st : 비용이 가능한 작은
	  2nd : 거쳐가는 도로상태의 여유분의 합 가능한 큰
   3) 모든화물을 운송할때까지 1), 2)를 반복한다.

4. dist[]배열을 Data타입을 수정하여 처리한다. // ##### 수정된 부분

TC: 1,  SEED: 1, SCORE:  11'179'775
PASS

TC: 10, SEED: 1, SCORE: 111'184'946
PASS

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

enum { LM = 10000, FLM = 2000, RLM = 3000, INF = 1 << 20 };
Road roads[RLM];
Freight freights[RLM];
int status[RLM];
int truckPos;

struct Node {
	int city, rid;  // child도시번호, 도로(간선)번호
}adj[LM][100];      // 인접배열
int alen[LM];       // 길이
void setG(int s, int e, int rid) {
	adj[s][alen[s]++] = { e, rid };
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
		if (sCity == eCity)  // 출발지 == 도착지인 경우는 배송할 필요가 없다.
			continue;   // !!!!! !!!!!
		cityCargo[sCity][clen[sCity]++] = { i, eCity, freights[i].weight };
	}

	// 출발지별 화물 목록을 화물무게의 오름차순으로 정렬
	for (int i = 0; i < LM; ++i) {
		insertionSort(cityCargo[i], clen[i]);
	}
}

struct Data {
	int city, cost, statSum;
	bool operator<(const Data&t)const {
		if (cost != t.cost)
			return cost < t.cost;    // 1st prior
		return statSum > t.statSum;  // 2nd prior
	}
}dist[LM];                             // ##### 수정된 부분

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
		dist[i] = { 0, INF, 0 }; // ##### 수정된 부분
		pathCity[i] = pathRoad[i] = 0;
	}
	dist[src] = { src, 0, 0 };  // ##### 수정된 부분
	pathCity[src] = -1;
	pq.push({ src, 0, 0 });

	// Dijkstra main process : 비용계산
	while (!pq.empty()) {
		// 1. extract min
		Data t = pq.top(); pq.pop();

		// 2. check node
		if (t.city == dest)	break; 
		if (dist[t.city] < t) continue; // ##### 수정된 부분

		// 3. relaxation
		for (int i = 0; i < alen[t.city]; ++i) {
			Node nxt = adj[t.city][i];  // { city, roadID }
			int repair = totWei > status[nxt.rid] ? totWei - status[nxt.rid] : 0; // 필요한 수선값 구하기
			int nCost = t.cost + (10 + repair * totWei); // 비용계산하기

			// ##### 수정된 부분 ######################
			Data nd = { nxt.city, nCost, t.statSum + status[nxt.rid] + repair - totWei };
			if (nd < dist[nxt.city]) {
				dist[nxt.city] = nd;        // 최단거리(최소비용) 업데이트
				pathCity[nxt.city] = t.city;   // 도시 경로
				pathRoad[nxt.city] = nxt.rid;  // 사용된 간선번호
				pq.push(nd); 
			}
			// ##### 수정된 부분 ######################
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

int findCity() {
	if (clen[truckPos]) return truckPos;  // 트럭의 현재위치에 화물이 있는 경우

	// init()
	int totWei = 10, weight = 0;
	int src = truckPos, dest = -1;
	pq.init();
	for (int i = 0; i < LM; ++i) {
		dist[i] = { 0, INF, 0 };  // ##### 수정된 부분
		pathCity[i] = pathRoad[i] = 0;
	}
	dist[src] = { src, 0, 0 };    // ##### 수정된 부분
	pathCity[src] = -1;
	pq.push({ src, 0, 0 });

	// Dijkstra main process : 비용계산
	while (!pq.empty()) {
		// 1. extract min
		Data t = pq.top(); pq.pop();
		// 2. check node
		if (dist[t.city] < t) continue; // ##### 수정된 부분
		if (clen[t.city]) {  // 배송할 화물이 존재하고
			if (weight < cityCargo[t.city][clen[t.city] - 1].weight) {
				dest = t.city;
				weight = cityCargo[t.city][clen[t.city] - 1].weight;
			}
		}

		// 3. relaxation
		for (int i = 0; i < alen[t.city]; ++i) {
			Node nxt = adj[t.city][i];  // { city, roadID }
			int repair = totWei > status[nxt.rid] ? totWei - status[nxt.rid] : 0; // 필요한 수선값 구하기
			int nCost = t.cost + (10 + repair * totWei); // 비용계산하기

			// ##### 수정된 부분 ######################
			Data nd = { nxt.city, nCost, t.statSum + status[nxt.rid] + repair - totWei };
			if (nd < dist[nxt.city]) {
				dist[nxt.city] = nd;        // 최단거리(최소비용) 업데이트
				pathCity[nxt.city] = t.city;   // 도시 경로
				pathRoad[nxt.city] = nxt.rid;  // 사용된 간선번호
				pq.push(nd);
			}
			// ##### 수정된 부분 ######################
		}
	}

	// 역추적하여 경로 저장하기
	if (dest > -1) {
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
	return dest;
}

void process() {
	userInit();

	// 배송하기
	while (1) {
		// 1. 트럭의 현재위치에 화물이 있다면 트럭위치가 목적도시
		// 2. 그렇지 않은경우 트럭의 현재 위치로부터 가장 무거운 화물을가진
		//    도시까지 최단경로(최소비용경로)로 이동한다.
		int city = findCity();   // 찾은도시
		if (city < 0) return;    // 모든 배송이 끝난 경우
		truckPos = city;
		// city있는 가장 무거운 화물 아이디를 꺼내고 목록에서 지우기
		Cargo tg = cityCargo[city][--clen[city]];
		load(tg.id);
		Dijkstra(truckPos, tg.dest, tg.weight);
		unload();
		truckPos = tg.dest;   // 아마타 트럭이동
	}
}
```
