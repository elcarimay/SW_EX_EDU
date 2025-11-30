```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
/*
21_발전소짓기
*/
#include <cstdio>

enum{ LM = 100005 };
int N, K, ans;
int entry[LM], ecnt;  // 발전소 설비가 가능한 위치 목록

int main() {
#ifndef ONLINE_JUDGE
	freopen("21.txt", "r", stdin);
#endif // ONLINE_JUDGE
	scanf("%d %d", &N, &K);
	for (int i = 1, sign; i <= N; ++i) {
		scanf("%d", &sign);
		if (sign) entry[++ecnt] = i; // 1_base로 설비가능한 위치들 저장
	}

	int tg = K, lastPos = 0;
	// 마지막 발전소위치로 가능한 최대 위치 : N - K + 1 이후에 지을 필요없다.
	for (int i = 1; i <= ecnt;) {
		for (; i <= ecnt && entry[i] <= tg; ++i);
		int curPos = entry[i - 1];
		if (lastPos == curPos)     // 새로운 위치를 찾지 못한경우
			break;
		lastPos = curPos;          // 마지막으로 건설한 발전소 위치를 curPos로 업데이트
		tg = lastPos + K * 2 - 1;  // 새롭게 지을 발전소의 최대 위치를 가정
		ans++;
		if (curPos >= N - K + 1) break;  // 종료 조건
	}

	if (lastPos + K <= N)  // 마지막 발전소가 마지막 도시에 전기를 공급할 수 없는 경우
		ans = - 1;

	printf("%d\n", ans);

	return 0;
}

```
