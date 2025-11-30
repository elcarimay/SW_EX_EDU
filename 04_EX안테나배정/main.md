```cpp
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
static const int MAP_SIZE = 100;
static const int ANTENNA_NUM = 150;
static const int ANTENNA_CAPA = 100;
static const int UE_NUM = 10'000;
static const int TC_COUNT = 10;
static const int SUBTASK_COUNT = 10;
static const int DIR_NUM = 20;
static const long long PENALTY = 1'000'000'000;
static const int dy[DIR_NUM] = { 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0 };
static const int dx[DIR_NUM] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1 };

struct Coordinates
{
	int y, x;

	Coordinates()
	{
		y = x = 0;
	}
	Coordinates(int _y, int _x)
	{
		y = _y;
		x = _x;
	}

	int operator-(Coordinates& param)
	{
		return ABS(y - param.y) + ABS(x - param.x);
	}
};

extern void init(Coordinates[]);
extern void scanUE(Coordinates[], int[], int[]);

static long long SCORE = 0;

static Coordinates antenna_list[ANTENNA_NUM];
static Coordinates antenna_list_bak[ANTENNA_NUM];
static int antenna_range[ANTENNA_NUM];
static int antenna_ref_count[ANTENNA_NUM];

static Coordinates UE_list[UE_NUM];
static Coordinates UE_list_bak[UE_NUM];
static int UE_move_direction[UE_NUM];
static int antenna_UE_connection[UE_NUM];

static bool run()
{
	memset(antenna_ref_count, 0, sizeof(antenna_ref_count));

	for (int i = 0; i < ANTENNA_NUM; i++)
		antenna_list_bak[i] = antenna_list[i] = Coordinates(psuedo_rand() % MAP_SIZE, psuedo_rand() % MAP_SIZE);

	init(antenna_list_bak);

	for (int k = 0; k < UE_NUM; k++)
	{
		UE_list[k] = Coordinates(psuedo_rand() % MAP_SIZE, psuedo_rand() % MAP_SIZE);
		UE_move_direction[k] = psuedo_rand() % DIR_NUM;
	}

	for (int t = 0; t < SUBTASK_COUNT; t++)
	{
		for (int k = 0; k < UE_NUM; k++)
			UE_list_bak[k] = UE_list[k];


		scanUE(UE_list_bak, antenna_range, antenna_UE_connection);

		for (int i = 0; i < ANTENNA_NUM; ++i)
		{
			if (antenna_range[i] > 200)
				return false;

			antenna_ref_count[i] = 0;
		}

		for (int k = 0; k < UE_NUM; k++)
		{
			int i = antenna_UE_connection[k];
			if (i < 0 || i >= ANTENNA_NUM)
				return false;

			antenna_ref_count[i]++;
		}

		for (int i = 0; i < ANTENNA_NUM; i++)
		{
			if (antenna_ref_count[i] > ANTENNA_CAPA)
				return false;
		}

		for (int minutes = 0; minutes < 5; minutes++)
		{
			for (int k = 0; k < UE_NUM; k++)
			{
				int i = antenna_UE_connection[k];
				Coordinates& antenna = antenna_list[i];
				Coordinates& ue = UE_list[k];

				if (antenna_range[i] < antenna - ue)
					return false;
			}

			for (int k = 0; k < UE_NUM; k++)
			{
				int& dir = UE_move_direction[k];

				if (dy[dir] == dx[dir])
					continue;

				if (UE_list[k].y + dy[dir] < 0 || UE_list[k].x + dx[dir] < 0 || UE_list[k].y + dy[dir] >= MAP_SIZE || UE_list[k].x + dx[dir] >= MAP_SIZE)
				{
					dir = (dir + 10) % DIR_NUM;
				}

				UE_list[k].y += dy[dir];
				UE_list[k].x += dx[dir];
			}
		}

		for (int i = 0; i < ANTENNA_NUM; i++)
			SCORE += (antenna_range[i] * antenna_range[i]);
	}
	return true;
}

int main()
{
	setbuf(stdout, NULL);
	//////////////////////////////////////
	int sd = 5;
	//scanf("%d", &sd);
	seed = sd;
	//////////////////////////////////////

	for (int tc = 1; tc <= TC_COUNT; ++tc)
	{
		if (run() == false)
		{
			printf("SCORE: %lld\n", PENALTY);
			return 0;
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
