// ver0.1.1

// ------------------------------------------------------------ //
// 			Initialization
// ------------------------------------------------------------ //

// テスト用
// 動作確認ができている最新のバージョンは 0.1.0

state("Marufusha", "ver1.0.0.3")
{
    // memSize : 667648
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

    // challenge
	settings.Add("challenge", false, "Challenge mode");
    settings.Add("ch_x5", false, "Split at every x5 days (05, 15, 25, ...)", "challenge");
    settings.Add("ch_x0", true, "Split at every x0 days (10, 20, 30, ...)", "challenge");

    // init for start
    vars.ResetVars = (EventHandler)((s, e) => {
        vars.oldDay = 0;
        vars.currentDay = 0;

        vars.endlOldDay = 0;
        vars.endlCurrentDay = 0;
    });
    timer.OnStart += vars.ResetVars;
}

init
{
	// ver check
    var module = modules.First();
	print("ModuleMemorySize : " + module.ModuleMemorySize.ToString());
    print("FileVersion : " + module.FileVersionInfo.FileVersion);
    switch (module.ModuleMemorySize)
	{
		case 667648:
			version = "ver1.0.0.3";
            // 同じメモリサイズのため判別不可
            // だたし、レジストリの仕様は変わっていないと思われる
            // version = "ver1.0.0.2";
			break;
		default:
        	version = "ver unknown";
			break;
	}

    // for init
    vars.oldDay = 0;
    vars.currentDay = 0;

    vars.endlOldDay = 0;
    vars.endlCurrentDay = 0;

    vars.oldSalary = 0;

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

    // vars.needStart = false;
    vars.needSplit = false;
    vars.needReset = false;

    using(Microsoft.Win32.RegistryKey regKey = Microsoft.Win32.Registry.CurrentUser.OpenSubKey(@"Software\hinyari9\Marufusha"))
    {
        int salary = 0;
        int level = 1;
        int stage = 1;
        int ENDLlevel = 1;

        foreach (string name in regKey.GetValueNames())
        {
            // for reset
            if (name.StartsWith("basicSalary_"))
            {
                try
                {
                    salary = (int)regKey.GetValue(name);
                }
                catch (System.Exception)
                {
                    continue;
                }
            }
            // for split
            if (name.StartsWith("Level_"))
            {
                try
                {
                    level = (int)regKey.GetValue(name);
                }
                catch (System.Exception)
                {
                    continue;
                }
            }
            if (name.StartsWith("stage_"))
            {
                try
                {
                    stage = (int)regKey.GetValue(name);
                }
                catch (System.Exception)
                {
                    continue;
                }
            }
            if (name.StartsWith("EndLessModeNowLevel_"))
            {
                try
                {
                    ENDLlevel = (int)regKey.GetValue(name);
                }
                catch (System.Exception)
                {
                    continue;
                }
            }
        } // end foreach
        
        // for reset
        if (salary < vars.oldSalary)
        {
            vars.needReset = true;
        }
        vars.oldSalary = salary;

        // for split
        if (settings["challenge"])
        {
            // for challenge split
            vars.endlOldDay = vars.endlCurrentDay;
            if (vars.endlCurrentDay < ENDLlevel)
                vars.endlCurrentDay = ENDLlevel;

            if (vars.endlOldDay != vars.endlCurrentDay)
            {
                print("vars.endlCurrentDay : " + vars.endlCurrentDay.ToString());
                print("vars.endlOldDay \t: " + vars.endlOldDay.ToString());
            }
            if (vars.endlCurrentDay == vars.endlOldDay + 1)
            {
                int sw = vars.endlOldDay % 10;
                print("current == old + 1, sw : " + sw.ToString());
                switch (sw)
                {
                    case 0:
                        vars.needSplit = settings["ch_x0"];
                        print("-- split x0 " + settings["ch_x0"].ToString() + " --");
                        break;
                    case 5:
                        vars.needSplit = settings["ch_x5"];
                        print("-- split x5 " + settings["ch_x5"].ToString() + " --");
                        break;
                    default:
                        break;
                }
            }
        }
        else
        {
            // for main split
            int tempDay = (stage - 1) * 40 + level;
            vars.oldDay = vars.currentDay;
            if (vars.currentDay < tempDay)
                vars.currentDay = tempDay;

            if (vars.currentDay == vars.oldDay + 1)
            {
                for (int index = 1; index < 10; index++)
                {
                    if (vars.currentDay == (index * 10 + 1))
                        vars.needSplit = settings["day" + (index * 10)];
                }
                if (vars.currentDay== 99)
                    vars.needSplit = settings["day99"];
            }
        }

    } // end useing

    // for info
    if (vars.tcss.Count > 0)
    {
        int today = vars.currentDay;
        if (settings["challenge"])
            today = vars.endlCurrentDay;
        
        vars.tcss[0].Text1 = "Now"; // Text1は左寄せの文字
        vars.tcss[0].Text2 = "Day " + today.ToString(); // Text2は右寄せの文字
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

shutdown
{
    timer.OnStart -= vars.ResetVars;
}

// ------------------------------------------------------------ //
// 			EOF
// ------------------------------------------------------------ //
