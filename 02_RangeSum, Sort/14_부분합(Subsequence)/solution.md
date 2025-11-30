```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
/*
14_부분합
two-pointer
*/
#include <cstdio>

constexpr int LM = 100005;
int N, S, A[LM], ans = LM;
int main() {
#ifndef ONLINE_JUDGE
    freopen("14.txt", "r", stdin);
#endif // ONLINE_JUDGE
    scanf("%d%d", &N, &S);
    for (int i = 0;i < N;i++) scanf("%d", A + i);

    int L = 0, R = 1; // two pointer
    int sum = 0; // 연속부분합
    for (;R <= N;R++) {
        sum += A[R];
        while (sum >= S) { // 연속부분합 >= 기준합
            if (ans > R - L) ans = R - L; // 구간크기 업데이트
            sum -= A[++L]; // 제일 앞쪽 데이터 합에서 제거하기
        }
    }
    // 답을 구할 수 없는 경우: A배열 전체합이 S보다 작은 경우
    printf("%d\n", ans == LM ? 0 : ans);
    return 0;
}
```
