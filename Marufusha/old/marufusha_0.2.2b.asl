// ver0.2.2b

// ------------------------------------------------------------ //
// 			Initialization
// ------------------------------------------------------------ //

// 0.2.2の簡易化版
// ゲームのバージョンアップ対策として、レジストリを利用した機能のみに絞る
// チャレンジモード関連の機能も一時的に削除

state("Marufusha")
{ }

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
    });
    timer.OnStart += vars.ResetVars;
}

init
{
    // for init
    // for main mode
    vars.oldDay = 0;
    vars.currentDay = 0;

    // for reset
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
    vars.needSplit = false;
    vars.needReset = false;

    // for info
    int wpLimit = 0;
    byte[] gunNameByte = null;

    using(Microsoft.Win32.RegistryKey regKey = Microsoft.Win32.Registry.CurrentUser.OpenSubKey(@"Software\hinyari9\Marufusha"))
    {
        int salary = 0;
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

            // for info
            if (name.StartsWith("wpLimit_"))
            {
                try
                {
                    wpLimit = (int)regKey.GetValue(name);
                }
                catch (System.Exception)
                {
                    continue;
                }
            }
            if (name.StartsWith("equipedGunName_"))
            {
                try
                {
                    gunNameByte = (byte[])regKey.GetValue(name);
                }
                catch (System.Exception)
                {
                    continue;
                }
            }
        } // end foreach
        
        if (settings["main"])
        {
            // for main split

            // for reset
            if ((salary < vars.oldSalary) && (timer.CurrentPhase == TimerPhase.Running))
            {
                vars.needReset = true;
                return true;
            }
            vars.oldSalary = salary;

            // for split
            int tempDay = (stage - 1) * 40 + level;
            vars.oldDay = vars.currentDay;
            if (vars.currentDay < tempDay)
                vars.currentDay = tempDay;

            if ((vars.currentDay == vars.oldDay + 1) && vars.currentDay > 1)
            {
                for (int index = 1; index < 10; index++)
                {
                    if (vars.currentDay == (index * 10 + 1))
                    {
                        vars.needSplit = settings["day" + (index * 10)];
                    }
                }
                if (vars.currentDay== 99 + 1)
                {
                    vars.needSplit = settings["day99"];
                    return true;
                }

                vars.needSplit |= settings["mainEveryDay"];
            }
        } // end else

    } // end useing

    // for info day
    if (vars.tcss.Count > 0)
    {
        string mode = "Main";
        int today = vars.currentDay;
        if (settings["challenge"])
        {
            mode = "Challenge";
            today = vars.endlCurrentDay;
        }
        
        vars.tcss[0].Text1 = mode; // Text1は左寄せの文字
        vars.tcss[0].Text2 = "Day " + today.ToString(); // Text2は右寄せの文字
    }
    // for info wpLimit
    if (vars.tcss.Count > 1)
    {
        int limit = 0;
        byte[] wpNameByte = null;
        if (settings["challenge"])
        {
            limit = EndlWpLimit;
            wpNameByte = EndlGunNameByte;
        }
        else
        {
            limit = wpLimit;
            wpNameByte = gunNameByte;
        }

        string limitSs = limit > 0 ? limit.ToString() : "-" ;
        string wpNameSs = "-";
        if (wpNameByte != null)
            wpNameSs = System.Text.Encoding.UTF8.GetString(wpNameByte);

        vars.tcss[1].Text1 = wpNameSs; // Text1は左寄せの文字
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

shutdown
{
    timer.OnStart -= vars.ResetVars;
}

// ------------------------------------------------------------ //
// 			EOF
// ------------------------------------------------------------ //
