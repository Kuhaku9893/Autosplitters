// ver0.1.0

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
    return (current.igt > 0.0) && (old.igt == 0.0);
}

reset
{
    return (current.igt == 0.0) && (old.igt == 0.0);
}

split
{
    return current.stage > old. stage;
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
