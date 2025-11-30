```cpp
/*
48_EX노후화된도로_user_ver04_optional

[해법연구 4]
1. 해법연구 3과 같이 하는데 단, 출발지와 목적지를 바꾸어 전 처리한다.
2. 결과의 역순으로 진행하면서 수선이 필요한 간선은
   각 간선별 최소 가중치일때 수선한다.


SEED : 1, TC : 1,  SCORE:   11'176'712 =>  11'171'195
SEED : 1, TC : 10, SCORE:  111'143'300 => 111'140'661
PASS
*/
///////////////////////////////////////////////////////////////////////////

struct Road
{
	int city1;
	int city2;
	int calcStatus;
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

///////////////////////////////////////////////////////////////////////////

#define Max(a, b) ((a) > (b)? (a):(b))
#define Min(a, b) ((a) < (b)? (a):(b))
#define Abs(a, b) ((a) < 0 ? -(a):(a))
template<class T>
void Swap(T&a, T&b) {
	T t = a; a = b; b = t;
}

enum { LM = 1000, FLM = 2000, ELM = 3000, INF = 1 << 30, CLM = 1 << 20 };
Road roads[ELM], revRoads;         // getRoadInfo() 의 매개 변수
Freight freight[FLM];    // getFreightInfo() 의 매개 변수

struct Cargo {
	int dest, weight, id;
	bool operator<(const Cargo&t)const {
		return weight < t.weight;
	}
}cargoByNode[LM][100];
int clen[LM];

struct Edge {
	int city, eid;
}adj[LM][100]; // 인접배열
int alen[LM];

int truckPos;            // 트럭 위치
int calcStatus[ELM];     // 미리 계산해본 내구도
int minusStatus[ELM];    // 미리 계산할 때 계속하여 무게를 밸셈한 내구도
int status[ELM];         // 실제 배송시 사용하는 내구도

struct Data {
	int u, costSum, statSum;
	bool operator<(const Data&t)const {
		if (costSum != t.costSum)
			return costSum < t.costSum;  // mintop
		return statSum > t.statSum;      // maxtop
	}
}dist[LM];

struct PQ {
	Data heap[LM * 10];
	int hn;
	void init() { hn = 0; }
	int size() { return hn; }
	bool empty() { return hn == 0; }
	Data top() { return heap[1]; }
	void push(Data nd) {
		heap[++hn] = nd;
		for (int c = hn; c > 1 && heap[c] < heap[c >> 1]; c >>= 1)
			Swap(heap[c], heap[c >> 1]);
	}
	void pop() {
		Swap(heap[1], heap[hn--]);
		for (int c = 2; c <= hn; c <<= 1) {
			if (c < hn && heap[c + 1] < heap[c]) c++;
			if (heap[c] < heap[c >> 1]) Swap(heap[c], heap[c >> 1]);
			else break;
		}
	}
}pq;

struct Cmd {
	int eid, weight, cmd;
}cmdList[CLM];
int cmdLen;
int minRepair[ELM];                  // ##### 추가한 부분 !!! #####

int lastPos;
void userInit() {
	lastPos = -1;   // 운송을 시작할 첫 도시를 아직 찾지 못했음으로 초기화

	for (int i = 0; i < LM; ++i) {
		alen[i] = 0;  // 인접배열 초기화
		clen[i] = 0;  // 역별 화물 목록 초기화
	}
	for (int i = 0; i < ELM; ++i) {  // ##### 추가한 부분 !!! #####
		minRepair[i] = INF;
	}


	getRoadInfo(roads);
	getFreightInfo(freight);
	truckPos = 0;
	cmdLen = 0;

	for (int i = 0; i < ELM; ++i) {
		int s = roads[i].city1, e = roads[i].city2;
		adj[s][alen[s]++] = { e, i }, adj[e][alen[e]++] = { s, i }; // 인접 배열
		minusStatus[i] = calcStatus[i] = status[i] = roads[i].calcStatus;  // 간선 상태 기록
	}
	for (int i = 0; i < FLM; ++i) {
		int e = freight[i].pos, s = freight[i].dest;  // ***** 
		int w = freight[i].weight;
		if (s == e) {
			continue;
		}

		int j = clen[s] - 1;
		for (; j >= 0 && w < cargoByNode[s][j].weight; --j) // insertion sort
			cargoByNode[s][j + 1] = cargoByNode[s][j];
		cargoByNode[s][j + 1] = { e, w, i };
		clen[s]++;
	}
}

Edge path[LM];
int src, totWeight;
int minVal;

void trace(int city) {  // loop trace
	if (lastPos < 0)
		return;       // 운송할 첫 도시가 지정되지 않은 경우는 제외
	int spos = cmdLen + 1, epos;
	for (; city != src; city = path[city].city) {
		int eid = path[city].eid;
		if (minRepair[eid] > totWeight) {  // ##### 추가한 부분 !!! #####
			minRepair[eid] = totWeight;
		}
		if (calcStatus[eid] < totWeight) {
			cmdList[++cmdLen] = { eid, totWeight, 0 };
			calcStatus[eid] = 0;
		}
		else {
			cmdList[++cmdLen] = { eid, totWeight, 0 };
			calcStatus[eid] -= totWeight;
		}
		minusStatus[eid] -= totWeight;
		//err[eid].push_back({ totWeight, minusStatus[eid]});
		minVal = Min(minVal, minusStatus[eid]);
	}

	// 경로 뒤집기
	for (epos = cmdLen; spos < epos; ++spos, --epos)
		Swap(cmdList[spos], cmdList[epos]);
}

void myMove(int s, int e, int w, int sign = 1) { // sign(0): 배송지를 찾을 때, sign(1): 새로운 배송지가 있을 때
	pq.init();
	for (int i = 0; i < LM; ++i) {
		dist[i] = { i, INF, 0 }; // s로부터 각 노드까지(1st:최소비용, 2nd:최대 내구도합)을 초기화
		path[i] = { -1, -1 };    // s로부터 각 노드까지 최단 경로를 초기화
	}
	pq.push({ s, 0, 0 });
	path[s].city = s;

	src = s, totWeight = w + 10;

	while (!pq.empty()) {
		auto t = pq.top(); pq.pop();
		if (dist[t.u] < t) continue;
		dist[t.u] = t;
		if (sign) {// 배송지가 결정된 경우
			if (t.u == e) // 배송지에 도착한 상황
				break;
		}
		else {  // 배송할 물품을 찾는 중인 경우
			if (clen[t.u]) { // t.u도시에 배송할 화물이 있는데
				// 물품출발지가 아직 결정되지 않았거나 현재 물품출발지 e보다 t.u가 더 멀다면 물품출발지를 업데이트
				if (e == -1 || cargoByNode[e][clen[e] - 1] < cargoByNode[t.u][clen[t.u] - 1])
					e = t.u;
			}
		}
		for (int i = 0; i < alen[t.u]; ++i) {
			int v = adj[t.u][i].city, eid = adj[t.u][i].eid;
			int repairNum = Max(0, totWeight - calcStatus[eid]);
			int ncost = 10 + repairNum * totWeight;
			Data nd = { v, t.costSum + ncost, t.statSum + calcStatus[eid] + repairNum - totWeight };
			if (nd < dist[v]) {
				dist[v] = nd;
				path[v] = { t.u, eid };
				pq.push(nd);
			}
		}
	}

	if (e > -1) {
		trace(e);
	}
	truckPos = e;
}

void process() {
	userInit();
	while (1) {
		lastPos = truckPos;
		if (clen[truckPos] == 0) {
			myMove(truckPos, -1, 0, 0);  // 가장 무거운 화물이 있는 가장 우선순위 높은(1st.비용최소, 2nd.내구도합이 높은) 도시 찾기
			if (truckPos == -1)          // 모든 운송이 끝난 경우
				break;
		}
		auto tg = cargoByNode[truckPos][--clen[truckPos]];
		cmdList[++cmdLen] = { tg.id, 0, -1 };
		//load(tg.id);
		myMove(truckPos, tg.dest, tg.weight);
		cmdList[++cmdLen] = { tg.id, 0, 1 };
		//unload();
	}
	truckPos = lastPos;
	myMove(truckPos, 0, 0);


	for (int i = cmdLen; i >= 1; --i) {
		int id = cmdList[i].eid, weight = cmdList[i].weight;
		int cmd = cmdList[i].cmd;
		if (cmd) {
			if (cmd > 0)
				load(id);
			else
				unload();
		}
		else {
			int repair = 0;
			if (minusStatus[id] < 0) {           // 수선이 필요한 도로인 경우
				if (minRepair[id] == weight) { // ##### 수정한 부분 !!! #####
					repair = Min(-minusStatus[id], 1000 - status[id]); // 가능한 수선비용
				}
				else if (weight > status[id]) {  // 현재 수선이 필요한 경우
					repair = weight - status[id];// 부족한 내구도를 수선비용으로
				}
				status[id] += repair;
				minusStatus[id] += repair;
			}
			status[id] -= weight;        // 내구도만 감소
			move(id, repair);
		}
	}
}

```
