// ver.100_1

// ------------------------------------------------------------ //
// 			Initialization
// ------------------------------------------------------------ //

state("Typoman", "ver1.10")
{
	// memSize : 23171072
	int mainChap: "Typoman.exe", 0x0135A9E0, 0xC, 0x388, 0x98, 0xD8, 0x40;
    int subChap: "Typoman.exe", 0x0135A9E0, 0xC, 0x10, 0x98, 0xD8, 0x44;
    bool notMenuFlg: "Typoman.exe", 0x0140DDE8, 0x8, 0x28, 0x20, 0x5F4;
    bool isGameModeFlg: "Typoman.exe", 0x0140DDE8, 0x8, 0x48, 0x30, 0x384;
    int bossPhase: "Typoman.exe", 0x0135A9E0, 0xC, 0x10, 0x98, 0x538, 0x0, 0x118;
}

startup
{
	// chap.0 : 0, 2 - 8
	settings.Add("chapter0", true, "Prologue (8 sub-chapters)");
	settings.Add("0-0", true, "0-1", "chapter0");
	for (var index = 2; index < 8; ++index)
	{
		settings.Add("0-" + index.ToString(), true,
					 "0-" + index.ToString(), "chapter0");
	}
	settings.SetToolTip("chapter0",
						"Split \"Prologue\" equals split at the end of 0-8");

	// chap.1 : 0 - 9
	settings.Add("chapter1", true, "Chapter.1 (10 sub-chapters)");
	for (var index = 0; index < 9; ++index)
	{
		settings.Add("1-" + index.ToString(), true,
					 "1-" + (index+1).ToString(), "chapter1");
	}
	settings.SetToolTip("chapter1",
						"Split \"Chapter.1\" equals split at the end of 1-10");

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
				// flg = false;
				break;
			default:
				break;
		}
		settings.Add("2-" + index.ToString(), flg,
					 "2-" + (index+1).ToString() + str, "chapter2");
	}
	settings.SetToolTip("chapter2",
						"Split \"Chapter.2\" equals split at the end of 1-16");

	// chap.3 : 0 - 12
	settings.Add("chapter3", true, "Chapter.3 (13 sub-chapters)");
	for (var index = 0; index < 12; ++index)
	{
		settings.Add("3-" + index.ToString(), true,
					 "3-" + (index+1).ToString(), "chapter3");
	}
	settings.SetToolTip("chapter3",
						"Split \"Chapter.3\" equals split at the end of 1-13" +
						", and final split should manually");
}

init
{
	print("ModuleMemorySize : " + modules.First().ModuleMemorySize.ToString());
	switch (modules.First().ModuleMemorySize)
	{
		case 23171072:
			version = "ver1.10";
			break;
		default:
			version = "";
			break;
	}

	vars.mainChap = 0;
	vars.subChap = 0;
	vars.splitFlg = false;
	vars.inPhase4Time = TimeSpan.Zero;
	vars.split_3_13_flg = false;
}

// ------------------------------------------------------------ //
// 			Action
// ------------------------------------------------------------ //

update
{
	if (version == "")
		return false;
	
	// Move from menu screen to game screen
	if(current.notMenuFlg && current.isGameModeFlg && !old.isGameModeFlg)
	{
		vars.mainChap = current.mainChap;
		vars.subChap = current.subChap;
		vars.inPhase4Time = TimeSpan.Zero;
		vars.split_3_13_flg = false;
		print("-- ini in update --");
		print("game : " + current.mainChap + "-" + current.subChap);
		print("vars : " + vars.mainChap + "-" + vars.subChap);
	}
	vars.splitFlg = false;
}

// Start when select chapter0-0 from the main menu or the chapter selection menu

start
{
    if(current.mainChap == 0 && current.subChap == 0
       && current.notMenuFlg && !old.notMenuFlg)
    {
		print("-- start --");
		vars.mainChap = 0;
		vars.subChap = 0;
		vars.inPhase4Time = TimeSpan.Zero;
		vars.split_3_13_flg = false;
		return true;
    }
}

// Reset when return to main menu from pouse menu

reset
{
	return !current.notMenuFlg && !current.isGameModeFlg;
} 

// Split when changes main-chapter or sub-chapter

split
{
	if(current.notMenuFlg)
	{
		if(current.subChap != old.subChap || current.mainChap != old.mainChap)
		{
			print("game : " + current.mainChap + "-" + current.subChap);
			print("vars : " + vars.mainChap + "-" + vars.subChap);
		}
		
		if(current.bossPhase > 0 && current.bossPhase <= 4 && current.bossPhase != old.bossPhase)
		{
			print("boss phase : " + current.bossPhase);
		}
	}

	// when change subChapter
	if(current.isGameModeFlg && current.subChap != old.subChap) 
	{
		if(current.subChap > vars.subChap)
		{
			if(settings[vars.mainChap.ToString() + "-" + vars.subChap.ToString()])
				vars.splitFlg = true;
			
			vars.mainChap = current.mainChap;
			vars.subChap = current.subChap;
			print("-- subChap --");
			print("vars : " + vars.mainChap + "-" + vars.subChap);
		}
	}

	// when change mainChapter
	if(current.isGameModeFlg && current.mainChap != old.mainChap) 
	{
		if(current.mainChap > vars.mainChap)
		{
			if(settings["chapter" + vars.mainChap.ToString()])
				vars.splitFlg = true;
			vars.mainChap = current.mainChap;
			vars.subChap = 0;
			print("-- mainChap --");
			print("vars : " + vars.mainChap + "-" + vars.subChap);
		}
	}
	
	// Boss
	if(current.isGameModeFlg && current.mainChap == 3 &&
	   current.subChap == 12 && current.bossPhase == 4) 
	{
		if(old.bossPhase == 3)
		{
			vars.inPhase4Time = timer.CurrentTime.RealTime ?? TimeSpan.Zero;
			print("-- beat the Boss --");
		}
		
		if(vars.inPhase4Time.Milliseconds > 0 && !vars.split_3_13_flg)
		{
			TimeSpan timeCnt = (timer.CurrentTime.RealTime ?? TimeSpan.Zero)
							   - vars.inPhase4Time;
			print("timeCnt : " + timeCnt.Milliseconds);
			if(timeCnt.Milliseconds > 500 &&
			   settings["chapter" + vars.mainChap.ToString()])
			{
				vars.split_3_13_flg = true;
				vars.splitFlg = true;
			}
		}
	}

	// split or not
	if(vars.splitFlg)
	{
		print("-- split --");
	}
	return vars.splitFlg;
}

// ------------------------------------------------------------ //
// 			EOF
// ------------------------------------------------------------ //
