#include <conio.h>
#include <string.h>
#include <stdlib.h>
#include <malloc.h>
#include <iostream.h>
#include "elements.h"

#define pl '('                    // parentheses - right
#define pr ')'                    //               left
#define pn NULL                   //               none
#define max_subscript 60000L      // actually 59999

typedef struct tag_compoundType compoundType;

typedef compoundType *compoundType_ptr;
typedef compoundType_ptr *compoundType_ref;

struct tag_compoundType {
  char data[name_size];
  char paren;
  unsigned int subscript;
  unsigned int element_num;   //value given to elements 1..X (left to right)
  compoundType_ptr next;
};
/******************************************************/
typedef struct tag_equationType equationType;

typedef equationType *equationType_ptr;
typedef equationType_ptr *equationType_ref;

struct tag_equationType {
  unsigned int coef;
  compoundType_ptr compound;
  equationType_ptr next;
};
///////////////////////////////////////////////////////////////////
void setup_equation(equationType_ref reactants, equationType_ref products);
void input_equation(equationType_ref oneSide);
inline equationType_ptr create_compound();
inline compoundType_ptr create_element();
inline boolean canBeElement(const char *test_element);
inline int compare_part(const void *e1, const void *e2);
char distribute_SS(compoundType_ref first_element, unsigned int SS);
/******************INPUT ABOVE**************************************/
boolean balance_equation(equationType_ptr reactants, equationType_ptr products,
  const unsigned int curr_elementNum);        //method 1
boolean balance_equation(equationType_ptr reactants, equationType_ptr products,
  const unsigned int num_elements, const unsigned int curr_elementNum,
  const unsigned int tempCurr_elementNum = 1);//(overloaded)method 2 - backup
unsigned int number_elements(equationType_ptr reactants, equationType_ptr products);
compoundType_ptr firstZero_element(equationType_ref oneSide, compoundType_ptr curr_element);
int equal_elements(equationType_ptr reactants, equationType_ptr products,
  const unsigned int curr_elementNum);
boolean balance_element(equationType_ptr reactants, equationType_ptr products,
  const unsigned int curr_elementNum, int compared);
void reset_coefs(equationType_ptr oneSide);
equationType_ptr pop_compound(equationType_ptr oneSide);
compoundType_ptr pop_element(compoundType_ptr curr_element);
/******************OUTPUT BELOW**************************************/
void show_equation(equationType_ptr oneSide);
unsigned int factorOut_SS(compoundType_ptr curr_elementPL);

int main()
{
  equationType_ptr reactants = NULL, products = NULL;

  alphabetize_elements();
  setup_equation(&reactants, &products);
  unsigned int i = 1, num_elements = number_elements(reactants, products);
  while (i <= num_elements)
	 if (balance_equation(reactants, products, i))
		if (i == num_elements)
		  for (i = 1; i <= num_elements; i++) //finds first unbalanced element
			 if (equal_elements(reactants, products, i)) break;
			 else /*nothing*/;
		else i++;
	 else {   //first attempt failed - try again with recursion
		reset_coefs(reactants);
		reset_coefs(products);
		for (i = 1; i <= num_elements; i++)
		  if (!balance_equation(reactants, products, num_elements, i, i)) {
			 num_elements = 0;
			 break;
		  }
	 }
  if (num_elements) {
	 cout << "\n\n";
	 show_equation(reactants);
	 cout << " ---> ";
	 show_equation(products);
  }
  else
	 cout << "\nSorry!  The equation could not be balanced by this program.";

  while (reactants)       //free memory for compound list
	 reactants = pop_compound(reactants);
  while (products)
	 products = pop_compound(products);
  return 0;
}

void setup_equation(equationType_ref reactants, equationType_ref products)
{
  cout << "Enter element name, followed by subscript.\n";
  cout << "Press space bar for next compound; \"Enter\" to complete ";
  cout << "current half of equation.\n";
  cout << "Example equation:    H3PO4 + Mg(OH)2 ---> Mg3(PO4)2 + H2O\n";
  cout << "Balanced equation:   2H3PO4 + 3Mg(OH)2 ---> Mg3(PO4)2 + 6H2O\n\n";

  input_equation(reactants);
  cout << " ---> ";
  input_equation(products);

}

