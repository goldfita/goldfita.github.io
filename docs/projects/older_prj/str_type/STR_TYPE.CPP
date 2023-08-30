#include <iostream.h>
#include <string.h>
#include <stdlib.h>
#include "str_type.h"

bool str_type::is_error = FALSE;
bool str_type::err_check = FALSE;

bool str_type::check() {
//PRE:  none
//POST: checks string for errors; returns TRUE if none else FALSE;
//is error is set to true if there is an error
  str_type::is_error = TRUE;       //not really
  if (!strlen(string)) return FALSE;   //no numbers
  if ((string[0] == '-') || (string[0] >= '0' && string[0] <= '9')) { //works
	 unsigned i;
	 for (i = 1; i < strlen(string); i++)
		if (string[i] < '0' || string[i] > '9') return FALSE;   //bad
	 str_type::is_error = FALSE;           //passes all tests
	 return TRUE;
  }
  return FALSE;
}

str_type::str_int abs(str_type::str_int str) {
//PRE:  get a str_int
//POST: returns the string with all negatives removed from it
/*does NO error checking*/
  str_type s = to_str(str);
  s = s - "-";
  return s();
}

str_type remove_leading_zeros(str_type &str) {
//removes all leading zeros from a string
// "00009ajfs" becomes "9ajfs"
  unsigned count = 0;
  while (str.string[count] == '0') {
	 str.string[count] = '~';                    //replace initial zeros
	 count++;
  }
  str = str - "~";                              //remove ~
  return str;
}

str_type to_str(str_type::str_int str) {
//converts a str_int to a str
  str_type temp(str.s);
  return temp;
}
str_type to_str(const long str) {
//converts a long to a str
  char temp[12];             //max length of negative long + NULL
  ltoa(str, temp, 10);
  return (str_type)temp;
}
str_type::str_int to_str_int(const long str) {
//converts a long to a str_int
  char temp[12];            //max length of negative long + NULL
  str_type temp2;
  ltoa(str, temp, 10);
  temp2 = temp;
  return temp2();
}
long to_long(str_type str) { return atoi(str); }
long to_long(const char ch) { return ch - '0'; }
char to_char_num(const char num) { return num + '0'; }

