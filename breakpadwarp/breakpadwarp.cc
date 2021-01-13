#include "breakpadwarp.h"
#include "client/windows/handler/exception_handler.h"
#include <stdio.h>

using google_breakpad::ExceptionHandler;
using namespace google_breakpad;
static BeforeDumpCallback g_beforecb = nullptr;
static AfterDumpCallback g_aftercb = nullptr;
// We leak the object on purpose.
ExceptionHandler* exception_handler = nullptr;

bool OnMinidumpGenerated(const wchar_t* dump_path, const wchar_t* minidump_id, void* context,
                         EXCEPTION_POINTERS* exinfo, MDRawAssertionInfo* assertion, bool succeeded)
{
    return g_aftercb(dump_path, minidump_id, context, succeeded);
}

bool BeforeMinidumpGenerated(void* context, EXCEPTION_POINTERS* exinfo,
                                 MDRawAssertionInfo* assertion)
{
    return g_beforecb(context);
}
bool google_breakpad::InstallCrashHandler(
    const std::wstring& dump_path,
    BeforeDumpCallback beforecb,
    AfterDumpCallback aftercb,
    void* callback_context,
    const std::map<std::wstring, std::wstring> *custom_info
    )
    {
        // This is needed for CRT to not show dialog for invalid param
        // failures and instead let the code handle it.
        _CrtSetReportMode(_CRT_ASSERT, 0);
        g_beforecb = beforecb;
        g_aftercb = aftercb;
        CustomClientInfo custom_infoobj;
        CustomInfoEntry* cutEntrys = nullptr;
        if(custom_info){
            cutEntrys = new CustomInfoEntry[custom_info->size()];
            CustomInfoEntry* p_cutEntrys = cutEntrys;
            for (auto &kv : *custom_info) {
                p_cutEntrys->set(kv.first.c_str(), kv.second.c_str());
            }
            custom_infoobj.count = custom_info->size();
            custom_infoobj.entries = cutEntrys;
        }
        exception_handler = new ExceptionHandler(dump_path,
                                                g_beforecb ? BeforeMinidumpGenerated : nullptr,
                                                g_aftercb ? OnMinidumpGenerated : nullptr,
                                                callback_context,
                                                ExceptionHandler::HANDLER_ALL,
                                                MiniDumpNormal,
                                                L"",
                                                custom_info ? &custom_infoobj : nullptr);
        if(cutEntrys){
            delete[] cutEntrys;
        }
        return exception_handler;
    }