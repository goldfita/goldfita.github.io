// SGA (Simple Graphics Application) class, interface.

// David Mutchler, August 1996.
// Intended use: a Console project but with:
//   -- "Use MFC in a Shared DLL" (Project~Settings, General tab)
//   -- Library and include files for sound (Link tab, winmm.lib)
//   -- No precompiled headers (so the project is smaller)

#if !defined(sga_h)
#define sga_h

#include <afxwin.h>
#include <mmsystem.h>
#include "colors.h"

extern CDC* pDC;	// In main(), use pDC->BLAH.
void ShowGraphics();

LRESULT CALLBACK WndProc(HWND, UINT, WPARAM, LPARAM);

class SGA
{
public:
	SGA();
	void ShowGraphics();

private:
	HWND	m_hwndMain;	// handle for graphics window
	CDC		m_memoryDC;	// accumulates the graphics
	CBitmap	m_memoryBitmap;	// bitmap for memory DC
};

#endif // !defined(sga_h)
