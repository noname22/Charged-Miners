// Copyright © 2011, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/charge/charge.d (GPLv2 only).
module minecraft.lua.builtin;

import charge.sys.file;

void initLuaBuiltins()
{
	auto fm = FileManager();

	fm.addBuiltin("script/main-level.lua", import("main-level.lua"));
}