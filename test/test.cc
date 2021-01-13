
#include <breakpadwarp.h>
#include <stdio.h>

int main(int argc, char const *argv[])
{
    google_breakpad::InstallCrashHandler();
    int *a = (int *)0;
    *a += 1;
    printf("hello world");
    return *a;
}