str_type::str_int operator/(str_type::str_int str1, str_type::str_int str2) {
//PRE:  gets str1 and str2 which are converted to s1 and s2 as type str_type
//POST: returns str1 / str2 if the answer is an longeger; otherwise it returns
//      str1 div str2 followed by error and then str1 mod str2
//      example: 11 / 5 --- 2error1 
//if there is an error and the error checking flag is on, then
//the string is set to error
  str_type s1 = to_str(str1), s2 = to_str(str2), str_result, str_temp(strlen(s2) + 1);
  unsigned len;               //hold temporary length of str_temp
  char is_neg[2] = "";        //for a simple return statement
  if (str_type::err_check)
	 if (!(s1.check() && s2.check())) return error;

  if ((s1[0] != s2[0]) && ((s1[0] == '-') || (s2[0] == '-'))) is_neg[0] = '-';
  s1 = s1 - "-";
  s2 = s2 - "-";

  if (s2() == "0") { str_type::is_error = TRUE;  return error; }  //special
  else if (s1() == "0") return "0";
  str_type all_pos[10] = {         //initalize so it doesn't have to be
	 "0",                           //calculated in the while loop
	 s2,
	 to_str(s2() * "2"),
	 to_str(s2() * "3"),
	 to_str(s2() * "4"),
	 to_str(s2() * "5"),
	 to_str(s2() * "6"),
	 to_str(s2() * "7"),
	 to_str(s2() * "8"),
	 to_str(s2() * "9"),
  };

  str_temp[0] = NULL;
  while (s1.string[0]) {
	 len = strlen(str_temp);
	 str_temp[len] = s1[0];
	 if (len + 1 < str_temp.size) str_temp[len + 1] = NULL;
	 s1[0] = '~';
	 s1 = s1 - "~";
	 if (all_pos[5]() <= str_temp()) {              //start in the middle
		if (all_pos[6]() <= str_temp())
		  if (all_pos[7]() <= str_temp())
			 if (all_pos[8]() <= str_temp())
				if (all_pos[9]() <= str_temp()) { str_result = str_result + "9";  s1 = remove_leading_zeros(to_str((str_type::str_int)(str_temp() - all_pos[9]()))) + s1; }
				else { str_result = str_result + "8";  s1 = remove_leading_zeros(to_str((str_type::str_int)(str_temp() - all_pos[8]()))) + s1; }
			 else { str_result = str_result + "7";  s1 = remove_leading_zeros(to_str((str_type::str_int)(str_temp() - all_pos[7]()))) + s1; }
		  else { str_result = str_result + "6";  s1 = remove_leading_zeros(to_str((str_type::str_int)(str_temp() - all_pos[6]()))) + s1; }
		else { str_result = str_result + "5";  s1 = remove_leading_zeros(to_str((str_type::str_int)(str_temp() - all_pos[5]()))) + s1; }
	 }
	 else {
		if (all_pos[4]() > str_temp())
		  if (all_pos[3]() > str_temp())
			 if (all_pos[2]() > str_temp())
				if (all_pos[1]() > str_temp()) str_result = str_result + "0";
				else { str_result = str_result + "1";  s1 = remove_leading_zeros(to_str((str_type::str_int)(str_temp() - all_pos[1]()))) + s1; }
			 else { str_result = str_result + "2";  s1 = remove_leading_zeros(to_str((str_type::str_int)(str_temp() - all_pos[2]()))) + s1; }
		  else { str_result = str_result + "3";  s1 = remove_leading_zeros(to_str((str_type::str_int)(str_temp() - all_pos[3]()))) + s1; }
		else { str_result = str_result + "4";  s1 = remove_leading_zeros(to_str((str_type::str_int)(str_temp() - all_pos[4]()))) + s1; }
	 }
	 if ((str_result[strlen(str_result) - 1] != '0') ||
		 (len == str_temp.size - 1)) str_temp[0] = NULL;
  }
  if (!strlen(str_result)) str_result = str_result + "0" + error + s1;
  if (s1.string[0]) str_result = is_neg + str_result + error + s1;
  else str_result = is_neg + str_result;
  if (str_type::err_check) remove_leading_zeros(str_result); 
  return str_result();
}

