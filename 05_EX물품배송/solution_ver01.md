```cpp
/*
31_EX물품배송_use_ver01

[해법 연구1]
1. 센터별 물품 재고표를 작성한다.
   아래 과정2의 시간복잡도 개선을 위하여 물품별 센터목록을 준비한다.
   데이터를 분석해 보면 물품별 센터목록의 길이는 대부분 1자리이고 최대 16개이다.
2. 배송지를 센터에 할당한다.
   위 과정 1번을 이용하여 평균 시간이 O(DLM * 10)정도가 된다.
3. 트럭 배송은 다음 프로세스를 따른다.
	1) 트럭이 가장 가까운 배송할 물품이 남아 있는 센터로 이동한다.
	2) 센터에서에서 가장 가까운 물품1을 적재한다.
	   물품1에서 가장 가까운 물품2를 적재한다.
	   물품2에서 가장 가까운 물품3을...
	3) 적재한 모든 물품을 배송하고 1~3전략을 배송이 완료될때까지 반복한다.
		TH = 10,  SCORE: 10'334'543'820
		TH = 20,  SCORE:  9'349'401'560
		TH = 30,  SCORE:  9'741'594'340
		TH = 40,  SCORE: 10'492'786'460
		TH = 50,  SCORE: 113'67'923'140

		PASS
		RunTime : 4448

[고찰]
점수 계산식은 다음과 같다.
SCORE += dist (100 + truck_package_count 10);

앞에 배치된 배송지들은 트럭에 실린 물건수에 영향을 많이 받고
뒤에 배치된 배송지들은 트럭에 실린 물건수와 함께 트럭이 이동하는 거리가 증가할수록 많은 점수를 사용한다.
트럭에 싣는 물건수를 50개로 하는 것이 최선일까?
( 출제자는 50으로 정한 이유가 무엇일까? )

트럭이 배송중에 센터A => 배송지1 => 배송지2 로 이동할 때 누적 거리가
센터A => 배송지1 => 센터A(혹은 다른 센터) => 배송지2(혹은 다른 배송지) 보다 크다면
센터A(혹은 다른 센터)로 돌아가는 것이 더 유리하다.

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
enum { CLM = 1000, PLM = 10000, DLM = 1000000, TLM = 50, TH = 20 };
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
			//##### ver01 에서 바뀐부분 #####
			if (prodCenterCnt[pid][i] == 0) // pid물품을 가진 센터i를 목록에 추가
				prodCids[pid][pcLen[pid]++] = i;
			//###############################
			prodCenterCnt[pid][i] += cnt;  // pid물품재고의 i센터에 재고수가 cnt개 증가합니다.
		}
	}

	////for debug
	//int sum = 0, maxLen = 0;
	//for (int i = 0; i < PLM; ++i) {
	//	sum += pcLen[i];
	//	maxLen = Max(pcLen[i], maxLen); // 최대 16개
	//}
	//int avg = (sum + PLM - 1) / PLM;  // 평균 6개
	//int tt = 1;
}

void sendDeliveryList(int K, Coordinates deliveryCoordinatesList[], int deliveryProductList[])
{
	deliPos = deliveryCoordinatesList;
	deliProd = deliveryProductList;

	// 각 배송지를 센터에 할당하기
	for (int i = 0; i < DLM; ++i) {       // O(100만)
		int pid = deliProd[i];
		int cid = -1, minDist = DLM;

		// ##### ver01 에서 바뀐부분 #####
		for (int j = 0; j < pcLen[pid]; ++j) { // O(1000)에서 O(6) 으로 개선 
			int tid = prodCids[pid][j];   // pid물품을 가진 센터
			if (prodCenterCnt[pid][tid] == 0) continue; // pid물품이 cid센터에 없다면 제외하고
			int tdist = centerPos[tid] - deliPos[i];
			if (minDist > tdist)          // 가장 가까운 센터에 i배송지를 할당하기 위하여
				cid = tid, minDist = tdist;
		}
		// ###############################
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
	for (int i = 0; i < minLen; ++i) {
		int did = -1, minDist = DLM, tj = -1;
		for (int j = 0; j < clen; ++j) {   // 배송지 후보 중에 트럭의 현재 위치로 가장 가까운 배송지 선택하기
			int tid = centerDeli[cid][j];        // 배송지 후보
			int tdist = truckPos - deliPos[tid]; // 후보까지 거리 구하기
			if (minDist > tdist) // 더 가까운 배송지가 등장한 경우.
				did = tid, minDist = tdist, tj = j;
		}
		// 유저의 아바타 트럭에 배송지 아이디와 배송지 물품을 적재
		truckDeli[tlen] = did, truckProd[tlen] = deliProd[did], ++tlen;
		truckPos = deliPos[did];  // 유저의 아바타 트럭을 did배송지로 이동 : 다음 물품 적재를 위하여

		centerDeli[cid][tj] = centerDeli[cid][--clen];  // 마지막 물품으로 현재 물품 삭제
	}
}

void solve(Coordinates truckCoordinates)
{
	truckPos = truckCoordinates;

	for(int k=0;k<DLM;++k) {
		int cid = getNearestCenter();  // 배송할 물품이 남아 있는 트럭으로부터 가장 가까운 센터 찾기
		if (cid < 0)
			break;  // 배송이 완료된 경우
		myTruckLoading(cid);                 // 유저의 트럭에 배송지 정보를 적재하기
		if(truckLoading(cid, truckProd, tlen) == 0) // main의 트럭을 cid센터로 이동시켜 물품 적재하기
			int error = 1;  // 정상작동 여부 확인용

		// 배송하기 : 1개 뿐이지만 적재한 순서대로 배송하는 코드를 작성.
		for (int i = 0; i < tlen; ++i) {
			truckMove(truckDeli[i]);         // 배송시에는 배송지 아이디를 전송
		}
	}
}

```
