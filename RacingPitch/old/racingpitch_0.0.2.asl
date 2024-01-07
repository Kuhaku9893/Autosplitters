// ver0.0.2

// ------------------------------------------------------------ //
// 			Initialization
// ------------------------------------------------------------ //

// setingsを追加

state("Pitch")
{
	// memSize : 303104
    // filever : none

	int trackNum: "Pitch.exe", 0x0003D9B8, 0x70;
    bool trackFinishFlg: "Pitch.exe", 0x0003D9B8, 0x74;
    int time: "Pitch.exe", 0x0003D9B8, 0x6c;
}

startup
{
	for (int i = 1; i <= 11; i++)
    {
        settings.Add("tr" + i, true, "Track " + i);
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
}

// ------------------------------------------------------------ //
// 			Action
// ------------------------------------------------------------ //

update
{
	if (version == "")
		return false;
}

start
{
    // aslが60Hzなので、time == 0ms だと検知できない場合がある
    if ((current.trackNum == 1) && (current.time <= 2 * 1000 / 60))
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
    if (current.trackFinishFlg && !old.trackFinishFlg)
	{
		print("-- split --");
		return settings["tr" + current.trackNum];
	}
}

// ------------------------------------------------------------ //
// 			EOF
// ------------------------------------------------------------ //
