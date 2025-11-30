```cpp
/*
31_EX물품배송_use_sketchCode02

[sketchCode_ver02]
1. 센터별 물품 재고를 파악한다.
2. 배송지를 원하는 물품을 가진 가장 가까운 센터에 할당한다.                  => 배송지 우선순위는?
3. 트럭
   (1) 빈트럭 : 배송물품이 남아 있는 가장 가까운 센터로 이동
   (2) 센터에 남은 배송지 물품 1개를 적재후 배송하기 => 여러개 배송은?
	   1개씩 배송하는 경우 어차피 모든 배송지 물품을 배송해야 하므로
	   순서는 중요하지 않을 수 있다.

4. ##### sketchCode01 고찰1을 반영한 버전 #####
   row-major 코드로 변환하면 실행속도를 절반가량 줄일 수 있다.

[고찰]
   점수가 높다.
		=> 여러 개 배송하는 것은 어떨까?
		=> 여러 개 배송한다면 어떤 물품을 함께 적재할 것인가?
		=> 여러 개 배송한다면 어떤 물품을 먼저 적재(배송) 할 것인가?

SCORE: 46'029'280'220
FAIL
RunTime : 4931

*/
#define ABS(x)    ((x) > 0 ? (x) : -(x))

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
enum { CLM = 1000, PLM = 10000, DLM = 1000000, TLM = 50 };
Coordinates *centerPos, *deliPos, truckPos;
int * deliProd;
int truckDeli[TLM], truckProd[TLM], tlen;

int prodCenterCnt[PLM][CLM];           // [센터별][물품별] 물품 개수 ##### 바뀐부분 #####
int centerDeli[CLM][PLM], cdLen[CLM];  // 센터별 할당된 배송지 목록

void sendCenterList(int N, int M, Coordinates centerCoordinatesList[],
	Product centerProductList[][100], int centerProductSize[])
{
	centerPos = centerCoordinatesList;
	for (int i = 0; i < CLM; ++i) {         // 센터별 물품별 재고 파악
		int plen = centerProductSize[i];
		for (int j = 0; j < plen; ++j) {
			int pid = centerProductList[i][j].id;
			int cnt = centerProductList[i][j].count;
			prodCenterCnt[pid][i] += cnt;  // pid물품재고의 i센터에 재고수가 cnt개 증가합니다. ##### 바뀐부분 #####
		}
	}
}

void sendDeliveryList(int K, Coordinates deliveryCoordinatesList[],
	int deliveryProductList[])
{
	deliPos = deliveryCoordinatesList;
	deliProd = deliveryProductList;

	// 각 배송지를 센터에 할당하기
	for (int i = 0; i < DLM; ++i) {       // O(100만)
		int pid = deliProd[i];
		int cid = -1, minDist = DLM;
		for (int j = 0; j < CLM; ++j) {   // O(1000) pid물품을 가진 모든 센터를 대상으로 탐색
			if (prodCenterCnt[pid][j] == 0) continue;  // pid물품이 없는 센터느 제외하고 ##### 바뀐부분 #####
			int tdist = centerPos[j] - deliPos[i];
			if (minDist > tdist)          // 가장 가까운 센터에 i배송지를 할당하기 위하여
				cid = j, minDist = tdist;
		}
		prodCenterCnt[pid][cid]--;  // cid센터의 pid물품 재고 감소 ##### 바뀐부분 #####
		centerDeli[cid][cdLen[cid] ++] = i;  // cid센터의 배송지 목록에 i배송지를 추가
	}
}

// 트럭의 현재 위치로부터 가장 가까운 배송할 물품이 남아있는 센터 찾아 그 아이디를 반환
int getNearestCenter() {
	// implement here
	int cid = -1, minDist = DLM;
	for (int i = 0; i < CLM; ++i) {
		if (cdLen[i] == 0) continue;  // 배송할 물품이 없는 센터는 제외하고
		int tdist = truckPos - centerPos[i];
		if (minDist > tdist)          // 가장 가까운 센터 찾기
			minDist = tdist, cid = i;
	}
	return cid;
}

void myTruckLoading(int cid) {  // cid센터에서 1개의 물품만 적재하기
	int did = centerDeli[cid][--cdLen[cid]]; // 센터에 남아있는 배송지중에 마지막배송지를 선택
	int pid = deliProd[did];                 // did배송지가 받을 물품아이디
	tlen = 0;
	truckDeli[tlen] = did;     // 메인에 있는 트럭이 배송시 사용
	truckProd[tlen] = pid;     // 메인에 있는 트럭이 물품을 적재할 때 사용
	++tlen;                    // user의 아바타 트럭에 적재한 물품수 증가

	truckPos = deliPos[did];   // user의 아바타 트럭 이동
}

void solve(Coordinates truckCoordinates)
{
	truckPos = truckCoordinates;

	while (1) {
		int cid = getNearestCenter();  // 배송할 물품이 남아 있는 트럭으로부터 가장 가까운 센터 찾기
		if (cid < 0)
			break;  // 배송이 완료된 경우
		truckPos = centerPos[cid];

		// implement here
		myTruckLoading(cid);                 // 유저의 트럭에 배송지 정보를 적재하기
		truckLoading(cid, truckProd, tlen);  // main의 트럭을 cid센터로 이동시켜 물품 적재하기

		// 배송하기 : 1개 뿐이지만 적재한 순서대로 배송하는 코드를 작성.
		for (int i = 0; i < tlen; ++i) {
			truckMove(truckDeli[i]);         // 배송시에는 배송지 아이디를 전송
		}
	}
}
```
