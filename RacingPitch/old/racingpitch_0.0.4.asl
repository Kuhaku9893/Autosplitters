// ver0.0.4

// ------------------------------------------------------------ //
// 			Initialization
// ------------------------------------------------------------ //

// スタート条件を見直し
// IGT計測を追加

state("Pitch")
{
	// memSize : 303104
    // fileVer : none

	int menu: "Pitch.exe", 0x0003D9B8, 0x4;
	int trackNum: "Pitch.exe", 0x0003D9B8, 0x70;
    bool trackFinishFlg: "Pitch.exe", 0x0003D9B8, 0x74;
    int lap: "Pitch.exe", 0x0003D9B8, 0x58, 0x134;
    int maxLap: "Pitch.exe", 0x0003D9B8, 0x58, 0x138;
    int trackTime: "Pitch.exe", 0x0003D9B8, 0x58, 0xc8;
}

startup
{
	int[] lapArry = {3, 3, 3, 2, 2, 2, 2, 2, 2, 2, 1};
    for (int i = 1; i <= 11; i++)
    {
        settings.Add("tr" + i, true, "Track " + i);

        for (int j = 1; j < lapArry[i - 1]; j++)
        {
            settings.Add("tr" + i + "lap" + j, false, "Lap " + j, "tr" + i);
        }
    }
}

init
{
    var module = modules.First();
	print("ModuleMemorySize : " + module.ModuleMemorySize.ToString());
    print("ProcessName \t: " + game.ProcessName.ToLower());
	switch (module.ModuleMemorySize)
	{
		case 303104:
			version = "ver1.0.3";
			break;
		default:
			version = "";
			break;
	}

    vars.currentTime = 0;
    vars.prevTime = 0;
}

// ------------------------------------------------------------ //
// 			Event
// ------------------------------------------------------------ //

onStart
{
    vars.currentTime = 0;
    vars.prevTime = 0;
}

// ------------------------------------------------------------ //
// 			Action
// ------------------------------------------------------------ //

update
{
	if (version == "")
		return false;
    
    if (current.trackNum > old.trackNum)
        vars.currentTime = vars.prevTime += current.trackTime;
    else if (current.trackTime > old.trackTime)
        vars.currentTime = vars.prevTime + current.trackTime;
}

start
{
    if ((current.menu == 5) && (old.menu == 3))
    {
		print("-- start --");
		return true;
    }
}

reset
{
    if ((current.trackNum == 1) && (current.trackNum != old.trackNum))
	{
		print("-- reset --");
		return true;
	}
}

split
{
    if ((current.lap > old.lap) && (current.lap > 1) && (old.lap != current.maxLap))
	{
		print("-- split lap--");
		return settings["tr" + current.trackNum + "lap" + old.lap];
	}

    if (current.trackFinishFlg && !old.trackFinishFlg)
	{
		print("-- split track finish --");
		return settings["tr" + current.trackNum];
	}
}

isLoading
{
    return true;
}
gameTime
{
    return TimeSpan.FromMilliseconds(vars.currentTime);
}

// ------------------------------------------------------------ //
// 			EOF
// ------------------------------------------------------------ //
