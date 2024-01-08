// ver1.0.0

// ------------------------------------------------------------ //
//             Initialization
// ------------------------------------------------------------ //

state("Marfusha", "ver1.2.1")
{
    // memSize : 675840
    // filever : 2021.1.16.16457987
    
    // for start
    // KaiwaManager
    int eventId     : "mono-2.0-bdwgc.dll", 0x00497e28, 0x68, 0xe10, 0xd0, 0xd0, 0x70;

    // for reset
    // StoryModeData
    int basicSalary : "mono-2.0-bdwgc.dll", 0x00495A90, 0xe98, 0x20, 0x28, 0x208, 0x1f8, 0x60, 0x50;

    // for split
    // StoryModeData, EndlessModeData
    int day         : "mono-2.0-bdwgc.dll", 0x00495A90, 0xe98, 0x20, 0x28, 0x208, 0x1f8, 0x60, 0x30;
    int endlDay     : "mono-2.0-bdwgc.dll", 0x004A7490, 0x210, 0xaf8, 0x30;

    // for stop
    // EndingEventManager
    // ボス撃破直後に実体化、その後、ED分岐
    int endengFlg   : "mono-2.0-bdwgc.dll", 0x004A7428, 0x210, 0x790, 0x9c;

    // for info
    // StoryModeData, EndlessModeData
    int coin                        : "mono-2.0-bdwgc.dll", 0x00495A90, 0xe98, 0x20, 0x28, 0x208, 0x1f8, 0x60, 0x34;
    string10    weaponName          : "mono-2.0-bdwgc.dll", 0x00495A90, 0xe98, 0x20, 0x28, 0x208, 0x1f8, 0x60, 0x18, 0x14;
    int         weaponLimit         : "mono-2.0-bdwgc.dll", 0x00495A90, 0xe98, 0x20, 0x28, 0x208, 0x1f8, 0x60, 0x44;
    string10    helperName          : "mono-2.0-bdwgc.dll", 0x00495A90, 0xe98, 0x20, 0x28, 0x208, 0x1f8, 0x60, 0x10, 0x14;
    int         helperLevel         : "mono-2.0-bdwgc.dll", 0x00495A90, 0xe98, 0x20, 0x28, 0x208, 0x1f8, 0x60, 0x40;
    int         playerDamage        : "mono-2.0-bdwgc.dll", 0x00495A90, 0xe98, 0x20, 0x28, 0x208, 0x1f8, 0x60, 0x20, 0x10;
    int         playerFireRate      : "mono-2.0-bdwgc.dll", 0x00495A90, 0xe98, 0x20, 0x28, 0x208, 0x1f8, 0x60, 0x20, 0x14;
    int         endlCoin            : "mono-2.0-bdwgc.dll", 0x004A7490, 0x210, 0xaf8, 0x34;
    string10    endlWeaponName      : "mono-2.0-bdwgc.dll", 0x004A7490, 0x210, 0xaf8, 0x18, 0x14;
    int         endlWeaponLimit     : "mono-2.0-bdwgc.dll", 0x004A7490, 0x210, 0xaf8, 0x44;
    string10    endlHelperName      : "mono-2.0-bdwgc.dll", 0x004A7490, 0x210, 0xaf8, 0x10, 0x14;
    int         endlHelperLevel     : "mono-2.0-bdwgc.dll", 0x004A7490, 0x210, 0xaf8, 0x40;
    int         endlPlayerDamage    : "mono-2.0-bdwgc.dll", 0x004A7490, 0x210, 0xaf8, 0x20, 0x10;
    int         endlPlayerFireRate  : "mono-2.0-bdwgc.dll", 0x004A7490, 0x210, 0xaf8, 0x20, 0x14;
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
            version = "ver1.2.1";
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
//             Action
// ------------------------------------------------------------ //

update
{
    // for info day
    if (vars.tcss.Count > 0)
    {
        string  mode  = "Main";
        int     today = current.day;
        int     coin  = current.coin;
        if (settings["challenge"])
        {
            mode  = "Challenge";
            today = current.endlDay;
            coin  = current.endlCoin;
        }

        vars.tcss[0].Text1 = mode + " " + today.ToString(); // Text1は左寄せの文字
        vars.tcss[0].Text2 = "Coin " + coin.ToString(); // Text2は右寄せの文字
    }
    // for info wpLimit and helper
    if (vars.tcss.Count > 1)
    {
        string  wpName   = current.weaponName;
        int     limit    = current.weaponLimit;
        string  helpName = current.helperName;
        int     helpLv   = current.helperLevel;
        if (settings["challenge"])
        {
            wpName   = current.endlWeaponName;
            limit    = current.endlWeaponLimit;
            helpName = current.endlHelperName;
            helpLv   = current.endlHelperLevel;
        }

        string name;
        string lv = " Lv." + helpLv;
        switch (helpName)
        {
            case "A1":
                name = "Be";
                break;
            case "A2":
                name = "Su";
                break;
            case "B1":
                name = "Bi";
                break;
            case "B2":
                name = "Ar";
                break;
            case "C1":
                name = "Fe";
                break;
            case "C2":
                name = "En";
                break;
            case "D1":
                name = "Ra";
                break;
            default:
                name = "Solo";
                lv = "";
                break;
        }

        string limitSs = limit > 0 ? limit.ToString() : "-" ;
        vars.tcss[1].Text1 = wpName + " Limit " + limitSs; // Text1は左寄せの文字
        vars.tcss[1].Text2 = name + lv; // Text2は右寄せの文字
    }
    // for info wpLimit and helper
    if (vars.tcss.Count > 2)
    {
        int damage   = current.playerDamage;
        int fireRate = current.playerFireRate;
        if (settings["challenge"])
        {
            damage   = current.endlPlayerDamage;
            fireRate = current.endlPlayerFireRate;
        }

        vars.tcss[2].Text1 = "Damage Lv." + damage; // Text1は左寄せの文字
        vars.tcss[2].Text2 = "FireRate Lv." + fireRate; // Text2は右寄せの文字
    }

    // for timer
    if (version == "ver unknown")
        return false;

    vars.needStart = false;
    vars.needSplit = false;
    vars.needReset = false;

    if (settings["challenge"])
    {
        // for reset
        if ((current.endlDay == 1) && (old.endlDay > 1))
        {
            vars.needReset = true;
            return true;
        }

        // for split
        if ((current.endlDay == old.endlDay + 1) && current.endlDay > 1)
        {
            int sw = old.endlDay % 10;
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
    else if (settings["main"])
    {
        // for main split

        // for start
        if (current.eventId == 1 && old.eventId == 0)
        {
            vars.needStart = true;
            return true;
        }

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
    } // if main end

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
//             EOF
// ------------------------------------------------------------ //
