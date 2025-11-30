```cpp
/*
47_EX우주선착륙_user_ver01_1

[해결 전략 1_1]
: 착륙가능한 그룹에서 얻을 수 있는 가장 좋은 조합을 찾고
  이 조합에 필요한 우주선(들)을 착륙지가 선택하는 전략
* 우주선개수 10000개에 비하여 착륙가능한 지역은 8천여개(겹치는것 포함)이다.
  실제 착륙가능한 우주선 수는 7천여개가 된다.
* 따라서 착륙지를 분석해보는 전략을 생각해 볼 수 있다.
  outputLand.txt에서 보이는 것과 같이 착륙지끼리 겹치는 구역이 상당수 있다.
  이들을 한 그룹으로 하고 그 그룹에서 가능한 최적 조합을 찾는 것이다.
  예를 들어 한 그룹에 ⓐ(2, 2), ⓑ(3, 4), ⓒ(4, 4), ⓓ(4, 3) 가 있고
  ⓐⓑⓓ는 서로 겹치지 않으나 ⓒ는 모두와 겹친다면 단독으로 볼 때, ⓒ의 점수가 64점으로 가장 좋지만
  ⓐⓑⓓ의 점수를 합치면 8+36+36=80점으로 더 좋다.
  이런 경우라면 ⓐⓑⓓ를 선택하는 전략을 생각할 수 있다.
< 문제 해결 프로세스 >
1. init()
	(1) 착륙지를 찾고 겹치는 착륙지는 그룹을 지어 그룹별로 모은다.
	(2) 우주선을 크기별 목록에 담아 놓는다.
2. process()
	착륙지 각 그룹별 최적조합(가장 높은 점수를 내는)을 찾는다.
	이때, dfs를 이용하여 비교적 어렵지 않게 찾을 수 있다.
	찾은 조합을 구성하는 착륙지에 우주선을 착륙시킨다.
	이경우 seed = 5에서 최적해를 얻을 수 있다.
	그러나 seed = 32, seed = 176 등에서는 최적해를 얻기 매우 힘들다.
	따라서 이문제 역시 NP문제로 볼 수 있다.
3. 각 그룹별 찾은 조합을 배열에 표시하기

	SEED:   5, SCORE: 3001673
	SEED:  32, SCORE: 3011024
	SEED: 176, SCORE: 3022040
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
int (*Map)[LM];
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
			if (visited[i][j]) {             // 영역이 겹치는 착륙지를 만난경우
				int aid = Find(landCnt), bid = Find(visited[i][j]); // 그룹번호 구하기
				if (aid == bid) continue;    // 이미 같은 그룹이라면 제외
				if (aid < bid) G[bid] = aid; // 더 작은 번호 그룹으로 합치기
				else G[aid] = bid;
			}
			visited[i][j] = Find(landCnt);   // 영역을 그룹번호로 채우기
		}
	}
}

void myInit() {
	landCnt = 0;
	for (int i = 0; i < SLM; ++i) G[i] = gcnt[i] = 0;   // 그룹번호, 그룹별 착륙지 수 초기화
	for (int i = 0; i < LM; ++i) {
		for (int j = 0; j < LM; ++j) visited[i][j] = 0; // 그룹합치기를 위한 배열 초기화
	}
	for (int i = 2; i < 6; ++i) {
		for (int j = 2; j <= 6; ++j) hwLen[i][j] = 0;   // 우주선의 [세로길이별][가로길이별] 개수 초기화
	}
}

void init(int mMap[][LM], struct Spaceship spaceships[]) {
	Map = mMap;
	myInit();
	for (int i = 0; i < SLM; ++i) {  // 우주선을 [세로길이별][가로길이별] 목록에 분류하기
		int h = spaceships[i].height, w = spaceships[i].width;
		hwShipIDs[h][w][hwLen[h][w]++] = i;
	}

	// 겹치는 착륙지를 그룹핑하기
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

bool isAble(Land&t) {         // 착륙가능한 지역인지 확인하기
	for (int i = t.sr; i <= t.er; ++i) {
		for (int j = t.sc; j <= t.ec; ++j) {
			if (used[i][j]) return 0;
		}
	}
	return 1;
}

void marking(Land&t, int w) {  // 영역을 착륙지로 선택(1)했음으로 또는 해제(0)했음으로 표시
	for (int i = t.sr; i <= t.er; ++i) {
		for (int j = t.sc; j <= t.ec; ++j) {
			used[i][j] = w;
		}
	}
}

int maxScore, maxMark[20];
int mark[20];
int *grr, len;

void dfs(int step, int scoreSum) {
	if (step >= len) {  // 마지막까지 진행한 상태에서
		if (scoreSum > maxScore) { // 더 좋은 점수를 얻는 조합을 찾은 경우
			for (int i = 0; i < len; ++i) // 조합을 이루는 구성원소 백업
				maxMark[i] = mark[i];
			maxScore = scoreSum;   // 점수 업데이트
		}
		return;
	}
	
	int landID = grr[step];        // step번째 착륙지 아이디
	// 0. landID를 사용하지 않는 경우
	dfs(step + 1, scoreSum);
	// 1. landID를 사용하는 경우
	if (isAble(lands[landID])) {
		marking(lands[landID], 1); // 착륙지를 사용한다고 표시
		mark[step] = 1;            // landID를 착륙지를 선택함
		dfs(step + 1, scoreSum + lands[landID].score);
		mark[step] = 0;            // landID를 착륙지를 선택하지 않음
		marking(lands[landID], 0); // 착륙지를 사용하지 않음으로 표시
	}
}

void process(int rows[], int cols[], int dirs[]) {
	// 루트별로 착륙지 아이디를 모은다.
	for (int i = 1; i <= landCnt; ++i) {
		int rid = Find(i);
		groups[rid][gcnt[rid]++] = i;
	}

	// 각 착륙지 그룹의 루트에서 최적조합을 찾고 
	// 최적조합에 필요한 우주선을 초빙하기
	for (int i = 1; i <= landCnt; ++i) {
		if (G[i] != i) continue;   // 각 그룹의 루트가 아니라면 제외
		maxScore = 0;
		grr = groups[i], len = gcnt[i];
		for (int i = 0; i < 20; ++i) mark[i] = maxMark[i] = 0;
		dfs(0, 0);  // step, scoreSum

		// 최적 조합에 우주선을 초빙하기
		for (int j = 0; j < len; ++j) {
			if (maxMark[j] == 0) continue;
			int landID = grr[j];
			int h = lands[landID].h, w = lands[landID].w;
			int sign = 0;

			// implement here ///////////////////////////////////
			int sr = lands[landID].sr, sc = lands[landID].sc;
			if (hwLen[h][w]) {                        // 회전하지 않고 착륙하기 시도
				int sid = hwShipIDs[h][w][--hwLen[h][w]];
				rows[sid] = sr, cols[sid] = sc, dirs[sid] = 0;
				sign = 1;
			}
			if (sign == 0 && h != w && hwLen[w][h]) { // 회전하여 착륙하기 시도
				int sid = hwShipIDs[w][h][--hwLen[w][h]];
				rows[sid] = sr, cols[sid] = sc, dirs[sid] = 1;
			}
			/////////////////////////////////////////////////////
		}
	}
}
```
