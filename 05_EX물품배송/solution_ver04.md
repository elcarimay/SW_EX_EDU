```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
/*
12_EX물품배송_user_user_ver04

[해법 연구4]
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
4. [해법 연구1]의 고찰을 적용.
   아래와 같은 경우 (4)번 배송지 물품을 제외하고 (1), (2), (3)들만 함께 배송하고
   빈차로 center로 돌아온 후에 (4)번을 배송하는 것이 더 좋다.

	예) (4) -- 10 -- [center] -- 10 -- (1)  ---- 20 ---- (2) ------- 30 ------ (3)

	[load cost]
		{10 * ( 100 + 4 * 10)} + {20 * ( 100 + 3 * 10)} + {30 * ( 100 + 2 * 10)} + {70 * ( 100 + 1 * 10)}
		= 1400 + 2600 + 3600 + 7700 = 15300

		[unload cost]
		{10 * ( 100 + 3 * 10)} + {20 * ( 100 + 2 * 10)} + {30 * ( 100 + 1 * 10)} + 60* 100 + {10 * ( 100 + 1 * 10)}
		= 1300 + 2400 + 3300 + 6000 + 1100 = 14100

5. [해법 연구2]의 고찰을 적용
	맵의 중심으로부터 각 배송지까지 맨해튼 거리가 먼 배송지를 우선하여 센터를 배정한다.

6. 배송지 우선순위를 거리제곱의합 + 중앙으로부터의 거리로 산정한 경우이다.
	아래와 같이 약간의 점수를 개선할 수 있다.


	TH = 20,  SCORE:  9'112'919'700 => 8'998'401'380
	TH = 30,  SCORE:  9'003'347'400 => 8'874'145'960 = > 8'838'416'620

	PASS

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
//////////////////////////////////////////////////////////////////////////////

enum { LM = 1000, PLM = 10000, DLM = 1000000, TH = 30, WEI = 115 };
Coordinates *centerPos, *deliPos, truckPos;
int*deliProds;                                  // 배송지별 물품 아이디

int prodCenterCnt[PLM][LM];                     // 물품별 센터멸 물품수
int prodCids[PLM][LM], pclen[PLM];              // 물품별 센터 목록, 물픔별 센터 목록 길이 ##### 추가한 항목 #####
int centerDeli[LM][PLM], centerDeliLen[LM];     // 센터별 배송지 목록
int truckDeli[50], truckProd[50], truckProdLen; // 트럭의 배송지 목록, 물품 목록, 목록 길이

////// ver03에서 추가한 부분  //////////////////////////////////
Coordinates base = { 500, 499 };
struct Data {
	int id, prior;
	bool operator<(const Data&t) {
		return prior > t.prior;
	}
}drr[DLM], trr[DLM];

void mergeSort(Data*arr, int s, int e) { // [s, e)
	if (s + 1 >= e) return;
	int m = (s + e) / 2, i = s, j = m, k = s;
	mergeSort(arr, s, m), mergeSort(arr, m, e);
	while (i < m && j < e) {
		if (arr[j] < arr[i]) trr[k++] = arr[j++];
		else trr[k++] = arr[i++];
	}
	while (i < m) trr[k++] = arr[i++];
	while (j < e)trr[k++] = arr[j++];
	for (i = s; i < e; ++i) arr[i] = trr[i];
}
/////////////////////////////////////////////////////////////////

// N:센터수, M: 물품종류, 센터 좌표 목록, 센터별 물품정보 목록, 센터별 물품정보목록 길이
void sendCenterList(int N, int M, Coordinates centerCoordinatesList[], Product centerProductList[][100], int centerProductSize[])
{
	centerPos = centerCoordinatesList;             // 센터별 위치정보
	for (int i = 0; i < LM; ++i) {                 // 각 센터별
		for (int j = 0; j < centerProductSize[i]; ++j) { // 물품 목록을 순회하며 재고파악하기
			auto&prod = centerProductList[i][j];
			if (prodCenterCnt[prod.id][i] == 0)    // prod.id물품 목록에 i센터가 처음 등장한 경우
				prodCids[prod.id][pclen[prod.id]++] = i; // 물품별 센터아이디 목록에 i센터 추가
			prodCenterCnt[prod.id][i] += prod.count;// 센터별 물품별 물품수 업데이트
		}
	}
}

void sendDeliveryList(int K, Coordinates deliveryCoordinatesList[], int deliveryProductList[])
{
	deliPos = deliveryCoordinatesList;    // 배송지별 위치
	deliProds = deliveryProductList;      // 배송지별 물품 아이디

	////// ver04에서 변경한 부분  //////////////////////////////////
	for (int i = 0; i < K; ++i) {
		int prior = 0, pid = deliProds[i];
		for (int j = 0; j < pclen[pid]; ++j) {
			int dist = deliPos[i] - centerPos[prodCids[pid][j]]; // 각 센터까지 맨해튼 거리
			prior += dist * dist;      // diff보다 강조하기 위하여 제곱의 합으로 계산
		}
		int diff = base - deliPos[i];  // 맵의 중앙으로부터 맨해튼 거리
		drr[i] = { i, prior + diff };
	}
	mergeSort(drr, 0, K);
	////////////////////////////////////////////////////////////////

	// 배송지를 센터에 할당하기 : 주어진 순서대로 배송지를 순회
	for (int i = 0; i < K; ++i) {         // 1백만
		int deliID = drr[i].id;               // ##### ver03 추가
		int pid = deliveryProductList[deliID]; // 배송지가 받고자 하는 물품 아이디
		int cid = -1, minDist = 2000;
		for (int j = 0; j < pclen[pid]; ++j) {
			int tid = prodCids[pid][j];
			if (prodCenterCnt[pid][tid] == 0) continue;  // pid물품이 없는 센터는 제외하고
			int dist = deliPos[deliID] - centerPos[tid]; // deliID배송지와 j센터 사이 거리 구하기 ##### 
			if (dist < minDist)
				cid = tid, minDist = dist;
		}

		centerDeli[cid][centerDeliLen[cid]++] = deliID; // deliID배송지를 cid센터에 배정  ##### 
		prodCenterCnt[pid][cid]--;                      // cid센터의 pid 재고수 감소
	}
}

int getNearestCenter() {  // 트럭의 현재 위치로부터 배송할 물품이 남은 가장 가까운 센터 고르기        
	int cid = -1, minDist = 2000;
	for (int i = 0; i < LM; ++i) {
		if (centerDeliLen[i] == 0)
			continue;                        // 배송할 물품이 없는 센터는 제외
		int dist = truckPos - centerPos[i];  // 거리구하기
		if (dist < minDist)
			cid = i, minDist = dist;
	}
	return cid;
}

void myTruckLoading(int cid) { // 1개씩 운송한다면 우선순위에 큰 의미가 없다. 어차피 모두 운송할 예정이므로
	int&clen = centerDeliLen[cid];
	int minLen = Min(clen, TH);
	int distSum = 0;
	truckProdLen = 0;
	for (int i = 0; i < minLen && clen; ++i) {
		int did = -1, minDist = 2000, k = -1;
		for (int j = 0; j < clen; ++j) {
			int tid = centerDeli[cid][j];
			int tDist = truckPos - deliPos[tid];
			if (tDist < minDist)
				did = tid, minDist = tDist, k = j;         // 트럭의 현재위치로부터 가장 가까운 배송지 업데이트
		}
		if (i > 0) {
			//int loadCost = distSum * 10 + minDist * 110;  // 엄밀한 계산  => 점수가 오히려 좋지 않다.
			int loadCost = distSum * WEI + minDist * 110;   // 가중치를 휴리스틱하게 한 계산 => 다른 센터를 선택할 확률을 높여준다.
			int unloadCost = (deliPos[truckDeli[i - 1]] - centerPos[cid]) * 100 + (centerPos[cid] - deliPos[did]) * 110;
			if (loadCost > unloadCost)
				break;
		}
		distSum += minDist;

		truckDeli[i] = did, truckProd[i] = deliProds[did]; // 아바타 트럭에 적재하기
		truckProdLen++;
		truckPos = deliPos[did];                           // 아바타 트럭 이동

		// 마지막 배송지를 현재위치에 복사하고 개수를 줄이는 것으로 현재 배송지를 삭제
		centerDeli[cid][k] = centerDeli[cid][--clen];
	}
}

void solve(Coordinates truckCoordinates)
{
	truckPos = truckCoordinates;  // 트럭의 초기위치
	for (int i = 0; i < DLM; ++i) {  // 1백만
		int cid = getNearestCenter(); // 배송할 물품이 있는 가장 가까운 센터 찾기 : 1000
		if (cid < 0)                  // 센터를 찾을 수 없는 경우 => 모든 배송이 완료됨
			break;
		truckPos = centerPos[cid];    // 아바타 트럭을 센터로 이동

		myTruckLoading(cid);          // 아바타 트럭에 적재
		truckLoading(cid, truckProd, truckProdLen); // 메인의 트럭에 적재

		for (int i = 0; i < truckProdLen; ++i) {
			int did = truckDeli[i];   // 배송지 아이디
			truckMove(did);           // 메인의 배송지에 배송
		}
	}
}

```
