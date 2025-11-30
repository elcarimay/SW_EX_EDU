```cpp
/*
47_EX우주선착륙_user_sketchCode

[sketchCode]
: 점수가 높은 우주선이 착륙지를 선택하는 전략
  가능한 높은 점수를 얻는것이 목적이므로 다음과 같은 전략을 생각할 수 있다.
1. 우주선에 점수( h*w*min(h, w))를 부여하고 점수의 내림차순으로 정렬한다.
2. 우주선이 착륙가능한 지역을 찾아 크기별로 분류하여 저장한다.
3. 점수가 높은 우주선을 우선으로 착륙지를 배정한다.

landCnt : 8574, landedShipCnt : 7141
landCnt : 8764, landedShipCnt : 7174
landCnt : 8667, landedShipCnt : 7110
landCnt : 8814, landedShipCnt : 7224
landCnt : 8549, landedShipCnt : 7026
landCnt : 8594, landedShipCnt : 7048
landCnt : 8620, landedShipCnt : 7093
landCnt : 8727, landedShipCnt : 7141
landCnt : 8669, landedShipCnt : 7067
landCnt : 8674, landedShipCnt : 7094
SCORE: 2993947
FAIL
RunTime : 982
*/
#include <bits/stdc++.h>
using namespace std;

enum { LM = 1000, SLM = 10000 };

#define Min(x, y) (((x) < (y)) ? (x) : (y))
#define Max(x, y) (((x) > (y)) ? (x) : (y))

struct Spaceship {
	int height;
	int width;
};
///////////////////////////////////////////////////////////
int(*Map)[LM];

struct Land {
	int sr, sc;
}hwLand[6][6][SLM]; // 착륙지 [높이별][너비별] 상좌단위치 목록
int hwLen[6][6];
int land[LM][LM];   // 우주선이 착륙한 경우 표시
int landCnt;

struct Ship {
	int score, h, w, id;
	void init(int nid, int nh, int nw) {
		id = nid, h = nh, w = nw;
		score = h * w * Min(h, w);
	}
	bool operator<(const Ship&t)const {
		return score > t.score;  // desc정렬을 위하여
	}
}ships[SLM], trr[SLM];

void mergeSort(Ship*arr, int s, int e) {  // [s, e) :반개구간
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

void init() {
	landCnt = 0;
	for (int i = 0; i < LM; ++i) {
		for (int j = 0; j < LM; ++j) land[i][j] = 0;
	}
	for (int i = 2; i < 6; ++i) {
		for (int j = 2; j < 6; ++j) hwLen[i][j] = 0;
	}
}

void drawLand(int sr, int sc, int er, int ec) {
	for (int i = sr; i <= er; ++i) {
		for (int j = sc; j <= ec; ++j) land[i][j] ++;
	}
}

int isAble(int sr, int sc, int er, int ec) {
	for (int i = sr; i <= er; ++i) {
		for (int j = sc; j <= ec; ++j)
			if (land[i][j]) return 0;
	}
	return 1;
}

void init(int mMap[][LM], struct Spaceship spaceships[]) {
	Map = mMap;
	init();
	// 착류가능한 지역을 찾아 표시하기
	for (int sr = 0; sr <= LM - 2; ++sr) {                          // 착륙지 상좌단 후보 좌표
		for (int sc = 0; sc <= LM - 2; ++sc) {
			for (int er = sr + 1; er < LM && er < sr + 5; ++er) {   // 착륙지 하우단 후보 좌표
				int aminH = Min(Map[sr][sc], Map[er][sc]);
				int amaxH = Max(Map[sr][sc], Map[er][sc]);
				if (amaxH - aminH > 6)
					continue;
				for (int ec = sc + 1; ec < LM && ec < sc + 5; ++ec) {
					int minH = Min(aminH, Min(Map[sr][ec], Map[er][ec]));
					int maxH = Max(amaxH, Max(Map[sr][ec], Map[er][ec]));
					if (maxH - minH > 6) continue;
					// 착륙후보지를 찾은 경우 [높이별][너비별]목록에 추가
					int h = er - sr + 1, w = ec - sc + 1;
					hwLand[h][w][hwLen[h][w]++] = { sr, sc };
					landCnt++;
				}
			}
		}
	}

	// 우주선 처리
	for (int i = 0; i < SLM; ++i) 
		ships[i].init(i, spaceships[i].height, spaceships[i].width);

	mergeSort(ships, 0, SLM);
}

void process(int rows[], int cols[], int dirs[]) {
	// 점수가 높은 우주선부터 착륙지를 선택하기
	int landedShipCnt = 0;
	for (int i = 0; i < SLM; ++i) {
		int sid = ships[i].id, h = ships[i].h, w = ships[i].w;
		// implemet here
		if (hwLen[h][w]) {                           // 회전하지 않기
			Land*hw = hwLand[h][w];
			int&len = hwLen[h][w];
			for (--len; len>=0; --len) {
				int sr = hw[len].sr, sc = hw[len].sc;
				int er = sr + h - 1, ec = sc + w - 1;
				if (isAble(sr, sc, er, ec)) {
					rows[sid] = sr, cols[sid] = sc, dirs[sid] = 0;
					drawLand(sr, sc, er, ec);
					landedShipCnt++;
					break;
				}
			}
		}
		if (rows[sid] < 0 && h != w && hwLen[w][h]) { // 회전하지 않고는 착륙하지 못한경우 회전하여 착륙을 시도하기
			Land*wh = hwLand[w][h];
			int&len = hwLen[w][h];
			for (--len; len>=0; --len) {
				int sr = wh[len].sr, sc = wh[len].sc;
				int er = sr + w - 1, ec = sc + h - 1;
				if (isAble(sr, sc, er, ec)) {
					rows[sid] = sr, cols[sid] = sc, dirs[sid] = 1;
					drawLand(sr, sc, er, ec);
					landedShipCnt++;
					break;
				}
			}
		}
	}

	printf("landCnt : %d, landedShipCnt : %d\n", landCnt, landedShipCnt);
}
```
