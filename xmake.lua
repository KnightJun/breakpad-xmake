add_includedirs("breakpad\\src", "win_patch")
add_defines("_UNICODE", "UNICODE")
target("common")
    set_kind("static")
    add_files("breakpad\\src\\common\\windows\\guid_string.cc")
    add_files("breakpad\\src\\common\\windows\\http_upload.cc")
    add_files("breakpad\\src\\common\\windows\\string_utils.cc")
    

target("exception_handler")
    set_kind("static")
    add_files("breakpad\\src\\client\\windows\\handler\\exception_handler.cc")

target("crash_generation_client")
    set_kind("static")
    add_files("breakpad\\src\\client\\windows\\crash_generation\\crash_generation_client.cc")

target("wingetopt")
    set_kind("static")
    add_files("wingetopt\\wingetopt.c")

target("libdisasm")
    set_default(false)
    set_kind("static")
    add_files('breakpad\\src\\third_party\\libdisasm\\ia32_implicit.c',
	'breakpad\\src\\third_party\\libdisasm\\ia32_insn.c',
	'breakpad\\src\\third_party\\libdisasm\\ia32_invariant.c',
	'breakpad\\src\\third_party\\libdisasm\\ia32_modrm.c',
	'breakpad\\src\\third_party\\libdisasm\\ia32_opcode_tables.c',
	'breakpad\\src\\third_party\\libdisasm\\ia32_operand.c',
	'breakpad\\src\\third_party\\libdisasm\\ia32_reg.c',
	'breakpad\\src\\third_party\\libdisasm\\ia32_settings.c',
	'breakpad\\src\\third_party\\libdisasm\\x86_disasm.c',
	'breakpad\\src\\third_party\\libdisasm\\x86_format.c',
	'breakpad\\src\\third_party\\libdisasm\\x86_imm.c',
	'breakpad\\src\\third_party\\libdisasm\\x86_insn.c',
	'breakpad\\src\\third_party\\libdisasm\\x86_misc.c',
	'breakpad\\src\\third_party\\libdisasm\\x86_operand_list.c')

target("breakpadwarp")
    set_kind("shared")
    add_defines("Breakpadwarp_LIB")
    add_deps("exception_handler", "common", "crash_generation_client")
    add_files("breakpadwarp\\breakpadwarp.cc")
    add_headerfiles("breakpadwarp\\breakpadwarp.h")

target("processor")
    set_default(false)
    set_kind("static")
    add_deps("common", "libdisasm")
    add_files(
        'breakpad\\src\\processor\\basic_code_modules.cc',
        'breakpad\\src\\processor\\basic_source_line_resolver.cc',
        'breakpad\\src\\processor\\call_stack.cc',
        'breakpad\\src\\processor\\cfi_frame_info.cc',
        'breakpad\\src\\processor\\convert_old_arm64_context.cc',
        'breakpad\\src\\processor\\disassembler_x86.cc',
        'breakpad\\src\\processor\\dump_context.cc',
        'breakpad\\src\\processor\\dump_object.cc',
        'breakpad\\src\\processor\\exploitability.cc',
        'breakpad\\src\\processor\\exploitability_linux.cc',
        'breakpad\\src\\processor\\exploitability_win.cc',
        'breakpad\\src\\processor\\fast_source_line_resolver.cc',
        'breakpad\\src\\processor\\logging.cc',
        'breakpad\\src\\processor\\microdump_processor.cc',
        'breakpad\\src\\processor\\minidump.cc',
        'breakpad\\src\\processor\\minidump_processor.cc',
        'breakpad\\src\\processor\\module_comparer.cc',
        'breakpad\\src\\processor\\module_serializer.cc',
        'breakpad\\src\\processor\\pathname_stripper.cc',
        'breakpad\\src\\processor\\proc_maps_linux.cc',
        'breakpad\\src\\processor\\process_state.cc',
        'breakpad\\src\\processor\\simple_symbol_supplier.cc',
        'breakpad\\src\\processor\\source_line_resolver_base.cc',
        'breakpad\\src\\processor\\stack_frame_cpu.cc',
        'breakpad\\src\\processor\\stack_frame_symbolizer.cc',
        'breakpad\\src\\processor\\stackwalk_common.cc',
        'breakpad\\src\\processor\\stackwalker.cc',
        'breakpad\\src\\processor\\stackwalker_address_list.cc',
        'breakpad\\src\\processor\\stackwalker_amd64.cc',
        'breakpad\\src\\processor\\stackwalker_arm.cc',
        'breakpad\\src\\processor\\stackwalker_arm64.cc',
        'breakpad\\src\\processor\\stackwalker_mips.cc',
        'breakpad\\src\\processor\\stackwalker_ppc.cc',
        'breakpad\\src\\processor\\stackwalker_ppc64.cc',
        'breakpad\\src\\processor\\stackwalker_selftest.cc',
        'breakpad\\src\\processor\\stackwalker_sparc.cc',
        'breakpad\\src\\processor\\stackwalker_x86.cc',
        'breakpad\\src\\processor\\symbolic_constants_win.cc',
        'breakpad\\src\\processor\\synth_minidump.cc',
        'breakpad\\src\\processor\\tokenize.cc')

target("minidump_stackwalk")
    set_default(false)
    set_kind("binary")
    add_deps("wingetopt", "processor", "common")
    add_files("breakpad\\src\\processor\\minidump_stackwalk.cc")


target("test")
    set_default(false)
    set_kind("binary")
    add_includedirs("breakpadwarp")
    set_symbols("debug")
    add_deps("breakpadwarp")
    add_files("test\\test.cc")
    after_build(function (target)
        local pdbfile = path.join(target:targetdir(), target:basename()..'.pdb')
        local symfile = path.join(target:targetdir(), target:basename()..'.sym')
        os.execv("dump_syms.exe", {pdbfile}, {stdout = symfile})
        local  dbgsymdir = path.join(target:targetdir(), "debug_symbol")
        os.mkdir(dbgsymdir)
        local pdbdir = path.join(dbgsymdir, target:basename()..'.pdb')
        os.mkdir(pdbdir)
        local idstr = io.lines(symfile)():split(' ')[4]
        local iddir = path.join(pdbdir, idstr)
        os.mkdir(iddir)
        os.cp(symfile, iddir)
    end)