void input_equation(equationType_ref oneSide)
{
  char ch = NULL;
  boolean rightParen_expected, valid_element;
  equationType_ptr curr_compound = NULL;
  compoundType_ptr curr_element = NULL;

  while (ch != '\r') {
	 if (!*oneSide) {             //creates first compound
		if (!(curr_compound = create_compound())) exit(1);
		*oneSide = curr_compound;  //*oneSide stays on first compound - FIFO
	 }
	 else {                       //creates rest of compounds
		if (!(curr_compound->next = create_compound())) exit(1);
		curr_compound = curr_compound->next;
	 }
	 curr_compound->coef = 1; /*not this*/  //set record to NULL
	 curr_compound->compound = NULL;
	 curr_compound->next = NULL;
	 /*****************************/
	 rightParen_expected = FALSE;      //reset values
	 valid_element = FALSE;
	 while ((ch != ' ' && ch != '\r') || rightParen_expected || !valid_element) {
		switch (ch = getch()) {
		case pr:
		  if (rightParen_expected && valid_element && curr_element->paren != pl) {
			 cout << ch;
			 while (!(ch = distribute_SS(&curr_compound->compound, 0)));
			 curr_element->paren = pr;
			 rightParen_expected = FALSE;
		  }   //no break - must check ch
		  else break;
		case pl:                           //create new element
		  if (!rightParen_expected && ch == pl) {
			 if (curr_element)    //if not NULL test to see that data is NULL
				if (curr_element->data && !valid_element) break;
			 if (!curr_compound->compound) {     //creates first element
				if (!(curr_element = create_element())) exit(1);
				  curr_compound->compound = curr_element; //FIFO
			 }
			 else {                              //creates rest of elements
				if (!(curr_element->next = create_element())) exit(1);
				curr_element = curr_element->next;
			 }
			 cout << ch;
			 ch = getch();                //get first letter of element
			 char ch2[2] = {ch, NULL};    //needs NULL character
			 while (ch < 'A' || ch > 'Z' || !canBeElement(ch2)) {
				ch = getch();
				ch2[0] = ch;
			 }
			 curr_element->data[0] = ch;         //set to ch(user entered)
			 curr_element->data[1] = NULL;       //       NULL
			 curr_element->paren = pl;           //       pl
			 curr_element->subscript = 0;        //       NULL(actually 1)
			 curr_element->element_num = 0;      //       NULL
			 curr_element->next = NULL;          //       NULL
			 rightParen_expected = TRUE;
			 valid_element = isAnElement(curr_element->data);
			 cout << ch;
			 ch = NULL;   //no break
		  }    //no break - must check ch
		default:                 //create new element
		  if (ch >= 'A' && ch <= 'Z') {
			 if (curr_element)    //if not NULL test to see that data is NULL
				if (curr_element->data && !valid_element) break;
			 char ch2[2] = {ch, NULL};  //canBeElement requires NULL
			 if (canBeElement(ch2)) {   //character on parameter
				if (!curr_compound->compound) {   //creates first element
				  if (!(curr_element = create_element())) exit(1);
				  curr_compound->compound = curr_element; //FIFO
				}
				else {                            //creates rest of elements
				  if (!(curr_element->next = create_element())) exit(1);
				  curr_element = curr_element->next;
				}
				curr_element->data[0] = ch;         //set to ch(user entered)
				curr_element->data[1] = NULL;       //       NULL
				curr_element->paren = pn;           //       NULL
				curr_element->subscript = 0;        //       NULL(actually 1)
				curr_element->element_num = 0;      //       NULL
				curr_element->next = NULL;          //       NULL
				valid_element = isAnElement(curr_element->data);
				cout << ch;
			 }
		  }
		  else if (ch >= 'a' && ch <= 'z' && curr_element->subscript == 0) {
			 int i = 0;
			 while (curr_element->data[i]) i++;
			 if (i < name_size - 1) {
				curr_element->data[i] = ch;
				curr_element->data[i + 1] = NULL;
				if (canBeElement(curr_element->data))
				  cout << ch;
				else
				  curr_element->data[i] = NULL;
				valid_element = isAnElement(curr_element->data);
			 }
		  }
		  else if (ch >= '0' && ch <= '9' && valid_element) {  //get subscript
			 if ((curr_element->subscript || atoi(&ch)) &&
				  curr_element->subscript < max_subscript / 10) {
				curr_element->subscript = (curr_element->subscript * 10) + atoi(&ch);
				cout << ch;
			 }
		  }
		  break;
		}
	 }
	 if (ch == ' ') { cout << " + ";  curr_element = NULL; }
  }
}

inline equationType_ptr create_compound()
{  return (equationType_ptr)malloc(sizeof(equationType));  }

inline compoundType_ptr create_element()
{  return (compoundType_ptr)malloc(sizeof(compoundType));  }

inline boolean canBeElement(const char *test_element)
{
  if (bsearch(test_element, elements, numElements, name_size, compare_part))
	 return TRUE;
  else
	 return FALSE;
}

inline int compare_part(const void *e1, const void *e2)
{  return strncmp((const char *)e1, (const char *)e2, strlen((const char*) e1));  }

