
#include "client/windows/handler/exception_handler.h"

namespace {

using google_breakpad::ExceptionHandler;

const wchar_t kCrashDumpDirName[] = L"crash_dumps";
const wchar_t kHintMessage[] = L"我...挂了...囧rz";

// We leak the object on purpose.
ExceptionHandler* exception_handler = nullptr;

bool OnMinidumpGenerated(const wchar_t* dump_path, const wchar_t* minidump_id, void* context,
                         EXCEPTION_POINTERS* exinfo, MDRawAssertionInfo* assertion, bool succeeded)
{
    if (succeeded)
    {
        MessageBoxW(nullptr, kHintMessage, L"Error", MB_OK);
    }

    return succeeded;
}

void InstallCrashHandler()
{
    // This is needed for CRT to not show dialog for invalid param
    // failures and instead let the code handle it.
    _CrtSetReportMode(_CRT_ASSERT, 0);

    exception_handler = new ExceptionHandler(L"C:\\dumps\\",
                                             nullptr,
                                             OnMinidumpGenerated,
                                             nullptr,
                                             ExceptionHandler::HANDLER_ALL,
                                             MiniDumpNormal,
                                             L"",
                                             nullptr);
}

}   // namespace
int main(int argc, char const *argv[])
{
    InstallCrashHandler();
    int *a = (int *)0x12345;
    *a += 1;
    return *a;
}
