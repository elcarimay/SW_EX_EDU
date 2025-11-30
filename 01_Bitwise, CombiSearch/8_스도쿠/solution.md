```cpp
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
/*
08_스도쿠
DFS
*/
#include <cstdio>

int B[9][9];
int row[9][10], col[9][10], loc[9][10];

int sudoku(int step) {
	if (step > 80) return 1;              // base condition
	int i = step / 9, j = step % 9;
	if (B[i][j]) return sudoku(step + 1); // pruning

	// normal condition
	for (int k = 1; k < 10; ++k) {
		//  k가 현재행, 현재열, 현재영역에서 사용되지 않은 수라면
		if (row[i][k] + col[j][k] + loc[i / 3 * 3 + j / 3][k] == 0) {
			row[i][k] = col[j][k] = loc[i / 3 * 3 + j / 3][k] = 1;  // 사용해보기
			B[i][j] = k;  // k채워보기
			if (sudoku(step + 1))
				return 1; // 스도쿠 판을 모두 채운 경우
			B[i][j] = 0;  // 빈자리로 다시 복원
			row[i][k] = col[j][k] = loc[i / 3 * 3 + j / 3][k] = 0;
		}
	} 
	// 1. 함수형식 맞추기
	// 2. 아직 스도쿠 판을 못채웠으므로 이전 단계로 돌아가서 다른 수를 채워 보시오.
	return 0;
}

int main() {
#ifndef ONLINE_JUDGE
	freopen("08.txt", "r", stdin);
#endif // ONLINE_JUDGE
	for (int i = 0; i < 9; ++i) {
		for (int j = 0; j < 9; ++j) {
			scanf("%d", B[i] + j); // &B[i][j]
			if (B[i][j]) {  // 초기 입력에 수가 채워진 경우
				row[i][B[i][j]] = 1;  // i행에 B[i][j]수가 사용중입니다.
				col[j][B[i][j]] = 1;  // j열에 B[i][j]수가 사용중입니다.

				// (i / 3 * 3 + j / 3)영역에 B[i][j]수가 사용중입니다.
				loc[i / 3 * 3 + j / 3][B[i][j]] = 1;
			}
		}
	}

	sudoku(0); // 스도쿠 판 채우기

	// 채워진 결과 출력하기
	for (int i = 0; i < 9; ++i) {
		for (int j = 0; j < 9; ++j) printf("%d ", B[i][j]);
		puts("");
	}

	return 0;
}

```
