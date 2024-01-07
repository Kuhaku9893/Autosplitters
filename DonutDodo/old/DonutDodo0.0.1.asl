// ver0.0.1

// ------------------------------------------------------------ //
// 			Initialization
// ------------------------------------------------------------ //

state("DonutDodo", "ver1.39")
{
	// memSize : 37928960
    // filever : 1.3.4.0

	double igt:     "DonutDodo.exe", 0x023D7BC0, 0x100, 0x108, 0x10, 0x58, 0x20, 0x230;
	int    stage:   "DonutDodo.exe", 0x023D7BC0, 0x100, 0x108, 0x10, 0x58, 0x20, 0x1d0;
}

startup
{
	settings.Add("AllDifficulty", false, "All difficulty mode");
	settings.SetToolTip("AllDifficulty", "In each difficulty, only the 5th stage needs to be reset manually.");
}

init
{
    var module = modules.First();
	print("ModuleMemorySize : " + module.ModuleMemorySize.ToString());
    print("FileVersion \t: " + module.FileVersionInfo.FileVersion);
    print("ProcessName \t: " + game.ProcessName.ToLower());
	switch (module.ModuleMemorySize)
	{
		case 37928960:
			version = "ver1.39";
			break;
		default:
			version = "Unknown";
			break;
	}
}

// ------------------------------------------------------------ //
// 			Action
// ------------------------------------------------------------ //

update
{
	if (version == "Unknown")
		return false;
}

start
{
    if (settings["AllDifficulty"])
    {
        if (current.igt < old.igt)
            return true;

        return false;
    }
    if ((current.igt > 0.0) && (old.igt == 0.0))
    {
		print("-- start --");
		return true;
    }
}

reset
{
    if (settings["AllDifficulty"])
    {
		return false;
    }
    if ((current.igt == 0.0) && (old.igt == 0.0))
	{
		print("-- reset --");
		return true;
	}
}

split
{
    if (settings["AllDifficulty"] && (old.stage == 5))
    {
        if ((current.igt == 0.0) && (old.igt > 0.0))
            return true;
    }
    if (current.stage > old. stage)
	{
		print("-- split --");
		return true;
	}
}

isLoading
{
    return true;
}

gameTime
{
    return TimeSpan.FromSeconds(current.igt);
}

// ------------------------------------------------------------ //
// 			EOF
// ------------------------------------------------------------ //
