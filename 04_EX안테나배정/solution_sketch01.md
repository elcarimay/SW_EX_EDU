```cpp
/*
30_EX안테나배정_user_sketchCode01_code
[sketchCode01 전략]
1. 입력순으로 각 단말기가 안테나를 선택하는 전략
2. 단말기별로 가장 가까운 안테나를 선택하기
3. 안테나 수용한계를 생각하여 배정하기 : ### 제약조건을 만족하는 결과 만들기 ###
4. 유효 안테나를 대상으로                ######
   안테나별 range는 가장 먼 단말기까지 거리 + 4로 러프하게 정하기

<관찰> 어떤 UE도 할당받지 못한 안테나가 있는가? => 존재한다.

SEED : 5   SCORE: SCORE: 4808094
FAIL

*/
#include <bits/stdc++.h>
using namespace std;

#define ABS(x) (((x)<0)?(-(x)):(x))

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
};
//////////////////////////////////////////////////////////////////////
enum { LM = 100, ALM = 150, ULM = 10000 };
Coordinates *arr, *urr;
int*range, *connect;
int antUeCnt[ALM];      // 안테나별 할당된 유닛수


void init(Coordinates antennas[]) {
	arr = antennas;
}

void scanUE(Coordinates UE_list[], int antenna_range[], int antenna_UE_connection[]) {
	// user init
	urr = UE_list;
	range = antenna_range, connect = antenna_UE_connection;
	for (int i = 0; i < ALM; ++i) range[i] = antUeCnt[i] = 0;

	for (int i = 0; i < ULM; ++i) {   // 각 유닛을 대상으로 가장 가까운 안테나를 선택하기
		int aid = -1, minDist = 200;
		for (int j = 0; j < ALM; ++j) {
			if (antUeCnt[j] >= 100) continue;  // 수용한계에 도달한 안테나는 제외하고 ##### 변경된 부분 #####
			int tdist = urr[i] - arr[j];
			if (minDist > tdist)
				minDist = tdist, aid = j;
		}
		range[aid] = max(range[aid], minDist); // aid안테나의 가동범위 업데이트
		connect[i] = aid;                      // i단말기를 aid안테나에 할당하기
		antUeCnt[aid]++;                       // aid안테나에 할당된 단말기수 증가
	}

	for (int i = 0; i < ALM; ++i) {
		if (antUeCnt[i])      // 가동이 필요한 안테나만을 대상으로
			range[i] += 4;   // UE의 이동방향을 모르므로 안테나 가동범위를 일괄적으로 +4 크게 적용
	}
}
```
