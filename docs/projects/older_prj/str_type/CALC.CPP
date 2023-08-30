#include "str_type.h"
#include "calc.rh"
#include <windows.h>                   //must be after str_type.h
#include "ctl3d.h"                     //must be after windows.h

BOOL CALLBACK DialogFunc(HWND, UINT, WPARAM, LPARAM);
str_type op1 = "0", op2, ans;   //op1 is initially 0
bool is_op1 = FALSE;
unsigned char operation = 0;    //no initial operation

int WINAPI WinMain(HINSTANCE hThisInst, HINSTANCE hPrevInst,
						 LPSTR lpszArgs, int nWinMode)
{
  Ctl3dRegister(hThisInst);
  Ctl3dAutoSubclass(hThisInst);
  DialogBox(hThisInst, "Calculator", HWND_DESKTOP, (DLGPROC)DialogFunc);
  Ctl3dUnregister(hThisInst);
  return 0;
}

BOOL CALLBACK DialogFunc(HWND hdwnd, UINT message,
								 WPARAM wParam, LPARAM lParam)
{

  if (message == WM_COMMAND)
	 switch(LOWORD(wParam)) {
	 case IDCANCEL:
		EndDialog(hdwnd, 0);
		return 1;
	 case IDC_plus:
		operation = IDC_plus;
		break;
	 case IDC_minus:
		operation = IDC_minus;
		break;
	 case IDC_multiply:
		operation = IDC_multiply;
		break;
	 case IDC_divide:
		operation = IDC_divide;
		break;
	 case IDC_return:
		SetDlgItemText(hdwnd, IDC_num_box, ans);
		break;
	 case IDC_number0:
	 case IDC_number1:
	 case IDC_number2:
	 case IDC_number3:
	 case IDC_number4:
	 case IDC_number5:
	 case IDC_number6:
	 case IDC_number7:
	 case IDC_number8:
	 case IDC_number9:
		if (is_op1) {
		  is_op1 = FALSE;
		  op2 = op2 + to_str(LOWORD(wParam) - extra
		}
		else {
		  is_op1 = TRUE;
		  op1 = op1 + to_str(LOWORD(wParam) - extra);
		}
		break;
	 }

  switch operation {
  case IDC_plus:
	 ans = remove_leading_zeros(to_str((str_type::str_int)(op1() + op2())));
  case IDC_minus:
	 ans = remove_leading_zeros(to_str((str_type::str_int)(op1() - op2())));
  case IDC_multiply:
	 ans = remove_leading_zeros(to_str((str_type::str_int)(op1() * op2())));
  case IDC_divide:
	 ans = remove_leading_zeros(to_str((str_type::str_int)(op1() / op2())));
	 if (is_op1) is_op1 = FALSE;  else is_op1 = TRUE;
	 break;
  }

  return 0;
}