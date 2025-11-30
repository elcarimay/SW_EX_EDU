```cpp
/*
48_EX노후화된도로_user_analysis

1. 그래프 구성 : 인접배열? 인접리스트? 인접행렬?
2. 상하역 비용은 상수이므로 쉽게 계산된다.
3. 도로에 수선이 필요없다고 가정하면
   모든 도로는 이동비용이 10으로 일정하다.
   이를 이용하여 모든 화물을 목적지까지 운송하는데 필요한
   총비용의 하한을 가능해 볼 수 있다.

[ BFS로 화물을 운송하기 프로세스]
1. getRoadInfo(Road mRet[]) 간선정보를 얻고 그래프를 구성한다.
2. getFreightInfo(Freight mRet[]) 화물정보를 얻고 각 도시별 배송화물 목록를 만든다.
   이때 출발지와 도착지(목적지)가 같은 화물은 목록에 포함시키지 않는다. => EX화물기차의 경험을 살려서...
3. 간선의 비용을 10으로 고정, 도로의 내구도 손상을 0으로 하였으므로
   배송의 우선순위는 생각할 필요 없다.
4. 트럭은 다음과 같이 운송한다.
   1) 트럭의 현재위치에서 가장 가까운 배송할 화물이 있는 도시로 이동한다.
   2) 하나의 화물을 적재하고 목적지로 배송한다.
   3) 모든 화물이 도착지(목적지)에 도달할때까지 1), 2) 프로세스를 반복한다.

TC: 1, SEED: 1에서 점수는 11'120'398 이므로
실제 비용은 11'120'398 보다는 높다.

loadUnloadCost : 11037868
moveCost       :    82530
totalCost      : 11120398
<다음 정보를 추가로 알아볼 수 있다.>
상하차 비용 = loadUnloadCost : 11037868
BFS운송비용 = moveCost       :    82530
노드별 인접한 노드수는? 최대, 최소수는? => 최대 10 (SEED = 1, TC = 1)
출발지별 화물수는? 최대, 최소수는?      => 최대  7 (SEED = 1, TC = 1)
도착지별 화물수는? 최대, 최소수는?      => 최대  7 (SEED = 1, TC = 1)
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
////////////////////////////////////////////////////////////
#include <cstdio>
#define Max(a, b) ((a) > (b)? (a):(b))
#define Min(a, b) ((a) < (b)? (a):(b))
enum { LM = 1000, FLM = 2000, RLM = 3000 };
Road roads[RLM];
Freight freights[FLM];
int status[RLM];

struct Node {  // 인접한 노드 정보를 저장할 클래스
	int node, roadID;
};
Node adj[LM][100];           // 인접배열
int alen[LM];                // 각 노드별 인접 노드수
Freight cityCargos[LM][100]; // 도시별 배송이 필요한 화물 목록
int clen[LM];                // 도시별 배송이 필요한 화물 수 => 출발지별 화물수
int destCnt[LM];             // 도착지별 화물수
int myTruck;
int loadUnloadCost;          // 상하차 비용
int moveCost;                // 이동비용

void userInit() {
	// user_init
	for (int i = 0; i < LM; ++i) // 목록 초기화
		alen[i] = clen[i] = destCnt[i] = 0;
	myTruck = 0;   // 초기 트럭위치
	loadUnloadCost = moveCost = 0; // 비용초기화

	getRoadInfo(roads);        // 도로 정보 얻기
	getFreightInfo(freights);  // 화물정보 얻기

	// 인접 배열을 이용한 그래프 구성
	for (int i = 0; i < RLM; ++i) {
		int s = roads[i].city1, e = roads[i].city2;
		int rid = roads[i].id;
		status[rid] = roads[i].status;  // !!!!!
		adj[s][alen[s]++] = { e, rid }; // 양방향 그래프 구성
		adj[e][alen[e]++] = { s, rid };
	}

	int acntMax = 0, acntMin = LM;
	for (int i = 0; i < LM; ++i) {       // 각 도시별
		acntMax = Max(acntMax, alen[i]); // 인접노드수 최대값
		acntMin = Min(acntMin, alen[i]); // 인접노드수 최소값
	}

	// 도시별 배송이 필요한 화물 목록 생성
	int sCntMax = 0, eCntMax = 0;
	for (int i = 0; i < FLM; ++i) {
		int sp = freights[i].pos, ep = freights[i].dest;
		if (sp == ep) continue; // 출발지와 목적지가 같은 경우는 제외시킨다.
		cityCargos[sp][clen[sp]++] = freights[i];
		destCnt[ep]++;
		if (sCntMax < clen[sp]) sCntMax = clen[sp];
		if (eCntMax < destCnt[ep]) eCntMax = destCnt[ep];
	}
	printf("acntMax : %d, acntMin : %d\n", acntMax, acntMin);
	printf("sCntMax : %d\n", sCntMax);  // 출발도시중에 최대 화물수
	printf("eCntMax : %d\n", eCntMax);  // 도착도시중에 최대 화물수
}

int que[LM], fr, re;
int path[LM];        // 방문체크 + 경로저장
void BFS(int src, int dest, int weight) {
	// init()
	fr = re = 0;   // 큐 초기화
	for (int i = 0; i < LM; ++i) path[i] = -1; // 경로및 방문체크 배열 초기화
	que[re++] = src;
	path[src] = src;
	// bfs process
	while (fr < re) {
		int u = que[fr++];
		if (u == dest)
			break;
		for (int i = 0; i < alen[u]; ++i) {  // 인접한 노드를 방문하기
			int v = adj[u][i].node, rid = adj[u][i].roadID;
			if (path[v] > -1) continue;  // 이미 방문한 노드
			status[rid] -= weight + 10;  // for analysis
			que[re++] = v;
			path[v] = u;
		}
	}

	// 이동 경로를 따라 가면서 이동 비용 계산
	int id = dest, cost = 0;
	while (id != src) { // 거쳐간 도시 구하기
		cost += 10;
		id = path[id];
	}
	moveCost += cost;
}

void process() {
	userInit();
	for (int i = 0; i < LM; ++i) {             // 각 도시별
		for (int j = 0; j < clen[i]; ++j) {    // 화물을 
			int w = cityCargos[i][j].weight;
			loadUnloadCost += w * w * 2;       // 상하차비용계산
			BFS(i, cityCargos[i][j].dest, w);  // 배송하기 : 이동비용계산
		}
	}

	printf("loadUnloadCost : %8d\n", loadUnloadCost);
	printf("moveCost       : %8d\n", moveCost);
	printf("totalCost      : %8d\n", loadUnloadCost + moveCost);
}
```
