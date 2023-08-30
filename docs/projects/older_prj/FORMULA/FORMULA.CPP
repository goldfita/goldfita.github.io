/* Uses my formula to calculate the following for any complex number:
	Y^(X) + Y^(X - 1) + Y^(X - 2) + . . . + Y^2 + Y^1 + Y^0
	Doesn't work for 1 - undefined - use (X + 1) instead

	Formula:    Y^(X + 1) - 1
					-------------              = (Y^(X + 1) - 1) / (Y - 1)
					  	 Y - 1
	                                       ^ - symbol for power
*/

#include <iostream.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#define i 'i'

unsigned int x;          // Numbers to plug
long double a, b;        // into formula
long double aTop, aBottom, bTop, bBottom;     // copy of variables

void input()             // Gets input - A, B, and X
{
  cout << "Formula:  Y^(X) + Y^(X - 1) + Y^(X - 2) + . . . + Y^2 + Y^1 + Y^0";
  cout << "\n\nEnter the coefficients A and B for any complex ";
  cout << "number Y = A + Bi.\nExample:  -2.4 <return> 7.02";
  cout << "\nDon't use huge numbers or really small ones.\n";
  cout << "This may result in an underflow,";
  cout << " overflow, or inaccurate results.\nA = ";
  cin  >> a;
  cout << "B = ";
  cin  >> b;
  cout << "\nEnter a positive integer X.";
  cout << "  Again, don't use a huge number.\nX = ";
  cin  >> x;
  cout << "\n\n";
}

inline void showEquation()    // print out equation (not solved)
{
  cout << "Answer = ";        // print equation according to size of X
  if (x >= 3) cout << '(' << a << " + " << b << i << ")^" << x << " + ";
  if (x >= 4) cout << '(' << a << " + " << b << i << ")^" << (x - 1) << " + ";
  if (x >= 5) cout << '(' << a << " + " << b << i << ")^" << (x - 2) << " + ";
  if (x >= 6) cout << ". . .\n+ ";  else cout << '\n'; 
  if (x >= 2) cout << '(' << a << " + " << b << i << ")^2 + ";
  if (x >= 1) cout << '(' << a << " + " << b << i << ")^1 + ";
  cout << '(' << a << " + " << b << i << ")^0\n\n";
}

void evaluate_top()         // use    r cis degrees
{
  const long double toDegrees = 180 / M_PI;  // convert to degrees
  const long double toRadians = M_PI / 180;  // convert to radians
  long double r, degrees;   // long double (degrees) - for accuracy

  // change to polar
  r = sqrtl((a * a) + (b * b));
  if (a == 0 && b != 0) degrees = 90;
  else if (a == 0 && b == 0) degrees = 0;
  else degrees = atanl(b / a) * toDegrees;
  if (a < 0) degrees += 180;
  if (degrees == 90 && b < 0) degrees *= -1;

  /* calculate - (r cis degrees)^x = (r^x cis x * degrees) */
  r = powl(r, x + 1);
  degrees = (x + 1) * degrees;

  // simplify degrees to avoid rounding error
  while (degrees >= 360) degrees -= 360;
  while (degrees <= -360) degrees += 360;

  // calculation done - back to rectangular - A + Bi
  aTop = cosl(degrees * toRadians);
  bTop = sinl(degrees * toRadians);
  if (-1E-15 < aTop && aTop < 1E-15) aTop = 0;   // more protection against
  if (-1E-15 < bTop && bTop < 1E-15) bTop = 0;   // rounding error
  aTop *= r;
  bTop *= r;

  // simplify top of equation
  aTop--;
}

inline void evaluate_bottom() { aBottom = a;  aBottom--;  bBottom = b;  }

void simplify()        // multiply top and bottom by complex conjugate
{
  long double middle_foil;
  long double old_aBottom = aBottom, old_bBottom = -bBottom;

  // simplify bottom to A + 0i - FOIL (outers only)
  aBottom *= old_aBottom;
  bBottom *= old_bBottom;
  bBottom *= -1;              // i^2 = -1
  aBottom += bBottom;
  bBottom = 0;

  // simplify top - FOIL (whole thing)
  middle_foil = (aTop * old_bBottom) + (bTop * old_aBottom);
  aTop *= old_aBottom;
  bTop *= old_bBottom;
  bTop *= -1;                 // i^2 = -1
  aTop += bTop;
  bTop = middle_foil;

  // divide top by bottom
  aTop /= aBottom;
  bTop /= aBottom;     // aBottom would be set to 1 now - but not needed
}

int _matherrl(struct _exceptionl *fix)   // report error - quit
{
  if (fix->type == OVERFLOW)
	 cout << "\nResult is too large.  Your data caused an OVERFLOW.";
  else if (fix->type == UNDERFLOW)
	 cout << "\nResult is too small.  Your data caused an UNDERFLOW.";
  else if (fix->type == TLOSS)
	 cout << "\nResult is completely inaccurate.";
  else cout << "\nError!";
  exit(1);                        // quit because of error
}

int main()
{
  long double integer = 0;

  input();
  showEquation();

  if (a == 1 && b == 0)    // first exception - 1 + 0i - undefined
  {
	 a = x + 1;             // use alternate formula
	 b = 0;
	 cout << "Answer = "  << a << " + " << b << i;
	 return 0;
  }

  if (a == 0 && b == 0)    // second and last exception - 0^0 - not 1
  {                        // undefined in regular formula - 0^0 undefined
	 cout << "Answer = Undefined";    // always undefined
	 return 0;
  }
					// order of assignments is very important in this program
  evaluate_top();
  evaluate_bottom();
  simplify();
							 // here and down 4 lines - rounding error
  if ((modfl(a, &integer) == 0) && (modfl(b, &integer) == 0)) integer = 1;
  else integer = 0;
  a = aTop;
  b = bTop;
  if (integer == 1)   // even more protection against rounding error
  {                   // if A and B were integers they should stay that way
	 integer = modfl(a, &a);
	 if (integer >= .5) a += 1;
	 if (integer <= -.5) a -= 1;
	 integer = modfl(b, &b);
	 if (integer >= .5) b += 1;
	 if (integer <= -.5) b -= 1;
  }
  if (b < 0)                // prints to about 17 decimal places
	 printf("Answer = %.17LG - %.17LG%c", a, -b, i);  // b is negative
  else
	 printf("Answer = %.17LG + %.17LG%c", a, b, i);    // b is positive

  return 0;
}