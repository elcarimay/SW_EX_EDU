```cpp
/*
31_EX물품배송_use_analysis
*/
#include <bits/stdc++.h>
using namespace std;

#define ABS(x)    ((x) > 0 ? (x) : -(x))

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

extern int truckMove(int deliveryID);
extern int truckLoading(int centerID, int packageList[], int listSize);
///////////////////////////////////////////////////////////////////////////////////////

enum { LM = 1000, PLM = 10000, DLM = 1000000 };
int cMap[LM][LM], dMap[LM][LM];

void output(int Map[][LM], const char*ment, int sign = 0) {
	int cnt[100] = { 0 };
	printf(" ==== %s =============================================\n", ment);
	for (int i = 0; i < LM; ++i) {
		for (int j = 0; j < LM; ++j) {
			if (Map[i][j]) printf("%d", Map[i][j]);
			else printf(" ");
			if (sign)
				cnt[Map[i][j]] ++;
		}
		puts("");
	}
	if (sign) {
		puts("\n[수령하는 물품 개수별 배송지 수]");
		for (int i = 0; i < 100; ++i) {
			if (cnt[i]) printf("%d : %6d개\n", i, cnt[i]);
		}
	}
	puts("############################################################\n");
}

// N: 센터수 1000고정, M: 물품종류 10000고정, 센터별 좌표 목록, 센터별 물품 목록, 센터별 물품목록 길이
void sendCenterList(int N, int M, Coordinates centerCoordinatesList[], Product centerProductList[][100], int centerProductSize[])
{
	for (int i = 0; i < N; ++i) {
		auto&cd = centerCoordinatesList[i];
		cMap[cd.y][cd.x]++; // 중복이 없다.
	}

	output(cMap, "Center Map", 0);
}

// K : 배송지수 , 배송지 좌표, 배송지별 수령 물품 목록
void sendDeliveryList(int K, Coordinates deliveryCoordinatesList[], int deliveryProductList[])
{
	for (int i = 0; i < K; ++i) {
		auto&cd = deliveryCoordinatesList[i];
		dMap[cd.y][cd.x]++; // 중복이 있다.
	}

	output(dMap, "Delivery Map", 1);
}

void solve(Coordinates truckCoordinates)
{

}
```
