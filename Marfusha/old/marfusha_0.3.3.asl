// ver0.3.3

// ------------------------------------------------------------ //
// 			Initialization
// ------------------------------------------------------------ //

// ver1.2.0に対応
// ver1.1.0は判別できないため非対応とする

state("Marfusha", "ver1.2.0")
{
    // memSize : 675840
    // filever : 2021.1.16.16457987
    
    // for start
    // KaiwaManager
    int eventId : "mono-2.0-bdwgc.dll", 0x00497DE0, 0xb8, 0x188, 0x20, 0x30, 0xd8, 0x20, 0x70;

    // for reset
    // StoryModeData
    int basicSalary : "mono-2.0-bdwgc.dll", 0x00495A68, 0xc08, 0x78, 0x60, 0x50;

    // for split
    // StoryModeData
    int day : "mono-2.0-bdwgc.dll", 0x00495A68, 0xc08, 0x78, 0x60, 0x30;

    // for stop
    // Stage3BossBody2
    // monoのアドレスだと死亡判定フラグが使えるが、そもそも不安定
    // UnityPlayerのアドレスだとボス撃破と同時に値の取得ができなくなる
    // bool isAlreadyDead : "UnityPlayer.dll", 0x019A4EE8, 0x0, 0x0, 0x30, 0x30, 0x68, 0x28, 0x60;
    int bossHp : "UnityPlayer.dll", 0x019A4EE8, 0x0, 0x0, 0x30, 0x30, 0x68, 0x28, 0x58, 0x10;

    // for info
    // StoryModeData
    int weaponLimit : "mono-2.0-bdwgc.dll", 0x00495A68, 0xc08, 0x78, 0x60, 0x44;
    string10 weaponName : "mono-2.0-bdwgc.dll", 0x00495A68, 0xc08, 0x78, 0x60, 0x18, 0x14;

    // for gametime
    int player : "UnityPlayer.dll", 0x0193FDC0, 0x88, 0x318, 0x248, 0x60, 0x0;
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

    // init for start
    vars.ResetVars = (EventHandler)((s, e) => {
        vars.stopTime = TimeSpan.Zero;
    });
    timer.OnStart += vars.ResetVars;
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

    // for stop
    vars.stopTime = TimeSpan.Zero;

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
	if (version == "ver unknown")
		return false;

    vars.needStart = false;
    vars.needSplit = false;
    vars.needReset = false;

    // for start
    if (current.eventId == 1 && old.eventId == 0)
    {
        vars.needStart = true;
    }

    if (settings["main"])
    {
        // for main split

        // for reset
        if (current.basicSalary < old.basicSalary)
        {
            vars.needReset = true;
            return true;
        }

        // for split
        if ((current.day == old.day + 1) && current.day > 1)
        {
            for (int index = 1; index < 10; index++)
            {
                if (current.day == (index * 10 + 1))
                {
                    vars.needSplit = settings["day" + (index * 10)];
                }
            }
            if (current.day== 99 + 1)
            {
                vars.needSplit = settings["day99"];
                return true;
            }

            vars.needSplit |= settings["mainEveryDay"];
        }

        // final boss
        if (current.day == 100)
        {
            if (vars.stopTime > TimeSpan.Zero)
            {
                TimeSpan ts = timer.CurrentTime.RealTime ?? TimeSpan.Zero;
                if (ts >= vars.stopTime)
                {
                    vars.needSplit = settings["day100"];
                    vars.stopTime = TimeSpan.Zero;
                }
            }
            // else if (current.isAlreadyDead && !old.isAlreadyDead)
            else if ((current.bossHp <= 0) && (old.bossHp > 0))
            {
                vars.stopTime = (timer.CurrentTime.RealTime != null) ? timer.CurrentTime.RealTime + TimeSpan.FromMilliseconds(1050) : TimeSpan.Zero;
            }
        }
    }

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

isLoading
{
    if (current.player != 0)
        return false;
    return true;
}

shutdown
{
    timer.OnStart -= vars.ResetVars;
}

// ------------------------------------------------------------ //
// 			EOF
// ------------------------------------------------------------ //
