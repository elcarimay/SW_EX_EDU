```cpp
/*
31_EX물품배송_use_sketchCode03

[sketchCode03]
1. 센터별 물품 재고표를 작성한다.
2. 배송지를 센터에 할당한다. O(DLM * CLM = 10억)
3. 트럭 배송은 다음 프로세스를 따른다.
	1) 트럭이 빈트럭이라면 가장 가까운 배송할 물품이 남아 있는 센터로 이동한다.
	2) 센터에서 가장 가까운 물품1을 적재한다.
	   물품1에서 가장 가까운 물품2를 적재한다.
	   물품2에서 가장 가까운 물품3을
	   ...
	   물품TH-1에서 가장 가까운 물품 TH를 적재한다.
	3) 적재한 모든 물품을 배송하고 1~2전략을 배송이 완료될때까지 반복한다.
		TH = 10,  SCORE: 10'334'543'820
		TH = 20,  SCORE:  9'349'401'560
		TH = 30,  SCORE:  9'741'594'340
		TH = 40,  SCORE: 10'492'786'460
		TH = 50,  SCORE: 113'67'923'140

		PASS
		RunTime : 5227
[고찰]
	배송지를 센터에 할당하는 2번 프로세스가 시간복잡도 O(DLM * CLM = 10억)로 다소 느리다.
	이를 개선할 수 있을까?
	시험장 서버는 swea서버보다 1.6배 정도 느린 것으로 알려져 있다.
	속도를 개선할 수 있다면 개선하는 것이 안전하다.
	배송지별로 각배송지에 가장 가까운 가능한 센터를 할당하는 작업의 시간복잡도 O(1000000 * 1000)을 개선할 수 있을까?
	부품별 가능한 센터 목록을 만들어 놓으면 [10000][100]으로 만들수 있다.
	부품의 종류는 최대 10000개, 센터별 갖는 부품 종류는 최대 100 이고 데이터는 랜덤하게 생성된다.
	따라서 각 부품별 해당 부품을 가진 센터수는 많지 않다.
	실제로 메인에서 생성되는 데이터를 분석해보면 부품별 해당 부품을 가진 센터수는 대부분이 10개 미만이고 최대가 16이다.
	이를 이용하여 배송지별 각배송지에 가장 가까운 가능한 센터를 할당하는 작업은
	(1000000 100(그런데 실제로는 10미만이 상당수))으로 줄일 수 있다.


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

int prodCenterCnt[PLM][CLM];           // [센터별][물품별] 물품 개수
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
			prodCenterCnt[pid][i] += cnt;  // pid물품재고의 i센터에 재고수가 cnt개 증가합니다.
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
			if (prodCenterCnt[pid][j] == 0) continue;  // pid물품이 없는 센터는 제외하고
			int tdist = centerPos[j] - deliPos[i];
			if (minDist > tdist)          // 가장 가까운 센터에 i배송지를 할당하기 위하여
				cid = j, minDist = tdist;
		}
		prodCenterCnt[pid][cid]--;  // cid센터의 pid물품 재고 감소
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

void myTruckLoading(int cid) {     // cid센터에서 1개의 물품만 적재하기
     // ##### sketchCode03에서 바뀐부분 #####
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
     // #####################################
}

void solve(Coordinates truckCoordinates)
{
	truckPos = truckCoordinates;

	while (1) {
		int cid = getNearestCenter();  // 배송할 물품이 남아 있는 트럭으로부터 가장 가까운 센터 찾기
		if (cid < 0)
			break;  // 배송이 완료된 경우
		myTruckLoading(cid);                 // 유저의 트럭에 배송지 정보를 적재하기
		truckLoading(cid, truckProd, tlen);  // main의 트럭을 cid센터로 이동시켜 물품 적재하기

		// 배송하기 : 1개 뿐이지만 적재한 순서대로 배송하는 코드를 작성.
		for (int i = 0; i < tlen; ++i) {
			truckMove(truckDeli[i]);         // 배송시에는 배송지 아이디를 전송
		}
	}
}
```
