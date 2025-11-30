```cpp
/*
48_EX노후화된도로_main

[문제 구조]
1. TC와 SEED를 입력받아 처리(가변적)하며 TC당 1초의 제한시간이 있다. => 새로운 스타일의 시작 #####
2. interactive 문제이다. => EX물품배송의 경험을 이용하여 유저에 아바타를 생성하고 문제를 해결할 수 있다.
   : main에 있는 트럭으로 main에 있는 화물을 main에 있는 도로를 이용하여 main에 있는 도시에 운송한다.
     이때 유저는 main에 있는 getRoadInfo(), getFreightInfo(), move(), load(), unload() API함수를 이용할 수 있다.
3. 점수가 낮을 수록 좋다.

[문제 개요]
1000개의 도시, 3000개의 양방향도로, 2000개의 화물, 한대의 트럭이 주어진다.
도시는 id (0~999) 속성이 있다.
도로는 { 도시1, 도시2, 아이디, 도로내구도상태(100~399)} 속성이 주어진다.
화물은 { 현재위치, 목적위치, 무게(1~90)} 속성이 주어진다.
트럭은 { 현재위치, 1개의 화물포인터} 속성이 주어진다.
트럭 1대를 이용하여 모든 화물을 목적지까지 운송해야 한다.
트럭은 한번에 1개의 화물을 운송한다.
트럭은 도로를 이용할 때 (전체무게(화물무게+10)-수선값)만큼 도로내구도를 손상시킨다.
이때 비용(점수)은 10+수선값*전체무게가 발생한다.

[user.cpp에서 작성할 API함수]
: process()

[유저가 사용하는 main.cpp의 API함수]
getRoadInfo(), getFreightInfo(), move(), load(), unload()

[문제 분석]
최소 12000번 이상의 shuffle로 도로를 생성한다.
 => 모든 도시는 연결된다. 각 도시별 인접한 도시수는 비교적 고를 것으로 예상된다. 
 => 평균 3개, 최댓값은?, 최솟값은?

<비용 계산식>
  1. move() : 10 + 수선값*전체무게
  2. load(), unload() : 화물무게 제곱
<비용 분석>
  0. 출발지와 목적지가 다른 화물만 운송한다.
  1. load(), unload() 비용은 상수로 생각할 수 있다.
  2. move() 비용
     (1) 빈트럭도 10의 비용이 발생한다. => !!! 빈트럭 이동을 최소화할 필요가 있다. !!!
     (2) 화물의 무게가 무거울 수록 수선 비용이 높아진다.
         => !!! 수선이 필요한 같은 도로를 무게가 다른 두 화물이 이용하는 경우 
	        가벼운 화물이 이동할 때 미리 수선하면 비용을 감소시킬 수 있다. !!!
		 => 무거운 화물을 먼저 운송하는 것이 유리할 수 있다.

도로를 이용하면 내구도가 감소하고 도로를 이용하기 위해서는 (수선값 + 내구도) >= 전체무게 이어야 하므로
어떤 경로를 이용하는가에 따라 운송비용이 달라진다.
즉, 모든 도로 이용비용이 같지 않으므로 최단거리 문제로 볼수 있다.
간선 이용 비용이 음수가 없으므로 Dijkstra를 이용할 수 있다.

*/

#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif

#include <stdio.h>

/* seed and pseudo_rand function will be changed */
static unsigned long long seed;

static int pseudo_rand(void) {
	seed = seed * 25214903917ULL + 11ULL;
	return (seed >> 16) & 0x3fffffff;
}

static long long gTotalScore = 0;
static long long PENALTY = 1'000'000'000'000;  // 벌점 1조

/* These constant variables will NOT be changed */
static const int CITY_NUM = 1000;     // 도시수
static const int ROAD_NUM = 3000;     // 도로수
static const int FREIGHT_NUM = 2000;  // 화물수
static const int MAX_WEIGHT = 90;     // 화물의 최대 무게

struct Road {     // 도로 클래스
	int city1;    // 두 도시
	int city2;
	int status;   // 도로 상태
	int id;       // 도로 아이디
};


struct Freight {  // 화물 클래스
	int pos;      // 화물의 현재위치
	int dest;     // 화물의 목적위치
	int weight;   // 화물의 무게
};

struct Truck {    // 트럭 클래스
	int pos;      // 트럭의 현재 위치
	Freight* freight; // 적재한 화물 포인터
};

static Truck truck;
static Road roads[ROAD_NUM];
static Freight freights[FREIGHT_NUM];

////////////////////////////////////

bool move(int mRoadID, int repairNum)  // 트럭이 mRoadID도로를 이용하는데 수선값으로 repairNum를 사용
{
	// 도로 아이디(0~2999)와 수선값(0~1000) 유효성 검사
	if (mRoadID < 0 || mRoadID >= ROAD_NUM || repairNum < 0 || repairNum + roads[mRoadID].status > 1000)
		return false;

	// 전체무게 = 10 + 화물무게
	int totalWeight = 10 + ((truck.freight == nullptr) ? 0 : truck.freight->weight); // (*truck.freight).weight
	int score = 10 + repairNum * totalWeight; // 점수 = 10 + 수선값*전체비용
	// 트럭이 빈 차로 이동하여도 10의 점수(비용)가 부과된다.

	// 수선값+도로상태 >=  전체무게 이어야 도로를 이용할 수 있다.
	if (repairNum + roads[mRoadID].status >= totalWeight) {
		// 트럭이 mRoadID도로의 두 도시중 어느 한 도시에 있어야 한다.
		if (truck.pos != roads[mRoadID].city1 && truck.pos != roads[mRoadID].city2)
			return false;

		if (truck.pos == roads[mRoadID].city1) // 트럭이 city1에 있다면 city2로 이동
			truck.pos = roads[mRoadID].city2;
		else
			truck.pos = roads[mRoadID].city1;  // 트럭이 city2에 있다면 city1로 이동

		gTotalScore += score;  // 전체 점수 업데이트

		// 도로 상태 업데이트 : 도로는 (전체무게-수선비)만큼 내구도가 감소한다.
		roads[mRoadID].status += (repairNum - totalWeight);

		return true;
	}
	else {
		return false;
	}
}

bool load(int mFreightID)  // 적재 비용 : 화물무게의 제곱
{
	// 빈트럭이어야 하고 트럭이 화물이 있는 도시에 있어야 한다.
	if (truck.freight != nullptr || truck.pos != freights[mFreightID].pos)
		return false;

	truck.freight = &freights[mFreightID]; // 적재
	gTotalScore += truck.freight->weight * truck.freight->weight; // 비용계산

	return true;
}

bool unload()  // 하역 비용 : 화물무게의 제곱
{
	// 트럭이 화물을 싣고 있어야 한다.
	if (truck.freight == nullptr)
		return false;

	gTotalScore += truck.freight->weight * truck.freight->weight; // 비용계산

	truck.freight->pos = truck.pos; // 하역 : 화물을 트럭의 현재 위치로 이동
	truck.freight = nullptr;        // 빈트럭으로

	return true;
}

void getRoadInfo(Road mRet[])  // 유저가 도로 정보를 얻기 위하여 사용
{
	for (int i = 0; i < ROAD_NUM; i++) {
		mRet[i] = roads[i];
	}
}

void getFreightInfo(Freight mRet[]) // 유저가 화물 정보를 얻기 위하여 사용
{
	for (int i = 0; i < FREIGHT_NUM; i++) {
		mRet[i] = freights[i];
	}
}

////////////////////////////////////
static void init()   // 데이터 생성
{
	truck.pos = 0;            // 트럭 초기화 : 초기위치 0
	truck.freight = nullptr;  // 적재한 화물 없음

	int roadIdx = 0;          // 도로 인덱스 (갯수)

	int citylist[CITY_NUM] = { 0, };   // 1000개 도시목록

	for (int i = 0; i < CITY_NUM; i++) // 도시 아이디 목록 초기화
		citylist[i] = i;

	int shuffle_cnt = 3000;    // 셔플수

	// 2 * 999 = 1998 개의 도로를 생성한다.
	for (int i = 0; i < 2; i++) {
		for (int j = 0; j < shuffle_cnt; j++) {  // 3000번 섞기
			int x = pseudo_rand() % CITY_NUM;
			int y = pseudo_rand() % CITY_NUM;

			int t = citylist[x];       // 교환연산
			citylist[x] = citylist[y];
			citylist[y] = t;
		}

		// 1999개 도로 생성
		for (int j = 0; j < CITY_NUM - 1; j++) {
			roads[roadIdx].city1 = citylist[j];     // 인접한 두 도시를 연결
			roads[roadIdx].city2 = citylist[j + 1];
			roads[roadIdx].id = roadIdx;            // 도로 아이디
			roads[roadIdx].status = pseudo_rand() % 300 + 100;  // 도로 상태 :  100 ~ 399

			roadIdx++;  // 도로 아이디는 순차적으로
		}
	}

	// 3000-1998 = 1002 개의 도로를 생성한다.
	while (roadIdx < ROAD_NUM) {
		for (int j = 0; j < shuffle_cnt; j++) { // 도시아이디 목록 섞기
			int x = pseudo_rand() % CITY_NUM;
			int y = pseudo_rand() % CITY_NUM;
			 
			int t = citylist[x];       // 교환연산
			citylist[x] = citylist[y];
			citylist[y] = t;
		}

		int l = pseudo_rand() % CITY_NUM;  // 새로 생성할 도로수

		if (roadIdx + l > ROAD_NUM) {  // 기존생성한도로수 + 새로 생성할 도로수는 3000을 초과하지 않도록
			l = ROAD_NUM - roadIdx;    // 새로 생성할 도로수 조정
		}

		int startIdx = pseudo_rand() % CITY_NUM;  // 도로를 생성할 도시목록의 시작 인덱스 생성

		if (startIdx + l >= CITY_NUM) {  // l개의 도로를 생성하기 위하여
			startIdx = CITY_NUM - l - 1; // 시작 인덱스 조정
		}

		for (int j = 0; j < l; j++) {
			roads[roadIdx].city1 = citylist[j + startIdx];     // 인접한 두 도시를 연결
			roads[roadIdx].city2 = citylist[j + startIdx + 1];
			roads[roadIdx].id = roadIdx;
			roads[roadIdx].status = pseudo_rand() % 300 + 100; // 도로상태 : 100~299

			roadIdx++;
		}
	}

	for (int i = 0; i < FREIGHT_NUM; i++) {   // 2000개 화물 생성
		// 중복 체크가 없으므로 현재위치와 목적위치가 같을 수 있다. !!!!!
		// 1000개의 도시가 있으므로 한 도시당 평균 2개꼴이다.
		freights[i].pos = pseudo_rand() % CITY_NUM;          // 화물의 현재 위치
		freights[i].dest = pseudo_rand() % CITY_NUM;         // 화물의 목적 위치
		freights[i].weight = pseudo_rand() % MAX_WEIGHT + 1; // 화물 무게 : 1 ~ 90
	}

}

static bool score()  // 최종 유효성 검사
{
	for (int i = 0; i < FREIGHT_NUM; i++) {  // 모든 화물은 목적지에 도달하여야 한다.
		if (freights[i].pos != freights[i].dest)
			return false;
	}

	return true;
}

extern void process();

int main(int argc, char* argv[])
{
	setbuf(stdout, NULL);
	freopen("48.txt", "r", stdin);

	bool result = false;
	int TC;

	gTotalScore = 0;

	scanf("%d %lld", &TC, &seed);
	for (int tc = 0; tc < TC; ++tc) {
		init();     // 데이터 생성
		process();  // 사용자가 완성할 함수
		//if ((result = score()) == false)
		result = score();
		if (result  == false)
			break;
	}
	long long SCORE = (result) ? gTotalScore : PENALTY;
	printf("SCORE: %lld\n", SCORE);

	///////////////////////////////////////////////////////////////////////////////////
	long long cut;
	scanf("%lld", &cut);
	if (SCORE <= cut) {
		puts("PASS");
	}
	else {
		puts("FAIL");
	}
	///////////////////////////////////////////////////////////////////////////////////

	return 0;
}
```
