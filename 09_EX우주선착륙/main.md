```cpp
/*
47_EX우주선착륙_main

[문제 구조]
1. TC가 10개이다. : TC별 새로운 데이터를 사용한다.
2. batch processing 문제이다.
3. 가능한 점수가 높아야 한다.

[문제 개요]
1000*1000 크기의 행성이 주어진다.
각셀(행성 바닥 단위)의 높이는 0~124이다.
우주선은 세로길이(2~5)*가로길이(2~5) 속성을 가지며 10000대가 주어진다.
우주선의 4모서리에 다리는 125 ~ 131로 조정가능하도록 주어진다.
따라서 우주선의 다리가 놓이는 행성바닥셀 4곳이
조정범위 이내에 높이(4모서리 행성의 최대높이-최소높이 <= 6)라면 착륙할 수 있다.
또한 행성 범위를 벗어나지 않아야 하며 착륙하는 구간에 다른 우주선이 착륙한 적이 없어야 한다.
<점수 계산>
  : 점수는 착륙한 우주선의 세로길이*가로길이*min(세로길이, 가로길이)의 합들로 계산된다.

[API 함수]
* void init(int mMap[][MAP_SIZE], struct Spaceship spaceships[]):
  : 1000*1000 행성 지도 mMap[][]과 우주선 정보 spaceships[]가 주어진다.

* void process(int rows[], int cols[], int dirs[]) :
  : 착륙지에 착륙한 우주선의 착륙지 좌표와 회전 여부를 구하여 반환한다.
  : row[i] - i우주선이 착륙한 경우 행좌표
	col[i] - i우주선이 착륙한 경우 열좌표
	dir[i] - i우주선이 회전하여 착륙한 경우 1, 그렇지 않은 경우 0

[문제 분석]
  : 등장 주체는 착륙지와 우주선 둘 뿐이다.
  : 착륙하지 못한 우주선이 존재할 수 있다. (지도 출력과 같은 데이터 분석 후 알수 있다.)
	사용되지 못한 착륙지가 존재할 수 있다. (지도 출력과 같은 데이터 분석 후 알수 있다.)
  : main.cpp는 user.cpp에 모든 정보를 제공한다.
  : 맵에서 착륙가능한 지역을 먼저 찾아야 한다.
	착륙가능한 지역이 2개이상 여러 개가 겹칠수 있다.
	SEED = 5에서 최대 11개가 서로 겹친다. (데이터 분석 후 알 수 있다. - 유니온 파인드)
  : 점수는 착륙한 우주선의 세로길이*가로길이*min(세로길이, 가로길이)의 합들로 계산되므로
	1) 가능한 많은 우주선을 착륙시켜야 한다.
	2) 같은 수의 우주선을 착륙시킬 수 있는 경우가 2가지 이상 있다면
	   가능한 점수가 높은 우주선들을 착륙시키는 것이 유리하다.


	!!! 착륙지가 우주선을 선택할 것인가? or 우주선이 착륙지를 선택할 것인가?

	!!! 착륙가능한 지역이 겹쳐 있는 경우 어떻게 처리할 것인가?

*/

#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif

#include <stdio.h>

static unsigned long long seed = 5;
static int pseudo_rand(void)
{
	seed = seed * 25214903917ULL + 11ULL;
	return (seed >> 16) & 0x3fffffff;
}

/* These constant variables will NOT be changed */
static const long long PENALTY = 0LL;
static const int MAX_TC = 10;

static const int MAP_SIZE = 1000;
static const int SPACESHIP_NUM = 10000;

static int map_org[MAP_SIZE][MAP_SIZE];    // 맵 정보
static int map_bak[MAP_SIZE][MAP_SIZE];    // 맵 정보 복사본
static bool occupied[MAP_SIZE][MAP_SIZE];  // 우주선이 착륙했는지 표시


struct Spaceship {  // 우주선의
	int height;     // 세로길이
	int width;      // 가로길이
};

static struct Spaceship spaceship_org[SPACESHIP_NUM]; // 10000개의 우주선 정보
static struct Spaceship spaceship_bak[SPACESHIP_NUM];

// 유저가 작성할 답안지
static int rows[SPACESHIP_NUM]; // i번 우주선이 착륙한 행번호
static int cols[SPACESHIP_NUM]; // i번 우주선이 착륙한 열번호
static int dirs[SPACESHIP_NUM]; // i번 우주선이 착륙할 때 회전을 했는지 여부

static long long SCORE = 0;     // 점수는 높을수록 좋다.

#define MIN(x, y) (((x) < (y)) ? (x) : (y))
#define MAX(x, y) (((x) > (y)) ? (x) : (y))

//////////////////////////

static void make_tc() // TC별 데이터 생성
{
	for (register int y = 0; y < MAP_SIZE; y++)     // 1000 * 1000
	{
		for (register int x = 0; x < MAP_SIZE; x++)
		{
			map_org[y][x] = map_bak[y][x] = pseudo_rand() % 125; // 행성표면의 셀 단위별 높이: 0~124
			occupied[y][x] = false; // 우주선이 착륙한적이 없음으로 초기화
		}
	}

	for (int i = 0; i < SPACESHIP_NUM; i++) // 1만개 우주선 데이터 생성
	{
		spaceship_org[i].height = spaceship_bak[i].height = pseudo_rand() % 4 + 2; // 세로길이 : 2~5
		spaceship_org[i].width = spaceship_bak[i].width = pseudo_rand() % 4 + 2;   // 가로길이 : 2~5
		rows[i] = cols[i] = dirs[i] = -1;    // 우주선이 착륙하지 못했음으로 초기화
	}
}

static bool verify() // 유효성 검사
{
	for (int i = 0; i < SPACESHIP_NUM; i++)
	{
		if (rows[i] == -1 || cols[i] == -1 || dirs[i] == -1)
			continue; // 착륙하지 못한 우주선은 제외

		// 착륙한 우주선의 상좌단(y1, x1), 하우단(y2, x2) 좌표
		int y1 = rows[i], x1 = cols[i], y2, x2;

		if (dirs[i] == 0) // 회전하지 않고 착륙한 경우 하우단점
		{
			y2 = y1 + spaceship_org[i].height - 1; // 눈금을 칸으로 변환
			x2 = x1 + spaceship_org[i].width - 1;
		}
		else              // 회전하여 착륙한 경우 하우단점
		{
			y2 = y1 + spaceship_org[i].width - 1;
			x2 = x1 + spaceship_org[i].height - 1;
		}

		// 1. 맵을 벗어나서 착륙한 경우 착륙할 수 없다.
		if (y1 < 0 || x1 < 0 || y2 >= MAP_SIZE || x2 >= MAP_SIZE)
			return false;


		// 착륙한 4지점 높이의 최소값과 최대값 구하기
		int lo = MIN(MIN(MIN(map_org[y1][x1], map_org[y1][x2]), map_org[y2][x1]), map_org[y2][x2]);
		int hi = MAX(MAX(MAX(map_org[y1][x1], map_org[y1][x2]), map_org[y2][x1]), map_org[y2][x2]);

		// 2. 4지점의 최소값과 최대값 차이가 6을 초과하는 경우 착륙할 수 없다.
		if (hi - lo > 6)
			return false;

		for (int y = y1; y <= y2; y++)
		{
			for (int x = x1; x <= x2; x++)
			{
				// 3. 이미 다른 우주선이 착륙한 지역에 착륙을 시도하는 경우 착륙할 수 없다.
				if (occupied[y][x] == true)
					return false;

				occupied[y][x] = true; // 착륙에 사용했음을 표시
			}
		}

		// 점수 계산 : 착륙한 우주선의 세로길이*가로길이*min(세로길이*가로길이)
		// 1. 점수가 높아야 좋으므로 가능하면 많은 우주선을 착륙시켜야 한다.
		// 2. 같은 수의 우주선이라면 가능한 높은 점수를 갖는 우주선이 착륙하는 것이 유리하다.
		SCORE += (spaceship_org[i].height * spaceship_org[i].width * MIN(spaceship_org[i].height, spaceship_org[i].width));
	}

	return true; // 유저의 착륙요청이 모두 정상인 경우
}

extern void init(int[][MAP_SIZE], struct Spaceship[]);
extern void process(int[], int[], int[]);

#include <ctime>

int main()
{
#ifndef ONLINE_JUDGE
	//freopen("outputMap.txt", "w", stdout);          //  => TC : 1개만 출력해보기
	//freopen("outputLandMap.txt", "w", stdout);      //  => TC : 1개만 출력해보기
	//freopen("outputLandCount.txt", "w", stdout);    //  => TC : 10개 모두 출력해보기
#endif // ONLINE_JUDGE

	clock_t start = clock();
	setbuf(stdout, NULL);

	SCORE = 0;
	for (int tc = 0; tc < 10 /*MAX_TC*/; ++tc) { // TC 10개
		make_tc();  // 데이터생성 : 1. 행성표면의 높이(0~124), 2. 우주선의 가로길이(2~5), 세로길이(2~5)

		init(map_bak, spaceship_bak); // 행성지도와 우주선 정보를 전달
		process(rows, cols, dirs);    // 우주선이 착륙했다면 상좌단 좌표와 회전 여부를 기록한다.

		if (verify() == false) {
			SCORE = PENALTY;
			break;
		}
	}

	printf("SCORE: %lld\n", SCORE);

	/////////////////////////////////////////////////////////////////////////////////////////////
	if (SCORE >= 3'001'673) puts("PASS");
	else puts("FAIL");
	/////////////////////////////////////////////////////////////////////////////////////////////

	printf("RunTime : %d\n", clock() - start);
	return 0;
}

```
