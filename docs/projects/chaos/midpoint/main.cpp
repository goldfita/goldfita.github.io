// main.cpp :  Lab XXX, CS XXX or IFYCSEM, Section XXX.
// Written by YOUR NAME(s) and BOX NUMBER(s).
// Completed on DATE.
// This is a RHIT Console program. Use ShowGraphics() to show graphics.

// This program XXX describe what the program does XXX.

#include <iostream>
#include <string>
#include <math.h>
#include "sga.h"

using namespace std;

int const LEN = 700;

typedef struct pt {
	float x;
	float y;
} pt;

typedef struct pt3 {
	float x;
	float y;
	float z;
} pt3;

void midpoint(pt p_left, pt p_right, int n);
void midpoint3(pt3 p_left, pt3 p_right, pt3 p_top, int n, char s);

void main()
{
	pt p_left, p_right;
	pt3 p_top;

	p_left.x = p_left.y = p_right.y = 0;
	p_right.x = LEN;
	p_top.x = LEN / 2;
	p_top.y = LEN / 3;
	//p_left.z = p_right.z = p_left.z = 0;
	
	srand((unsigned) time(NULL));
	midpoint(p_left, p_right, 9);
	ShowGraphics();
}

void midpoint(pt p_left, pt p_right, int n)
{

	if(n <= 0) {
		pDC->MoveTo((int)p_left.x + 100, 500 - (int)p_left.y);
		pDC->LineTo((int)p_right.x + 100, 500 - (int)p_right.y);
		return;
	}

	pt mid;
	mid.x = (p_left.x + p_right.x) / 2;
	if(rand() < 16000)
		mid.y = (p_left.y + p_right.y) / 2 + rand() % 50;
	else
		mid.y = (p_left.y + p_right.y) / 2 - rand() % 50;
	midpoint(p_left, mid, n - 1);
	midpoint(mid, p_right, n - 1);
}

void midpoint3(pt3 p_left, pt3 p_right, pt3 p_top, int n, char s)
{

	if(n <= 0) {
		if(s == 'y') {
			pDC->MoveTo((int)p_left.x + 100, 400 - ((int)p_left.y + (int)(p_left.z * .4)));
			pDC->LineTo((int)p_right.x + 100, 400 - ((int)p_right.y + (int)(p_right.z * .4)));
		
			pDC->MoveTo((int)p_left.x + 100, 400 - ((int)p_left.y + (int)(p_left.z * .4)));
			pDC->LineTo((int)p_top.x + 100, 400 - ((int)p_top.y + (int)(p_top.z * .4)));
		
			pDC->MoveTo((int)p_right.x + 100, 400 - ((int)p_right.y + (int)(p_right.z * .4)));
			pDC->LineTo((int)p_top.x + 100, 400 - ((int)p_top.y + (int)(p_top.z * .4)));
		}
		return;
	}
	
	pt3 mid1, mid2, mid3;
	mid1.x = (p_left.x + p_right.x) / 2;
	mid2.x = (p_right.x + p_top.x) / 2;
	mid3.x = (p_left.x + p_top.x) / 2;
	mid1.y = (p_left.y + p_right.y) / 2;
	mid2.y = (p_right.y + p_top.y) / 2;
	mid3.y = (p_left.y + p_top.y) / 2;
	if(rand() < 16000) {
		mid1.z = (p_left.z + p_right.z) / 2 + rand() % 100;
		mid2.z = (p_right.z + p_top.z) / 2 + rand() % 100;
		mid3.z = (p_left.z + p_top.z) / 2 + rand() % 100;
	} else {
		mid1.z = (p_left.z + p_right.z) / 2 - rand() % 100;
		mid2.z = (p_right.z + p_top.z) / 2 - rand() % 100;
		mid3.z = (p_left.z + p_top.z) / 2 - rand() % 100;
	}

	midpoint3(p_left, mid1, mid3, n - 1, 'y');
	midpoint3(mid1, p_right, mid2, n - 1, 'y');
	midpoint3(mid2, p_top, mid3, n - 1, 'y');
	midpoint3(mid1, mid2, mid3, n - 1, 'n');
}