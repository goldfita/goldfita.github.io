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

const MAX_SIZE = 120000;
const STACK_SIZE = 10000;
const double PI = 3.14159265358979323846;
const float ANGLE = 45;
const int NUM_ITERATIONS = 1;

typedef struct heading {
	float x;
	float y;
	float a;
} heading;

char rule[][50] = {
	"F-F+F+F-F",
	"F-F+F+F-F",
	"F-F+F+F-F"
	};

char *iterate(char *axiom, int n);
void draw(char *result);

void main()
{
	char axiom[MAX_SIZE + 1] = "+F";

	srand((unsigned) time(NULL));
	draw(iterate(axiom, NUM_ITERATIONS));
	ShowGraphics();
}

char *iterate(char *axiom, int n)
{
	if(n <= 0)
		return axiom;

	char tmp[MAX_SIZE + 1];
	float p;
	int r;

	for(char *posa = axiom, *post = tmp; *posa != '\0'; posa++) {
		p = (rand() % 100) / (float)99;
		if(p < .33) 
			r = 0;
		else if(p < .67)
			r = 1;
		else 
			r = 2;
		if(MAX_SIZE < (post - tmp) + strlen(rule[r])) {
			cout << "Exceeded MAX_SIZE";
			exit(0);
		}
		if(*posa == 'F') {
			strcpy(post, rule[r]);
			post += strlen(rule[r]);
		} else {
			*post = *posa;
			post++;
		}
		*post = '\0';
	}
	strcpy(axiom, tmp);

	return iterate(axiom, n - 1);
}

void draw(char *result)
{
	heading h;
	heading *stack[STACK_SIZE];
	int level = 0;

	h.x = 0;
	h.y = 0;
	h.a = 0;
	pDC->MoveTo(h.x + 50, 400 - h.y);
	for(char *pos = result; *pos != '\0'; pos++) {
		if(*pos == 'F') {
			h.x += 50 * cos(h.a*PI/180);
			h.y += 50 * sin(h.a*PI/180);
			pDC->LineTo((int)h.x + 50, 400 - (int)h.y);
			pDC->MoveTo((int)h.x + 50, 400 - (int)h.y);
		} else if(*pos == '+')
			h.a += ANGLE;
		else if(*pos == '-')
			h.a -= ANGLE;
		else if(*pos == '[') {
			if(level == STACK_SIZE) {
				cout << "Stack overflow";
				exit(0);
			}
			heading *tmp = new heading;
			tmp->x = h.x;
			tmp->y = h.y;
			tmp->a = h.a;
			stack[level] = tmp;
			level++;
		} else if(*pos == ']') {
			h.x = stack[--level]->x;
			h.y = stack[level]->y;
			h.a = stack[level]->a;
			delete (stack[level]);
			pDC->MoveTo((int)h.x + 50, 400 - (int)h.y);
		}
	}
}