str_type::str_int operator*(str_type::str_int str1, str_type::str_int str2) {
//PRE:  gets str1 and str2 which are converted to s1 and s2 as type str_type
//POST: returns str1 * str2
//if there is an error and the error checking flag is on, then
//the string is set to error
  str_type s1 = to_str(str1), s2 = to_str(str2);
  char is_neg[2] = "";
  div_t digit;       //max carry is 8 - largest pos. number is 89
  if (str_type::err_check)
	 if (!(s1.check() && s2.check())) return error;

  if ((s1[0] != s2[0]) && ((s1[0] == '-') || (s2[0] == '-'))) is_neg[0] = '-';
  s1 = s1 - "-";
  s2 = s2 - "-";
  if (strlen(s1) < strlen(s2)) swap(s1, s2);
  //safe to declare now
  long large, small = strlen(s2) - 1, i;      //i is just for for loop
  str_type str_result("0"), str_temp;
  /////////////////////////////////////////////////

  for ( ; small > -1; small--) {
	 resize_string(str_temp, strlen(s1));   //must always be size of s1
	 digit.rem = 0;  digit.quot = 0;
	 if (s2[small] == '0')               //speed it up
		str_temp = "0";
	 else if (s2[small] == '1')
		str_temp = s1;
	 else {
		for (large = strlen(s1) - 1; large > -1; large--) {
		  digit = div(to_long(s1[large]) * to_long(s2[small]) + digit.quot, 10);
		  str_temp[large] = to_char_num(digit.rem);
		}
		if (digit.quot) str_temp = to_str(digit.quot) + str_temp;
	 }
	 for (i = strlen(s2) - small - 1; i > 0; i--)   //place holder
		str_temp = str_temp + "0";
	 str_result = to_str((str_type::str_int)(str_result() + str_temp()));
  }

  str_result = is_neg + str_result;
  if (str_type::err_check) remove_leading_zeros(str_result); 
  return str_result();
}
str_type::str_int operator+(str_type::str_int str1, str_type::str_int str2) {
//PRE:  gets two strings (as type str_int)
//POST: returns str1 + str2 (treated as integers)
//if there is an error and the error checking flag is on, then
//the string is set to error
  str_type s1 = to_str(str1), s2 = to_str(str2);
  div_t digit = {0,0};               //holds digit and   carry - (1 or 0)
  bool is_neg = FALSE;
  if (str_type::err_check)
	 if (!(s1.check() && s2.check())) return error;
													 //deals with subtraction
  if ((s1.string[0] == s2.string[0]) && (s2.string[0] == '-')) {
	 is_neg = TRUE;
	 s1 = s1 - "-";
	 s2 = s2 - "-";
  }
  else if ((s1.string[0] == '-')) {
	 s1 = s1 - "-";
	 return s2() - s1();               //-s1 + s2 == s2 - s1
	 }
  else if ((s2.string[0] == '-')) {
	 s2 = s2 - "-";
	 return s1() - s2();               //s1 + -s2 == s1 - s2
  }

  //safe to declare now
  long i, largest = max(strlen(s1), strlen(s2));    //i is multipurpose
  str_type str_result(largest);
  /////////////////////////////////////////////////
  i = largest - min(strlen(s1), strlen(s2));
  str_type temp(i);  i--;          //pad front of smaller string with zeros
  for (i; i > -1; i--) temp[i] = '0';    //set string to zeros
  if (strlen(s1) == largest)
	 s2 = temp + s2;
  else if (strlen(s2) == largest)
	 s1 = temp + s1;

  for (i = 0; i < largest; i++) {
	 digit = div(to_long(s1[largest - 1 - i]) + to_long(s2[largest - 1 - i]) + digit.quot, 10);
	 str_result[largest - 1 - i] = to_char_num(digit.rem);
  }
  if (digit.quot) str_result = "1" + str_result;     // append a 1 to front
  if (is_neg) str_result = "-" + str_result;         // append a - to front
  if (str_type::err_check) remove_leading_zeros(str_result);
  return str_result();
}

str_type::str_int operator-(str_type::str_int str1, str_type::str_int str2) {
//PRE:  gets two strings (as type str_int)
//POST: returns str1 - str2 (treated as integers)
//if there is an error and the error checking flag is on, then
//the string is set to error
  str_type s1 = to_str(str1), s2 = to_str(str2);
  long i;                             //i is multipurpose
  bool carry = FALSE;
  bool is_neg = FALSE;
  if (str_type::err_check)
	 if (!(s1.check() && s2.check())) return error;

												 //deal with minus and negatives
  if ((s1.string[0] == s2.string[0]) && (s2.string[0] == '-')) {
	 s1 = s1 - "-";
	 s2 = s2 - "-";
	 return s2() - s1();             //-s1 - -s2 == s2 - s1
  }
  else if (s1.string[0] == '-') {
	 s2 = "-" + s2;
	 return s1() + s2();            //-s1 - s2 == -(s1 + s2)
  }
  else if (s2.string[0] == '-') {
	 s2 = s2 - "-";
	 return s1() + s2();            //s1 - -s2 == s1 + s2
  }
  if (s1() < s2()) { swap(s1, s2);  is_neg = TRUE; }   //make s2 <= s1
  /*now it's safe to declare these*/
  long largest = max(strlen(s1), strlen(s2));
  str_type str_result(largest);
  /////////////////////////////////

  i = largest - min(strlen(s1), strlen(s2));
  str_type temp(i);  i--;          //pad front of smaller string with zeros
  for (i; i > -1; i--) temp[i] = '0';    //set string to zeros
  if (strlen(s1) == largest)
	 s2 = temp + s2;
  else if (strlen(s2) == largest)
	 s1 = temp + s1;

  for (i = largest - 1; i > -1; i--)
	 if (s1.string[i] < (s2.string[i] + carry)) {
		str_result.string[i] = to_char_num((10 + to_long(s1.string[i])) - (to_long(s2.string[i]) + carry));
		carry = TRUE;
	 }
	 else {
		str_result.string[i] = to_char_num(to_long(s1.string[i]) - to_long((s2.string[i] + carry)));
		carry = FALSE;
	 }

  if (str_type::err_check) remove_leading_zeros(str_result);
  if (is_neg) str_result = "-" + str_result;
  return str_result();
}

