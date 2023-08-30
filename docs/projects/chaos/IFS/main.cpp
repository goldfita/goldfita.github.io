//Todd Goldfinger
#include <iostream>
#include <string>
#include <math.h>
#include "sga.h"

using namespace std;

long size = 1;
const int NUM_MAPS = 4;
const double PI = 3.14159265358979323;

typedef struct point {
	float x;
	float y;
} Point;

void twigCode(Point *p1, Point *p2);
void fernCode(Point *p1, Point *p2);

void main()
{
	Point *p1, *p2;
	
	p1 = new Point[size];
	p1[0].x = 0;
	p1[0].y = 0;

	for(long i = 0; i < 5; i++) {
		p2 = new Point[size*NUM_MAPS];
		fernCode(p1, p2);
		delete p1;
		size *= NUM_MAPS;

		p1 = new Point[size*NUM_MAPS];
		fernCode(p2, p1);
		delete p2;
		size *= NUM_MAPS;
	}
	for(i = 0; i < size; i++) {
		p1[i].x = 50 * p1[i].x + 100;
		p1[i].y = 50 * p1[i].y;
		pDC->MoveTo(p1[i].x, p1[i].y);
		p1[i].x += 1;
		pDC->LineTo(p1[i].x, p1[i].y);
	}
	ShowGraphics();
	delete p1;
}

void twigCode(Point *p1, Point *p2)
{
	for(int i = 0, j = 0; i < size; i++) {
		p2[j].x = p1[i].x * -.467 + p1[i].y * .02 + .4;
		p2[j++].y = p1[i].x * -.113 + p1[i].y * .015 + .4;

		p2[j].x = p1[i].x * .387 + p1[i].y * .43 + .256;
		p2[j++].y = p1[i].x * .43 + p1[i].y * -.387 + .522;

		p2[j].x = p1[i].x * .441 + p1[i].y * -.091 + .421;
		p2[j++].y = p1[i].x * -.009 + p1[i].y * -.322 + .505;
	}
}

void fernCode(Point *p1, Point *p2)
{
	for(int i = 0, j = 0; i < size; i++) {
		p2[j].x = .85 * cos(-2.5*PI/180) * p1[i].x - .85 * sin(-2.5*PI/180) * p1[i].y;
		p2[j++].y = .85 * sin(-2.5*PI/180) * p1[i].x + .85 * cos(-2.5*PI/180) * p1[i].y + 1.6;

		p2[j].x = .3 * cos(49*PI/180) * p1[i].x - .34 * sin(49*PI/180) * p1[i].y;
		p2[j++].y = .3 * sin(49*PI/180) * p1[i].x + .34 * cos(49*PI/180) * p1[i].y + 1.6;

		p2[j].x = .3 * cos(120*PI/180) * p1[i].x - .37 * sin(-50*PI/180) * p1[i].y;
		p2[j++].y = .3 * sin(120*PI/180) * p1[i].x + .37 * cos(-50*PI/180) * p1[i].y + .44;

		p2[j].x = 0;
		p2[j++].y = (float).16 * p1[i].y;
	}
}