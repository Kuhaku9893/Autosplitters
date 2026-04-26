// ver1.0.0

// ------------------------------------------------------------ //
// 			Initialization
// ------------------------------------------------------------ //

state("Beltmatic")
{
    // game ver 1.0.9
    int level   : "GameAssembly.dll", 0x01A91B38, 0xaf0, 0x1f0, 0x30, 0x48, 0x18;
    long tick   : "GameAssembly.dll", 0x01A91B38, 0xaf0, 0x1f0, 0x30, 0x10;
}

startup
{
    var splitLevels = new List<int> {5, 10, 20, 30};
    vars.SplitLevels = splitLevels;

    // Settings
    foreach (int level in splitLevels.Reverse<int>())
    {
        string l = level.ToString();
        settings.Add("each" + l, false, "Split at each " + l + " levels.");
    }
    settings.Add("each1", true, "Split at each level.");
}

// ------------------------------------------------------------ //
// 			Action
// ------------------------------------------------------------ //

start
{
    return current.tick > 0 && old.tick == 0;
}

reset
{
    return current.tick == 0;
}

split
{
    // split
    if (current.level <= old.level)
    {
        return false;
    }

    if (settings["each1"])
    {
        print("-- split each1--");
        return true;
    }

    foreach (var level in vars.SplitLevels)
    {
        string l = level.ToString();
        if (settings["each" + l] && (current.level % level == 0))
        {
            print("-- split each" + l + "--");
            return true;
        }
    }
}

// ------------------------------------------------------------ //
// 			EOF
// ------------------------------------------------------------ //
