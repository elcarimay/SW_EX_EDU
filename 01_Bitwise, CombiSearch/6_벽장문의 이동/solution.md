```cpp
/*
06_벽장문의이동
재귀를 이용한 조합
*/
#include <cstdio>

#define Abs(a) ((a)<0? -(a):(a))
// #define LM 22 // c style
constexpr int LM = 22; // LiMit // c++ style
int N, a, b, Q, door[LM];
int minCost = (int)21e8; // 지수표기법 21* 1의 8제곱

// 직전까지 a와 b벽장문이 열려있고 비용은 cost이다.
// 이번에 door[step]벽장문을 열어야 한다.
// 선택가능한 방법은 a를 닫고 door[step]벽장문을 열기
// 또는 b를 닫고 door[step]벽장문을 여는 것이다.
void dfs(int step, int a, int b, int cost) {
    if (step >= Q) {
        if (minCost > cost) minCost = cost; // 다양한 방법으로 update가능
        return;
    }
    // 1. a문을 닫고 door[step]벽장문을 열기
    dfs(step + 1, door[step], b, cost + Abs(a - door[step]));
    // 2. b문을 닫고 door[step]벽장문을 열기
    dfs(step + 1, a, door[step], cost + Abs(b - door[step]));
}
int main() {
#ifndef ONLINE_JUDGE
    freopen("06.txt", "r", stdin);
#endif // ONLINE_JUDGE
    scanf("%d %d %d %d", &N, &a, &b, &Q);
    for (int i = 0;i < Q;i++) scanf("%d", door + i);

    dfs(0, a, b, 0);
    printf("%d\n", minCost);
    return 0;
}
```
