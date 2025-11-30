```cpp
/*
30_EX안테나배정_user_sketchCode01_code

[sketchCode02 전략]
1. 단말기에 우선순위를 두어 안테나를 배정하기  #####
   (1) 각 단말기별로 모든 안테나까지 거리를 구하고
	   안테나들을 거리의 오름차순으로 정렬한다.
   (2) 단말기 아이디를 단말기와 가장 가까운 안테나 까지 거리의 오름차순으로 정렬한다.
   (3) 가장 가까운 안테나 한개까지 거리가 가장 먼 단말기를 우선으로 안테나를 배정한다.
	   이렇게 하는 경우 아래 예에서 최적해를 얻을 수 있기 때문이다.

   예) 안테나 두대, 단말기 두대가 주어지고 안테나별 수용량이 1인 경우 예이다.
	   단말기 번호 순서대로 단말기가 가장 가까이에 있는 안테나를 선택하는 경우
   단말기1은 안테나2를 단말기2는 안테나1을 선택한다.

		   ant1.......................ue1...ant2...............ue2

   그러나 단말기에 우선순위를 준다면 단말기2가 먼저 선택할 수 있으므로 최적해를 구할 수 있다.
   <고찰> 반례가 있을수 있으나 일단 그리디하게 생각해 본다. !!!!

2. 단말기별로 가장 가까운 안테나에 배정하기
3. 안테나 수용한계를 생각하여 배정하기
4. 유효 안테나를 대상으로
   안테나별 range는 가장 먼 단말기까지 거리 + 4로 러프하게 정하기

SCORE : 4'117'288 (std::sort), 4'031'621(custom_mergeSort)
FAIL
*/
#define Abs(x) (((x)<0)?(-(x)):(x))
#define Max(a, b) ((a) > (b)? (a):(b))
#define Min(a, b) ((a) < (b)? (a):(b))

struct Coordinates {
	int y, x;
	Coordinates() {
		y = x = 0;
	}
	Coordinates(int _y, int _x) {
		y = _y;
		x = _x;
	}
	int operator-(Coordinates& param) {
		return Abs(y - param.y) + Abs(x - param.x);
	}
};
//////////////////////////////////////////////////////////////////////
enum { LM = 100, ALM = 150, ULM = 10000 };
Coordinates *arr, *urr;
int*range, *connect;
int antUeCnt[ALM];      // 안테나별 할당된 유닛수

struct Data {
	int id, cost; // 안테나: 거리, 단말기: 점수
	bool operator<(const Data&t)const {
		return cost < t.cost;
	}
}tab[ULM][ALM], UE[ULM], trr[ULM];

void mergeSort(Data*arr, int s, int e) { // [s, e) : 반개구간 => 다양한 구현 측면에서 보여드립니다.
	if (s + 1 >= e) return;
	int m = (s + e) / 2, i = s, j = m , k = s;
	mergeSort(arr, s, m), mergeSort(arr, m, e);
	while (i < m && j < e) {
		if (arr[j] < arr[i]) trr[k++] = arr[j++];
		else trr[k++] = arr[i++];
	}
	while (i < m) trr[k++] = arr[i++];
	while (j < e) trr[k++] = arr[j++];
	for (i = s; i < e; ++i) arr[i] = trr[i];
}

void init(Coordinates antennas[]) {
	arr = antennas;
}

void scanUE(Coordinates UE_list[], int antenna_range[], int antenna_UE_connection[]) {
	// user init
	urr = UE_list;
	range = antenna_range, connect = antenna_UE_connection;
	for (int i = 0; i < ALM; ++i) range[i] = antUeCnt[i] = 0;

	// sketchCode02 ///////////////////////////////////////////
	// 각 단말기는 모든 안테나까지 거리를 구하고 거리의 오름차순으로 정렬한다.
	for (int i = 0; i < ULM; ++i) {
		for (int j = 0; j < ALM; ++j) {
			tab[i][j] = { j, urr[i] - arr[j] };
		}
		mergeSort(tab[i], 0, ALM);  // std::sort
		UE[i] = {i, tab[i][0].cost}; // i단말기로부터 가장 가까운 안테나까지 거리
	}
	mergeSort(UE, 0, ULM);

	// 가장 가까운 안테나까지 거리가 가장 먼 단말기부터 안테나를 선택하기
	for (int i = ULM - 1; i >= 0; --i) {
		int uid = UE[i].id, aid = -1, minDist = 200;
		for (int j = 0; j < ALM; ++j) {
			int tid = tab[uid][j].id, tdist = tab[uid][j].cost;  // #####
			if (antUeCnt[tid] >= 100) continue; // tid안테나의 수용여력이 없는 경우 제외
			aid = tid, minDist = tdist;
			break;
		}
		range[aid] = Max(range[aid], minDist);
		connect[uid] = aid;
		antUeCnt[aid] ++;
	}

	///////////////////////////////////////////////////////////

	for (int i = 0; i < ALM; ++i) {
		if (antUeCnt[i])      // 가동이 필요한 안테나만을 대상으로
			range[i] += 4;   // UE의 이동방향을 모르므로 안테나 가동범위를 일괄적으로 +4 크게 적용
	}
}
```
