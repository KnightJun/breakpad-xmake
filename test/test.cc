
#include <breakpadwarp.h>
#include <stdio.h>

int main(int argc, char const *argv[])
{
    google_breakpad::InstallCrashHandler();
    int c = 1;
    c--;
    int d = 12 / c;
    int *a = (int *)0;
    *a += 1;
    printf("hello world");
    return *a;
}
