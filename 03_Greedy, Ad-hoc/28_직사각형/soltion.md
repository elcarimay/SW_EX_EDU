```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
/*
28_직사각형
Ad-hoc
두 직사각형 만나는 경우 만들어지는 직사각형을 구해본다.
그 결과를 이용하여 분류할 수 있다.
*/
#include <cstdio>

#define Min(a, b) ((a) < (b)? (a):(b))
#define Max(a, b) ((a) > (b)? (a):(b))

int ax, ay, ap, aq;
int bx, by, bp, bq;
int cx, cy, cp, cq;

int main() {
#ifndef ONLINE_JUDGE
	freopen("28.txt", "r", stdin);
#endif // ONLINE_JUDGE
	for (int i = 0; i < 4; ++i) {
		scanf("%d %d %d %d %d %d %d %d", &ax, &ay, &ap, &aq, &bx, &by, &bp, &bq);
		int cx = Max(ax, bx), cy = Max(ay, by);
		int cp = Min(ap, bp), cq = Min(aq, bq);
		if (cx > cp || cy > cq) puts("d");
		else if (cx < cp && cy < cq) puts("a");
		else if (cx == cp && cy == cq) puts("c");
		else puts("b");
	}

	return 0;
}


```