bool operator!=(str_type::str_int str1, str_type::str_int str2) {
//PRE:  gets str1 and str2 which are converted to s1 and s2 as type str_type
//POST: returns TRUE if numbers in string are not equal, otherwise FALSE
//      if there is an error and the error checking flag is on, then
//      FALSE is returned
  str_type s1 = to_str(str1), s2 = to_str(str2);
  return (bool)!(s1 == s2);
}

bool operator==(str_type::str_int str1, str_type::str_int str2) {
//PRE:  gets str1 and str2 which are converted to s1 and s2 as type str_type
//POST: returns TRUE if numbers in string are equal, otherwise FALSE
//      if there is an error and the error checking flag is on, then
//      FALSE is returned
/* in order to compare strings as numbers all zeros are removed from the
front of the string and the right side is padded with zeros so they are
the same length*/
  str_type s1 = to_str(str1), s2 = to_str(str2);
  bool is_neg1 = FALSE, is_neg2 = FALSE;
  long i;
  if (str_type::err_check)
	 if (!(s1.check() && s2.check())) { str_type::is_error = TRUE;  return FALSE; }

  if (s1.string[0] == '-') { is_neg1 = TRUE; s1.string[0] = '0'; }
  if (s2.string[0] == '-') { is_neg2 = TRUE; s2.string[0] = '0'; }
  if (is_neg1 != is_neg2) return FALSE;
  remove_leading_zeros(s1);
  remove_leading_zeros(s2);

  if (strlen(s1) < strlen(s2))  //pad right of smaller string with zeros
	 for (i = strlen(s1); i < strlen(s2); i++) s1 = s1 + "0";
  else if (strlen(s2) < strlen(s1))
	 for (i = strlen(s2); i < strlen(s1); i++) s2 = s2 + "0";

  return (bool)!strcmp(s1.string, s2.string);
}

bool operator<(str_type::str_int str1, str_type::str_int str2) {
//PRE:  gets str1 and str2 which are converted to s1 and s2 as type str_type
//POST: returns TRUE if str1 < str2, otherwise FALSE
//      if there is an error and the error checking flag is on, then
//      returns FALSE
/*if strcmp is used then strlen(s1) == strlen(s2)*/
  str_type s1 = to_str(str1), s2 = to_str(str2);
  bool is_neg1 = FALSE, is_neg2 = FALSE;
  if (str_type::err_check)
	 if (!(s1.check() && s2.check())) { str_type::is_error = TRUE;  return FALSE; }

  if (s1.string[0] == '-') { is_neg1 = TRUE; s1.string[0] = '0'; }
  if (s2.string[0] == '-') { is_neg2 = TRUE; s2.string[0] = '0'; }
  if (is_neg1 > is_neg2)                  //one is pos - one is "-"
	 return TRUE;
  else if (is_neg1 < is_neg2)
	 return FALSE;
  remove_leading_zeros(s1);
  remove_leading_zeros(s2);

  if (strlen(s1) < strlen(s2))               //smaller size means less
	 if (!is_neg1) return TRUE; else return FALSE;       //negs reverse
  else if (strlen(s1) > strlen(s2))
	 if (!is_neg1) return FALSE; else return TRUE;

  if (strcmp(s1.string, s2.string) < 0)      //both same
	 if (!is_neg1) return TRUE; else return FALSE;       //negs reverse
  else if (strcmp(s1.string, s2.string) > 0)
	 if (!is_neg1) return FALSE; else return TRUE;
  else return FALSE;                  //equal
}

