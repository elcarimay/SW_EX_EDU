```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
/*
30_EX안테나배정_user_ver03

[해결 전략 3]
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

5. [해법 연구1]의 고찰을 반영
   단말기가 안테나를 선택할 때, 수용공간이 남아 있는 안테나가 여럿인 경우
   가능하면 안테나의 최대 범위를 확대하지 않는 안테나를 선택하는 것이다.
   예를 들어 ant1과 ant2모두 수용공간이 남아 있는데
   ant1의 range는 10인 상황에서 ant1까지 거리가 12이고,
   ant2의 range는 20인 상황에서 ant2까지 거리가 19라면
   단말기가 ant2를 선택하도록 하는 것이다.

6. [해법 연구2]의 고찰을 반영한 버전이다.       ##### 해법연구2를 보완 #####
   range를 확장시키지 않는 안테나가 여러개라면 여분의 공간이 많이 남아 있는 안테나를 선택한다.

SEED: 5   SCORE: 2'050'331 => 1'814'342 => 1'758'474
PASS
*/
#define ABS(x) (((x)<0)?(-(x)):(x))
#define Max(a, b) ((a)>(b)? (a):(b))
#define Min(a, b) ((a)<(b)? (a):(b))

enum { ALM = 150, ULM = 10000, TH = 10 };

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
		return ABS(y - param.y) + ABS(x - param.x);
	}
}*arr, urr[ULM];

struct Data {
	int id, prior;
	bool operator<(const Data&t)const {
		return prior < t.prior;
	}
}tab[ULM][ALM], U[ULM], trr[ULM];

int ueCnt[ALM];  // 안테나별 할당받은 단말기수
int subTC;
int dir[ULM];    // 단말기별 방향
int dr[5] = { 1, 0, -1, 0, 0 }, dc[5] = { 0, 1, 0, -1, 0 };

void mergeSort(Data*arr, int s, int e) { // [s, e)
	// 1. base condition
	if (s + 1 >= e) return;
	// 2. divide & conquer
	int m = (s + e) / 2, i = s, j = m, k = s;
	mergeSort(arr, s, m), mergeSort(arr, m, e);
	// 3. merge
	while (i < m && j < e) {
		if (arr[j] < arr[i]) trr[k++] = arr[j++];
		else trr[k++] = arr[i++];
	}
	while (i < m) trr[k++] = arr[i++];
	while (j < e) trr[k++] = arr[j++];
	// 4. copy
	for (i = s; i < e; ++i) arr[i] = trr[i];
}

void init(Coordinates antennas[]) {
	arr = antennas;
	subTC = 0;
}

void process1(int*range, int*connect) {
	// 각 단말기별 모든 안테나까지 거리구하고 거리의 오름차순으로 안테나를 정렬하기
	for (int i = 0; i < ULM; ++i) {
		for (int j = 0; j < ALM; ++j) {
			tab[i][j] = { j, urr[i] - arr[j] }; // i단말기로부터 j안테나까지 거리구하여 저장
		}
		mergeSort(tab[i], 0, ALM);
		int prior = 0;
		for (int j = 0; j < TH; ++j) {
			prior += tab[i][j].prior * tab[i][j].prior;  // +=  !!!!!!
		}
		U[i] = { i, prior };
	}

	// 단말기를 단말기별 가장 가까운 안테나까지 거리의 오름차순으로 정렬하기
	mergeSort(U, 0, ULM);

	// 가장 가까운 안테나까지 거리가 가장 먼 단말기를 우선하여 안테나를 배정하기
	for (int i = ULM - 1; i >= 0; --i) {
		int uid = U[i].id;  // 단말기 아이디 얻기
		int aid = -1, minDist = 200;
		for (int j = 0; j < ALM; ++j) {
			int tid = tab[uid][j].id;  // 검증할 안테나 아이디
			int tdist = tab[uid][j].prior;
			if (ueCnt[tid] >= 100) continue;
			if (aid < 0) {  // 여분의 공간이 있는 tid가 처음 등장한 경우
				aid = tid, minDist = tab[uid][j].prior;
			}
			else if (tdist <= range[tid]) {  // uid단말기가 tid안테나의 가동범위를 확대하지 않는 경우
				if (minDist <= range[aid]) { // 이미 선택한 안테나 aid도 가동범위를 확대하지 않는 경우
					if (ueCnt[tid] < ueCnt[aid]) {   // 여분의 공간이 tid안테나가 더 많다면 
						minDist = tab[uid][j].prior; // tid를 선택하기
						aid = tid;
					}
				}
				else {                       // 기존에 선택한 안테나 aid는 uid가 가동범위를 확대하는 경우
					minDist = tab[uid][j].prior;
					aid = tid;
				}
			}
		}
		ueCnt[aid] ++;
		range[aid] = Max(minDist, range[aid]);
		connect[uid] = aid;
	}

	for (int i = 0; i < ALM; ++i) {
		if (ueCnt[i] == 0) continue;
		range[i] += 4;
	}
}

void findDir(int uid, Coordinates&past, Coordinates&cur) {
	int dist = past - cur;
	dir[uid] = 4;
	if (dist == 0) return; // uid 단말기의 방향이 없는 경우
	if (dist == 5) {       // 방향이 바뀌지 않은 경우
		if (past.y == cur.y) {
			if (past.x < cur.x) dir[uid] = 1;
			else dir[uid] = 3;
		}
		else {
			if (past.y < cur.y) dir[uid] = 0;
			else dir[uid] = 2;
		}
	}
	else {                  // 방향이 바뀐 경우
		if (past.y == cur.y) {
			if (cur.x < 5) dir[uid] = 1;
			else dir[uid] = 3;
		}
		else {
			if (cur.y < 5) dir[uid] = 0;
			else dir[uid] = 2;
		}
	}
}

void scanUE(Coordinates UE_list[], int antenna_range[], int antenna_UE_connection[]) {
	subTC++;
	int*range = antenna_range;
	int*connect = antenna_UE_connection;
	for (int i = 0; i < ALM; ++i) range[i] = ueCnt[i] = 0;

	if (subTC == 1) {
		// subTC : 2에서 방향을 알아내야 하므로 복사하여 사용한다.
		for (int i = 0; i < ULM; ++i) urr[i] = UE_list[i];
		process1(range, connect);
		return;
	}

	if (subTC == 2) {
		for (int i = 0; i < ULM; ++i) {
			findDir(i, urr[i], UE_list[i]);
		}
	}

	// implement here
	// 이동하는 유닛의 이동을 고려하여 안테나를 선택하기

	for (int i = 0; i < ULM; ++i) urr[i] = UE_list[i];  // 단말기 위치 업데이트

	////// process2 //////////////////////////////////////
	for (int i = 0; i < ULM; ++i) {
		if (dir[i] > 3) continue;         // 방향이 없는 경우는 제외 : 80%
		Coordinates crr[6] = { urr[i], }; // 5번 이동한 거리를 저장, 5번째 이동은 사용하지 않지만 5번째에서 방향이 전환될 수 있다.
		for (int j = 1; j < 6; ++j) {
			int ny = crr[j - 1].y + dr[dir[i]], nx = crr[j - 1].x + dc[dir[i]];
			if (ny < 0 || ny > 99 || nx < 0 || nx > 99) {
				dir[i] ^= 2;  // 180도 회전, dir[i] = (dir[i] + 2) % 4와 같은 의미이다.
			}
			crr[j] = { crr[j - 1].y + dr[dir[i]], crr[j - 1].x + dc[dir[i]] };
		}

		for (int j = 0; j < ALM; ++j) {
			int maxDist = 0;
			for (int k = 0; k < 5; ++k) // 0~4번까지 이동을 고려하여 가장 먼 거리를 j 안테나와의 거리로 정한다.
				maxDist = Max(maxDist, crr[k] - arr[j]);
			tab[i][j] = { j, maxDist };
		}
		mergeSort(tab[i], 0, ALM);
	}
	//////////////////////////////////////////////////////

	for (int i = 0; i < ULM; ++i) {
		int prior = 0;
		for (int j = 0; j < TH; ++j)
			prior += tab[i][j].prior * tab[i][j].prior;
		U[i] = { i, prior };
	}
	mergeSort(U, 0, ULM);

	for (int i = ULM - 1; i >= 0; --i) {
		int uid = U[i].id;  // 단말기 아이디 얻기
		int aid = -1, minDist = 200;
		for (int j = 0; j < ALM; ++j) {
			int tid = tab[uid][j].id;  // 검증할 안테나 아이디
			int tdist = tab[uid][j].prior;
			if (ueCnt[tid] >= 100) continue;
			if (aid < 0) {
				minDist = tab[uid][j].prior;
				aid = tid;
			}
			else if (tdist <= range[tid]) {
				if (minDist <= range[aid]) {
					if (ueCnt[tid] < ueCnt[aid]) {
						minDist = tab[uid][j].prior;
						aid = tid;
					}
				}
				else {
					minDist = tab[uid][j].prior;
					aid = tid;
				}
			}
		}

		ueCnt[aid] ++;
		range[aid] = Max(minDist, range[aid]);
		connect[uid] = aid;
	}
}

```
