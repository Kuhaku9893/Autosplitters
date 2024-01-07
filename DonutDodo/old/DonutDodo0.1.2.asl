// ver0.1.2

// ------------------------------------------------------------ //
// 			Initialization
// ------------------------------------------------------------ //
// ゲーム起動or aslロード時に自動的にGameTimeに切り替えて、
// ゲーム終了or aslアンロード時に自動的に元に戻す機能を追加したが
// ダメ、失敗
// 先にLivesplitを終了すると、期待したようには動作しなかった

state("DonutDodo", "ver1.39")
{
	// memSize : 37928960
    // filever : 1.3.4.0

	double igt:     "DonutDodo.exe", 0x023D7BC0, 0x100, 0x108, 0x10, 0x58, 0x20, 0x230;
	int    stage:   "DonutDodo.exe", 0x023D7BC0, 0x100, 0x108, 0x10, 0x58, 0x20, 0x1d0;
}

startup
{
    settings.Add("GameTime", true, "Sets Current Timing Method to Game Time.");
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

    vars.oldSettingsGameTime = settings["GameTime"];
    if (settings["GameTime"])
    {
        vars.originalTimingMethod = timer.CurrentTimingMethod;
        timer.CurrentTimingMethod = TimingMethod.GameTime;
    }
}

exit
{
    timer.CurrentTimingMethod = vars.originalTimingMethod;
}

// ------------------------------------------------------------ //
// 			Action
// ------------------------------------------------------------ //

update
{
	if (version == "Unknown")
		return false;
    
    if (vars.oldSettingsGameTime != settings["GameTime"])
    {
        if (settings["GameTime"])
        {
            vars.originalTimingMethod = timer.CurrentTimingMethod;
            timer.CurrentTimingMethod = TimingMethod.GameTime;
        }
        else
        {
            timer.CurrentTimingMethod = vars.originalTimingMethod;
        }
    }
    vars.oldSettingsGameTime = settings["GameTime"];
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
