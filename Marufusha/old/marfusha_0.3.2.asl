// ver0.3.2

// ------------------------------------------------------------ //
// 			Initialization
// ------------------------------------------------------------ //

// eventIdのアドレスを見直し
// 戦闘中のみGameTimeを進める機能を追加

state("Marfusha", "ver1.1.0")
{
    // memSize : 675840
    // filever : 2021.1.16.16457987
    
    // for start
    // KaiwaManager
    int eventId : "UnityPlayer.dll", 0x01A06EB0, 0x10, 0x0, 0x38, 0x58, 0x28, 0x20, 0x70;

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

    // challenge
    /*
	settings.Add("challenge", false, "Challenge mode");
    settings.Add("ch_x5", false, "Split at every x5 days (05, 15, 25, ...)", "challenge");
    settings.Add("ch_x0", true, "Split at every x0 days (10, 20, 30, ...)", "challenge");
    settings.Add("chEveryDay", false, "Split at every day", "challenge");
    */

    // init for start
    vars.ResetVars = (EventHandler)((s, e) => {
        vars.stopTime = TimeSpan.Zero;

        // vars.endlOldDay = 0;
        // vars.endlCurrentDay = 0;
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
    /* else
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
    } // end else
    */

    // for info day
    if (vars.tcss.Count > 0)
    {
        string mode = "Main";
        int today = current.day;
        /*
        if (settings["challenge"])
        {
            mode = "Challenge";
            today = vars.endlCurrentDay;
        }
        */
        
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
        /*
        else
        {
            limit = EndlWpLimit;
            // wpName = EndlGunNameByte;
        }
        */

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
