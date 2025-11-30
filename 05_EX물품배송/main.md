```cpp
/*
31_EX물품배송_main

[문제 구조] :
  1. TC가 1개뿐(subTC가 없다)인 문제이다. => 안테나배정과 대비된다.(문제의 다양성)
  2. 원격으로 배송을 처리해야하는 interactive 문제이다.
	 main에 있는 트럭을 이용하여, main에 있는 센터에서 물품을 적재한 후, main에 있는 배송지에 배송한다.
	 <이러한 문제의 경우 일반적인 처리방법>
	  : user.cpp에 main.cpp의 아바타 트럭, 센터, 배송지를 준비하여 main과 동시에 움직인다.
	  : 기출예제 문제 [로봇청소기4]
  3. 센터, 물품, 트럭, 배송지 라는 주체가 등장한다.
	 센터, 트럭, 배송지 주체가 물품을 매개로 연결성을 가진다.

[문제 개요]
  1000*1000 맵이 주어진다.
  1. 센터 : 1000개, 중복되지 않도록 램덤하게 배치된다.
	(1) 2차원 좌표와 아이디(0~999)를 갖는다.
	(2) 하나의 센터는 10000개의 물품중에 {물품번호, 개수(1~100)} 목록을 1~100개 갖는다.
		따라서 최대 1~10000개의 물품을 배정받을 수 있다.
  2. 물품 : 10000개 종류가 있다. 아이디(0~9999)를 갖는다.
  3. 트럭 :
	(1) 좌표를 갖는다.
	(2) 최대 50개를 적재할 공간을 갖는다.
	(3) 물품을 맨해튼 거리로 배송할 때 사용된다.
  4. 배송지 : 1백만개가 있다.
	(1) 좌표(중복가능)와 아이디(0~999999)를 갖는다.
	(2) 받고자 하는 물품 하나의 아이디를 배정받는다.
		=> 하나의 배송지가 여러 개를 받을 수 있는가? => 좌표가 중복생성되는 것을 통하여 가능하다.
  5. 최종 유효성 검사
	: 모든 배송지에는 배송지가 원하는 물품이 반드시 배송완료 되어야한다.
	: 데이터는 이것이 가능하도록 만들어져 있다.
  6. 점수 계산
	(1) 센터로 이동시          : 맨해튼거리 * (100 + 트럭에적재된물품수 * 10)
	(2) 배송지에 물품을 배송시 : 맨해튼거리 * (100 + 트럭에적재된물품수 * 10)
	   거리와 적재된 물품수에 비례하여 비용이 증가한다.
	   물품이 없어도(빈차라도) 거리*100의 비용이 추가된다.

[해야 할일]
  * 유저는 main.cpp의 트럭을 이용하여 main.cpp에 있는 센터에서 물품을 싣고
	main.cpp에 있는 배송지가 원하는 물품을 배송해야 한다.
  * 가능한 최소의 점수로 모든 물품을 배송하시오.

[유저가 완성할 API함수]
  * void sendCenterList(int N, int M, Coordinates centerCoordinatesList[], Product centerProductList[][100], int centerProductSize[])
	: 센터수(1천 고정), 물품종류수(1만 고정), 센터 좌표, 센터에 할당된 물품 목록, 물품목록 길이
  * void sendDeliveryList(int K, Coordinates deliveryCoordinatesList[],	int deliveryProductList[])
	: 배송지 수(1백만 고정), 배송지 좌표, 배송지가 받을 물품 아이디
  * void solve(Coordinates truckCoordinates)
	: main.cpp에 정의된 트럭의 초기위치 - 트럭은 비어있다.

[배송을 위하여 유저가 사용하는 main에 정의된 API함수]
  * int truckMove(int deliveryID) : deliveryID 배송지에 배송할 때 사용 => 최소 100만번 호출해야 한다.
	트럭을 이동시키고 배송 비용을 계산한다.
	1. deliveryID가 유효하지 않다면 0을 반환
	2. deliveryID가 원하는 물품이 트럭에 없다면 0을 반환
  * int truckLoading(int centerID, int packageList[], int listSize) : 센터에서 물품 적재하기
	1. centerID 유효성 검사
	2. listSize(적재요청수)+트럭에적재중인 물품수가 50을 초과할 수 없다.
	3. centerID 센터에 packageList[i]물품이 없다면 적재하지 못한다.
	4. listSize만큼 적재한 경우 1을반환한다.

[문제 분석]
  * 구현 자유도가 높다.
	우리가 *팡 배송기사라고 생각해보자.
	배송트럭을 타고 센터에 갔는데 물품만 있고 배송지가 없는 상황이다. 어떻게 해야 하나?
	일단 물건부터 싣고 배송지를 찾아 다녀야 할까?
	[EX안테나배정]에서는 안테나-유닛이 직접 연결되는데
	이문제에서는 센터와 배송지 사이에 트럭과 물품을 매개로 연결된다. ㅠㅠㅠ
  * 문제의 요구조건이 복잡하고 어려우므로 요구조건을 줄여서 생각해 볼 수 있을가?
  * 현실세계에서 우리가 *팡 배송기사라고 생각해 보자.
	현실세계라면 *팡 배송트럭이 센터가 간 경우 배송지가 적힌 물품을 받는다.
	배송기사는 배송 우선순위만 생각하여 배송한다. 이를 이용하면 어떨까?
	(1) 배송지를 센터에 할당하기
		배송지가 원하는 물품을 가진 가장 가까운 센터에 배송지를 배정한다. => 배송지 우선순위는?
	(2) 트럭이 센터를 선택하기
		빈 트럭이라면 가장 가까운 센터로 가기
		물품을 적재중이라면 가장 가까운 배송지로 가기 => 배송 우선순위는?
*/
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif

#include <stdio.h>
#include <string.h>

#define ABS(x)    ((x) > 0 ? (x) : -(x))

static unsigned long long seed = 5;

static int pseudo_rand(void)
{
	seed = seed * 25214903917ULL + 11ULL;
	return (seed >> 16) & 0x3fffffff;
}

struct Coordinates
{
	int y;
	int x;
	Coordinates() {
		y = x = 0;
	}
	Coordinates(int _y, int _x) {
		y = _y;
		x = _x;
	}
	int operator-(Coordinates& param) {  // 맨해튼 거리
		return ABS(y - param.y) + ABS(x - param.x);
	}
};

struct Product
{
	int id;
	int count;

	Product() {
		id = count = 0;
	}
	Product(int _id, int _count) {
		id = _id;
		count = _count;
	}
};

static const long long PENALTY = 1'000'000'000'000;         // 벌점 1조

static int center_map[1000][1000];                          // 센터 중복생성 방지를 위하여 체크하는 용도로 사용
static Coordinates center_coordinates_list[1000];           // 센터 아이디별 좌표 목록
static Coordinates center_coordinates_list_bak[1000];
static Product center_product_list[1000][100];              // 세넡 아이디별 물품 목록
static Product center_product_list_bak[1000][100];
static int center_product_size[1000];                       // 세넡 아이디별 물품 목록 길이
static int center_product_size_bak[1000];

static Coordinates delivery_coordinates_list[1000000];      // 배송지 좌표 목록
static Coordinates delivery_coordinates_list_bak[1000000];
static int delivery_order_list[1000000];                    // 배송지별 수령할 물품 아이디 목록
static int delivery_order_list_bak[1000000];

static int product_stock_count[10000];                      // 물품 아이디별 재고 수
static Coordinates truck_pos;                               // 트럭의 위치
static int truck_package_list[50];                          // 트럭에 적재된 물품 아이디 목록
static int truck_package_count;                             // 트럭에 적재된 물품 아이디 목록 길이

static long long SCORE = 0;

extern void sendCenterList(int, int, Coordinates[], Product[][100], int[]);
extern void sendDeliveryList(int, Coordinates[], int[]);
extern void solve(Coordinates);

// user.cpp에서 배송시 호출하여 사용하는 함수
int truckMove(int deliveryID) // 배송지 아이디를 전달
{
	if (deliveryID < 0 || deliveryID >= 1000000)  // 배송지 아이디 유효성 검사
		return 0;

	Coordinates dest_pos = delivery_coordinates_list[deliveryID]; // 배송지 위치
	int dist = dest_pos - truck_pos;  // 트럭이 이동하는 맨해튼 거리 계산

	SCORE += dist * (100 + truck_package_count * 10); // 점수 계산: 거리와 적재된 물품수에 비례하여 증가한다.
	truck_pos = dest_pos;   // 트럭을 deliveryID배송지 위치로 이동

	int& product_id = delivery_order_list[deliveryID]; // 배송지가 받을 물품아디디를 참조타입으로 저장 => 원본 변경을 위하여
	if (product_id == -1) // 배송지지가 이미 물품을 수령한 경우
		return 0;

	for (int i = 0; i < truck_package_count; i++) { // 트럭에 적재된 물품 중에 product_id물품 찾기
		if (truck_package_list[i] == product_id) {  // 찾은경우
			product_id = -1;                        // 배송완료 표시

			// 마지막 데이터를 현재 위치에 저장하여 현재 데이터를 삭제
			// $$$$$ [실전에 종종 사용하는 기법] $$$$$
			// 배열에서 순서를 유지하면서 삭제할 때 걸리는 시간은 O(N)이다.
			// 그러나 순서가 중요하지 않은 경우 O(1)에 삭제할 수 있다.
			// 마지막 데이터를 삭제하려는 데이터 위치에 복사하고 마지막 데이터를 지우면 된다.
			truck_package_list[i] = truck_package_list[truck_package_count - 1]; // 1. 현재 위치에 마지막 데이터를 복사
			truck_package_count -= 1;                                            // 2. 마지막 데이터 삭제
			return 1;
		}
	}

	return 0;
}

// user.cpp에서 트럭에 물건을 적재할 때 호출하여 사용하는 함수
int truckLoading(int centerID, int packageList[], int listSize) // 센터아이디, 적재할 물품 목록, 목록 길이
{
	// 센터 아이디 유효성 검사
	if (centerID < 0 || centerID >= 1000)
		return 0;

	Coordinates center_pos = center_coordinates_list[centerID]; // 센터 위치 얻기
	int dist = center_pos - truck_pos;

	SCORE += dist * (100 + truck_package_count * 10); // 점수 계산 : 거리*(100+적재된물품수*10)
	truck_pos = center_pos; // 트럭을 센터로 이동

	if (listSize + truck_package_count > 50) // 적재된 물품수는 50을 넘을 수 없다.
		return 0;

	int ret = 0;   // 현재 호출로 적재한 물품수 0으로 초기화

	for (int i = 0; i < listSize; i++) {
		for (int k = 0; k < center_product_size[centerID]; k++) {
			// 물품 아이디가 현재 센터에 존재하고, 재고도 남아 있다면
			if (center_product_list[centerID][k].id == packageList[i] && center_product_list[centerID][k].count > 0) {
				center_product_list[centerID][k].count -= 1;                                   // 센터에서 1개 제거
				truck_package_list[truck_package_count] = center_product_list[centerID][k].id; // 트럭에 적재
				truck_package_count++;                                                         // 트럭에 적재한 물품수 증가

				ret++;  // 현재 호출로 적재한 물품수 증가
				break;
			}
		}
	}

	return ret == listSize ? 1 : 0; // 요청한 물품수 만큼 적재한 경우 1을 그렇지 않은 경우 0을 반환
}

static bool run()
{
	memset(center_map, -1, sizeof(center_map));                  // center_map[1000][1000]전체를 -1로 채우시오
	memset(product_stock_count, 0, sizeof(product_stock_count)); // product_stock_count[1000]전체를 0으로 채우시오. 물품 아이디별 재고를 0으로 초기화

	truck_package_count = 0;  //트럭에 적재된 화물수를 0으로 초기화

	// 센터 정보 생성
	for (int i = 0; i < 1000; i++) {
		int y, x;
		do {
			y = pseudo_rand() % 1000;
			x = pseudo_rand() % 1000;
		} while (center_map[y][x] != -1);  // 센터좌표 생성 : 중복 방지 코드

		center_map[y][x] = i;  // center_map[y][x]에 i센터를 세우기
		center_coordinates_list_bak[i] = center_coordinates_list[i] = Coordinates(y, x);  // i센터위치는 (y, x) 임을 저장

		int P = pseudo_rand() % 100 + 1;  // i센터가 가진 물품 목록의 길이

		center_product_size_bak[i] = center_product_size[i] = P;  // 물품 목록 길이 저장

		// 한 센터당 물품 개수는 : 1 ~ 100*100 이다.
		for (int j = 0; j < P; j++) {     // 물품 목록 길이 만큼 물품정보{물품 아이디, 갯수} 생성
			Product new_product = Product(pseudo_rand() % 10000, pseudo_rand() % 100 + 1);  // 중복된 물품아디디가 생성될 수 있다.
			center_product_list_bak[i][j] = center_product_list[i][j] = new_product; // i센터 물품 목록에 new_product물품 정보 저장
			product_stock_count[new_product.id] += new_product.count;  // 물품 아이디별 재고수 업데이트
		}
	}

	// 배송지 정보 생성
	for (int i = 0; i < 1000000; i++) {
		int id;
		do {
			id = pseudo_rand() % 10000;
		} while (product_stock_count[id] == 0); // 재고가 남아 잇는 물품아이디 고르기

		//배송지 위치 생성 : 중복된 위치가 생성될 수 있다.
		delivery_coordinates_list_bak[i] = delivery_coordinates_list[i] = Coordinates(pseudo_rand() % 1000, pseudo_rand() % 1000);
		delivery_order_list_bak[i] = delivery_order_list[i] = id; // i배송지가 받을 물품 아이디

		product_stock_count[id] -= 1;  // id 물품 재고 감소
	}

	// 트럭의 초기 위치를 랜덤하게 생성
	truck_pos = Coordinates(pseudo_rand() % 1000, pseudo_rand() % 1000);

	// 사용자가 완성할 API함수 호출
	// 센터수:1000으로 고정, 물품종류수:10000으로 고정, 센터별좌표목록, 센터별 물품정보 목록, 센터별 물품정보 목록의 길이
	sendCenterList(1000, 10000, center_coordinates_list_bak, center_product_list_bak, center_product_size_bak);

	// 배송지수: 100만으로 고정, 배송지별 좌표 목록, 배송지별 받을 물품 아이디 목록
	sendDeliveryList(1000000, delivery_coordinates_list_bak, delivery_order_list_bak);

	// 트럭의 초기위치 전달, 초기에 트럭은 적재한 물품이 없다.
	solve(truck_pos);

	// 유효성 검사 : 모든 배송지가 원하는 물품을 받았는가?
	for (int i = 0; i < 1000000; i++) {
		if (delivery_order_list[i] >= 0)
			return false;  // 1곳이라도 받지 못한 경우 false => 1조의 벌점
	}

	return true; // 모든 배송지가 원하는 물품을 받은 경우
}

int main()
{
#ifndef ONLINE_JUDGE
	freopen("outputMap.txt", "w", stdout);
#endif // ONLINE_JUDGE


	setbuf(stdout, NULL);

	if (run() == false) {  // TC가 1개뿐이다. !!!
		printf("SCORE: %lld\n", PENALTY);
		return 0;
	}

	printf("SCORE: %lld\n", SCORE);

	// 본 사이트의 cut score 이므로 실제 시험 결과와 다를 수 있음 /////////
	if (SCORE < 13'000'000'000) {  // 130억점 컷
		puts("PASS");
	}
	else {
		puts("FAIL");
	}
	////////////////////////////////////////////////////////////////////

	return 0;
}

```
