#pragma once
#include <map>
#include <string>
namespace google_breakpad{
    typedef bool (*BeforeDumpCallback)(void* context);
    typedef bool (*AfterDumpCallback)(const wchar_t* dump_path,
                                    const wchar_t* minidump_id,
                                    void* context,
                                    bool succeeded);
    bool InstallCrashHandler(
        const std::wstring& dump_path = L"./CrashDumps",
        BeforeDumpCallback beforecb = nullptr,
        AfterDumpCallback aftercb = nullptr,
        void* callback_context = nullptr,
        const std::map<std::wstring, std::wstring> *custom_info = nullptr
        );
}
