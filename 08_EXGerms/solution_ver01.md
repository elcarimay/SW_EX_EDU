```cpp
/*
45_EXGerms_user_ver01

[해법 연구1]
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
4. 각도차이를 고려대상에서 제외하는 방법은 match()의 각도차를 계산하는 식에서 힌트를 얻을수 있다.
   각도 차이 diff각 180미만이라면 diff를 180이상이라면 360-diff를 뺀 값을 반환하므로
   1st match에서 얻은 sim1 = 각도차1 + 크기차 + etc(색차:0 + 유형차:0)이고
   rotate(180)을 한 후에
   2nd match에서 얻은 sim2 = 각도차2 + 크기차 + etc(색차:0 + 유형차:0)이다.
   sim1 + sim = 180(각도차1 + 각도차2) + 크기차*2 + 0 인 경우가 찾는 경우가 된다.

   결론적으로 sim1 + sim == 180 + 크기차 *2 인 경우를 찾으면 된다.
   
SCORE: 1718
PASS

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
	// 0번 세균은 target세균의 크기를 알아내는 목적으로 사용
	info(0, 0);        // 0번 세균의 크기, 조정각, 색 저장
	scale(0, 0, -10);  // 0번 세균의 크기를 10줄이기
	match(0, 0);       // 0번 세균의 유사도1 구하기
	scale(0, 0, 20);   // 0번 세균의 크기를 20 크게 하기
	match(0, 0);       // 0번 세균의 유사도2 구하기

	int ans = 0;
	int core = 1;
	for (int i = 1; i < GLM; ++i) {
		if (core >= CLM) core = 1;
		info(core, i);
		blen[core] += 5;
		++core;
	}
	gpu_process(buf);

	// 0번 세균 정보저장 & target세균의 크기 알아내기
	int a = buf[0][2], tgSize = a + (buf[0][7] - buf[0][10]) / 2;
	grr[0] = {a + 10, buf[0][4], 0};

	// 1~999999세균의 크기, 색을 백업
	for (int i = 1; i < CLM; ++i) {
		for (int j = 0; j < blen[i]; j += 5) {
			int gid = buf[i][j + 1];
			grr[gid] = {buf[i][j + 2], buf[i][j + 4], 0};
		}
	}

	// 16384단위로 일반세균을 검색하며 target의 색 알아내기
	int tgColor = -1, id = 0;
	while (tgColor < 0 && id < GLM) {
		for (int i = 0; i < CLM; ++i) {
			match(i, id);
			rotate(i, id, 180);
			match(i, id);
			++id;
		}
		gpu_process(buf);
		for (int i = 0; i < CLM; ++i) {
			int gid = buf[i][1];
			int simSum = buf[i][2] + buf[i][5];
			if (simSum == 180 + Abs(tgSize - grr[gid].size) * 2) {
				tgColor = grr[gid].color;
				ans++;
			}
		}
	}

	bufInit();
	core = 0;
	for (; id < GLM; ++id) {
		if (core >= CLM) core = 0;
		if (tgColor != grr[id].color) continue; // 색이 다른 경우는 제외하고
		match(core, id);
		rotate(core, id, 180);
		match(core, id);
		blen[core] += 6;
		++core;
	}
	gpu_process(buf);

	for (int i = 0; i < CLM; ++i) {
		for (int j = 0; j < blen[i]; j += 6) {
			int gid = buf[i][j + 1];
			int simSum = buf[i][j + 2] + buf[i][j + 5];
			if (simSum == 180 + Abs(tgSize - grr[gid].size) * 2)
				ans++;
		}
	}

	result(ans);
}
```
