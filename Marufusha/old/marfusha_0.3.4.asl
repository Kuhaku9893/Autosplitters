// ver0.3.4

// ------------------------------------------------------------ //
// 			Initialization
// ------------------------------------------------------------ //

// StoryModeDataのアドレス見直し
// KaiwaManagerのアドレス見直し
// day1で「初日からやり直す」を選択した時にもreset
// タイマーストップの判定に使う値を変更
// 一部、スクリプトの構文を見直し
// GameTimeを利用した特殊機能廃止

state("Marfusha", "ver1.2.0")
{
    // memSize : 675840
    // filever : 2021.1.16.16457987
    
    // for start
    // KaiwaManager
    int eventId : "mono-2.0-bdwgc.dll", 0x00497e28, 0x68, 0xe10, 0xd0, 0xd0, 0x70;

    // for reset
    // StoryModeData
    int basicSalary : "mono-2.0-bdwgc.dll", 0x0049d208, 0x190, 0x88, 0x78, 0x60, 0x50;

    // for split
    // StoryModeData
    int day : "mono-2.0-bdwgc.dll", 0x0049d208, 0x190, 0x88, 0x78, 0x60, 0x30;

    // for stop
    // EndingEventManager
    // ボス撃破直後に実体化、その後、ED分岐
    int endengFlg : "mono-2.0-bdwgc.dll", 0x004A7428, 0x210, 0x790, 0x9c;

    // for info
    // StoryModeData
    int weaponLimit : "mono-2.0-bdwgc.dll", 0x0049d208, 0x190, 0x88, 0x78, 0x60, 0x44;
    string10 weaponName : "mono-2.0-bdwgc.dll", 0x0049d208, 0x190, 0x88, 0x78, 0x60, 0x18, 0x14;
}

startup
{
	// settings

    // main
	settings.Add("main", true, "Main mode");
    for (int index = 1; index < 10; ++index)
	{
		settings.Add("day" + (index * 10).ToString(), true, "Day " + (index * 10).ToString(), "main");
	}
    settings.Add("day99", false, "Day 99", "main");
    settings.Add("day100", true, "Day 100 (Timer Stop)", "main");
    settings.Add("mainEveryDay", false, "Split at every day", "main");
}

init
{
	// ver check
    var module = modules.First();
	print("ModuleMemorySize : " + module.ModuleMemorySize.ToString());
    print("FileVersion \t: " + module.FileVersionInfo.FileVersion);
    print("ProcessName \t: " + game.ProcessName.ToLower());
    switch (module.ModuleMemorySize)
	{
		case 675840:
			version = "ver1.2.0";
			break;
		default:
        	version = "ver unknown";
			break;
	}

    // for init

    // for info
    vars.tcss = new List<System.Windows.Forms.UserControl>();
    foreach (LiveSplit.UI.Components.IComponent component in timer.Layout.Components)
    {
      if (component.GetType().Name == "TextComponent")
      {
        vars.tc = component;
        vars.tcss.Add(vars.tc.Settings);
        print("[ASL] Found text component at " + component); // 確認用メッセージ
      }
    }
    // 確認用メッセージ
    print("[ASL] *Found " + vars.tcss.Count.ToString() + " text component(s)*");
}

// ------------------------------------------------------------ //7
// 			Action
// ------------------------------------------------------------ //

update
{
    // for info day
    if (vars.tcss.Count > 0)
    {
        string mode = "Main";
        int today = current.day;
        
        vars.tcss[0].Text1 = mode; // Text1は左寄せの文字
        vars.tcss[0].Text2 = "Day " + today.ToString(); // Text2は右寄せの文字
    }
    // for info wpLimit
    if (vars.tcss.Count > 1)
    {
        int limit = 0;
        string wpName = "-";
        if (settings["main"])
        {
            limit = current.weaponLimit;
            wpName = current.weaponName;
        }

        string limitSs = limit > 0 ? limit.ToString() : "-" ;
        vars.tcss[1].Text1 = wpName; // Text1は左寄せの文字
        vars.tcss[1].Text2 = "Limit " + limitSs; // Text2は右寄せの文字
    }

	if (version == "ver unknown")
		return false;

    vars.needStart = false;
    vars.needSplit = false;
    vars.needReset = false;

    // for start
    if (current.eventId == 1 && old.eventId == 0)
    {
        vars.needStart = true;
        return true;
    }

    if (settings["main"])
    {
        // for main split

        // for reset
        if (current.basicSalary < old.basicSalary)
        {
            vars.needReset = true;
            print("-- reset --");
            return true;
        }
        if ((current.day == 1) && (current.weaponLimit == 0) && (old.weaponLimit == -1))
        {
            vars.needReset = true;
            print("-- reset day1 --");
            return true;
        }

        // for split
        if ((current.day > old.day) && current.day > 1)
        {
            for (int index = 1; index < 10; index++)
            {
                if (current.day == (index * 10 + 1))
                {
                    vars.needSplit = settings["day" + (index * 10)];
                }
            }
            if (current.day == 99 + 1)
            {
                vars.needSplit = settings["day99"];
            }

            vars.needSplit |= settings["mainEveryDay"];
            return true;
        }

        // final boss
        if ((current.day == 100) && (current.endengFlg == 1) && (old.endengFlg == 0))
        {
            vars.needSplit = settings["day100"];
        }
    }

}

reset
{
    return vars.needReset;
}
split
{
    return vars.needSplit;
}
start
{
    return vars.needStart;
}

// ------------------------------------------------------------ //
// 			EOF
// ------------------------------------------------------------ //
