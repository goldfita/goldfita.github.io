#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctl3d.h>
#include <math.h>
#include <mem.h>
#include "bases.rh"

#define Max 32       // Maximum number of digits in binary - pow(2, 31)
#define Max10 "4294967295" // Largest number in base 10 - pow(2, 32) - 1

int yourBase;        // Base of number entered
BOOL CALLBACK DialogFunc(HWND, UINT, WPARAM, LPARAM);

BOOL isBadInput(char yourNum[], int base)  // returns 1 (TRUE) if bad input
{
  unsigned char chr;
  unsigned char digit = '0' + ((base > 10) ? 10: base); //digit == '0' + (2 to 10)
  unsigned char letter = 'A' + ((base > 10) ? base - 10: 0); //letter == 'A' + (0 to 26)

  /* searches for non-valid characters */
  for (chr = 1; chr < '0'; chr++)             // pre-digits
	 if (strchr(yourNum, chr)) return 1;
  for (chr = digit; chr < 'A'; chr++)         // post-digits, pre-letters
	 if (strchr(yourNum, chr)) return 1;
  for (chr = letter; chr < 255; chr++)        // post-letters
	 if (strchr(yourNum, chr)) return 1;
  if (strchr(yourNum, 255)) return 1;         //check character 255
  return 0;
}

int inline first(char d[])      // return first letter (digit)
{
  char d2[Max + 1];
  strcpy(d2, d);
  if (d2[0] > '9') {
	 itoa((d2[0] - 55), d2, 10);          // (55) - subtract to get base
	 d2[2] = '\0';
  } else d2[1] = '\0';
  return atoi(d2);
}

void ToBaseTen(char yourNum[])
{
  unsigned long numTen = 0;
  char *digit = yourNum;
  int YNlen = strlen(digit);
  for (int i = 0; i < YNlen; i++)
	 numTen += pow(yourBase, YNlen - (i + 1)) * first(digit++);
  ultoa(numTen, yourNum, 10);     // changes other yourNum to base 10
}

char *FromBaseTen(char numInTen[], int base)
{
  int len = 0;
  char newNum[Max + 1];
  memset(newNum, '0', Max);                         // string to all 0's
  unsigned long num = strtoul(numInTen, NULL, 10);
  while (num)
  {
	 float temp = 1;         // need large size for powers in loops
	 unsigned long tempI;
	 for (int i = 0; ; i++)
	 {
		if (temp * base <= 4294967295L) temp *= base;
		else { tempI = i;  break; }
		if (temp > num) { temp /= base;  tempI = i;  break; }
	 }
	 if (tempI > len) len = tempI;
	 for (i = 1; ; i++)             // find number - make into character
	 {
		temp *= i;
		if (temp > num || temp >= 4294967295L) {
		  char s[1];
		  if (i - 1 <= 9) {
			 if (i - 1 == 0) s[0] = num + 55;
			 else itoa(i - 1, s, 10);
		  }
		  else s[0] = i + 54;              // (i - 1) + 55
		  newNum[len - tempI] = s[0];
		  tempI = pow(base, tempI) * (i - 1);
		  break;
		}
		else temp /= i;
	 }
	 num -= tempI;
  }
  newNum[len + 1] = '\0';

  return &newNum[0];
}

int WINAPI WinMain(HINSTANCE hThisInst, HINSTANCE hPrevInst,
						 LPSTR lpszArgs, int nWinMode)
{
  Ctl3dRegister(hThisInst);
  Ctl3dAutoSubclass(hThisInst);
  DialogBox(hThisInst, "MainWindow", HWND_DESKTOP, (DLGPROC)DialogFunc);
  return 0;
  Ctl3dUnregister(hThisInst);
}

BOOL CALLBACK DialogFunc(HWND hdwnd, UINT message,
								 WPARAM wParam, LPARAM lParam)
{
  enum {n2,n3,n4,n5,n6,n7,n8,n9,a,b,c,d,e,f,g,h,i,j,k,l,m,n,
		  o,p,q,r,s,t,u,v,w,x,y,z,end} rightBase;
  char yourNum[Max + 1], temp_num[Max + 1];
  static BOOL program_edit = 0;  //FALSE
  static BOOL alarm_state = 1;   //TRUE - ON

  if (program_edit) return 0;

  if (message == WM_COMMAND)
	 switch(LOWORD(wParam)) {
	 case ID_ALARM_ON:       //Change to off
		ModifyMenu(GetMenu(hdwnd), ID_ALARM_ON, MF_BYCOMMAND, ID_ALARM_OFF, "&ALARM  OFF");
		DrawMenuBar(hdwnd);
		alarm_state = 0;
		return 1;
	 case ID_ALARM_OFF:      //change to on
		ModifyMenu(GetMenu(hdwnd), ID_ALARM_OFF, MF_BYCOMMAND, ID_ALARM_ON, "&ALARM  ON");
		DrawMenuBar(hdwnd);
      alarm_state = 1;
		return 1;
	 case ID_RESET:
      program_edit = 1;
		for (rightBase = n2; rightBase <= end; rightBase++) //Set to 0
			 SetDlgItemText(hdwnd, ID_Base2 + rightBase, "0");
		program_edit = 0;
		return 1;
	 case IDCANCEL:
		EndDialog(hdwnd, 0);
		return 1;
	 }
	 if (HIWORD(lParam) == EN_UPDATE)                      //change made
		for (rightBase = n2; rightBase <= end; rightBase++) //find base edited
		  if (LOWORD(wParam) == ID_Base2 + rightBase) {
			 yourBase = rightBase + 2;
			 if(!GetDlgItemText(hdwnd, ID_Base2 + rightBase, yourNum, Max + 1)) return 0;
			 /*Get max value in base entered - stored in temp_num*/
			 if (yourBase != 10) strcpy(temp_num, FromBaseTen(Max10, yourBase));
			 else strcpy(temp_num, Max10);
			 if (((strcmp(yourNum, temp_num) > 0) && //number too high
				   (strlen(temp_num) <= strlen(yourNum))) ||
				  (isBadInput(yourNum, yourBase))) {  //invalid character entered
				WORD chr;
				chr = LOWORD(SendDlgItemMessage(hdwnd, ID_Base2 + rightBase, EM_GETSEL, 0, 0));
				SendDlgItemMessage(hdwnd, ID_Base2 + rightBase, EM_SETSEL, 0, MAKELONG(chr - 1, chr));
				SendDlgItemMessage(hdwnd, ID_Base2 + rightBase, EM_REPLACESEL, 0, (LPARAM)"");
				if (alarm_state) MessageBeep(MB_OK);     //fix bad input
				return 1;
			 }
			 SendDlgItemMessage(hdwnd, ID_Base2 + rightBase, EM_EMPTYUNDOBUFFER, 0, 0);
			 ToBaseTen(yourNum);

			 program_edit = 1;
			 for (rightBase = n2; rightBase <= end; rightBase++) { //convert all
				if (rightBase == (yourBase - 2)) continue;
				strcpy(temp_num, FromBaseTen(yourNum, rightBase + 2));
				SetDlgItemText(hdwnd, ID_Base2 + rightBase, temp_num);
			 }
			 program_edit = 0;
			 return 1;
		  };
  return 0;
}
