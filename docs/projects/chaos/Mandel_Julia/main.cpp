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

void Mandelbrot();
void Mandelbrot2();
void Mandelbrot3();
void Julia();

void main()
{
	Julia();
	//Mandelbrot();
	ShowGraphics();
}

void Mandelbrot() {
	float a, b, tmp_a, a_original, b_original;
	int iter;

	for(int y = 300; y >= -300; y--) {
		for(int x = -300; x <= 300; x++) {
			a_original = a = (float)x/150;
			b_original = b = (float)y/150;
			for(iter = 0; iter < 600; iter++) {
				tmp_a = a;
				a = a * a - b * b + a_original;
				b = 2 * b * tmp_a + b_original;
				if(a * a + b * b > 4) break;
			}
			if(iter >= 599) {
				pDC->MoveTo(x + 350, 600 - (y + 300));
				pDC->LineTo(x + 351, 600 - (y + 300));
			}
		}
	}
}

void Mandelbrot2() {
	float a, b, tmp_a, a_original, b_original;
	int iter;

	for(int y = 300; y >= -300; y--) {
		for(int x = -300; x <= 300; x++) {
			a_original = a = (float)x/150;
			b_original = b = (float)y/150;
			for(iter = 0; iter < 600; iter++) {
				tmp_a = a;
				a = a * a * a - 3 * a * b * b + a_original;
				b = 3 * tmp_a * tmp_a * b - b * b * b + b_original;
				if(a * a + b * b > 4) break;
			}
			if(iter >= 599) {
				pDC->MoveTo(x + 350, 600 - (y + 300));
				pDC->LineTo(x + 351, 600 - (y + 300));
			}
		}
	}
}

void Mandelbrot3() {
	float a, b, tmp_a, a_original, b_original;
	int iter;

	for(int y = 300; y >= -300; y--) {
		for(int x = -300; x <= 300; x++) {
			a_original = a = (float)x/150;
			b_original = b = (float)y/150;
			for(iter = 0; iter < 600; iter++) {
				tmp_a = a;
				a = a*a_original-b*b_original-a*a*a_original+b*b*a_original+2*b_original*a*b;
				b = a_original*b+b_original*tmp_a-2*a_original*tmp_a*b-tmp_a*tmp_a*b_original+b*b*b_original;
				if(a * a + b * b > 4) break;
			}
			if(iter >= 599) {
				pDC->MoveTo(x + 350, 600 - (y + 300));
				pDC->LineTo(x + 351, 600 - (y + 300));
			}
		}
	}
}

void Julia() {
	float a = .25, b = 0, x = -.75, y = .1, tmp;
	
	srand((unsigned) time(NULL));
	for(int pts = 0; pts <= 200000; pts++) {
		a = a - x;
		b = b - y;
		if(a > 0) {
			a = sqrt((a + sqrt(a*a + b*b))/2);
			b = b/(2*a);
		} else if (a < 0) {
			tmp = b;
			b = sqrt((sqrt(a*a + b*b) - a)/2);
			if(b < 0) b = -b;
			a = tmp/(2*b);
		} else {
			a = sqrt(abs(b)/2);
			if(a > 0) b = b/(2*a);
			else b = 0;
		}
		if(pts == 0) a += .5;
		if(rand() % 100 < 50) {
			a = -a;
			b = -b;
		}
		pDC->MoveTo(a*100 + 350, 600 - (b*100 + 300));
		pDC->LineTo(a*100 + 351, 600 - (b*100 + 300));
	}
}