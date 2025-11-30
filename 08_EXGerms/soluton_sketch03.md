```cpp
/*
45_EXGerms_user_sketchCode03

[sketchCode03]
1. sketchCode02에서 유사도에 크기차이를 반영한 버전이다.
2. 만일 target세균의 크기를 알고있다면 유사도는 크기차이만 남는다.
   info()를 통하여 모든 일반세균의 크기는 알수있으므로
   target세균의 크기를 알아낼 수 있다면 현재 문제를 해결할 수 있다.
3. target세균의 크기를 알아내기
   1) grr[0]번 세균의 크기를 a, target세균의 크기를 b라고 하자.
   2) grr[0]번 세균의 크기를 10만큼 감소시킨다. 크기는 a-10이 된다.
      그리고 유사도를 구한다. sim1 = abs((a - 10) - b) + etc(색차 + 유형차)
	  절대값을 벗기면 sim1 = b - a + 10 + etc
   3) grr[0]번 세균의 크기를 20만큼 증가시킨다. 크기는 a+10이 된다.
	  그리고 유사도를 구한다. sim2 = abs((a + 10) - b) + etc(색차 + 유형차)
	  절대값을 벗기면 sim2 = -b + a + 10 + etc
   4) sim1에서 sim2를 변변 빼준다.
      sim1 - sim2 = 2b -2a => (sim1-sim2) + 2a = 2b
	  정리하면 b = (sim1 - sim2)/2 + a
	SCORE: 1305
	PASS

[고찰]
	유사도가 온전하지 않은 상태에서 점수이므로 PASS라고 할 수 없다.
	이제 각도를 유사도에서 제외하고 생각할 수 있는 방법을 찾을수 있다면
	문제를 해결할 수 있다.

	각도를 어떻게 유사도에서 제외시킬 수 있을까?

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
#define Abs(a) ((a) < 0? -(a):(a))

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
	int core = 1;
	info(0, 0);
	scale(0, 0, -10); // 0번 세균의 크기를 10감소
	match(0, 0);      // 0번 세균의 sim1 구하기
	scale(0, 0, 20);  // 0번 세균의 크기를 20증가
	match(0, 0);      // 0번 세균의 sim2 구하기

	// 1 ~ 999999 세균은 1~16383코어를 사용하도록한다.
	// 점수에 변화가 없으면서 처리가 비교적 간단해진다.
	for (int i = 1; i < GLM; ++i) {
		if (core >= CLM) core = 1;
		info(core, i);
		blen[core] += 5;
		++core;
	}
	gpu_process(buf); // 72점

	// 0번 세균정보 저장 및 target세균 크기 구하기
	grr[0] = { buf[0][2] + 10, buf[0][4], 0 };
	int b = (buf[0][7] - buf[0][10]) / 2 + buf[0][2];

	for (int i = 1; i < CLM; ++i) {
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
			if (buf[j][2] == Abs(b - grr[gid].size)) { // 크기차이만 남는다면 원하는 경우이다.
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
			int gid = buf[i][j + 1];
			if (buf[i][j+2] == Abs(b - grr[gid].size)) // 크기차이만 남는다면 원하는 경우이다.
				ans++;
		}
	}

	result(ans);
}
```
