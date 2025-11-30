```cpp
/*
45_EXGerms_user_sketchCode01

[sketchCode01]
    match() 함수의 유사도는 (색차 + 유형차 + 크기차 + 각도)이다.
	이를 (색차 + 유형차)로 바꾸면 비교적 쉽게 답을 구할 수 있다.
	이를 이용하여 답을 구해보면 몇 점을 얻을 수 있을까?
	SCORE: 3200
	FAIL

[고찰]
    모든세균을 match()하면 점수가 1800(공부하는 관점에서)점을 초과한다.
	따라서 모든세균을 match()하지않고 답을 구하는 아이디어가 필요함을 알수 있다.
*/
static const int CLM = 16384;
static const int GLM = 1'000'000;
static const int BLM = 1024;

extern void info(int coreIndex, int id);
extern void rotate(int coreIndex, int id, int degree);
extern void scale(int coreIndex, int id, int scale);
extern void match(int coreIndex, int id);
extern void gpu_process(int sharedBuffer[CLM][BLM]);
extern void result(int anwer);
///////////////////////////////////////////////////////////////////
int buf[CLM][BLM], blen[CLM];
struct Data {
	int id, simil;
}grr[GLM];

void process()
{
	for (int i = 0; i < CLM; ++i) blen[i] = 0;
	int ans = 0;
	int core = 0;

	for (int i = 0; i < GLM; ++i) {  // 310점
		if (core >= CLM) core = 0;
		match(core, i);
		blen[core] +=3;
		++core;
	}
	gpu_process(buf);                // 10점

	for (int i = 0; i < CLM; ++i) {
		for (int j = 0; j < blen[i]; j += 3) {
			int gid = buf[i][j + 1];
			int sim = buf[i][j + 2];  // 유사도에 (색차 + 유형차) 만 있으므로
			if (sim == 0) ans++;      // 유사도가 0이면 우리가 찾는 일반세균이다.
		}
	}

	result(ans);
}
```