char distribute_SS(compoundType_ref first_element, unsigned int SS)
{                                                    //Will point to:
  compoundType_ptr temp_elementPL;                   //paren left
  compoundType_ptr last_element = *first_element;    //last element
  char ch;

  while (last_element) {  //loop until end of element list (compound)
	 if (last_element->paren == pl) temp_elementPL = last_element;
	 last_element = last_element->next;
  }  //while loop - finds last set of parentheses in compound

  ch = getch();
  char ch2[2] = {ch, NULL};            //ch2 requires NULL character
  if (ch >= '0' && ch <= '9')
	 if ((SS || atoi(&ch)) && SS < max_subscript / 10) {
		SS = (SS * 10) + atoi(&ch);
		last_element = temp_elementPL;
		while (last_element)             //check subscripts
		  if ((long)last_element->subscript * (long)SS < max_subscript)
			 last_element = last_element->next;
		  else                           //SS too high
			 return NULL;
		cout << ch;
		while (!(ch = distribute_SS(first_element, SS)));
      return ch;
	 }
	 else return NULL;
  else if (SS && (canBeElement(ch2) || ch == ' ' || ch == '\r' || ch == pl)) {
	 while (temp_elementPL) {       //distribute SS - end of recursion
		if (!temp_elementPL->subscript) temp_elementPL->subscript++;//0 - add 1
		temp_elementPL->subscript *= SS;
		temp_elementPL = temp_elementPL->next;
	 }
	 return ch;
  }
  else return NULL;
}

boolean balance_equation(equationType_ptr reactants, equationType_ptr products,
  const unsigned int num_elements, const unsigned int curr_elementNum,
  const unsigned int tempCurr_elementNum)
{
  int compared;        //out of stack space - too much recursion
  if (!num_elements || (stackavail() < (size_t)100)) return FALSE;
  if (tempCurr_elementNum > curr_elementNum) return TRUE;
  //(above)made it to curr_elementNum - recursive from 1 ... curr_elementNum
  if (compared = equal_elements(reactants, products, tempCurr_elementNum))
	 if (!(balance_element(reactants, products, tempCurr_elementNum, compared) &&
		 balance_equation(reactants, products, num_elements, curr_elementNum)))
		return FALSE;      //unable to balance equation
  if (!balance_equation(reactants, products, num_elements,
	 curr_elementNum, tempCurr_elementNum + 1)) return FALSE;
  return TRUE;
}

boolean balance_equation(equationType_ptr reactants, equationType_ptr products,
  const unsigned int curr_elementNum)
{
  int compared;
  if (compared = equal_elements(reactants, products, curr_elementNum))
	 if (!balance_element(reactants, products, curr_elementNum, compared))
		return FALSE;      //unable to balance element
  return TRUE;
}
unsigned int number_elements(equationType_ptr reactants, equationType_ptr products)
{
  equationType_ptr temp_side;
  compoundType_ptr curr_element = reactants->compound, temp_element;
  unsigned int num_elements = 1;     //number of different reac. elements
  char temp_elementName[name_size];  //name of element being numbered

  while (curr_element = firstZero_element(&reactants, curr_element)) {
	 strcpy(temp_elementName, curr_element->data);
	 temp_side = reactants;  temp_element = curr_element;
	 while (temp_element = firstZero_element(&temp_side, temp_element))
		if (!strcmp(temp_element->data, temp_elementName))
		  temp_element->element_num = num_elements;    //number reactants
		else temp_element = temp_element->next;
	 temp_side = products;  temp_element = products->compound;
	 while (temp_element = firstZero_element(&temp_side, temp_element))
		if (!strcmp(temp_element->data, temp_elementName))
		  temp_element->element_num = num_elements;    //number products
		else temp_element = temp_element->next;
	 if (((curr_element = firstZero_element(&reactants, curr_element)) &&
		 !firstZero_element(&products, products->compound)) ||
		 (!(curr_element = firstZero_element(&reactants, curr_element)) &&
		 firstZero_element(&products, products->compound)))
		return 0;    //different elements on each side of equation
	 if (num_elements == 65535L) return 0; else num_elements++;
  }
  return num_elements - 1;
}

compoundType_ptr firstZero_element(equationType_ref oneSide, compoundType_ptr curr_element)
{
  /* finds first zero value of num_elements; retruns NULL if none */
  while (*oneSide) {
	 while (curr_element)
		if (curr_element->element_num)
		  curr_element = curr_element->next;
		else return curr_element;  //found a zero value
	 *oneSide = (*oneSide)->next;
	 if (oneSide) curr_element = (*oneSide)->compound;
  }
  return NULL;                   //end of list - no more compounds
}

