/******************************str_type***********************************
Todd Goldfinger -- runtime library    v 1.0

The str_type type declares a dynamic string.  It is declared in the following
formats:
  str_type str;                              //size is 1
  str_type str("TODD GOLDFINGER");           //size is 16
  str_type str(10);                          //size is 11
  str_type str = "TODD";                     //size is 5
  str_type str[10]                           //creates 10 strings of len 1
The user doesn't have to worry about the NULL character (and I wouldn't
  recommend using one).
Strings can be resized at runtime using the resize_string function.
Keep in mind that if you create an array of strings, the number of strings
  is not dynamic.  It must remain constant throughout the len of the program.
str_type does bounds checking - it warns you if the program oversteps the
  string's bounds.  Again, if you create an array of strings, the program
  won't tell you if you overstep the bounds of the array.
The maximum len of a string is 65,534 (be warned, you can exceed this limit
  with some bad consequences).
If you assign a string to a str_type and the string is larger than the size
  of the str_type variable, the variable is resized.
You can append strings with the addition operator.

Using str_int:
You shouldn't directly access this type.
To convert a str_type to a str_int (the str_int type is a string which
  contains only integers and can do operations on those integers) put
  parentheses on the end of a str_type object.
  Example:
	 str_type num("-1000");
	 cout << abs(num());       //outputs             1000
	 cout << num;              //outputs             -1000
You can add, subtract, multiply, divide str_int objects.
If you assign a str_int to a str_type, you must use the to_str function.
If you assign a str_int, which has had an operation done on it, to a
  str_type you must use a type conversion (otherwise the compiler will fail
  and cause big problems -- don't ask why).
  Example:
	 str_type a("10"), b = "20";
	 a = to_str(a());      //or just a = a;   (both ways accomplish nothing)
	 a = to_str((str_type::str_int)(a() * b()));  //a == 200
To perform error checking on str_ints use the set_err_check function.
This function checks str_int strings to see if the only have numbers (or
  a minus sign at the front).  It also removes leading zeros from results
  of operations.  This checking can dramatically slow down calculations.
To check to see if there was an error use the error_status function.
Use the clear_error function to clear the error flag.
All flags are initially false.

Don't do this -- str_type a;
					  a = 'f';                //NO  --  bad
					  a = "f";                //YES
					  a = to_char_num('f');   //this will work
There is also a bool type defined.
There is one #define  --  error
*************************************************************************/

#ifndef strtype
#define strtype

#include <iostream.h>
#include <string.h>
#include <stdlib.h>

#define error "ERROR"

typedef enum {FALSE, TRUE} bool;

class str_type {
  char *string;            //string
  long size;               //size of string
  static bool err_check;   //programmer sets this flag to TRUE if
									//he wants arithmetic error checking
  static bool is_error;    //set to true when there is an error
  bool check();            //check for numbers only
public:
  struct str_int {
	 str_int(char *str = NULL) {
		long i = strlen(str);
		s = new char[i + 1];
		if (!s) {
		  cout << "Allocation error";
		  exit(1);
		}
		if (str) strcpy(s, str);
		s[i] = NULL;
	 }
	 str_int(const str_int &str) {
		long i = strlen(str.s);
		s = new char[i + 1];
		if (!s) {
		  cout << "Allocation error";
		  exit(1);
		}
		strcpy(s, str.s);
		s[i] = NULL;
	 }
	 ~str_int() { if (s) delete s;  }
	 friend ostream &operator<<(ostream &stream, str_type::str_int str);
	 friend str_type to_str(str_type::str_int str);
  private:
	 char *s;
  };

  str_type(char *str = NULL) {
	 long i = strlen(str);
	 size = i;
	 if (size < 0) {
		cout << "String size too small." << endl
			  << "Program terminated.";
		exit(1);
	 }
	 string = new char[size + 1];
	 if (!string) {
		cout << "Allocation error";
		exit(1);
	 }
	 if (str) strcpy(string, str);
	 string[size] = NULL;
  }
  str_type(long string_size) {
	 if (string_size < 0) {
	 cout << "String size too small." << endl
			<< "Program terminated.";
	 exit(1);
	 }
	 string = new char[string_size + 1];
	 if (!string) {
		cout << "Allocation error";
		exit(1);
	 }
	 size = string_size;
	 string[size] = NULL;
  }
  str_type(const str_type &str) {
	 string = new char[str.size + 1];
	 size = str.size;
	 if (!string) {
		 cout << "Allocation error";
		 exit(1);
	 }
	strcpy(string, str.string);
	string[size] = NULL;
  }
  ~str_type() { if (string) delete string;  }

  friend str_type operator+(str_type str1, str_type str2);
  friend str_type operator+(str_type str1, char * str2);
  friend str_type operator+(char *str1, str_type str2);
  friend str_type operator-(str_type str1, str_type str2);
  friend str_type operator-(str_type str1, char *str2);
  friend str_type operator&(str_type str1, str_type str2);
  str_type operator=(str_type str);

  friend str_int operator+(str_int str1, str_int str2);
  friend str_int operator-(str_int str1, str_int str2);
  friend str_int operator*(str_int str1, str_int str2);
  friend str_int operator/(str_int str1, str_int str2);
  friend bool operator!=(str_int str1, str_int str2);
  friend bool operator==(str_int str1, str_int str2);
  friend bool operator<(str_int str1, str_int str2);
  friend bool operator<=(str_int str1, str_int str2);
  friend bool operator>(str_int str1, str_int str2);
  friend bool operator>=(str_int str1, str_int str2);
  friend str_int abs(str_int str);

  friend ostream &operator<<(ostream &stream, str_type str);
  friend istream &operator>>(istream &stream, str_type &str);
  friend void resize_string(str_type &str, const long i);
  friend void swap(str_type &str1, str_type &str2);
  friend str_type remove_leading_zeros(str_type &str);
  friend void set_err_check(bool a) { str_type::err_check = a; }
  friend void clear_error() { str_type::is_error = FALSE; }
  friend bool error_status() { return str_type::is_error; }
  friend bool operator==(str_type str1, str_type str2);
  friend bool operator<(str_type str1, str_type str2);
  friend bool operator>(str_type str1, str_type str2);

  operator char *() { return string; }     //changes an object to a string
  str_type operator()(const long lower, str_type str);
  str_type operator()(str_type sub_str1, str_type sub_str2);
  str_int operator()();
  char &operator[](long i);
};

str_type to_str(const long str);
str_type to_str(str_type::str_int str);
str_type::str_int to_str_int(const long str);
long to_long(str_type str);
long to_long(const char ch);
char to_char_num(const char num);
str_type::str_int sumI(str_type::str_int i);
str_type::str_int factorial(long top);
#endif
