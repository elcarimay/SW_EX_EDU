```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
/*
41_직사각형그룹
Union Find + Path compressing
*/
#include <cstdio>

#define Max(a, b) ((a) > (b)? (a):(b))
#define Min(a, b) ((a) < (b)? (a):(b))

enum { LM = 3005 };
int gcnt, maxSize = 1;
int N, G[LM], gsize[LM];

int Find(int r) {
	if (G[r] == r) return r;
	return G[r] = Find(G[r]);
}

void Union(int x, int y) {
	x = Find(x), y = Find(y);
	if (x == y) return;
	gcnt--;
	G[y] = x;
	gsize[x] += gsize[y];
	maxSize = Max(maxSize, gsize[x]);
}

struct Rect {
	int sr, sc, er, ec;
	//bool isOver(const Rect&t) {
	//	return !(t.er < sr || er < t.sr || t.ec < sc || ec < t.sc);
	//}
	bool isOver(const Rect&t) {  // 겹치는 부분이 있다 == 안겹치지 않는다.
		return !(Max(sr, t.sr) > Min(er, t.er) || Max(sc, t.sc) > Min(ec, t.ec));
	}
}rects[LM];

int main() {
#ifndef ONLINE_JUDGE
	freopen("41.txt", "r", stdin);
#endif // ONLINE_JUDGE
	scanf("%d", &N);
	int sr, sc, er, ec;
	for (int i = 1; i <= N; ++i) {
		scanf("%d %d %d %d", &sr, &sc, &er, &ec);
		rects[i] = { sr, sc, er, ec };
		G[i] = i, gsize[i] = 1;
		gcnt++;
		for (int j = i - 1; j > 0; --j) {
			if (rects[i].isOver(rects[j]))
				Union(i, j);
		}
		printf("%d %d\n", gcnt, maxSize);  // 전체 그룹수, 가장 많은 원소를 갖는 그룹의 원소수
	}

	return 0;
}

```
