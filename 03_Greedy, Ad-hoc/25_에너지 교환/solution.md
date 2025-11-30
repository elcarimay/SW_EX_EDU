```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
/*
25_에너지교환
Ad-hoc

[문제 분석]
모든 거북이가 'L'로만 구성되어 있거나, 'R'로만 구성되어 있다면 에너지 변화는 없다.

"RL"이 발견되는 경우만 고려하면 된다.
"RL"이 발견되면 "RL"의 'R'왼쪽에 연속한 'R'들의 점수합과
"RL"의 'L'오른쪽에 연속한 'L'들의 점수합에서만 에너지 감소가 발생한다.

문자열을 "RL"이 포함된 그룹단위로 나누어  점수를 구할 수 있다.
*/
#include <cstdio>
#define Min(a, b) ((a) < (b)? (a):(b))

enum { LM = 200005 };
using LL = long long;
int N, M, capa[LM];
char str[LM];
LL  ans;

int main() {
#ifndef ONLINE_JUDGE
	freopen("25.txt", "r", stdin);
#endif // ONLINE_JUDGE
	scanf("%d %d %s", &N, &M, str);
	for (int i = 0; i < N; ++i) {
		scanf("%d", capa + i);
		ans += capa[i];
	}

	for (int i = 0; i < N; ++i) {
		if (str[i] == 'R' && str[(i + 1) % N] == 'L') {
			LL sum = 0;  // 'R'의 왼쪽그룹(연속한 'R'들의 모임) 탐색
			for (int j = (i - 1 + N) % N; str[j] == 'R'; j = (j - 1 + N) % N) {
				sum += capa[j];
			}
			ans -= Min(sum, M); // "RL"의 'R' 왼쪽 그룹에서 소모된 에너지 양을 빼주기

			sum = 0;    // 'L'의 오른쪽 그룹(연속한 'L'들의 모임) 탐색
			for (int j = (i + 2) % N; str[j] == 'L'; j = (j + 1) % N) {
				sum += capa[j];
			}
			ans -= Min(sum, M); // "RL"의 'L' 오른쪽 그룹에서 소모된 에너지 양을 빼주기
		}
	}

	printf("%lld\n", ans);

	return 0;
}


```
