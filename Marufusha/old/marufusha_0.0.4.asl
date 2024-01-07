// ver0.0.4

// ------------------------------------------------------------ //
// 			Initialization
// ------------------------------------------------------------ //

// 自動スタートを削除
// タイトルが面で init が実行されると必ずタイマースタートしてしまうため

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

    // init for start
    vars.ResetVars = (EventHandler)((s, e) => {
        vars.oldDay = 0;
        vars.currentDay = 0;
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
        int level = 0;
        int stage = 0;

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
                // print("salary : " + salary.ToString());
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
                // print("resultSalary : " + resultSalary.ToString());
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
                // print("level : " + level.ToString());
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
                // print("stage : " + stage.ToString());
            }
        } // end foreach
        
        // for reset
        if (salary < vars.oldSalary)
        {
            vars.needReset = true;
        }

        // for stop
        if (resultSalary > 0 && resultSalary != vars.oldResultSalary)
        {
            vars.needSplit = true;
        }
        vars.oldResultSalary = resultSalary;

        // for split
        int day = 0;
        int oldday = 0;

        int tempDay = (stage - 1) * 40 + level;
        if (vars.currentDay < tempDay)
        {
            vars.oldDay = vars.currentDay;
            vars.currentDay = tempDay;

            // print("day : " + tempDay.ToString());
        }
        else
        {
            vars.oldDay = vars.currentDay;
        }
        today = tempDay;

        for (int index = 1; index < 10; index++)
        {
            if (vars.currentDay == (index * 10 + 1) && vars.oldDay == (index * 10))
                vars.needSplit = settings["day" + (index * 10)];
        }
        if (vars.currentDay == 100 && vars.oldDay == 99)
            vars.needSplit = settings["day99"];

    } // end useing

    // for info
    if (vars.tcss.Count > 0)
    {
        vars.tcss[0].Text1 = "Now"; // Text1は左寄せの文字
        vars.tcss[0].Text2 = "Days " + today.ToString(); // Text2は右寄せの文字
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
