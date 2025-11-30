```cpp
// *** main.cpp ***
#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>
 
#define MAX          4
#define MAX_COUNT 2520
 
static int baseballNumbers[MAX];
static int numbersCheck[10];
 
extern void tryBest(int suppose[]); ////************
 
static int queryCallCount;
static const int queryLimit = 10;
 
struct Data {
    int strike;
    int ball;
};
 
static unsigned long long seed = 123;
int rand(void){
    seed = seed * 1103515245 + 12345;
    return (unsigned int)(seed >> 16) & 65535;
}
 
static bool isAble(int suppose[]) {
    int supposeCheck[10];
 
    for (int count = 0; count < 10; ++count)
        supposeCheck[count] = 0;
    for (int idx = 0; idx < MAX; ++idx) {
        if (suppose[idx] < 0 || suppose[idx] >= 10 || supposeCheck[suppose[idx]] > 0)
            return false;
        supposeCheck[suppose[idx]]++;
    }
    return true;
}
 
Data query(int suppose[]) {
    Data result;
 
    if (queryCallCount > MAX_COUNT) {
        result.strike = -1;
        result.ball = -1;
        return result;
    }
 
    queryCallCount++;
 
    if (!isAble(suppose)) {
        result.strike = -1;
        result.ball = -1;
        return result;
    }
 
    result.strike = 0;
    result.ball = 0;
 
    for (int idx = 0; idx < MAX; ++idx)
        if (suppose[idx] == baseballNumbers[idx])
            result.strike++;
        else if (numbersCheck[suppose[idx]] > 0)
            result.ball++;
 
    return result;
}
 
static void initialize() {
    for (int count = 0; count < 10; ++count)
        numbersCheck[count] = 0;
    for (int idx = 0; idx < MAX;) {
        int c = rand() % 10;
        if (numbersCheck[c] == 0) {
            baseballNumbers[idx] = c;
            numbersCheck[c]++;
            idx++;
        }
    }
    queryCallCount = 0;
}
 
static bool check(int suppose[]) {
    for (int idx = 0; idx < MAX; ++idx) {
        if (suppose[idx] != baseballNumbers[idx])
            return false;
    }
    return true;
}
 
int main() {
    int score = 100;
 
    setbuf(stdout, NULL);
    int sd = 123, TC = 50;
 
    seed = sd;
    for (int testcase = 1; testcase <= TC; ++testcase) {
 
        initialize();
 
        int suppose[MAX] = { 0 };
        queryCallCount = 0;
 
        tryBest(suppose);
 
        if (!check(suppose))
            queryCallCount = MAX_COUNT;
        
        if (queryCallCount > queryLimit) {
            score = 0;
            break;
        }
    }
    printf("%d\n", score);
 
    return 0;
}
```
