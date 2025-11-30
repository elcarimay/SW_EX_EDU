```cpp
/*
07_숫자야구2_user
[문제 구조]
1. TC50개인 문제이다. 매 TC마다 데이터를 새로 생성한다.
2. interactive 문제이다. (batch processing)
3. 점수가 낮을수록 좋다.

[문제 개요]
메인에서 4자리 숫자야구 문제를 내면
유저는 query(suppose[])함수를 이용하여 힌트를 얻고 정답을 맞춰야 한다.
단 query()함수를 10번 이하로 호출하여야 한다.

[해결 전략]
현재까지 알려진 정보를 infos[]에 저장하고
새롭게 추측한 수를 query()에 보내기 전에 infos[]를 통해서 유효성을 검증한다.
유효성을 통과한 수만 query()에 보낸다.
1. 정답을 맞춘 경우 프로그램 종료
2. 그렇지 않은 경우 infos[]에 추가하고 새로운 추측을 계속한다.

새로운 수를 생성하고 검증하는 위 프로세스를 재귀를 이용하여 구현할 수 있다.
*/
struct Data {
	int strike;
	int ball;
};
extern Data query(int supose[]);
////////////////////////////////////////

int*srr;
int infoCnt, used[10];
struct Info {
	int A[6]; // 0~3:추측했던 수들, 4:스트라익수, 5:볼수
	bool isOK() {
		// srr[]에 담긴 4개의 수가 정답이라고 가정할 경우
		// A[4]==st && A[5] == ba 를 만족해야 한다.
		int st = 0, ba = 0;
		// 검증 코드
		for (int step = 0; step < 4; ++step) {
			if (used[A[step]] == step) st++;   // 같은 자리에 등장한 경우 : 스트라이크 증가
			else if (used[A[step]] > -1) ba++; // 등장만 한 경우 : 볼 증가
		}
		return st == A[4] && ba == A[5];
	}
}infos[10];

int dfs(int step) {
	// base condition
	if (step >= 4) {
		// 자기 검렬 : 현재까지 정보로 query()함수를 호출할 가치가 있는지 검사
		for (int i = 0; i < infoCnt; ++i) {
			if (infos[i].isOK() == false) return 0; // 가치가 없는 경우 : 답을 아직 찾지 못함
		}
		Data res = query(srr); // srr[]에 담긴수에 대한 결과를 얻기
		if (res.strike == 4) return 1;  // 드뎌 답을 찾은 경우 프로그램 종료

		// 아직 답을 못 찾은 경우 : 이후에 가정한 수를 검증할 때 사용할 것이므로 보관하기
		infos[infoCnt++] = { srr[0], srr[1], srr[2], srr[3], res.strike, res.ball };
		return 0;  // 답을 아직 찾지 못함
	}
	// normal condition
	for (int i = 0; i < 10; ++i) {  // 순열 생성 코드
		if (used[i] < 0) {  // i가 사용된적이 없다면 
			used[i] = step; // i라는 수가 step번째 사용됨으로 체크
			srr[step] = i;  // step번째 수는 i이다.
			if (dfs(step + 1))
				return 1;   // 정답을 찾은 경우 이후에 새로운 수를 가정해볼 필요가 없다.
			used[i] = -1;   // 체크 풀어주기
		}
	}

	// 1. 함수 형식을 맞춰야 한다.
	// 2. 아직 정답을 못찾았으므로 다른 조합을 시도해 보시오.
	return 0;
}

void tryBest(int suppose[]) {
	srr = suppose;
	infoCnt = 0;   // query()를 통하여 할게된 정보 목록
	for (int i = 0; i < 10; ++i) used[i] = -1;
	dfs(0);
}
```
