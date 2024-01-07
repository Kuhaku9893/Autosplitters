// This is semi-autosplitter, you should stop manually.
// This autosplitter can start, split and reset timer.

// ------------------------------------------------------------ //
// 			Initialization
// ------------------------------------------------------------ //

state("Typoman", "ver1.10.02.05.17")
{
	// memSize : 23171072
	int mainChap: "Typoman.exe", 0x0135A9E0, 0xC, 0x388, 0x98, 0xD8, 0x40;
    int subChap: "Typoman.exe", 0x0135A9E0, 0xC, 0x10, 0x98, 0xD8, 0x44;
    int notMenuFlg: "Typoman.exe", 0x0140DDE8, 0x8, 0x28, 0x20, 0x5F4;
    int isGameModeFlg: "Typoman.exe", 0x0140DDE8, 0x8, 0x48, 0x30, 0x384;
}

startup
{
	settings.Add("note", true, "note : If start toggle is uncheked, autosplitter dosn't work");
	settings.SetToolTip("note", "Note's toggle has no effect");
	
	// chap.0 : 0, 2 - 8
	settings.Add("chapter0", true, "Prologue (8 sub-chapters)");
	settings.Add("0-0", true, "0-1", "chapter0");
	for (var index = 2; index < 8; ++index)
	{
		settings.Add("0-" + index.ToString(), true, "0-" + index.ToString(), "chapter0");
	}
	settings.SetToolTip("chapter0", "Split \"Prologue\" equals split at the end of 0-8");

	// chap.1 : 0 - 9
	settings.Add("chapter1", true, "Chapter.1 (10 sub-chapters)");
	for (var index = 0; index < 9; ++index)
	{
		settings.Add("1-" + index.ToString(), true, "1-" + (index+1).ToString(), "chapter1");
	}
	settings.SetToolTip("chapter1", "Split \"Chapter.1\" equals split at the end of 1-10");

	// chap.2 : 0 - 15
	settings.Add("chapter2", true, "Chapter.2 (16 sub-chapters)");
	for (var index = 0; index < 15; ++index)
	{
		var str = "";
		var flg = true;
		switch (index)
		{
			case 0:
				str = " (cut scene only)";
				break;
			case 2:
				str = " (very short segment)";
				flg = false;
				break;
			default:
				break;
		}
		settings.Add("2-" + index.ToString(), flg, "2-" + (index+1).ToString() + str, "chapter2");
	}
	settings.SetToolTip("chapter2", "Split \"Chapter.2\" equals split at the end of 1-16");

	// chap.3 : 0 - 12
	settings.Add("chapter3", true, "Chapter.3 (13 sub-chapters)");
	for (var index = 0; index < 12; ++index)
	{
		settings.Add("3-" + index.ToString(), true, "3-" + (index+1).ToString(), "chapter3");
	}
	settings.SetToolTip("chapter3", "Split \"Chapter.3\" equals split at the end of 1-13, and final split should manually");
}

init
{
	print("ModuleMemorySize : " + modules.First().ModuleMemorySize.ToString());
	if (modules.First().ModuleMemorySize == 23171072)
		version = "ver1.10.02.05.17";

	vars.mainChap = 0;
	vars.subChap = 0;
	vars.splitFlg = false;
}

// ------------------------------------------------------------ //
// 			Action
// ------------------------------------------------------------ //

update
{
	if (version == "" || !settings.StartEnabled)
		return false;
}

// Start when select chapter0-0 from the main menu or the chapter selection menu.
start
{
    if(current.mainChap == 0 && current.subChap == 0 && current.notMenuFlg == 1 && old.notMenuFlg ==0)
    {
		vars.mainChap = current.mainChap;
		vars.subChap = current.subChap;
		vars.splitFlg = false;
		print("-- start --");
		return true;
    }
}

// Reset when return to main menu from pouse menu.
reset
{
	if(current.notMenuFlg == 0 && current.isGameModeFlg == 0)
	{
		print("-- reset --");
		return true;
	}
} 

// Vars are initialized at auto-start of the timer.
// If the "start" toggle is unchecked, split won't work correctly.
split
{
	if(current.isGameModeFlg == 1 && current.subChap != old.subChap) 
	{
		print("game : " + current.mainChap + "-" + current.subChap);
		print("vars : " + vars.mainChap + "-" + vars.subChap);
		
		// change subChapter
		if (current.subChap > vars.subChap)
		{
			if (settings[vars.mainChap.ToString() + "-" + vars.subChap.ToString()])
				vars.splitFlg = true;
			if (vars.mainChap == 0 && vars.subChap == 0)
				vars.subChap+=2; // chap 0-1 not exist
			else
				vars.subChap++;
			print("subChap++");
		}
		
		// change mainChapter
		if (current.mainChap > vars.mainChap)
		{
			if (settings["chapter" + vars.mainChap.ToString()])
				vars.splitFlg = true;
			vars.mainChap++;
			vars.subChap = current.subChap;
			print("mainChap++");
		}
		print("vars : " + vars.mainChap + "-" + vars.subChap);
		
		// split or not
		if (vars.splitFlg)
		{
			vars.splitFlg = false;
			print("-- split --");
			return true;
		}
		print("-- split : false --");
	}
}

// ------------------------------------------------------------ //
// 			EOF
// ------------------------------------------------------------ //
