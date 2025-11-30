```cpp
/*
31_EX물품배송_use_ver02

[해법 연구2]
1. 배송지를 가장 가까운 센터에 할당하여 센터별 할당 배송지 목록을 준비한다.
   이 프로세스를 단순하게 처리하면 O(1'000'000 * 1'000) 시간이 걸린다.
   이를 개선하기 위하여 다음과 같이 처리할 수 있다.
   사실 이문제는 4개의 객체가 등장한다.
   1.센터, 2.배송지, 3.트럭   그리고   4.물품 이다.
   4번째 객체인 물품을 이용해보자.
   물품 아이디별로 이 물품을 가진 센터를 목록으로 준비한다.
   최악의 경우라 해도 100을 초과하지 않는다.
   main.cpp에서 생성하는 각 센터당 물품 목록수는 1~100이기 때문이다.
   그런데 데이터를 분석하여 출력해 보면 각 물품 아이디별 센터의 갯수는 대부분 10개 미만이다.
   SEED = 5에서 가장 많은 경우가 16이다.
   이를 이용한다면 시간복잡도는 O(1'000'000 * 10) 정도로 줄어든다.
2. 차량은 현재 위치에서 가장 가까운 센터로 이동하여 다음 방법으로 TH개의 물품을 싣는다.
   (1) 센터에 남은 배송지중에서 가장 가까운 배송지를 1번 배송지로 선택한다.
   (2) 2번 배송지는 1번 배송지에서 가장 가까운 배송지를 선택한다.
   ...
   TH번 배송지는 TH-1번 배송지에서 가장 가까운 배송지를 선택한다.
   **********************************************************************
   (3) 아래와 같은 경우 물품1만 적재하여 배송하고
		빈차로 센터에 돌아와 물품2를 적재하여 배송하는 것(1)이
		2개의 물품 모두를 적재하고 배송하는 것(1)보다 비용이 적게 든다.
		물품1_____dist1____센터_________dist2______물품2
		예)     (4) -- 10 -- [center] -- 10 -- (1)  ---- 20 ---- (2) ------- 30 ------ (3)
		[load cost]
		{10 ( 100 + 4 10)} + {20 ( 100 + 3 10)} + {30 ( 100 + 2 10)} + {70 ( 100 + 1 10)}
		= 1400 + 2600 + 3600 + 7700 = 15300
		[unload cost]
		{10 ( 100 + 3 10)} + {20 ( 100 + 2 10)} + {30 ( 100 + 1 10)} + 60* 100 + {10 ( 100 + 1 10)}
		= 1300 + 2400 + 3300 + 6000 + 1100 = 14100
    **********************************************************************
3. 트럭은 트럭에 물품이 없는 경우 가장 가까운 배송 물품이 남아 있는 센터로 이동한다.
4. 모든 배송이 끝날때까지 2, 3을 반복한다.
	SEE = 5
	TH = 10 => SCORE: 10'334'347'820
	TH = 15 => SCORE:  9'504'272'800
	TH = 20 => SCORE:  9'349'203'960 => 9'179'669'400 (9107311680)
	TH = 30 => SCORE:  9'741'425'740 => 9'129'758'500 (9003347400)
	TH = 40 => SCORE: 10'492'700'260
	TH = 50 => SCORE: 11'367'644'540
	PASS

[고찰]
* 위 구현들은 배송지 우선순위가 없이 주어진 순서대로 센터를 선택한 버전이다.
* 배송지에 우선순위를 부여한다면 어떨까?
   예를 들자면 맵의 중심으로부터 가장 먼 배송지는 맵의 중심으로부터 가까운 배송지보다
   센터를 선택하는 선택의 폭이 좁다. 따라서 맵의 중심으로부터 먼 배송지부터 센터를 선택하는
   전략을 시도해볼 수 있다.

*/
#define ABS(x)    ((x) > 0 ? (x) : -(x))
#define Min(a, b) ((a) < (b)? (a):(b))
#define Max(a, b) ((a) > (b)? (a):(b))

struct Coordinates
{
	int y;
	int x;
	Coordinates() {
		y = x = 0;
	}
	Coordinates(int _y, int _x) {
		y = _y;
		x = _x;
	}
	int operator-(Coordinates& param) {
		return ABS(y - param.y) + ABS(x - param.x);
	}
};

struct Product
{
	int id;
	int count;
	Product() {
		id = count = 0;
	}
	Product(int _id, int _count) {
		id = _id;
		count = _count;
	}
};

extern int truckMove(int deliveryID);
extern int truckLoading(int centerID, int packageList[], int listSize);
///////////////////////////////////////////////////////////////////////////////
enum { CLM = 1000, PLM = 10000, DLM = 1000000, TLM = 50, TH = 30 };
Coordinates *centerPos, *deliPos, truckPos;
int * deliProd;
int truckDeli[TLM], truckProd[TLM], tlen;

int prodCenterCnt[PLM][CLM];           // [물품별][센터별] 물품 개수
int prodCids[PLM][CLM], pcLen[PLM];    // [물품별][센터별] 센터 목록 => 최대 16개, 평균 6개이다. ##### ver01 에서 바뀐부분 #####
int centerDeli[CLM][PLM], cdLen[CLM];  // 센터별 할당된 배송지 목록

void sendCenterList(int N, int M, Coordinates centerCoordinatesList[], Product centerProductList[][100], int centerProductSize[])
{
	centerPos = centerCoordinatesList;
	for (int i = 0; i < CLM; ++i) {         // 센터별 물품별 재고 파악
		int plen = centerProductSize[i];
		for (int j = 0; j < plen; ++j) {
			int pid = centerProductList[i][j].id;
			int cnt = centerProductList[i][j].count;
			if (prodCenterCnt[pid][i] == 0) // pid물품을 가진 센터i를 목록에 추가
				prodCids[pid][pcLen[pid]++] = i;
			prodCenterCnt[pid][i] += cnt;  // pid물품재고의 i센터에 재고수가 cnt개 증가합니다.
		}
	}
}

void sendDeliveryList(int K, Coordinates deliveryCoordinatesList[], int deliveryProductList[])
{
	deliPos = deliveryCoordinatesList;
	deliProd = deliveryProductList;

	// 각 배송지를 센터에 할당하기
	for (int i = 0; i < DLM; ++i) {       // O(100만)
		int pid = deliProd[i];
		int cid = -1, minDist = DLM;
		for (int j = 0; j < pcLen[pid]; ++j) { // O(1000)에서 O(6) 으로 개선 
			int tid = prodCids[pid][j];   // pid물품을 가진 센터
			if (prodCenterCnt[pid][tid] == 0) continue; // pid물품이 cid센터에 없다면 제외하고
			int tdist = centerPos[tid] - deliPos[i];
			if (minDist > tdist)          // 가장 가까운 센터에 i배송지를 할당하기 위하여
				cid = tid, minDist = tdist;
		}
		prodCenterCnt[pid][cid]--;  // cid센터의 pid물품 재고 감소
		centerDeli[cid][cdLen[cid] ++] = i;  // cid센터의 배송지 목록에 i배송지를 추가
	}
}

// 트럭의 현재 위치로부터 가장 가까운 배송할 물품이 남아있는 센터 찾아 그 아이디를 반환
int getNearestCenter() {
	int cid = -1, minDist = DLM;
	for (int i = 0; i < CLM; ++i) {
		if (cdLen[i] == 0) continue;  // 배송할 물품이 없는 센터는 제외하고
		int tdist = truckPos - centerPos[i];
		if (minDist > tdist)          // 가장 가까운 센터 찾기
			minDist = tdist, cid = i;
	}
	return cid;
}

void myTruckLoading(int cid) {     // cid센터에서 1개의 물품만 적재하기
	truckPos = centerPos[cid];     // 아바타 트럭을 먼저 cid로 이동
	tlen = 0;                      // 트럭에 적재된 물품수 초기화
	int&clen = cdLen[cid];         // cid센터에 등록된 남아 있는 배송지 수
	int minLen = Min(clen, TH);    // 남아 있는 배송지수와 TH중 더 최소값이 배송가능한 수이다.
	int distSum = 0;
	for (int i = 0; i < minLen; ++i) {
		int did = -1, minDist = DLM, tj = -1;
		for (int j = 0; j < clen; ++j) {   // 배송지 후보 중에 트럭의 현재 위치로 가장 가까운 배송지 선택하기
			int tid = centerDeli[cid][j];        // 배송지 후보
			int tdist = truckPos - deliPos[tid]; // 후보까지 거리 구하기
			if (minDist > tdist) // 더 가까운 배송지가 등장한 경우.
				did = tid, minDist = tdist, tj = j;
		}
		if (i > 0) {
			//int loadCost = distSum * 10 + minDist * 110;  // 엄밀한 측정
			int loadCost = distSum * 110 + minDist * 110; // Heuristic 측정 => 다른 센터를 선택할 확률을 높여준다.
			int unloadCost = (deliPos[truckDeli[i - 1]] - centerPos[cid]) * 100 + (centerPos[cid] - deliPos[did]) * 110;
			if (unloadCost <= loadCost) break;
		}

		distSum += minDist;
		// 유저의 아바타 트럭에 배송지 아이디와 배송지 물품을 적재
		truckDeli[tlen] = did, truckProd[tlen] = deliProd[did], ++tlen;
		truckPos = deliPos[did];  // 유저의 아바타 트럭을 did배송지로 이동 : 다음 물품 적재를 위하여

		centerDeli[cid][tj] = centerDeli[cid][--clen];  // 마지막 물품으로 현재 물품 삭제
	}
}

void solve(Coordinates truckCoordinates)
{
	truckPos = truckCoordinates;

	for (int k = 0; k < DLM; ++k) {
		int cid = getNearestCenter();  // 배송할 물품이 남아 있는 트럭으로부터 가장 가까운 센터 찾기
		if (cid < 0)
			break;  // 배송이 완료된 경우
		myTruckLoading(cid);                 // 유저의 트럭에 배송지 정보를 적재하기
		if (truckLoading(cid, truckProd, tlen) == 0) // main의 트럭을 cid센터로 이동시켜 물품 적재하기
			int error = 1;  // 정상작동 여부 확인용

		// 배송하기 : 1개 뿐이지만 적재한 순서대로 배송하는 코드를 작성.
		for (int i = 0; i < tlen; ++i) {
			truckMove(truckDeli[i]);         // 배송시에는 배송지 아이디를 전송
		}
	}
}

```
