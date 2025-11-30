```cpp
/*
30_EX안테나배정_user_ver02_code

[해결 전략 2]
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
	   각 단말기별 가장 가까운 안테나 TH개의 거리제곱의 합으로 정의한다.

2. 단말기별로 가장 가까운 안테나에 배정하기
3. 안테나 수용한계를 생각하여 배정하기

4. 스케치 코드에서는 단말기가 4번 이동하는 동안 안테나의 가동범위를 벗어날 수 있으므로
   모든 안테나의 가동범위를 일괄적으로 +4만큼 증가시킨값으로 처리했다.

   그런데 다음과 같은 방법으로 처리한다면 안테나 가동범위를 조금더 세밀하게 설정할 수 있다.      #####  sketchCode 전략을 보완. #####
   (1) 첫번째 부분문제는 스케치코드4와 같이 실행한다.
   (2) 두번째 부분문제에서 각 단말기의 방향을 구한다.
	   방향이 있는 단말기는 반드시 첫번째 위치와 두번째 위치가 다르기 때문에 방향을 구할 수 있다.
	   이제 각 단말기의 방향을 이용하여 두번째 ~ 10번째 부분문제에서는
	   이동하는 단말기의 이동한 결과를 이용하여 각 안테나까지 거리를 계산한다.
	   이동하는 단말기와 안테나 사이의 거리는 가장 먼거리로 정하면 된다.
	   메인에서 안테나와 단말기 사이 거리를 이렇게 계산하기 때문이다.
	   이를 이용하여 부분 문제1과 같은 방법으로 단말기의 우선순위를 정하고
	   우선순위 높은 단말기부터 안테나를 선택한다.

	   두번째 ~ 10번째 부분문제에서는 모든 안테나에 일괄적으로 +4 하는 일을 하지 않으므로 약 100만여 점을 절약하게 된다.

5. [해법 연구1]의 고찰을 반영한 버전이다.    ##### 해법연구1을 보완 #####
   단말기가 안테나를 선택할 때, 수용공간이 남아 있는 안테나가 여럿인 경우
   가능하면 안테나의 최대 가동 범위를 확대하지 않는 안테나를 선택하는 것이다.
   예를 들어 ant1과 ant2모두 수용공간이 남아 있는데
   ant1의 range는 10인 상황에서 ant1까지 거리가 12이고,
   ant2의 range는 20인 상황에서 ant2까지 거리가 19라면
   단말기가 ant2를 선택하도록 하는 것이다.

[고찰]
   range를 확장시키지 않는 안테나가 여러개라면 어떤 안테나를 선택하는 것이 더 좋을까?

SEED: 5   SCORE: 2'050'331 => 1'814'342
PASS
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
Coordinates *arr, urr[ULM];  // 1st_subTC결과가 백업되어 있어야 2nd 단말기 위치로 방향을 복원할 수 있다.
int*range, *connect;
int antUeCnt[ALM];      // 안테나별 할당된 유닛수
int subTC;
int dir[ULM];
int dy[5] = { 1, 0, -1, 0, 0 }, dx[5] = { 0, 1, 0, -1, 0 };

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
	subTC = 0;
	arr = antennas;
}

void process1() {
	// 각 단말기는 모든 안테나까지 거리를 구하고 거리의 오름차순으로 정렬한다.
	for (int i = 0; i < ULM; ++i) {
		for (int j = 0; j < ALM; ++j) {
			tab[i][j] = { j, urr[i] - arr[j] };
		}
		mergeSort(tab[i], 0, ALM);
		// i단말기로부터 가장 가까운 TH개 안테나까지 거리합을 우선순위로
		int prior = 0;
		for (int j = 0; j < TH; ++j) prior += tab[i][j].cost * tab[i][j].cost;
		UE[i] = { i, prior };
	}
	mergeSort(UE, 0, ULM);

	// 가장 가까운 안테나까지 거리가 가장 먼 단말기부터 안테나를 선택하기
	for (int i = ULM - 1; i >= 0; --i) {
		int uid = UE[i].id, aid = -1, minDist = 200;
		for (int j = 0; j < ALM; ++j) {
			int tid = tab[uid][j].id, tdist = tab[uid][j].cost;
			if (antUeCnt[tid] >= 100) continue; // tid안테나의 수용여력이 없다면 제외
			if (range[tid] >= tdist) {
				aid = tid, minDist = tdist;
				break;
			}
			if (tdist < minDist)
				aid = tid, minDist = tdist;
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

int findDir(Coordinates&past, Coordinates&cur) {
	int dist = past - cur;
	if (dist == 0) return 4;  // 방향이 없는 경우
	if (dist == 5) {  // 방향전환이 없는 경우
		if (past.x == cur.x) { // 수직이동
			if (past.y < cur.y) return 0;
			return 2;
		}
		else {
			if (past.x < cur.x) return 1;
			return 3;
		}
	}
	else {  // 방향이 전환된 경우
		if (past.x == cur.x) { // 수직이동
			if (cur.y < 5) return 0;
			return 2;
		}
		else {
			if (cur.x < 5) return 1;
			return 3;
		}
	}
	return 4;  // 함수 형직을 맞추기 위한 반환 값
}

void scanUE(Coordinates UE_list[], int antenna_range[], int antenna_UE_connection[]) {
	// user init
	subTC++;
	range = antenna_range, connect = antenna_UE_connection;
	for (int i = 0; i < ALM; ++i) range[i] = antUeCnt[i] = 0;

	if (subTC == 1) {
		for (int i = 0; i < ULM; ++i) urr[i] = UE_list[i]; // 단말기 정보 백업하여 사용
		process1();
		return;
	}
	if (subTC == 2) {
		for (int i = 0; i < ULM; ++i)
			dir[i] = findDir(urr[i], UE_list[i]);
	}
	// !!!!!!!!!!!!!! subTC : 2 ~ 10일때까지 모두 다 적용되어야 함.
	for (int i = 0; i < ULM; ++i) urr[i] = UE_list[i];
	// !!!!!!!!!!!!!!

	// 1. 단말기의 방향과 이동을 고려하여 안테나까지의 거리 구하기
	for (int i = 0; i < ULM; ++i) {
		if (dir[i] < 4) {     // 방향이 없는 단말기의 거리는 subTC1에서 이미 구했으므로 패스
			Coordinates crr[6] = { urr[i] }; // 0 ~ 5번 이동한 결과를 저장
			int&d = dir[i];                 // 원본수정을 위한 참조타입
			for (int j = 1; j < 6; ++j) {   // 이동시켜 보기 : 5번째 이동은 방향이 바뀔수 있으므로 실행한다.
				int ny = crr[j - 1].y + dy[d], nx = crr[j - 1].x + dx[d];
				if (ny < 0 || nx < 0 || ny >= LM || nx >= LM)
					d ^= 2; // d = (d + 2) % 4; or d = (d + 2) & 3;  180도 회전하기
				crr[j] = { crr[j - 1].y + dy[d], crr[j - 1].x + dx[d] };
			}
			for (int j = 0; j < ALM; ++j) {
				int maxDist = 0;
				for (int k = 0; k < 5; ++k) {  // 거리는 0~4번 이동한것까지만 고려하면 된다.
					maxDist = Max(maxDist, crr[k] - arr[j]);
				}
				tab[i][j] = { j, maxDist };   // 이동을 고려하여 가장 먼 거리를 j안테나와 거리로 계산한다.
			}
			mergeSort(tab[i], 0, ALM);        // 안테나를 정렬하기
		}
		int prior = 0;  // 단말기별 우선순위는 새로구해야 한다.
		for (int j = 0; j < TH; ++j) {  // 단말기 우선순위값 구하기
			prior += tab[i][j].cost * tab[i][j].cost;  // 메인의 점수 계산방식과 동일하게 적용
		}
		UE[i] = { i, prior };
	}
	mergeSort(UE, 0, ULM);              // 단말기를 정렬하기

	// implement here
	for (int i = 0; i < ULM; ++i) {
		int uid = UE[ULM - i - 1].id, aid = -1, minDist = 200;  // *****
		for (int j = 0; j < ALM; ++j) {
			int tid = tab[uid][j].id, tdist = tab[uid][j].cost;
			if (antUeCnt[tid] >= 100) continue; // tid안테나의 수용여력이 없다면 제외
			if (range[tid] >= tdist) {
				aid = tid, minDist = tdist;
				break;
			}
			if (tdist < minDist)
				aid = tid, minDist = tdist;
		}
		range[aid] = Max(range[aid], minDist);
		connect[uid] = aid;
		antUeCnt[aid] ++;
	}
}
```
