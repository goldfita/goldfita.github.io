//Todd Goldfinger
#include <iostream>
#include <string>
#include <math.h>
#include "sga.h"

using namespace std;

const double PI = 3.14159265358979323;

void pixel(float x, float y);
void rectangle(float &x, float &y, float &xn, float &yn, float &p);
void koch(float &x, float &y, float &xn, float &yn, float &p);
void fern(float &x, float &y, float &xn, float &yn, float &p);
void random1(float &x, float &y, float &xn, float &yn, float &p);
void my_fern(float &x, float &y, float &xn, float &yn, float &p);
void castle(float &x, float &y, float &xn, float &yn, float &p);

void main()
{
	float x = 0.0;
	float y = 0.0;
	float xn, yn, p;

	srand((unsigned) time(NULL));
	for(long i = 0; i < 200000; i++) {
		p = (float)(rand() % 100) / (float)99;
		
		castle(x, y, xn, yn, p);
		pixel(xn, yn);

		x = xn;
		y = yn;
	}

	ShowGraphics();
}

void pixel(float x, float y)
{
	pDC->MoveTo(x * 60+300, 600 - y * 60);
	pDC->LineTo(x * 60 + 1+300, 600 - y * 60);
}

void rectangle(float &x, float &y, float &xn, float &yn, float &p)
{
	if(p < .1) {
		xn = .5 * x;
		yn = .5 * y;
	}
	else if(p < .3) {
		xn = .5 * x + 1.5;
		yn = .5 * y;
	}
	else if(p < .6) {
		xn = .5 * x;
		yn = .5 * y + .5;
	}
	else if(p < 1) {
		xn = .5 * x + 1.5;
		yn = .5 * y + .5;
	}
}

void koch(float &x, float &y, float &xn, float &yn, float &p)
{
	if(p < .1) {
		xn = (float)1/3 * x;
		yn = (float)1/3 * y;
	}
	else if(p < .3) {
		xn = (float)1/3 * cos(PI/180*60) * x - (float)1/3 * sin(PI/180*60) * y + (float)1/3;
		yn = (float)1/3 * cos(PI/180*60) * y + (float)1/3 * sin(PI/180*60) * x;
	}
	else if(p < .6) {
		xn = (float)1/3 * cos(-PI/180*60) * x - (float)1/3 * sin(-PI/180*60) * y + (float)1/2;
		yn = (float)1/3 * cos(-PI/180*60) * y + (float)1/3 * sin(-PI/180*60) * x + (float)1/3 * sin(PI/180*60);
	}
	else if(p < 1) {
		xn = (float)1/3 * x + (float)2/3;
		yn = (float)1/3 * y;
	}
}

void fern(float &x, float &y, float &xn, float &yn, float &p)
{
	if(p < .2) {
		xn = .85 * cos(-2.5*PI/180) * x - .85 * sin(-2.5*PI/180) * y;
		yn = .85 * sin(-2.5*PI/180) * x + .85 * cos(-2.5*PI/180) * y + 1.6;
	} else if(p < .3) {
		xn = .3 * cos(49*PI/180) * x - .34 * sin(49*PI/180) * y;
		yn = .3 * sin(49*PI/180) * x + .34 * cos(49*PI/180) * y + 1.6;
	} else if(p < .4) {
		xn = .3 * cos(120*PI/180) * x - .37 * sin(-50*PI/180) * y;
		yn = .3 * sin(120*PI/180) * x + .37 * cos(-50*PI/180) * y + .44;
	} else if(p < 1) {
		xn = 0;
		yn = (float).16 * y;
	}
}

void random1(float &x, float &y, float &xn, float &yn, float &p)
{
	/*if(p < .3) {
		xn = .8 * x;
		yn = .4 * x + 1.3 * y;
	} else if(p < .6) {
		xn = .4 * x + .2 * y + .7;
		yn = .4 * y + .1;
	} else if(p < 1) {
		xn = float(1/3) * x + (float)(1/3);
		yn = x + y + (float)(1/3) - .2;
	}*/


	if(p < .3) {
		xn = .85 * cos(10*PI/180) * x - .2 * sin(10*PI/180) * y;
		yn = .85 * sin(10*PI/180) * x + .2 * cos(10*PI/180) * y ;
	} else if(p < .5) {
		xn = 1.4 * cos(20*PI/180) * x - 1.1 * sin(90*PI/180) * y + .4;
		yn = 1.1 * sin(20*PI/180) * x + 1.1 * cos(90*PI/180) * y + .4;
	} else if(p < 1) {
		xn = .9 * cos(50*PI/180) * x - .9 * sin(30*PI/180) * y;
		yn = .9 * sin(50*PI/180) * x + .9 * cos(30*PI/180) * y + .1;
	}
}

