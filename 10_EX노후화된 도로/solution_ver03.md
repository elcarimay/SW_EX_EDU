```cpp
/*
48_EX노후화된도로_user_ver03

[해법 연구 03]
1. 그래프 구성하기 : 인접배열 이용
2. 각 도시별 화물목록 구성하기
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

4. dist[]배열을 Data타입을 수정하여 처리한다.

5. 각 간선의 사용상황을 시뮬레이션한 결과를 먼저 구한다.
   수선이 필요한 간선은 totWeight가 최소일때 최대한 수선한다.             // ##### 수정된 부분
   totWeight가 최소일때이므로 빈차일때도 포함된다.
   수선비용 계산식은 (10 + 수선값*(화물무게+10))임을 이용한다.

TC: 1,  SEED: 1, SCORE:  11'179'775 =>  11'177'414 (빈차일때 최대로 수선하기) =>  11'176'712 (최소가중치일때 수선하기)
PASS

TC: 10, SEED: 1, SCORE: 111'184'946 => 111'149'715 (빈차일때 최대로 수선하기) => 111'143'300 (최소가중치일때 수선하기)
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
int truckPos;
int minWeight[RLM];// ### 추가된 내용 ######
int status[RLM];       // 실제 main의 트럭을 이동시에 사용
int simulStatus[RLM];  // ##### 시뮬레이션시에 사용하는 도로 상태
int minusStatus[RLM];  // ##### 계속 감소만 시키는 도로 상태
struct Commmad {
	int cmd, id, totW; // cmd: (1)load, (0)move, (-1)unload
}cmds[LM * 100];
int cmdLen;

struct Node {
	int city, rid;  // child도시번호, 도로(간선)번호
}adj[LM][100];      // 인접배열
int alen[LM];       // 길이
void setG(int s, int e, int rid) {
	adj[s][alen[s]++] = { e, rid };
}

struct Cargo {
	int id, dest, weight;  // 화물아이디, 목적지, 무게
}cityCargo[LM][100];       // 출발도시별 화물 목록
int clen[LM];              // 화물수

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
	cmdLen = 0;
	for (int i = 0; i < LM; ++i) alen[i] = clen[i] = 0;

	getRoadInfo(roads);
	getFreightInfo(freights);

	// 그래프 구성하기
	for (int i = 0; i < RLM; ++i) {
		
		minWeight[i] = INF; // ### 추가된 내용 ######

		int s = roads[i].city1, e = roads[i].city2;
		int rid = roads[i].id;
		status[rid] = simulStatus[rid] = minusStatus[rid] = roads[i].status;
		setG(s, e, rid), setG(e, s, rid);
	}

	// 출발도시별 화물 목록 구성하기
	for (int i = 0; i < FLM; ++i) {
		int sCity = freights[i].pos, eCity = freights[i].dest;
		if (sCity == eCity)
			continue;   // !!!!! !!!!!
		cityCargo[sCity][clen[sCity]++] = { i, eCity, freights[i].weight };
	}

	for (int i = 0; i < LM; ++i) {
		insertionSort(cityCargo[i], clen[i]);
	}
}

struct Data {
	int city, cost, statSum;
	bool operator<(const Data&t)const {
		if (cost != t.cost)
			return cost < t.cost;
		return statSum > t.statSum;
	}
}dist[LM];

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
int route[LM], rcnt;
void Dijkstra(int src, int dest, int wei) {
	// init()
	int totWei = wei + 10;
	pq.init();
	for (int i = 0; i < LM; ++i) {
		dist[i] = { 0, INF, 0 };
		pathCity[i] = pathRoad[i] = 0;
	}
	dist[src] = { src, 0, 0 };
	pathCity[src] = -1;
	pq.push({ src, 0, 0 });

	// Dijkstra main process : 비용계산
	while (!pq.empty()) {
		// 1. extract min
		Data t = pq.top(); pq.pop();

		// 2. check node
		if (t.city == dest)	break;
		if (dist[t.city] < t) continue;

		// 3. relaxation
		for (int i = 0; i < alen[t.city]; ++i) {
			Node nxt = adj[t.city][i];  // { city, roadID }
			int repair = totWei > simulStatus[nxt.rid] ? totWei - simulStatus[nxt.rid] : 0; // 필요한 수선값 구하기
			int nCost = t.cost + (10 + repair * totWei); // 비용계산하기

			Data nd = { nxt.city, nCost, t.statSum + simulStatus[nxt.rid] + repair - totWei };
			if (nd < dist[nxt.city]) {
				dist[nxt.city] = nd;        // 최단거리(최소비용) 업데이트
				pathCity[nxt.city] = t.city;   // 도시 경로
				pathRoad[nxt.city] = nxt.rid;  // 사용된 간선번호
				pq.push(nd);
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
		int repair = totWei > simulStatus[rid] ? totWei - simulStatus[rid] : 0;
		simulStatus[rid] += repair - totWei; // 도로 상태 업데이트
		minusStatus[rid] -= totWei;
		minWeight[rid] = Min(minWeight[rid], totWei);  // #### 추가된 부분
		cmds[++cmdLen] = { 0, rid, totWei };
	}
}

int findCity() {
	if (clen[truckPos]) return truckPos;  // 트럭의 현재위치에 화물이 있는 경우

	// init()
	int totWei = 10, weight = 0;
	int src = truckPos, dest = -1;
	pq.init();
	for (int i = 0; i < LM; ++i) {
		dist[i] = { 0, INF, 0 };
		pathCity[i] = pathRoad[i] = 0;
	}
	dist[src] = { src, 0, 0 };
	pathCity[src] = -1;
	pq.push({ src, 0, 0 });

	// Dijkstra main process : 비용계산
	while (!pq.empty()) {
		// 1. extract min
		Data t = pq.top(); pq.pop();
		// 2. check node
		if (dist[t.city] < t) continue;
		if (clen[t.city]) {  // 배송할 화물이 존재하고
			if (weight < cityCargo[t.city][clen[t.city] - 1].weight) {
				dest = t.city;
				weight = cityCargo[t.city][clen[t.city] - 1].weight;
			}
		}

		// 3. relaxation
		for (int i = 0; i < alen[t.city]; ++i) {
			Node nxt = adj[t.city][i];  // { city, roadID }
			int repair = totWei > simulStatus[nxt.rid] ? totWei - simulStatus[nxt.rid] : 0; // 필요한 수선값 구하기
			int nCost = t.cost + (10 + repair * totWei); // 비용계산하기
			Data nd = { nxt.city, nCost, t.statSum + simulStatus[nxt.rid] + repair - totWei };
			if (nd < dist[nxt.city]) {
				dist[nxt.city] = nd;        // 최단거리(최소비용) 업데이트
				pathCity[nxt.city] = t.city;   // 도시 경로
				pathRoad[nxt.city] = nxt.rid;  // 사용된 간선번호
				pq.push(nd);
			}
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
			int repair = totWei > simulStatus[rid] ? totWei - simulStatus[rid] : 0;
			simulStatus[rid] += repair - totWei; // 도로 상태 업데이트
			minusStatus[rid] -= totWei;
			minWeight[rid] = Min(minWeight[rid], totWei);  // #### 추가된 부분
			cmds[++cmdLen] = { 0, rid, totWei };
		}
	}
	return dest;
}

void process() {
	userInit();

	// 배송하기
	while (1) {
		int city = findCity();   // 찾은도시
		if (city < 0) break;    // 모든 배송이 끝난 경우
		truckPos = city;
		// city있는 가장 무거운 화물 아이디를 꺼내고 목록에서 지우기
		Cargo tg = cityCargo[city][--clen[city]];
		cmds[++cmdLen] = { 1, tg.id };
		Dijkstra(truckPos, tg.dest, tg.weight);
		cmds[++cmdLen] = { -1 };
		truckPos = tg.dest;   // 아마타 트럭이동
	}

	for (int i = 1; i <= cmdLen; ++i) {
		if (cmds[i].cmd) {
			if (cmds[i].cmd > 0) load(cmds[i].id);
			else unload();
		}
		else {
			int rid = cmds[i].id, totWei = cmds[i].totW, repair = 0;
			if (minusStatus[rid] < 0) {
				if (totWei == minWeight[rid]) {   // 빈차이고 rid간선에 수선이 필요한 경우
					repair = Min(-minusStatus[rid], 1000 - status[rid]);
				}
				else if (status[rid] < totWei) { // 빈차는 아니지만 수선이 필요한 경우
					repair = totWei - status[rid];
				}
				minusStatus[rid] += repair;
				status[rid] += repair;       // 실제 도로상태
			}
			status[rid] -= totWei;
			move(rid, repair);
		}
	}
}
```
