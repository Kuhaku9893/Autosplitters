// ver0.0.6

// ------------------------------------------------------------ //
// 			Initialization
// ------------------------------------------------------------ //

// 40dayの不具合対応用
// ver0.0.7は暫定公開用、不具合修正はver0.0.6にて行う
// 現在の日数で表示するのはvars.currentDayの方が良いのでは？
// デバッグ用ならtempDayでも良いと思うが

state("Marufusha", "ver1.0.0.2")
{
    // memSize : 667648
}

startup
{
	// settings
	for (int index = 1; index < 10; ++index)
	{
		settings.Add("day" + (index * 10).ToString(), true, "Day " + (index * 10).ToString());
	}
    settings.Add("day99", false, "Day 99");
    settings.Add("day100", true, "Day 100 (Timer Stop)");

    // init for start
    vars.ResetVars = (EventHandler)((s, e) => {
        vars.oldDay = 0;
        vars.currentDay = 0;
        print("-- start --");
    });
    timer.OnStart += vars.ResetVars;
}

init
{
	// ver check
    var module = modules.First();
	print("ModuleMemorySize : " + module.ModuleMemorySize.ToString());
    switch (module.ModuleMemorySize)
	{
		case 667648:
			version = "ver1.0.0.2";
			break;
		default:
        	version = "ver unknown";
			break;
	}

    // for init
    vars.oldDay = 0;
    vars.currentDay = 0;

    vars.oldSalary = 0;
    vars.oldResultSalary = 0;

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

    int today = 0;

    using(Microsoft.Win32.RegistryKey regKey = Microsoft.Win32.Registry.CurrentUser.OpenSubKey(@"Software\hinyari9\Marufusha"))
    {
        int salary = 0;
        int resultSalary = 0;
        int level = 1;
        int stage = 1;

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
            // for stop
            if (name.StartsWith("resultSalary_"))
            {
                try
                {
                    resultSalary = (int)regKey.GetValue(name);
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
        } // end foreach
        
        // for reset
        if (salary < vars.oldSalary)
        {
            vars.needReset = true;
            print("-- reset --");
        }
        vars.oldSalary = salary;

        // for stop
        if (resultSalary > 0 && resultSalary != vars.oldResultSalary)
        {
            vars.needSplit = settings["day100"];
            print("resultSalary \t: " + resultSalary.ToString());
            print("oldResultSalary : " + vars.oldResultSalary.ToString());
            print("-- split day100 --");
        }
        vars.oldResultSalary = resultSalary;

        // for split
        int day = 0;
        int oldday = 0;

        int tempDay = (stage - 1) * 40 + level;
        if (vars.currentDay != tempDay)
        {
            print("currentDay : " + vars.currentDay.ToString());
            print("tempDay \t\t: " + tempDay.ToString());
        }
        if (vars.currentDay < tempDay)
        {
            vars.oldDay = vars.currentDay;
            vars.currentDay = tempDay;

            print("day : " + tempDay.ToString());
        }
        else
        {
            vars.oldDay = vars.currentDay;
        }
        today = tempDay;

        for (int index = 1; index < 10; index++)
        {
            if (vars.currentDay == (index * 10 + 1) && vars.oldDay == (index * 10))
            {
                vars.needSplit = settings["day" + (index * 10)];
                print("-- split day" + (index * 10).ToString() + "--");
            }
        }
        if (vars.currentDay == 100 && vars.oldDay == 99)
        {
            vars.needSplit = settings["day99"];
            print("-- split day99 --");
        }

    } // end useing

    // for info
    if (vars.tcss.Count > 0)
    {
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
