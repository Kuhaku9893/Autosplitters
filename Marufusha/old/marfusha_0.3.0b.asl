// ver0.3.0b

// ------------------------------------------------------------ //
// 			Initialization
// ------------------------------------------------------------ //

// 自動スタートと自動ストップのみ

state("Marfusha", "ver1.1.0")
{
    // memSize : 675840
    // filever : 2021.1.16.16457987
    
    // for start
    int eventId : "mono-2.0-bdwgc.dll", 0x00497DE0, 0xb8, 0x188, 0x20, 0x30, 0xd8, 0x20, 0x70;

    // for stop
    bool isAlreadyDead : "UnityPlayer.dll", 0x01946248, 0xf88, 0x428, 0x28, 0x128, 0x60;
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
        vars.oldDay = 0;
        vars.currentDay = 0;
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
			version = "ver1.1.0";
			break;
		default:
        	version = "ver unknown";
			break;
	}

    // for init
    // for main mode
    vars.oldDay = 0;
    vars.currentDay = 0;

    // for reset
    vars.oldSalary = 0;

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
    if (current.eventId == 1 && old.eventId == 0 && timer.CurrentPhase == TimerPhase.NotRunning)
    {
        vars.needStart = true;
    }

    using(Microsoft.Win32.RegistryKey regKey = Microsoft.Win32.Registry.CurrentUser.OpenSubKey(@"Software\hinyari9\Marfusha"))
    {
        int salary = 0;
        int level = 1;
        int stage = 1;
        int ENDLlevel = 1;

        if (settings["main"])
        {
            // for main split

            // final boss
            if (vars.currentDay >= 0)
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
                else if (current.isAlreadyDead && !old.isAlreadyDead)
                {
                    vars.stopTime = (timer.CurrentTime.RealTime != null) ? timer.CurrentTime.RealTime + TimeSpan.FromMilliseconds(1050) : TimeSpan.Zero;
                }
            }
        } // end else

    } // end useing

    // for info day
    if (vars.tcss.Count > 0)
    {
        string mode = "Main";
        vars.tcss[0].Text1 = mode; // Text1は左寄せの文字
        vars.tcss[0].Text2 = "not work"; // "Day " + today.ToString(); // Text2は右寄せの文字
    }
    // for info wpLimit
    if (vars.tcss.Count > 1)
    {
        string wpNameSs = "-";
        vars.tcss[1].Text1 = wpNameSs; // Text1は左寄せの文字
        vars.tcss[1].Text2 = "not work"; // "Limit " + limitSs; // Text2は右寄せの文字
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

shutdown
{
    timer.OnStart -= vars.ResetVars;
}

// ------------------------------------------------------------ //
// 			EOF
// ------------------------------------------------------------ //
