```cpp
/*
07_숫자야구2_main
*/
#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>

#define MAX          4
#define MAX_COUNT 2520

static int baseballNumbers[MAX];
static int numbersCheck[10];

extern void tryBest(int suppose[]); ////************

// 전역변수나 함수에 static을 붙이는 경우 현재파일 외부에서 접근을 방지한다.
static int queryCallCount;
static const int queryLimit = 10;

struct Data {
	int strike;
	int ball;
};

static unsigned long long seed = 123;
int rand(void) {
	seed = seed * 1103515245 + 12345;
	return (unsigned int)(seed >> 16) & 65535;
}

// 유저가 가정한 수들이 유효한지 유효성 검사.
// 1. 수의 범위가 0 ~ 9인가.
// 2. 2번 이상 등장하는 수가 있는가?
static bool isAble(int suppose[]) { 
	int supposeCheck[10];

	for (int count = 0; count < 10; ++count)
		supposeCheck[count] = 0; // suppose[]라는 배열에 등장한 수를 체크하기 위하여 모두 0으로 초기화
	for (int idx = 0; idx < MAX; ++idx) {
		// suppose[idx]범위를 벗어났거나 2번이상 등장하는 경우 불허함으로 보고
		if (suppose[idx] < 0 || suppose[idx] >= 10 || supposeCheck[suppose[idx]] > 0)
			return false;
		supposeCheck[suppose[idx]]++;  // 등장한 수 증가시켜 체크
	}
	return true;
}

Data query(int suppose[]) { // user.cpp에서 문제를 풀때 호출하여 사용하는 함수
	Data result;

	if (queryCallCount > MAX_COUNT) { // user가 query()함수를 2520번 초과하여 호출하는 경우 거부된다.
		result.strike = -1;
		result.ball = -1;
		return result;
	}

	queryCallCount++; // 유저가 query()호출한 회수 증가

	if (!isAble(suppose)) { // 유저가 가정한 수들이 유효한지 검사.
		result.strike = -1;
		result.ball = -1;
		return result;
	}

	// 유저가 추측한 수 목록에서 스트라익수와 볼수 구하기
	result.strike = 0;
	result.ball = 0;

	for (int idx = 0; idx < MAX; ++idx)
		if (suppose[idx] == baseballNumbers[idx])
			result.strike++; // 같은 자리에 같은 값인 경우 스트라이크 개수 증가
		else if (numbersCheck[suppose[idx]] > 0)
			result.ball++;   // 다른자리지만 퀴즈목록에 등장하는 경우 볼 개수 증가

	return result;
}

static void initialize() {
	for (int count = 0; count < 10; ++count)
		numbersCheck[count] = 0;
	for (int idx = 0; idx < MAX;) {   // [0], [1], [2], [3]
		int c = rand() % 10;          // 0 ~ 9
		if (numbersCheck[c] == 0) {   // c가 처음 등장한 수라면
			baseballNumbers[idx] = c; // 퀴즈 목록에 추가
			numbersCheck[c]++;        // 사용중임을 표시
			idx++;                    // 퀴즈 목록에 추가된 수 개수 증가
		}
	}
	queryCallCount = 0;  // 사용자가 query()함수를 호출한 횟수 초기화
}

static bool check(int suppose[]) {
	for (int idx = 0; idx < MAX; ++idx) {
		if (suppose[idx] != baseballNumbers[idx])
			return false; // 하나라도 틀리면 false
	}
	return true;
}

int main() {
	int score = 100;

	setbuf(stdout, NULL);
	int sd = 123, TC = 50;

	seed = sd;
	for (int testcase = 1; testcase <= TC; ++testcase) { // 50번 실행

		// 퀴즈 출제하기
		initialize(); // F12 : 함수의 정의부로 이동, ctrl + '-':되돌아올 때

		int suppose[MAX] = { 0 };
		queryCallCount = 0;

		tryBest(suppose);  // 유저가 최소의 query()함수 호출로 퀴즈를 맞춰야 한다.

		if (!check(suppose))  // 정답을 맞추지 못한 경우
			queryCallCount = MAX_COUNT;  

		if (queryCallCount > queryLimit) { // query()함수는 10을 초과하여 호출할 수 없다.
			score = 0;
			break;
		}
	}
	printf("%d\n", score);

	return 0;
}
```
