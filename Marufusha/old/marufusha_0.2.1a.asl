// ver0.2.2

// ------------------------------------------------------------ //
// 			Initialization
// ------------------------------------------------------------ //

// ラスボス判定検証用
// 動作確認済みの最新verは0.2.1

// ラスボス戦でボス判定出現前に電熱砲を使用すると検知できない

state("Marufusha", "ver1.0.0.6")
{
    // memSize : 667648
    int eventId : "mono-2.0-bdwgc.dll", 0x00493DE0, 0xa0, 0x498, 0x78, 0x58, 0x64;
    float bossHp : "UnityPlayer.dll", 0x01746D40, 0x3b0, 0x270, 0x70, 0xc30, 0x118, 0x18, 0x78;
    float bossOriginalHp : "UnityPlayer.dll", 0x01746D40, 0x3b0, 0x270, 0x70, 0xc30, 0x118, 0x18, 0x7c;
    bool isDetected : "UnityPlayer.dll", 0x01746D40, 0x3b0, 0x270, 0x70, 0xc30, 0x118, 0x18, 0x80;
    bool isDead : "UnityPlayer.dll", 0x01746D40, 0x3b0, 0x270, 0x70, 0xc30, 0x118, 0x18, 0x81;
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

    // challenge
	settings.Add("challenge", false, "Challenge mode");
    settings.Add("ch_x5", false, "Split at every x5 days (05, 15, 25, ...)", "challenge");
    settings.Add("ch_x0", true, "Split at every x0 days (10, 20, 30, ...)", "challenge");
    settings.Add("chEveryDay", false, "Split at every day", "challenge");

    // init for start
    vars.ResetVars = (EventHandler)((s, e) => {
        vars.oldDay = 0;
        vars.currentDay = 0;
        vars.stopTime = TimeSpan.Zero;

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
    switch (module.ModuleMemorySize)
	{
		case 667648:
			version = "ver1.0.0.6";
            // 1.0.0.2 - 同じメモリサイズのため判別不可
            // だたし、レジストリの仕様は変わっていないと思われる
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

    // for challenge mode
    vars.endlOldDay = 0;
    vars.endlCurrentDay = 0;

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

    // for info
    int wpLimit = 0;
    byte[] gunNameByte = null;
    int EndlWpLimit = 0;
    byte[] EndlGunNameByte = null;

    if (current.eventId == 1 && old.eventId == 0 && timer.CurrentPhase == TimerPhase.NotRunning)
    {
        vars.needStart = true;
    }

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
            if (name.StartsWith("ENDLwpLimit_"))
            {
                try
                {
                    EndlWpLimit = (int)regKey.GetValue(name);
                }
                catch (System.Exception)
                {
                    continue;
                }
            }
            if (name.StartsWith("ENDLequipedGunName_"))
            {
                try
                {
                    EndlGunNameByte = (byte[])regKey.GetValue(name);
                }
                catch (System.Exception)
                {
                    continue;
                }
            }
        } // end foreach
        
        if (settings["challenge"])
        {
            // for challenge split

            vars.endlOldDay = vars.endlCurrentDay;
            if (vars.endlCurrentDay < ENDLlevel)
                vars.endlCurrentDay = ENDLlevel;

            // for reset
            if ((ENDLlevel == 1) && (vars.endlOldDay > 1) && (timer.CurrentPhase == TimerPhase.Running))
            {
                vars.needReset = true;
                return true;
            }
            
            // for split
            if ((vars.endlCurrentDay == vars.endlOldDay + 1) && vars.endlCurrentDay > 1)
            {
                int sw = vars.endlOldDay % 10;
                switch (sw)
                {
                    case 0:
                        vars.needSplit = settings["ch_x0"] || settings["chEveryDay"];
                        break;
                    case 5:
                        vars.needSplit = settings["ch_x5"] || settings["chEveryDay"];
                        break;
                    default:
                        vars.needSplit = settings["chEveryDay"];
                        break;
                }
            }
        }
        else
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

            // final boss
            if (vars.currentDay == 100)
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
                else if ((current.bossHp <= 0) && (old.bossHp > 0) && (old.bossOriginalHp > 0))
                {
                    vars.stopTime = (timer.CurrentTime.RealTime != null) ? timer.CurrentTime.RealTime + TimeSpan.FromMilliseconds(1050) : TimeSpan.Zero;
                }
            }
            if (vars.currentDay >= 100)
            {
                if (current.bossHp != old.bossHp)
                    print("bossHp : " + current.bossHp.ToString());
                if (current.bossOriginalHp != old.bossOriginalHp)
                    print("originalHP : " + current.bossOriginalHp.ToString());
                if (current.isDetected != old.isDetected)
                    print("isDetected : " + current.isDetected.ToString());
                if (current.isDead != old.isDead)
                    print("isDead : " + current.isDead.ToString());
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
