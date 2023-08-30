// SGA (Simple Graphics Application) class, implementation.

// David Mutchler, August 1996.
// Intended use: a Console project but with:
//   -- "Use MFC in a Shared DLL" (Project~Settings, General tab)
//   -- Library and include files for sound (Link tab, winmm.lib)
//   -- No precompiled headers (so the project is smaller)

#include <afxwin.h>
#include <iostream>
#include "sga.h"

using namespace std;
SGA  sga;
CDC* pDC;

void ShowGraphics()
// Call this from main() to show the graphics window.
// Call it only once.
{
	sga.ShowGraphics();
}

SGA::SGA()
// Register the window class.
// Create the graphics windows.
{
	WNDCLASS wc;
	HINSTANCE hinst;

	// Set the resource handle (to enable loading bitmaps).

	hinst = GetModuleHandle( NULL );
	AfxSetResourceHandle( hinst );
		
	// Register the window class.

	wc.style = 0; 
    wc.lpfnWndProc = (WNDPROC) WndProc; 
    wc.cbClsExtra = 0; 
    wc.cbWndExtra = 0;
    wc.hInstance = (HINSTANCE) NULL; 
    wc.hIcon = LoadIcon((HINSTANCE) NULL,
		IDI_APPLICATION); 
    wc.hCursor = LoadCursor((HINSTANCE) NULL,
		IDC_ARROW); 
    wc.hbrBackground =
		(HBRUSH) GetStockObject(WHITE_BRUSH); 
    wc.lpszMenuName =  "MainMenu"; 
    wc.lpszClassName = "MainWndClass"; 
 
    if (!AfxRegisterClass(&wc))
	{
		cout << "Something is wrong: "
			<< "AfxRegisterClass failed." << endl;
		cout << "Get help from your instructor." << endl;
		exit( 0 );
	}
           
    // Create the graphics window. 
 
    m_hwndMain = CreateWindow("MainWndClass",
		"Simple Graphics Application",
        WS_OVERLAPPEDWINDOW,
		CW_USEDEFAULT, CW_USEDEFAULT,
        CW_USEDEFAULT, CW_USEDEFAULT,
		(HWND) NULL, 
        (HMENU) NULL, (HINSTANCE) NULL, (LPVOID) NULL); 
	
	if (!m_hwndMain)
	{
		cout << "Something is wrong: "
			<< "CreateWindow failed." << endl;
		cout << "Get help from your instructor." << endl;
		exit( 0 );
	}
	
	// Create the memory device context and its bitmap.

	CWnd* pWindow;
	pWindow = CWnd::FromHandle( m_hwndMain );

	CClientDC dc( pWindow );
	
	m_memoryBitmap.CreateCompatibleBitmap( &dc, 800, 600 );
	m_memoryDC.CreateCompatibleDC( &dc );
	m_memoryDC.SelectObject( & m_memoryBitmap );
	m_memoryDC.SelectObject( GetSysColorBrush(
		GetSysColor( COLOR_WINDOW ) ) );
	m_memoryDC.PatBlt( 0, 0, 800, 600, PATCOPY );

	pDC = & (sga.m_memoryDC);
}

void SGA::ShowGraphics()
// Display the graphics window,
// then enter the message loop.
// Stay in the message loop
// until a WM_DESTROY message arrives.
{
	MSG msg;

	cout << flush;

	ShowWindow( m_hwndMain, SW_SHOWMAXIMIZED );
	UpdateWindow( m_hwndMain );

    while (GetMessage(&msg, (HWND) NULL, 0, 0) == TRUE)
	{
        TranslateMessage(&msg); 
        DispatchMessage(&msg); 
    }
}

LRESULT CALLBACK WndProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
// Handle a windows message.
{
	PAINTSTRUCT ps;
	HDC hdc;

	switch (message) { 
		case WM_PAINT:
			hdc = BeginPaint (hWnd, &ps);
			BitBlt( hdc, 0, 0, 800, 600,
				pDC->GetSafeHdc(),
				0, 0, SRCCOPY );
			EndPaint (hWnd, &ps);
			break;        

		case WM_DESTROY:
			PostQuitMessage(0);
			break;

		default:
			return (DefWindowProc(hWnd, message, wParam, lParam));
	}
	return(0);
}