bool operator>(str_type::str_int str1, str_type::str_int str2) {
//PRE:  gets str1 and str2 which are converted to s1 and s2 as type str_type
//POST: returns TRUE str1 > str2, otherwise FALSE
//      if there is an error and the error checking flag is on, then
//      returns FALSE
/*if strcmp is used then strlen(s1) == strlen(s2)*/
  str_type s1 = to_str(str1), s2 = to_str(str2);
  bool is_neg1 = FALSE, is_neg2 = FALSE;
  if (str_type::err_check)
	 if (!(s1.check() && s2.check())) { str_type::is_error = TRUE;  return FALSE; }

  if (s1.string[0] == '-') { is_neg1 = TRUE; s1.string[0] = '0'; }
  if (s2.string[0] == '-') { is_neg2 = TRUE; s2.string[0] = '0'; }
  if (is_neg1 < is_neg2)                  //one is pos - one is neg
	 return TRUE;
  else if (is_neg1 > is_neg2)
	 return FALSE;
  remove_leading_zeros(s1);
  remove_leading_zeros(s2);

  if (strlen(s1) > strlen(s2))               //smaller size means less
	 if (!is_neg1) return TRUE; else return FALSE;       //negs reverse
  else if (strlen(s1) < strlen(s2))
	 if (!is_neg1) return FALSE; else return TRUE;

  if (strcmp(s1.string, s2.string) > 0)         //both pos
	 if (!is_neg1) return TRUE; else return FALSE;       //negs reverse
  else if (strcmp(s1.string, s2.string) < 0)
	 if (!is_neg1) return FALSE; else return TRUE;
  else return FALSE;   //equal
}

bool operator<=(str_type::str_int str1, str_type::str_int str2) {
//PRE:  gets str1 and str2 which are converted to s1 and s2 as type str_type
//POST: returns TRUE if str1 < str2, otherwise FALSE
//      if there is an error and the error checking flag is on, then
//      returns FALSE
/*if strcmp is used then strlen(s1) == strlen(s2)*/
  str_type s1 = to_str(str1), s2 = to_str(str2);
  bool is_neg1 = FALSE, is_neg2 = FALSE;
  if (str_type::err_check)
	 if (!(s1.check() && s2.check())) { str_type::is_error = TRUE;  return FALSE; }

  if (s1.string[0] == '-') { is_neg1 = TRUE; s1.string[0] = '0'; }
  if (s2.string[0] == '-') { is_neg2 = TRUE; s2.string[0] = '0'; }
  if (is_neg1 > is_neg2)                  //one is pos - one is "-"
	 return TRUE;
  else if (is_neg1 < is_neg2)
	 return FALSE;
  remove_leading_zeros(s1);
  remove_leading_zeros(s2);

  if (strlen(s1) < strlen(s2))               //smaller size means less
	 if (!is_neg1) return TRUE; else return FALSE;       //negs reverse
  else if (strlen(s1) > strlen(s2))
	 if (!is_neg1) return FALSE; else return TRUE;

  if (strcmp(s1.string, s2.string) < 0)      //both same
	 if (!is_neg1) return TRUE; else return FALSE;       //negs reverse
  else if (strcmp(s1.string, s2.string) > 0)
	 if (!is_neg1) return FALSE; else return TRUE;
  else return TRUE;                  //equal
}

