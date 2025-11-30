```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
/*
43_트리(중등)
Query Optimization(역순처리 idea) + UnionFind 
*/
#include <cstdio>

enum { LM = 200005, LM2 = LM * 2 };
int N, Q, qcnt, par[LM];
int cmd[LM2], nodeA[LM2], nodeB[LM2]; // 쿼리를 저장할 용도
int ans[LM], an;
int G[LM];
int Find(int r) {
	if (G[r] != r) G[r] = Find(G[r]);
	return G[r];
}

int main() {
#ifndef ONLINE_JUDGE
	freopen("43.txt", "r", stdin);
#endif // ONLINE_JUDGE
	scanf("%d %d", &N, &Q), qcnt = N - 1 + Q;
	for (int i = 2; i <= N; ++i) scanf("%d", par + i);
	for (int i = 1; i <= qcnt; ++i) {
		scanf("%d %d", cmd + i, nodeA + i);
		if (cmd[i]) scanf("%d", nodeB + i);
	}

	// 역순으로 쿼리 처리
	for (int i = 1; i <= N; ++i) G[i] = i;   // 초기 그룹번호는 자기자신 *****

	for (int i = qcnt; i > 0; --i) {
		if (cmd[i]) ans[++an] = Find(G[nodeA[i]]) == Find(G[nodeB[i]]);
		else G[nodeA[i]] = Find(par[nodeA[i]]);  // nodeA[i]의 부모의 루트로 그룹을 정한다.
	}

	for (int i = an; i > 0; --i) puts(ans[i] ? "YES" : "NO");

	return 0;
}

```
