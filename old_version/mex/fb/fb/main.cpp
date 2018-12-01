#include <cstdlib>
#include <windows.h>
#include <stdlib.h>
#include <string.h>
#include <tchar.h>
#include <time.h>
#include "lsl_cpp.h"
using namespace std;

/*typedef struct _RECT {
  LONG left;
  LONG top;
  LONG right;
  LONG bottom;
} RECT, *PRECT;*/


static TCHAR szWindowClass[] = _T("win32app");
static TCHAR szTitle[] = _T("Win32 Guided Tour Application");
string field = "name";
string value = "feedback";
short fb;
short old_fb;
long window_width = 1280;
long window_height = 1024;



const RECT fb_rect = {0,0, window_width, window_height};



LRESULT CALLBACK WndProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
{
	PAINTSTRUCT ps;
	HDC hdc;// = GetDC(hWnd);
	//int aElements[1] = {COLOR_WINDOW};

	//DWORD aNewColors[1];
	HBRUSH brush = CreateSolidBrush(RGB(0xff, old_fb,old_fb)); 

	switch (message)
	{
		case WM_ERASEBKGND:

			//return 1;
		
	case WM_PAINT:
		
		
			//aNewColors[0] = RGB(0xff, old_fb,old_fb); 
			hdc = BeginPaint(hWnd, &ps);
			//SetSysColors(1, aElements, aNewColors);

			
			FillRect(hdc,&fb_rect,brush);


			DeleteObject(brush);
			EndPaint(hWnd, &ps);
		
		break;
	case WM_DESTROY:
		PostQuitMessage(0);
		break;
	

	default:
		
		return DefWindowProc(hWnd, message, wParam, lParam);

		break;
	}

	return 0;
}




int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance,LPSTR lpCmdLine,int nCmdShow)
{

		vector<lsl::stream_info> streams = lsl::resolve_stream(field,value);
		lsl::stream_inlet inlet(streams[0],1,1,1);



	WNDCLASSEX wcex;

	wcex.cbSize = sizeof(WNDCLASSEX);
	wcex.style          = CS_HREDRAW | CS_VREDRAW;
	wcex.lpfnWndProc    = WndProc;
	wcex.cbClsExtra     = 0;
	wcex.cbWndExtra     = 0;
	wcex.hInstance      = hInstance;
	wcex.hIcon          = LoadIcon(hInstance, MAKEINTRESOURCE(IDI_APPLICATION));
	wcex.hCursor        = LoadCursor(NULL, IDC_ARROW);
	wcex.hbrBackground  = (HBRUSH)(COLOR_WINDOW+1);
	wcex.lpszMenuName   = NULL;
	wcex.lpszClassName  = szWindowClass;
	wcex.hIconSm        = LoadIcon(wcex.hInstance, MAKEINTRESOURCE(IDI_APPLICATION));



	if (!RegisterClassEx(&wcex))
	{
		MessageBox(NULL,
			_T("Call to RegisterClassEx failed!"),
			_T("Win32 Guided Tour"),
			NULL);

		return 1;
	}


	HWND hWnd = CreateWindow(
		szWindowClass,
		szTitle,
		WS_OVERLAPPEDWINDOW,
		CW_USEDEFAULT, CW_USEDEFAULT,
		window_width, window_height,
		NULL,
		NULL,
		hInstance,
		NULL
		);

	if (!hWnd)
	{
		MessageBox(NULL,
			_T("Call to CreateWindow failed!"),
			_T("Win32 Guided Tour"),
			NULL);

		return 1;
	}


	ShowWindow(hWnd,1);

	UpdateWindow(hWnd);

	MSG msg;
	double timestamp;
	
	while (true)//(GetMessage(&msg, NULL, 0, 0))
	{
		try
		{
		timestamp = inlet.pull_sample(&fb,1,0.1);
		}
		catch (...)
{			return 300;}

		if (timestamp)
		{
			old_fb = 255-fb;
			if (old_fb > 255)
			{
				old_fb = 255;
			}
			else if(old_fb < 0)
			{
				old_fb = 0;
			}
			
			InvalidateRect(hWnd,&fb_rect,1);
		GetMessage(&msg, NULL, 0, 0);
		TranslateMessage(&msg);
		DispatchMessage(&msg);
		}
		
		
		//RedrawWindow(hWnd,&fb_rect,NULL,RDW_INTERNALPAINT );
		//ShowWindow(hWnd,1);
		//UpdateWindow(hWnd);
		//Sleep(10);
		
	}

	return (int) msg.wParam;
}









