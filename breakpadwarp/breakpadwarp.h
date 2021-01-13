#pragma once
#include <map>
#include <string>

#if defined(_MSC_VER)
#  define DECL_EXPORT __declspec(dllexport)
#  define DECL_IMPORT __declspec(dllimport)
#endif

#ifndef BUILD_STATIC
# if defined(Breakpadwarp_LIB)
#  define Breakpadwarp_EXPORT DECL_EXPORT
# else
#  define Breakpadwarp_EXPORT DECL_IMPORT
# endif
#else
# define Breakpadwarp_EXPORT
#endif

namespace google_breakpad{
    typedef bool (*BeforeDumpCallback)(void* context);
    typedef bool (*AfterDumpCallback)(const wchar_t* dump_path,
                                    const wchar_t* minidump_id,
                                    void* context,
                                    bool succeeded);
    Breakpadwarp_EXPORT bool InstallCrashHandler(
        const std::wstring& dump_path = L"./CrashDumps",
        BeforeDumpCallback beforecb = nullptr,
        AfterDumpCallback aftercb = nullptr,
        void* callback_context = nullptr,
        const std::map<std::wstring, std::wstring> *custom_info = nullptr
        );
}
