// main.cpp :  Lab XXX, CS XXX or IFYCSEM, Section XXX.
// Written by YOUR NAME(s) and BOX NUMBER(s).
// Completed on DATE.
// This is a RHIT Console program. Use ShowGraphics() to show graphics.

// This program XXX describe what the program does XXX.

#include <iostream>
#include <string>
#include "sga.h"

using namespace std;

void main()
{
	float x = 0, y = 0, x_prev = 0, y_prev = 0;
	float a = 1.4, b = .3;
	for(int n = 0; n < 10000; n++) {
		x = 1 + y_prev - a * x_prev * x_prev;
		y = b * x_prev;
		x_prev = x;
		y_prev = y;
		pDC->MoveTo(x * 200 + 300, 500 - y * 200);
		pDC->LineTo(x * 200 + 301, 500 - y * 200);
	}
	ShowGraphics();
}
