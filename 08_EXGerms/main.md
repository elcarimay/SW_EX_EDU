```cpp
/*
45_EXGerms_main

[문제 구조]
1. TC10개인 문제이다. 매TC당 새로운 데이터를 생성한다.
2. interactive형식의 batch_process문제로 생각할 수 있다. => 문제의 다양성
   답을 구하는 과정에 main.cpp의 api함수를 사용하기는 하지만
   아바타를 만들어 사용할 필요가 없기 때문이다.
   답을 구하여 반환하면 되는 문제이다.
3. 등장하는 주인공 종류는 Germs 한종류이지만 속성값은
   7가지(id, 크기, 색, 각도, 조정각, 유형, 사용중인 코어(행)번호)이다. => 문제의 다양성
   user.cpp가 작성할 함수는 process() 1개뿐이나 참조할 main.cpp의 함수는
   info(), rotate(), scale(), match(), gpu_process(), result() 6개이다.
4. 점수를 가능한 최소화해야 한다.

[문제 개요]
메인에 정의된 info(), rotate(), scale(), match(), gpu_process(), result()함수를 이용하여
100만개의 일반세균중에서 target세균과 색이 같고 유형이 같은 일반세균수를 구해야한다.

[user.cpp 의 API 함수]
process()

[main.cpp의 API 함수]
info(id)       :  1점, 요청한 일반세균의 크기, 조정각, 색을 버퍼에 기록한다.
rotate(id)     :  2점, 조정각(degree)를 -359~359범위로 변경한다. 기록 안함
scale(id)      :  3점, 요청한 id일반세균의 크기를 변경한다. -INF ~ INF
match(id)      :  5점, id일반세균과 target세균과의 유사도(색차+유형차+크기차+각도차)를 버퍼에 기록한다.
gpu_process(sharedBuffer[][]): 10점, 메인의 버퍼에 기록된 내용을 sharedBuffer[][]에 복사하여 알려준다.
result(answer) :  0점, 답을 메인에 보고

[문제 분석]
1. target세균의 정보는 전혀 알려주지 않는다.
2. 일반세균의 정보중에 각도(direction)과 유형(shape)를 알려주지 않는다.
3. 유사도 = 색차 + 유형차 + 크기차 + 조정각을 고려한 각도차 이다.
4. 점수계산
   : gpu_process()호출시 코어(행)별 점수들중에 (최대점수 + 10)을 총점에 누적한다.
     따라서 코어(행)을 고르게 사용해야 한다.
5. info(), rotate(), scale(), match(), gpu_process()함수를 적절히 이용하여
   target세균과 색이 같고 유형이 같은 일반세균수를 구하여 result()로 보고해야 한다.

   어떻게 할 수 있을까?
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
static const long long PENALTY = 10'000'000'000'000LL;  // 벌점 10조
static const int MAX_TC = 10;           // 테스트 케이스 수

static const int MAX_CORE = 16384;      // 2의 14제곱 : 코어(행)의 개수
static const int CORE_BUF_SIZE = 1024;  // 2의 10제곱 : 열의 개수

static const int MAX_GERM = 1'000'000;  // 세균수
static const int MAX_COLOR = 16;        // 색종류 : 0 ~ 15
static const int MAX_GERM_TYPE = 1000;  // 유형   : 0 ~ 999

static long long SCORE;                 // 점수
static long long gCoreCycle[MAX_CORE];  // 각 행별 점수를 기록
static int gAnswer;                     // 사용자가 보고한 답

struct Germs {       // 세균 클래스
	int size;        // 크기
	int color;       // 색
	int direction;   // 각도
	int degree;      // 조정각
	int shape;       // 유형
	int usedCore;    // 사용중인 코어(행)번호
};

static struct Germs germs[MAX_GERM], target;    // 100만개 일반세균과, 목적세균 정보

static int gGpuBuffer[MAX_CORE][CORE_BUF_SIZE]; // [16384][1024] 버퍼 : info(), match()에서 기록한다.
static int gGpuBufferIndex[MAX_CORE];           // 각 코어(행)별 기록된 정보의 길이

#define ABS(x) (((x) > 0) ? (x) : -(x))

//////////////////////////
// info(코어(행)번호, 세균 아이디)
void info(int coreIndex, int id) // 1점, 버퍼에 기록함
{
	if (coreIndex < 0 || coreIndex >= MAX_CORE || id < 0 || id >= MAX_GERM)
		return; // 코어(행)번호(0~16383)와 세균 아이디(0~999999) 유효성 검사

	gCoreCycle[coreIndex] += 1; // 코어(행)에 점수 1증가

	// id세균에 대하여 초기에 한번 코어(행)를 지정할 수 있으나 지정된 이후에는 기억해두고 지정한 코어(행)을 호출해야 한다.
	// gpu_process() 함수가 호출되면 초기화된다.
	if (germs[id].usedCore == -1 || germs[id].usedCore == coreIndex) {
		germs[id].usedCore = coreIndex;

		// id세균의 크기, 조정각, 색은 기록하지만
		// 각도, 유형 기록하지 않는다.     => 숨기는 이유는?
		// 코어(행)번호도 알려주지 않는다. => 기록하고 있어야 한다.
		int& bufferIndex = gGpuBufferIndex[coreIndex];
		gGpuBuffer[coreIndex][bufferIndex++] = 0;                // info()에서 기록합니다.
		gGpuBuffer[coreIndex][bufferIndex++] = id;               // id세균정보입니다.
		gGpuBuffer[coreIndex][bufferIndex++] = germs[id].size;   // 크기
		gGpuBuffer[coreIndex][bufferIndex++] = germs[id].degree; // 조정각
		gGpuBuffer[coreIndex][bufferIndex++] = germs[id].color;  // 색
	}
}

void rotate(int coreIndex, int id, int degree)  // 2점, 조정각을 변경, 버퍼에 기록하지 않음
{
	if (coreIndex < 0 || coreIndex >= MAX_CORE || id < 0 || id >= MAX_GERM)
		return;  // 코어(행)번호(0~16383)와 세균 아이디(0~999999) 유효성 검사

	gCoreCycle[coreIndex] += 2; // 코어(행)에 점수 2증가

	if (germs[id].usedCore == -1 || germs[id].usedCore == coreIndex) {
		germs[id].usedCore = coreIndex;
		germs[id].degree = (germs[id].degree + degree) % 360; // 조정각 범위는 -359 ~ 359
	}
}

void scale(int coreIndex, int id, int scale) // 3점, 크기를 변경, 버퍼에 기록하지 않음
{
	if (coreIndex < 0 || coreIndex >= MAX_CORE || id < 0 || id >= MAX_GERM)
		return;

	gCoreCycle[coreIndex] += 3;

	if (germs[id].usedCore == -1 || germs[id].usedCore == coreIndex) {
		germs[id].usedCore = coreIndex;
		germs[id].size = germs[id].size + scale; // -INF ~ +INF
	}
}

void match(int coreIndex, int id)  // 5점, 유사도를 구하고, 버퍼에 기록합
{
	if (coreIndex < 0 || coreIndex >= MAX_CORE || id < 0 || id >= MAX_GERM)
		return;

	gCoreCycle[coreIndex] += 5;

	if (germs[id].usedCore == -1 || germs[id].usedCore == coreIndex) {
		germs[id].usedCore = coreIndex;

		int similarity = ABS(target.color - germs[id].color);  // 색차
		similarity += ABS(target.shape - germs[id].shape);     // 유형차

		//similarity += ABS(target.size - germs[id].size);       // 크기차
		//int direction = ABS(target.direction - (germs[id].direction + germs[id].degree)) % 360; // 조정각+각도 차 : 0 ~ 359
		//similarity += (direction < 180) ? direction : 360 - direction; // 결과값은 0~180범위

		int& bufferIndex = gGpuBufferIndex[coreIndex];
		gGpuBuffer[coreIndex][bufferIndex++] = 1;           // match에서 기록합니다.
		gGpuBuffer[coreIndex][bufferIndex++] = id;          // id세균의
		gGpuBuffer[coreIndex][bufferIndex++] = similarity;  // 유사도(색차+유형차+크기차+각도차) 를 기록
	}
}

void gpu_process(int sharedBuffer[MAX_CORE][CORE_BUF_SIZE])  // 10점,  버퍼에 기록된 내용을 유저가 알고 싶을때 사용
{
	for (int i = 0; i < MAX_CORE; i++)   // gGpuBuffer[][]의 내용을 sharedBuffer에 복사한다.
		for (int j = 0; j < gGpuBufferIndex[i]; j++)
			sharedBuffer[i][j] = gGpuBuffer[i][j];

	for (int i = 0; i < MAX_CORE; i++)
		gGpuBufferIndex[i] = 0;

	int maxScore = 0;
	for (int coreIndex = 0; coreIndex < MAX_CORE; coreIndex++) {
		if (maxScore < gCoreCycle[coreIndex])
			maxScore = gCoreCycle[coreIndex]; // 코어(행)점수 중에 최대값을 최대점수로
		gCoreCycle[coreIndex] = 0;            // 코어(행)별 점수 초기화
	}
	SCORE += (maxScore + 10);                 // (최대점수+10)이 gpu_process()호출시마다 최종점수에 누적된다.

	for (int i = 0; i < MAX_GERM; i++)        // 각 세균별 사용중인 코어(행)번호 초기화
		germs[i].usedCore = -1;
}

void result(int answer)  // 사용자가 구한답을 메인에 보고할 때 사용
{
	gAnswer = answer;
}

//////////////////////////

static void init()  // 세균 데이터 생성
{
	gAnswer = -1;   // 사용자가 구한 답 초기화

	for (int i = 0; i < MAX_GERM; i++) {  // 100만개의 일반세균 생성
		germs[i].size = pseudo_rand() % 10;              // 크기   0 ~ 9
		germs[i].direction = pseudo_rand() % 360;        // 각도   0 ~ 359
		germs[i].degree = 0;                             // 조정각 0으로 초기화
		germs[i].color = pseudo_rand() % MAX_COLOR;      // 색     0 ~ 15
		germs[i].shape = pseudo_rand() % MAX_GERM_TYPE;  // 유형   0 ~ 999
		germs[i].usedCore = -1;                          // 사용중인 코어(행)는 아직 없음으로 초기화
	}

	// 목적 세균 생성
	target.size = pseudo_rand() % 10;              // 크기  0 ~ 9
	target.direction = pseudo_rand() % 360;        // 각도  0 ~ 359
	target.degree = 0;
	target.color = pseudo_rand() % MAX_COLOR;      // 색    0 ~ 15
	target.shape = pseudo_rand() % MAX_GERM_TYPE;  // 유형  0 ~ 999

	for (register int i = 0; i < MAX_CORE; i++)    
	{
		gGpuBufferIndex[i] = 0;  // 버퍼(정보를 기록하는 공간) 초기화
		gCoreCycle[i] = 0;       // 코어(행)별 점수 초기화
	}
}

static bool verify()  // 검증 작업
{
	int count = 0;

	// 100만개 일반세균중에서 목적세균과 색이 같고 유형이 같은 일반세균수 구하기
	for (int i = 0; i < MAX_GERM; i++) {
		if (target.color == germs[i].color && target.shape == germs[i].shape)
			count++;
	}

	if (count == gAnswer) // 유저가 구한 수와 같아야 유효성검사를 통과한다.
		return true;

	return false;
}

extern void process();

int main()
{
	setbuf(stdout, NULL);

	SCORE = 0;
	for (int tc = 0; tc < MAX_TC; ++tc) {  // 10개의 테스트 케이스
		init();    // 데이터 생성

		process(); // 유저는 목적세균과 색이같고 유형이 같은 일반세균수를 구하여야 한다.

		if (verify() == false) {
			SCORE = PENALTY;
			break;
		}
	}

	printf("SCORE: %lld\n", SCORE);

	//////////////////////////////////////////////////////
	if (SCORE > 1800) puts("FAIL");
	else puts("PASS");
	//////////////////////////////////////////////////////

	return 0;
}

```
