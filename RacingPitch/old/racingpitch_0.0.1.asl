// ver0.0.1

// ------------------------------------------------------------ //
// 			Initialization
// ------------------------------------------------------------ //

state("Pitch")
{
	// memSize : 303104
    // filever : none

	int trackNum: "Pitch.exe", 0x0003D9B8, 0x70;
    bool trackFinishFlg: "Pitch.exe", 0x0003D9B8, 0x74;
    int time: "Pitch.exe", 0x0003D9B8, 0x6c;
}

init
{
    var module = modules.First();
	print("ModuleMemorySize : " + module.ModuleMemorySize.ToString());
    print("FileVersion \t: " + module.FileVersionInfo.FileVersion);
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
    // aslが60Hzなので、time == 0 だと検知できない場合がある
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
		return true;
	}
}

// ------------------------------------------------------------ //
// 			EOF
// ------------------------------------------------------------ //
