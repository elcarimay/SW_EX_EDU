```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
/*
26_개미
순환마디 찾기
*/
#include <cstdio>

int W, H, p, q, t;

int main() {
#ifndef ONLINE_JUDGE
	freopen("26.txt", "r", stdin);
#endif // ONLINE_JUDGE
	scanf("%d %d %d %d %d", &W, &H, &p, &q, &t);
	p = (p + t) % (W * 2);
	q = (q + t) % (H * 2);
	if (p > W) p = W * 2 - p;
	if (q > H) q = H * 2 - q;
	printf("%d %d\n", p, q);
	return 0;
}

```