int equal_elements(equationType_ptr reactants, equationType_ptr products,
  const unsigned int curr_elementNum)
{
  unsigned long reacTot = 0, prodTot = 0; //values could exceed unsigned int
  compoundType_ptr curr_element = reactants->compound;

  while (reactants) {
	 while (curr_element) {
		if (curr_element->element_num == curr_elementNum)
		  reacTot += ((unsigned long)reactants->coef *
		  ((curr_element->subscript == 0) ? 1 : curr_element->subscript));
		curr_element = curr_element->next;
	 }
	 reactants = reactants->next;
	 if (reactants) curr_element = reactants->compound;
  }

  curr_element = products->compound;
  while (products) {
	 while (curr_element) {
		if (curr_element->element_num == curr_elementNum)
		  prodTot += ((unsigned long)products->coef *
		  ((curr_element->subscript == 0) ? 1 : curr_element->subscript));
		curr_element = curr_element->next;
	 }
	 products = products->next;
	 if (products) curr_element = products->compound;
  }       //change to pointers and send the value
  return (reacTot < prodTot) ? -1 : ((reacTot > prodTot) ? 1 : 0);
}

boolean balance_element(equationType_ptr reactants, equationType_ptr products,
  const unsigned int curr_elementNum, int compared)
{                                       //values could exceed unsigned int
  unsigned long low, least_occurrence;  //-one below lowest possible value
  equationType_ptr oneSide, temp_oneSide;
  compoundType_ptr curr_element;
  do {
	 low = 4294967295L;  least_occurrence = 0;
	 temp_oneSide = oneSide = (compared == -1) ? reactants : products;
	 curr_element = oneSide->compound;
	 while (oneSide) {
		while (curr_element) {
		  if (curr_element->element_num == curr_elementNum)
			 least_occurrence += ((unsigned long)oneSide->coef *
			 ((curr_element->subscript == 0) ? 1 : curr_element->subscript));
		  curr_element = curr_element->next;
		}
		if (low > least_occurrence && least_occurrence != 0) {
		  low = least_occurrence;
		  least_occurrence = 0;
		  temp_oneSide = oneSide;
		}
		oneSide = oneSide->next;
		if (oneSide) curr_element = oneSide->compound;
	 }
  if (temp_oneSide->coef == 65535L) return FALSE; //maximum unsigned int
  temp_oneSide->coef++;
  } while (compared = equal_elements(reactants, products, curr_elementNum));
  return TRUE;
}

void show_equation(equationType_ptr oneSide)
{
  compoundType_ptr curr_element = oneSide->compound;
  unsigned int SS;

  while (oneSide) {
	 if (oneSide->coef > 1) cout << oneSide->coef;
	 while (curr_element) {
		if (curr_element->paren == pl)
		  if ((SS = factorOut_SS(curr_element)) > 1) cout << pl;
		cout << curr_element->data;
		if (curr_element->subscript > 1) cout << curr_element->subscript;
		if (curr_element->paren == pr && SS > 1) {
		  cout << pr;
		  cout << SS;
		}
		curr_element = curr_element->next;
	 }
	 oneSide = oneSide->next;
	 if (oneSide) {
		curr_element = oneSide->compound;
		cout << " + ";
	 }
  }
}

void reset_coefs(equationType_ptr oneSide)
{
  while (oneSide) {
	 oneSide->coef = 1;
	 oneSide = oneSide->next;
  }
}

equationType_ptr pop_compound(equationType_ptr oneSide)
{
  equationType_ptr temp_side = oneSide->next;
  while (oneSide->compound)       //free memory for element list
	 oneSide->compound = pop_element(oneSide->compound);
  free(oneSide);
  return temp_side;
}

compoundType_ptr pop_element(compoundType_ptr curr_element)
{
  compoundType_ptr temp_element = curr_element->next;
  free(curr_element);
  return temp_element;
}

unsigned int factorOut_SS(compoundType_ptr curr_elementPL)
{
  compoundType_ptr curr_elementPR = curr_elementPL;
  unsigned int SS;

  for (SS = max_subscript - 1; SS > 0; SS--) {  //find SS
	 while (!(curr_elementPR->subscript % SS)) {
      if (curr_elementPR->paren == pr) break;
		curr_elementPR = curr_elementPR->next;
	 }
	 if (curr_elementPR->paren == pr && !(curr_elementPR->subscript % SS)) break;
	 curr_elementPR = curr_elementPL;
  }

  while (curr_elementPL != curr_elementPR) {    //factor out SS
	 curr_elementPL->subscript /= SS;
	 curr_elementPL = curr_elementPL->next;
  }
  curr_elementPL->subscript /= SS;

  return SS;
}
