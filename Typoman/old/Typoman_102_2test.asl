// This is semi-autosplitter, you have to manually stop
// This autosplitter can start, split and reset timer

// ver.102_2

// ------------------------------------------------------------ //
// 			Initialization
// ------------------------------------------------------------ //

state("Typoman", "ver1.10")
{
	// memSize : 23171072
	int mainChap: "Typoman.exe", 0x0135A9E0, 0xC, 0x10, 0x98, 0xD8, 0x40;
    int subChap: "Typoman.exe", 0x0135A9E0, 0xC, 0x10, 0x98, 0xD8, 0x44;
    bool menuActiveFlg: "Typoman.exe", 0x0140DDE8, 0x8, 0x8, 0x10, 0x20, 0x29;
    bool isGameModeFlg: "Typoman.exe", 0x0140DDE8, 0x8, 0x10, 0x20, 0x384;
}

startup
{
	// note
	settings.Add("note", true, "note : You have to manually stop the timer when you beat the Boss");

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

	// for info
	vars.tcss = new List<System.Windows.Forms.UserControl>();
	foreach (LiveSplit.UI.Components.IComponent component in timer.Layout.Components) {
		if (component.GetType().Name == "TextComponent")
		{
			vars.tc = component;
			vars.tcss.Add(vars.tc.Settings);
			print("[ASL] Found text component at " + component);
		}
	}
	print("[ASL] *Found " + vars.tcss.Count.ToString() + " text component(s)*");

}

init
{
	vars.gameVer = "unknown";
	print("ModuleMemorySize : " + modules.First().ModuleMemorySize.ToString());
	switch (modules.First().ModuleMemorySize)
	{
		case 23171072:
			version = "ver1.10";
			vars.gameVer = version;
			break;
		default:
			version = "";
			break;
	}

	vars.mainChap = 0;
	vars.subChap = 0;
	
	vars.startFlg = false;
	vars.resetFlg = false;
	vars.splitFlg = false;
	vars.infoRefreshFlg = false;
}

// ------------------------------------------------------------ //
// 			Action
// ------------------------------------------------------------ //

update
{
	if (version == "")
		return false;
	
	string infoMsg = "info";
	string subMsg1 = "sub1";
	string subMsg2 = "sub2";
	
	vars.startFlg = false;
	vars.resetFlg = false;
	vars.splitFlg = false;
	vars.infoRefreshFlg = false;

	// Move from menu screen to game screen
	if(!current.menuActiveFlg && current.isGameModeFlg && !old.isGameModeFlg)
	{
		vars.mainChap = current.mainChap;
		vars.subChap = current.subChap;
		
		infoMsg = "-- ini in update --";
		subMsg1 = "game : " + current.mainChap + "-" + current.subChap;
		subMsg2 = "vars : " + vars.mainChap + "-" + vars.subChap;
		vars.infoRefreshFlg = true;
	}
	
	// start
    if(current.mainChap == 0 && current.subChap == 0
       && !current.menuActiveFlg && old.menuActiveFlg)
    {
		vars.mainChap = 0;
		vars.subChap = 0;
		vars.startFlg = true;
		
		infoMsg = "-- start --";
		vars.infoRefreshFlg = true;
    }
    
    // reset
	if(current.mainChap == 0 && current.subChap == 0
	   && current.menuActiveFlg && !current.isGameModeFlg)
	{
		vars.resetFlg = true;
		
		infoMsg = "-- reset --";
		vars.infoRefreshFlg = true;
	}
	
	// split
	if(!current.menuActiveFlg)
	{
		if(current.subChap != old.subChap || current.mainChap != old.mainChap)
		{
			infoMsg = "-- change subChap --";
			subMsg1 = "game : " + current.mainChap + "-" + current.subChap;
			subMsg2 = "vars : " + vars.mainChap + "-" + vars.subChap;
			vars.infoRefreshFlg = true;
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
			
			infoMsg = "-- split subChap --";
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
			
			infoMsg = "-- split mainChap --";
		}
	}
	
	// show info
	if(vars.infoRefreshFlg)
	{
		if (vars.tcss.Count > 1)
		{
			vars.tcss[0].Text1 = infoMsg;
			vars.tcss[0].Text2 = vars.gameVer;
			vars.tcss[1].Text1 = subMsg1;
			vars.tcss[1].Text2 = subMsg2;
		}
		else
		{
			print(infoMsg + " | " + vars.gameVer);
			print(subMsg1 + " | " + subMsg2);
		}
	}
}

// Start when select chapter0-0 from the main menu or the chapter selection menu

start{return vars.startFlg;}

// Reset when return to main menu from pouse menu

reset{return vars.resetFlg;}

// Split when changes main-chapter or sub-chapter

split{return vars.splitFlg;}

// ------------------------------------------------------------ //
// 			EOF
// ------------------------------------------------------------ //