bool operator>=(str_type::str_int str1, str_type::str_int str2) {
//PRE:  gets str1 and str2 which are converted to s1 and s2 as type str_type
//POST: returns TRUE str1 > str2, otherwise FALSE
//      if there is an error and the error checking flag is on, then
//      returns FALSE
/*if strcmp is used then strlen(s1) == strlen(s2)*/
  str_type s1 = to_str(str1), s2 = to_str(str2);
  bool is_neg1 = FALSE, is_neg2 = FALSE;
  if (str_type::err_check)
	 if (!(s1.check() && s2.check())) { str_type::is_error = TRUE;  return FALSE; }

  if (s1.string[0] == '-') { is_neg1 = TRUE; s1.string[0] = '0'; }
  if (s2.string[0] == '-') { is_neg2 = TRUE; s2.string[0] = '0'; }
  if (is_neg1 < is_neg2)                  //one is pos - one is neg
	 return TRUE;
  else if (is_neg1 > is_neg2)
	 return FALSE;
  remove_leading_zeros(s1);
  remove_leading_zeros(s2);

  if (strlen(s1) > strlen(s2))               //smaller size means less
	 if (!is_neg1) return TRUE; else return FALSE;       //negs reverse
  else if (strlen(s1) < strlen(s2))
	 if (!is_neg1) return FALSE; else return TRUE;

  if (strcmp(s1.string, s2.string) > 0)         //both pos
	 if (!is_neg1) return TRUE; else return FALSE;       //negs reverse
  else if (strcmp(s1.string, s2.string) < 0)
	 if (!is_neg1) return FALSE; else return TRUE;
  else return TRUE;   //equal
}

void swap(str_type &str1, str_type &str2) {
//swaps to strings
  str_type temp;

  temp = str1;
  str1 = str2;
  str2 = temp;
}

str_type::str_int str_type::operator()() {
//returns this as a str_int (changes a str_type to a str_int)
  str_type::str_int temp(string);
  return temp;
}

str_type operator+(str_type str1, str_type str2) {
//appends str2 to the end of str1
  str_type temp(strlen(str1.string) + strlen(str2.string));

  strcpy(temp.string, str1.string);
  strcat(temp.string, str2.string);
  return temp;
}

str_type operator+(str_type str1, char *str2) {
//appends str2 to the end of str1
  str_type temp(strlen(str1.string) + strlen(str2));

  strcpy(temp.string, str1.string);
  strcat(temp.string, str2);
  return temp;
}

str_type operator+(char *str1, str_type str2) {
//appends str2 to the end of str1
  str_type temp(strlen(str1) + strlen(str2.string));

  strcpy(temp.string, str1);
  strcat(temp.string, str2.string);
  return temp;
}

str_type str_type::operator=(str_type str) {
//assignes str to this  --  if str.size < this then enough room is
//allocated for str to hold information in this
  if (str.size > size) {
	 delete string;
	 string = new char[str.size + 1];
	 if (!string) {
		cout << "Allocation error.\n";
		exit(1);
	 }
  }
  strcpy(string, str.string);
  size = str.size;
  string[size] = NULL;
  return *this;
}

ostream &operator<<(ostream &stream, str_type str) {
//outputs a string
  stream << str.string;
  return stream;
}

ostream &operator<<(ostream &stream, str_type::str_int str) {
//outputs a str_int
  stream << str.s;
  return stream;
}

istream &operator>>(istream &stream, str_type &str) {
//inputs a string
  stream >> str.string;
  return stream;
}

bool operator==(str_type str1, str_type str2) {
//tests to see if str1 == str2
  if (!strcmp(str1.string, str2.string))
	 return TRUE;
  else
	 return FALSE;
}

bool operator<(str_type str1, str_type str2) {
//tests to see if str1 is less
  if (strcmp(str1.string, str2.string) < 0)
	 return TRUE;
  else
	 return FALSE;
}

bool operator>(str_type str1, str_type str2) {
//tests to see if str1 is greater
  if (strcmp(str1.string, str2.string) > 0)
	 return TRUE;
  else
	 return FALSE;
}

void resize_string(str_type &str, const long i) {
//resizes string according to size of i; i > 0*/
  if (i < 1) {
	 cout << "String size too small." << endl
			<< "Program terminated.";
	 exit(1);
  }
  delete str.string;
  str.string = new char[i + 1];
  if (!str.string) {
		cout << "Allocation error.\n";
		exit(1);
  }
  str.size = i;
  str.string[str.size] = NULL;
}

