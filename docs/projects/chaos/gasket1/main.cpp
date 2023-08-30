/* Todd Goldfinger
	draws the Sierpinski gasket using the chaos game */

#include <iostream>
#include <string>
#include <cmath>
#include "sga.h"

using namespace std;

#define SCALE 500  //size I want my gasket to be

#define MARKER1X 0 * SCALE
#define MARKER1Y 0 * SCALE

#define MARKER2X 1 * SCALE
#define MARKER2Y 0 * SCALE

#define MARKER3X .5 * SCALE
#define MARKER3Y sqrt(3)/2 * SCALE

void init(POINT *location);
void chooseMarker1(POINT *location);//problem number 1
void chooseMarker2(POINT *location);//problem number 2

void main()
{
	/* iterate through the points, each time moving to the new location
	and placing a pixel there */

	POINT *youAreHere = (POINT *)malloc(sizeof(POINT));
	init(youAreHere);
	
	for(int i = 0; i < 100000; i++) {
		youAreHere->y = MARKER3Y - youAreHere->y;//flip the y coordinate so
												 // my gasket is right side up
		pDC->MoveTo(*youAreHere);
		youAreHere->x += 1;  /* I don't know how to do points; so, I'm using
							 MoveTo and LineTo instead.  I have to add one to
							 one of the coordinates or it won't draw anything.*/
		pDC->LineTo(*youAreHere);
		youAreHere->x -= 1;//fix x coordinate
		youAreHere->y = MARKER3Y - youAreHere->y;//flip y coordinate back
		chooseMarker1(youAreHere);//select a new random point
	}
	ShowGraphics();
	free(youAreHere);
}

void init(POINT *location)
{
	srand((unsigned) time(NULL));
	location->x = rand() % SCALE;//choose an initial random point
	location->y = rand() % SCALE;
}

void chooseMarker1(POINT *location)
{
	/*select a random pont with probablilty 1/3 and move half way to it*/
	int choice = rand() % 3;

	if(choice == 0) {
		location->x = (location->x + MARKER1X)/2;
		location->y = (location->y + MARKER1Y)/2;
	}
	if(choice == 1) {
		location->x = (location->x + MARKER2X)/2;
		location->y = (location->y + MARKER2Y)/2;
	}
	if(choice == 2) {
		location->x = (location->x + MARKER3X)/2;
		location->y = (location->y + MARKER3Y)/2;
	}
}

void chooseMarker2(POINT *location)
{
	/*select a random pont with probablilty 2/3,1/6,1/6 and move half way to it*/
	int choice = rand() % 6;

	if(choice < 3) {/* 2/3 */
		location->x = (location->x + MARKER1X)/2;
		location->y = (location->y + MARKER1Y)/2;
	}
	if(choice == 4) {
		location->x = (location->x + MARKER2X)/2;
		location->y = (location->y + MARKER2Y)/2;
	}
	if(choice == 5) {
		location->x = (location->x + MARKER3X)/2;
		location->y = (location->y + MARKER3Y)/2;
	}
}