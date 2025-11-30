```cpp
/*
47_EX우주선착륙_user_ver03


[해결 전략 3]
* [해결전략 2]에서 그룹의 수가 작은 것부터 처리하기
				   <ver01>    <ver02>    <ver03>
seed :   5  SCORE: 3001673(최적해)
seed :  32  SCORE: 3011024 => 3011261 => 3011679
seed : 176  SCORE: 3022040 => 3022226 => 3022447
PASS



*/
enum { LM = 1000, SLM = 10000 };

#define Min(x, y) (((x) < (y)) ? (x) : (y))
#define Max(x, y) (((x) > (y)) ? (x) : (y))

struct Spaceship {
	int height;
	int width;
};
/////////////////////////////////////////////////////////////
int hwShipIDs[6][6][SLM], hwLen[6][6];  // 우주선의 [세로길이별][가로길이별] 아이디목록과 길이
int used[LM][LM];  // 착륙지를 선택할 수 있는지 여부를 판단하는 용도
int Map[LM][LM];
struct Land {
	int sr, sc, er, ec, h, w, score;
	void init(int nsr, int nsc, int ner, int nec) {
		sr = nsr, sc = nsc, er = ner, ec = nec;
		h = er - sr + 1, w = ec - sc + 1;
		score = h * w * Min(h, w);
	}
}lands[SLM];
int G[SLM + 5], visited[LM][LM], landCnt;
int groups[SLM][100], gcnt[SLM];

int Find(int r) {
	if (G[r] == r) return r;
	return G[r] = Find(G[r]);
}

void Union(int sr, int sc, int er, int ec) {
	for (int i = sr; i <= er; ++i) {
		for (int j = sc; j <= ec; ++j) {
			if (visited[i][j]) {
				int aid = Find(landCnt), bid = Find(visited[i][j]);
				if (aid == bid) continue;
				if (aid < bid) G[bid] = aid;
				else G[aid] = bid;
			}
			visited[i][j] = Find(landCnt);
		}
	}
}

void myInit() {
	landCnt = 0;
	for (int i = 0; i < SLM; ++i) G[i] = gcnt[i] = 0;
	for (int i = 0; i < LM; ++i) {
		for (int j = 0; j < LM; ++j) visited[i][j] = 0;
	}
	for (int i = 2; i < 6; ++i) {
		for (int j = 2; j <= 6; ++j) hwLen[i][j] = 0;
	}
}

void init(int mMap[][LM], struct Spaceship spaceships[]) {
	for (int i = 0; i < LM; ++i) for (int j = 0; j < LM; ++j) Map[i][j] = mMap[i][j];
	myInit();
	for (int i = 0; i < SLM; ++i) {
		int h = spaceships[i].height, w = spaceships[i].width;
		hwShipIDs[h][w][hwLen[h][w]++] = i;
	}

	// 착륙지를 그룹핑하기
	for (int sr = 0; sr <= LM - 2; ++sr) {
		for (int sc = 0; sc <= LM - 2; ++sc) {
			for (int er = sr + 1; er < LM && er < sr + 5; ++er) {
				int aminH = Min(Map[sr][sc], Map[er][sc]);
				int amaxH = Max(Map[sr][sc], Map[er][sc]);
				if (amaxH - aminH > 6) continue;
				for (int ec = sc + 1; ec < LM && ec < sc + 5; ++ec) {
					int minH = Min(aminH, Min(Map[sr][ec], Map[er][ec]));
					int maxH = Max(amaxH, Max(Map[sr][ec], Map[er][ec]));
					if (maxH - minH > 6) continue;
					lands[++landCnt].init(sr, sc, er, ec);
					G[landCnt] = landCnt;
					Union(sr, sc, er, ec);
				}
			}
		}
	}
}

bool isAble(Land&t) {
	for (int i = t.sr; i <= t.er; ++i) {
		for (int j = t.sc; j <= t.ec; ++j) {
			if (used[i][j]) return 0;
		}
	}
	return 1;
}

void marking(Land&t, int w) {
	for (int i = t.sr; i <= t.er; ++i) {
		for (int j = t.sc; j <= t.ec; ++j) {
			used[i][j] = w;
		}
	}
}

int maxScore, maxBit;
int *grr, len;

void dfs(int step, int scoreSum, int bit) {
	if (step >= len) {
		if (scoreSum > maxScore) {
			maxBit = bit;
			maxScore = scoreSum;
		}
		return;
	}

	int landID = grr[step];
	int h = lands[landID].h, w = lands[landID].w;
	// 0. landID를 사용하지 않는 경우
	dfs(step + 1, scoreSum, bit);
	// 1. landID를 사용하는 경우
	if (isAble(lands[landID]) && (hwLen[h][w] || hwLen[w][h])) {
		marking(lands[landID], 1);
		dfs(step + 1, scoreSum + lands[landID].score, bit | (1 << step));
		marking(lands[landID], 0);
	}
}

void process(int rows[], int cols[], int dirs[]) {
	// 루트별로 착륙지 아이디를 모은다.
	int maxCnt = 0;
	for (int i = 1; i <= landCnt; ++i) {
		int rid = Find(i);
		groups[rid][gcnt[rid]++] = i;
		if (maxCnt < gcnt[rid]) maxCnt = gcnt[rid];
	}

	// 각 착륙지 그룹의 루트에서 최적조합을 찾고 
	// 최적조합에 필요한 우주선을 초빙하기

	for (int c = 1; c <= maxCnt; ++c) {     // #####
		for (int i = 1; i <= landCnt; ++i) {
			if (G[i] != i) continue;    // 각 그룹의 루트가 아니라면 제외
			if (gcnt[i] != c) continue; // 그룹의 크기가 c인 경우 아래 코드를 실행
			maxScore = maxBit = 0;
			grr = groups[i], len = gcnt[i];
			dfs(0, 0, 0);  // step, scoreSum

			// 최적 조합에 우주선을 초빙하기
			for (int j = 0; j < len; ++j) {
				if (((maxBit >> j) & 1) == 0) continue;
				int landID = grr[j];
				int h = lands[landID].h, w = lands[landID].w;
				int sign = 0;

				// implement here ///////////////////////////////////
				int sr = lands[landID].sr, sc = lands[landID].sc;
				if (hwLen[h][w]) {
					int sid = hwShipIDs[h][w][--hwLen[h][w]];
					rows[sid] = sr, cols[sid] = sc, dirs[sid] = 0;
					sign = 1;
				}
				if (sign == 0 && h != w && hwLen[w][h]) {
					int sid = hwShipIDs[w][h][--hwLen[w][h]];
					rows[sid] = sr, cols[sid] = sc, dirs[sid] = 1;
				}
				/////////////////////////////////////////////////////
			}
		}
	}
}
```
