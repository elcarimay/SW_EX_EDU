```cpp
/*
45_EXGerms_user_sketchCode02

[sketchCode02]
1. match() 함수의 유사도는 (색차 + 유형차 + 크기차 + 각도)이다.
   이를 (색차 + 유형차)로 바꾸면 비교적 쉽게 답을 구할 수 있다.
2. sketchCode01의 고찰을 반영하여 다음 프로세스를 진행한다.
   1) match함수호출은 5점, info함수호출은 1점이다. 또한 info함수는 각 세균의 size, degree, color를 알려준다.
      모든 세균에 대한 info()함수를 호출하여 size, degree, color를 버퍼에 기록한다. => 62점
   2) 16384 단위로 match()를 호출하고 gpu_process를 호출하여
      target세균과 색이같고 유형이 같은 첫 일반세균을 찾아낸다.  => 15(5+10) * @
	  이를 통하여 target세균의 색을 알아낼 수 있다.
   3) info()로 알아낸 각 일반세균의 색정보를 이용하여
      target세균과 같은 색인 일반세균들만 match()함수를 호출한다.
	  탐색범위가 16분의 1로 줄어든다.

	SCORE: 1305
	PASS 

[고찰]
	유사도가 온전하지 않은 상태에서 점수이므로 PASS라고 할 수 없다.
	이제 크기와 각도를 유사도에서 제외하고 생각할 수 있는 방법을 찾을수 있다면
	문제를 해결할 수 있다.

	먼저 크기를 어떻게 유사도에서 제외시킬 수 있을까?
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
	int size, color, simil;
}grr[GLM];

void bufInit() {
	for (int i = 0; i < CLM; ++i) blen[i] = 0;
}

void process()
{
	bufInit();
	int ans = 0;
	int core = 0;

	for (int i = 0; i < GLM; ++i) {
		if (core >= CLM) core = 0;
		info(core, i);
		blen[core] += 5;
		++core;
	}
	gpu_process(buf); // 72점
	for (int i = 0; i < CLM; ++i) {
		for (int j = 0; j < blen[i]; j += 5) {
			int gid = buf[i][j + 1];
			grr[gid] = { buf[i][j + 2], buf[i][j + 4], 0 };
		}
	}

	int tgColor = -1, id = 0;
	while (tgColor < 0 && id < GLM) {
		bufInit();
		for (int core = 0; core < CLM; ++core) {
			match(core, id++);
		}
		gpu_process(buf);
		for (int j = 0; j < CLM; j++) {
			int gid = buf[j][1];
			if (buf[j][2] == 0) {
				tgColor = grr[gid].color;
				ans++;
			}
		}
	}

	bufInit();
	core = 0;
	for (int i = id; i < GLM; ++i) {
		if (core >= CLM) core = 0;
		if (grr[i].color != tgColor) continue;
		match(core, i);
		blen[core] += 3;
		++core;
	}
	gpu_process(buf);
	for (int i = 0; i < CLM; ++i) {
		for (int j = 0; j < blen[j]; j += 3) {
			if (buf[i][j + 2] == 0)
				ans++;
		}
	}

	result(ans);
}
```
