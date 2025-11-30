```cpp
/*
30_EX안테나배정_main

UE : 무선통신에서 사용하는 용어로 user equipment(사용자 단말기)의 약자라고 합니다.

[문제 구조]
  1. 10개TC, TC마다 데이터 생성 10개 subTC에서 계속사용
  2. batch_processing 문제 (interactive)
  3. 안테나와 UE(사용자 단말기) 두 주인공이 등장한다.
  4. 배정(할당) 문제
  5. 가능한 점수를 최소화 하시오.

[문제 개요]
1. 100 * 100 맵에 150개의 안테나와 1만개의 UE가 랜덤하게 배치된다.
	: 단말기(1만 : 0 ~ 9999): (1)좌표, (2)방향(평균 20%만 방향을 갖는다) (3) 방향이 있는 단말기는 이동한다.  (4) 위치가 중복될 수 있다.
	: 안테나(150 : 0 ~ 149) : (1)좌표, (2)수용력 100, (3)최대 전파가동범위 200, 안테나는 움직이지 않는다.  (4) 위치가 중복될 수 있다.
2. 매 TC별 처음 한 번 안테나 위치를 제공한다.
   매 subTC마다 각 단말기는 어느 한 안테나에 배정되어 한다. 배정되지 못한 단말기가 있는 경우 FAIL.
   매 subTC마다 각 안테나별 최대 전파가동범위를 구해야 한다.
   페널티를 받게 되면 TC당 10억의 벌점부과
	<페널티 기준>
	1) 각 안테나의 최대 range(200) 유효성
	2) 각 ue에 할당된 안테나 번호(0~149)의 유효성
	3) 각 안테나의 최대 수용 ue수(ANTENNA_CAPA = 100)의 유효성
	4) 유닛이 이동후 배정된 안테나 range를 벗어나는 경우 검사


[유저가 할일]
  안테나위치, 단말기의 위치를 받아
  (1) 각 단말기에 안테나를 할당하라.
  (2) 안테나별 가동범위를 결정하라. 단, 이동하는 단말기의 이동범위를 고려하여 결정해야 한다.
  안테나의 가동범위는 할당받은 단말기의 이동을 고려할 때 최대 이동범위이다.
  안테나별 최대 100개의 단말기를 할당받을 수 있다.
  매 subTC마다 방향이 있는 단말기는 5번 움직인다. => 검사는 0~4번까지만 수행.
  점수는 안테나별 가동범위제곱의 합으로 결정된다.
  점수를 최소화 하시오.

[유저의 API함수]
  1. init(antenna_list_bak)                                    : TC별 1번 호출
	  150개 안테나의 초기 2D 좌표가 주어진다.
  2. scanUE(UE_list_bak, antenna_range, antenna_UE_connection) : subTC별 호출
	  (1) 1만개 UE가 위치한 2D좌표가 주어진다.
	  (2) antenna_range에 안테나별 최대 전파 가동범위를 구하시오.
	  (3) antenna_UE_connection에 각 단말기에 할당된 안테나 번호를 구하시오.

[점수 계산]
  안테나별 최대전파가동범위 제곱의 합으로 점수를 계산한다.
  점수는 낮을 수록 좋다.

[문제 분석]
  <데이터 분석>
  랜덤하게 배치된 안테나와 UE는 맵상에 어떻게 위치할까? => 고른배치? 한쪽으로 쏠린 배치? 중복은 얼마나 많이 발생할까?

  <소스 분석>
   안테나는 위치, 최대전파가동범위 속성이 있다.
   UE는 위치, 방향 속성이 있다.
   !!! 그런데 유저에는 방향 속성을 알려주지 않는다. !!! => 이를 문제해결에 사용할 수 있을까? 어떻게?

   방향을 갖는 UE는 매 subTC마다 현재 방향으로 5번 이동한다.
   !!! 그런데 main.cpp의 run()에서 0번 ~ 4번 이동한 경우만 유효성 체크를 한다.  !!! => 의도된 것인가? 이를 문제해결에 이용할 수 있을까?

   UE수는 1만이고 안테나 전체 수용량은 150 * 100 = 15000 이므로 5000개의 여유분이 있다.
   모든 UE는 반드시 안테나에 할당되어야 하지만
   어떤 안테나는 0개의 UE를 할당받아도 상관없다. => 이러한 경우가 있을까?

   < 유효성 검사 분석 >
   (1) 안테나 가동범위는 0 ~ 200                => 당연한 검사1
   (2) 단말기별 할당받은 안테나 번호는 0 ~ 149  => 당연한 검사2
   (3) 안테나별 할당받은 단말기수는 0 ~ 100                                  => 고려해야 할 검사1 !!!!
   (4) 단말기가 할당된 안테나와의 맨해튼거리가 안테나 가동범위를 벗어나는가? => 고려해야 할 검사2 !!!!
*/

#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif

#include <stdio.h>
#include <string.h>

#define ABS(x) (((x)<0)?(-(x)):(x))

static unsigned long long seed = 5;

static int psuedo_rand(void)
{
	seed = seed * 25214903917ULL + 11ULL;
	return (seed >> 16) & 0x3fffffff;
}

/* These constant variables will NOT be changed */
static const int MAP_SIZE = 100;       // 지도 크기
static const int ANTENNA_NUM = 150;    // 안테나 수
static const int ANTENNA_CAPA = 100;   // 안테나별 수용력 한계
static const int UE_NUM = 10'000;      // 단말기수
static const int TC_COUNT = 10;        // 테스트 케이스 수
static const int SUBTASK_COUNT = 10;   // 서브 테스트 케이스 수
static const int DIR_NUM = 20;         // 방향범주
static const long long PENALTY = 1'000'000'000; // 벌점 10억

// (0,0)을 상좌단, (99, 99)를 하우단이라고 할 때,  4(하), 9(우), 14(상), 19(좌)
static const int dy[DIR_NUM] = { 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0 };
static const int dx[DIR_NUM] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1 };

struct Coordinates
{
	int y, x;       // Expert시험에서는 예외없이 y:행좌표, x:열좌표 이다.
	                // 때때로 int x, y;로 표기되기도 하나 y:행좌표, x:열좌표는 변함없이 유지되었다.

	Coordinates()   // default constructor: 기본 생성자
	{
		y = x = 0;
	}
	Coordinates(int _y, int _x) // constructor:생성자
	{
		y = _y;
		x = _x;
	}

	int operator-(Coordinates& param) // 연산자 오버로딩
	{
		return ABS(y - param.y) + ABS(x - param.x); // 맨해튼 거리, taxi_cap distance => EX시험에서는 거의 대부분
	}
};

extern void init(Coordinates[]);
extern void scanUE(Coordinates[], int[], int[]);

static long long SCORE = 0;

static Coordinates antenna_list[ANTENNA_NUM];     // 안테나 좌표 목록
static Coordinates antenna_list_bak[ANTENNA_NUM]; // 백업본 => cheating을 방지하기 위하여 백업본을 user.cpp에 전달한다.
static int antenna_range[ANTENNA_NUM];            // 안테나별 가동범위 : user.cpp가 결정하여 기록한다.
static int antenna_ref_count[ANTENNA_NUM];        // 안테나별 단말기 할당 수 : 최대 100을 초과할 수 없다.
                                                  // 유저가 작성한 antenna_UE_connection[UE_NUM];를 토대로 main.cpp에서 작성한다.
static Coordinates UE_list[UE_NUM];               // 단말기별 좌표 목록
static Coordinates UE_list_bak[UE_NUM];           // 백업본 => cheating을 방지하기 위하여 백업본을 user.cpp에 전달한다.
static int UE_move_direction[UE_NUM];             // 단말기별 방향 목록 : user.cpp에 알려주지 않는다. !!!!!
static int antenna_UE_connection[UE_NUM];         // 단말기별 할당된 안테나 번호 : user.cpp가 결정하여 기록한다.

static bool run()
{
	// mem 3형제^^ : 필수로 알아 둘 내용임. 속도가 빠르다. 메인에 비교적 자주 등장한다.
	// memset(배열이름, (0 or -1), sizeof(정적 배열이름)) : 배열 전체를 0 또는 -1로 초기화
	// memcpy(to, from, size) : to 배열에 from배열의 내용을 size만큼 복사
	// memcmp(A, B, size)     : A배열과 B배열을 size만큼 비교 똑같은 경우 0을 반환
	memset(antenna_ref_count, 0, sizeof(antenna_ref_count)); // antenna_ref_count배열전체를 0으로 초기화

	// TC별 안테나 좌표 생성 : 중복체크가 없으므로 좌표(0~99, 0~99)가 중복될 수 있다.
	for (int i = 0; i < ANTENNA_NUM; i++)  // 150개 안테나 정보 생성
		antenna_list_bak[i] = antenna_list[i] = Coordinates(psuedo_rand() % MAP_SIZE, psuedo_rand() % MAP_SIZE);

	init(antenna_list_bak);   // user.cpp에 안테나 좌표 전달

	// TC별 단말기 좌표와 방향 생성 : 중복체크가 없으므로 좌표가 중복될 수 있다.
	for (int k = 0; k < UE_NUM; k++)  // 1만개
	{
		UE_list[k] = Coordinates(psuedo_rand() % MAP_SIZE, psuedo_rand() % MAP_SIZE);  // 좌표(0~99, 0~99) 생성
		UE_move_direction[k] = psuedo_rand() % DIR_NUM; // 방향(0~19) 생성 : 평균 20%확률로 방향을 갖는다.
	}

	for (int t = 0; t < SUBTASK_COUNT; t++)  // subTC가 있다.
	{
		for (int k = 0; k < UE_NUM; k++)     // 1만개 단말기 좌표를 복사한다.
			UE_list_bak[k] = UE_list[k];

		// user.cpp에 방향은 제외하고 단말기 좌표를 알려준다.
		// antenna_range:각 안테나별 최대 가동범위              => 유저가 완성해야 한다.
	    // antenna_UE_connection:각 단말기가 배정된 안테나 번호 => 유저가 완성해야 한다.
		scanUE(UE_list_bak, antenna_range, antenna_UE_connection);

		for (int i = 0; i < ANTENNA_NUM; ++i)  // 1. 안테나 가동범위 유효성 검사 : 200이하
		{
			if (antenna_range[i] > 200)// (0, 0)으로부터 (99,99)사이 맨해튼 거리는 최대 198이므로 당연한 검사1 ^^^
				return false;

			antenna_ref_count[i] = 0;  // 안테나별 할당받은 단말기수 초기화
		}

		for (int k = 0; k < UE_NUM; k++)       // 2. 단말기별 배정된 안테나 번호 유효성 검사 : 0~149
		{
			int i = antenna_UE_connection[k];   // k유닛이 할당된 안테나 번호
			if (i < 0 || i >= ANTENNA_NUM) // 안테나 번호는 0~149이므로 당연한 검사2 ^^^
				return false;

			antenna_ref_count[i]++;  // 안테나별 할당받은 단말기수 증가
		}

		for (int i = 0; i < ANTENNA_NUM; i++)  // 3. 안테나별 최대 수용 단말기수 : 0~100 : 주의할 검사1 #####
		{
			if (antenna_ref_count[i] > ANTENNA_CAPA)
				return false;
		}

		for (int minutes = 0; minutes < 5; minutes++)
		{
			// 1st. 검사 후
			for (int k = 0; k < UE_NUM; k++)
			{
				int i = antenna_UE_connection[k];  // k 단말기가 배정된 안테나 번호 => 모든 단말기는 안테나에 할당되어야 한다. #####
				/*
				[참조타입(reference) 변수를 사용하는 경우]
				1. 복사비용(시간, 메모리)을 절약하기 위하여
				2. 원본값 수정을 위하여
				*/
				Coordinates& antenna = antenna_list[i];  // 안테나 정보를 참조타입으로 : 복사비용절약
				Coordinates& ue = UE_list[k];            // 단말기 정보를 참조타입으로 : 복사비용절약

				// 4. 이동하는 단말기가 배정된 안테나 가동범위를 벗어나는가? : 주의할 검사2 #####
				if (antenna_range[i] < antenna - ue)
					return false;
			}
			// 2nd. 이동한다. => 의도된 것인가?
			for (int k = 0; k < UE_NUM; k++)      // 1만개 단말기에 대하여 유효성 검사
			{
				int& dir = UE_move_direction[k];  // 방향을 참조타입으로 : 원본 수정을 위하여

				if (dy[dir] == dx[dir])  // 방향이 없는 단말기(평균 80%)는 제외하고
					continue;

				// 방향이 있는 단말기가 현재 방향으로 이동시 맵 경계를 벗어나는 경우
				if (UE_list[k].y + dy[dir] < 0 || UE_list[k].x + dx[dir] < 0 || UE_list[k].y + dy[dir] >= MAP_SIZE || UE_list[k].x + dx[dir] >= MAP_SIZE)
				{
					// ##### dir이 참조 타입이므로 원본인 UE_move_direction[k]값이 수정된다. #####
					dir = (dir + 10) % DIR_NUM; // 방향을 180도로 회전한다. 
				}

				// 유효한 범위에서 이동하기
				UE_list[k].y += dy[dir];
				UE_list[k].x += dx[dir];
			}
		}

		// 점수는 안테나 가동범위제곱의 합으로 계산된다.
		for (int i = 0; i < ANTENNA_NUM; i++)
			SCORE += (antenna_range[i] * antenna_range[i]);
	}
	return true; // 모든 단말기가 규칙에 맞게 배정된 경우
}

int main()
{
//#ifndef ONLINE_JUDGE
//	freopen("output.txt", "w", stdout);
//#endif // ONLINE_JUDGE
//

	setbuf(stdout, NULL);
	//////////////////////////////////////
	int sd = 5;
	//scanf("%d", &sd);
	seed = sd;
	//////////////////////////////////////

	for (int tc = 1; tc <= TC_COUNT; ++tc) // 10개의 TC
	{
		if (run() == false) // 유효성 검사 + 점수 계산
		{
			//printf("SCORE: %lld\n", PENALTY); // 유효성 검사를 통과하지 못한 경우 벌점 10억
			//return 0;
		}
	}

	printf("SCORE: %lld\n", SCORE);

	//////////////////////////////////////
	int cut = 2100000;
	//scanf("%d", &cut);
	if (cut < SCORE) puts("FAIL");
	else puts("PASS");
	//////////////////////////////////////
	return 0;
}

```
