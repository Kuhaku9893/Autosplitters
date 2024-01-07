// ver1.0.0

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
    if (timer.CurrentTimingMethod == TimingMethod.RealTime)
    {        
        var timingMessage = MessageBox.Show (
            "This game uses Game Time (IGT) as the main timing method.\n"+
            "LiveSplit is currently set to show Real Time (RTA).\n"+
            "Would you like to set the timing method to Game Time?",
            "LiveSplit | Donut Dodo",
            MessageBoxButtons.YesNo,MessageBoxIcon.Question
        );
        
        if (timingMessage == DialogResult.Yes)
        {
            timer.CurrentTimingMethod = TimingMethod.GameTime;
        }
    }

	settings.Add("AllDifficulty", false, "All Difficulties Mode");
	settings.SetToolTip("AllDifficulty", "In each difficulties, only the 5th stage needs to be reset manually.");
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

    vars.beforeDifficultyTime = 0.0;
}

// ------------------------------------------------------------ //
// 			Action
// ------------------------------------------------------------ //

onStart
{
    vars.beforeDifficultyTime = 0.0;
}

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

    return (current.igt > 0.0) && (old.igt == 0.0);
}

reset
{
    if (settings["AllDifficulty"])
    {
        if (old.stage == 5)
            return false;
    }

    return (current.igt == 0.0) && (old.igt > 0.0);
}

split
{
    if (settings["AllDifficulty"] && (old.stage == 5))
    {
        if ((current.stage == 1) && (old.stage == 5))
        {
            vars.beforeDifficultyTime += old.igt;
            return true;
        }
    }

    return current.stage > old. stage;
}

isLoading
{
    return true;
}

gameTime
{
    return TimeSpan.FromSeconds(vars.beforeDifficultyTime + current.igt);
}

// ------------------------------------------------------------ //
// 			EOF
// ------------------------------------------------------------ //