void my_fern(float &x, float &y, float &xn, float &yn, float &p)
{
	/*if(p < .7225) {
		xn = .85 * cos(4*PI/180) * x - .85 * sin(4*PI/180) * y;
		yn = .85 * sin(4*PI/180) * x + .85 * cos(4*PI/180) * y + 1.6;
	} else if(p < .8245) {
		xn = .25 * cos(-70*PI/180) * x - .3 * sin(70*PI/180) * y;
		yn = .25 * sin(-70*PI/180) * x + .3 * cos(70*PI/180) * y + .6;
	} else if(p < .9338) {
		xn = .25 * cos(-70*PI/180) * x - .3 * sin(-42*PI/180) * y;
		yn = .25 * sin(-70*PI/180) * x + .3 * cos(-42*PI/180) * y + .8;
	} else if(p < 1) {
		xn = 0;
		yn = (float).2 * y;
	}*/

	/*if(p < .72) {
		xn = .85 * cos(-2*PI/180) * x - .85 * sin(-2*PI/180) * y;
		yn = .85 * sin(-2*PI/180) * x + .85 * cos(-2*PI/180) * y + 2.5;
	} else if(p < .9) {
		xn = .3 * cos(-45*PI/180) * x - .5 * sin(-45*PI/180) * y ;
		yn = .3 * sin(-45*PI/180) * x + .5 * cos(-45*PI/180) * y + .6;
	} else if(p < 1) {
		xn = .3 * cos(45*PI/180) * x - .4 * sin(45*PI/180) * y ;
		yn = .3 * sin(45*PI/180) * x + .4 * cos(45*PI/180) * y + .7;
	} else if(p < 1.12) {
		xn = .2 * cos(-45*PI/180) * x - .5 * sin(-45*PI/180) * y ;
		yn = .2 * sin(-45*PI/180) * x + .5 * cos(-45*PI/180) * y + 1.6;
	} else if(p < 1.24) {
		xn = .2 * cos(45*PI/180) * x - .5 * sin(45*PI/180) * y ;
		yn = .2 * sin(45*PI/180) * x + .5 * cos(45*PI/180) * y + 1.7;
	} else if(p < 1.34) {
		xn = .2 * cos(-45*PI/180) * x - .4 * sin(-45*PI/180) * y ;
		yn = .2 * sin(-45*PI/180) * x + .4 * cos(-45*PI/180) * y + 2.8;
	} else if (p < 1.35) {
		xn = 0;
		yn = (float).2 * y;
	}*/
	/*if(p < .6) {
		xn = .85 * cos(0*PI/180) * x - .7 * sin(0*PI/180) * y;
		yn = .85 * sin(0*PI/180) * x + .7 * cos(0*PI/180) * y + 1.5;
	} else if (p < .78) {
		xn = .3 * cos(-55*PI/180) * x - .6 * sin(-55*PI/180) * y-.5;
		yn = .3 * sin(-55*PI/180) * x + .6 * cos(-55*PI/180) * y + 1.3;
	} else if (p < .96) {
		xn = .3 * cos(55*PI/180) * x - .6 * sin(55*PI/180) * y+.5;
		yn = .3 * sin(55*PI/180) * x + .6 * cos(55*PI/180) * y + 1.3;
	} else if (p < 1) {
		xn = 0;
		yn = .1 * y;
	}*/
}

void castle(float &x, float &y, float &xn, float &yn, float &p)
{
	if(p < .25) {
		xn = .5 * x;
		yn = .5 * y;
	} else if (p < .5) {
		xn = .5 * x + 2;
		yn = .5 * y;
	} else if (p < .75) {
		xn = .4 * x;
		yn = .4 * y + 1;
	} else if (p < 1) {
		xn = .5 * x + 2;
		yn = .5 * y + 1;
	}
}