str_type str_type::operator()(const long lower, str_type sub_str) {
//PRE:  gets lower(position in the string); sub_str is the new string
//POST: sub_str gets placed over the previous characters starting at position lower
/*returns error if lower < 0 or upper > size*/
  char *sub_ptr;           //points to lower position of the string
  long upper = lower + sub_str.size;
  if ((lower < 0) || (upper > size)) { str_type::is_error = TRUE;  return error; }

  sub_ptr = &this->string[lower];
  strncpy(sub_ptr, sub_str, sub_str.size);
  return *this;
}

char &str_type::operator[](long i) {
/*checks bounds for array - ends program if out-of-bounds*/
  if ((i < 0) || (i > size - 1)) {
	 cout << "Subscript is out-of-bounds." << endl
			<< "Incorrect subscript is " << i
			<< ".\nUpper bound is only " << (size - 1)
			<< ".\nProgram is terminated.";
	 exit(1);
  };
  return string[i];
}

str_type operator&(str_type str1, str_type str2) {
/*returns all characters that are the same in both strings and leaves
blanks where characters are different - ex: str == "hello"
str2 == "hippo"                       result == "h   o"*/
  long i = min(str1.size, str2.size) - 1;
  str_type and_str;
  and_str = str1;
  and_str = str2;

  strset(and_str, ' ');
  for ( ; i > -1; i--)
	 if (str1[i] == str2[i])
		and_str[i] = str1[i];
	 else
		and_str = ' ';
  return and_str;
}

str_type operator-(str_type str1, str_type str2) {
/*removes all ocurences of str2 from str1*/
  str_type temp = str1;
  char *str_ptr, *temp_str_ptr;
  long i = 0;

  if (str_ptr = strstr(str1, str2)) {
	 while (str_ptr != &str1.string[i]) {
		temp[i] = str1[i];
		i++;
	 }
	 temp_str_ptr = &temp[i];
	 strcpy(temp_str_ptr, str_ptr + str2.size);
	 strcpy(str1, str_ptr + str2.size);
	 if (strstr(str1, str2)) temp = temp - str2;
  }
  return temp;
}

str_type operator-(str_type str1, char *str2) {
/*removes all ocurences of str2 from str1*/
  str_type temp = str1;
  char *str_ptr, *temp_str_ptr;
  long i = 0;

  if (str_ptr = strstr(str1, str2)) {
	 while (str_ptr != &str1.string[i]) {
		temp[i] = str1[i];
		i++;
	 }
	 temp_str_ptr = &temp[i];
	 strcpy(temp_str_ptr, str_ptr + strlen(str2));
	 strcpy(str1, str_ptr + strlen(str2));
	 if (strstr(str1, str2)) temp = temp - str2;
  }
  return temp;
}

str_type::str_int sumI(str_type::str_int i) {
//PRE:  gets a positive integer i
//POST: returns the sumation of i
/*if the number is negative returns error*/
  str_type num = to_str(i), str_result;

  if (num() < "1") return error;
  str_result = to_str((str_type::str_int)(num() * (num() + "1")) / "2");
  remove_leading_zeros(str_result);
  return str_result();
}

str_type str_type::operator()(str_type sub_str1, str_type sub_str2) {
//PRE:  gets two substring of the same size
//POST: replaces all ocurences of sub_str1 in this with sub_str2
/*returns error if the length of the substrings are different*/
  if (sub_str1.size ^ sub_str2.size) { str_type::is_error = TRUE;  return error; }
  if (sub_str1 == sub_str2) return *this;
  char *str_ptr;
  long i;

  while (str_ptr = strstr(*this, sub_str1))
	 for (i = 0; i < sub_str2.size; i++)
		str_ptr[i] = sub_str2.string[i];
  return *this;
}

str_type::str_int factorial(long top) {
//PRE:  gets a long
//POST: returns top! (factorial) as type str_int
/* returns error if top < 0 */
  str_type str("1");
  long bottom;
  if (top < 0) return error;
  if ((top == 0) || (top == 1)) return str();//special case - also same for 1

  for (bottom = 2; bottom <= top; bottom++)
	 str = to_str((str_type::str_int)(str() * to_str_int(bottom)));
  return str();
}

