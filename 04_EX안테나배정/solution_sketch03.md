```cpp
/*
30_EX안테나배정_user_sketchCode03_code

[sketchCode03 전략]
1. 단말기에 우선순위를 두어 안테나를 배정하기
   (1) 각 단말기별로 모든 안테나까지 거리를 구하고
   안테나들을 거리의 오름차순으로 정렬한다.
   (2) 단말기 아이디를 단말기와 가장 가까운 안테나 까지 거리의 오름차순으로 정렬한다.
   (3) 가장 가까운 안테나까지 거리가 가장 먼 단말기를 우선으로 안테나를 배정한다.
	   이렇게 하는 경우 아래 예에서 최적해를 얻을 수 있다.
	   예) ant1.......................ue1...ant2...............ue2
   (4) 그런데 위 예제의 경우 아래와 같은 예제에서 반례를 발생시킨다.
	   예) ue1...ant2...............ue2.............................ant1
	   이를 보완 하기 위하여 각 단말기별  prior 를
	   각 단말기별 가장 가까운 안테나 TH개의 거리제곱의 합으로 정의한다.      #####  sketchCode 02 전략을 보완. #####

2. 단말기별로 가장 가까운 안테나에 배정하기
3. 안테나 수용한계를 생각하여 배정하기
4. 유효 안테나를 대상으로
   안테나별 range는 가장 먼 단말기까지 거리 + 4로 러프하게 정하기


SCORE : 3'096'240(custom_mergeSort)
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
enum { LM = 100, ALM = 150, ULM = 10000, TH = 10 };
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
	int m = (s + e) / 2, i = s, j = m, k = s;
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

	
	// 각 단말기는 모든 안테나까지 거리를 구하고 거리의 오름차순으로 정렬한다.
	for (int i = 0; i < ULM; ++i) {
		for (int j = 0; j < ALM; ++j) {
			tab[i][j] = { j, urr[i] - arr[j] };
		}
		mergeSort(tab[i], 0, ALM);  // std::sort

		// sketchCode03 ///////////////////////////////////////////
		// i단말기로부터 가장 가까운 TH개 안테나까지 거리합을 우선순위로
		int prior = 0;
		for (int j = 0; j < TH; ++j) prior += tab[i][j].cost * tab[i][j].cost;
		UE[i] = {i, prior};
		///////////////////////////////////////////////////////////
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

	for (int i = 0; i < ALM; ++i) {
		if (antUeCnt[i])      // 가동이 필요한 안테나만을 대상으로
			range[i] += 4;   // UE의 이동방향을 모르므로 안테나 가동범위를 일괄적으로 +4 크게 적용
	}
}
```
