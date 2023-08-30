// Element header file

#ifndef element_H
#define element_H

const numElements = 118;              // number of known elements
const name_size = 4;                  // name length of elements + 1 (null)

typedef enum {FALSE, TRUE} boolean;
															 // array for known elements
const extern char elements[numElements][name_size];

// Functions
void alphabetize_elements();                  // A to Z

int compare(const char *e1, const char *e2);

boolean isAnElement(const char *test_element);

#endif