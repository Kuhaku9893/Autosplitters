// ver1.0.4

// ------------------------------------------------------------ //
// 			Initialization
// ------------------------------------------------------------ //

state("DolphinsHaveNoScales")
{
    // memSize : 675840
    // filever : 2021.3.20.5732503
    // MD5hash : 02FBCD6B5801447FCADD91644F6CB55C

    // Main
    int state       : "mono-2.0-bdwgc.dll", 0x007280F8, 0x70, 0xf28, 0xec;
    int page        : "mono-2.0-bdwgc.dll", 0x007280F8, 0x70, 0xf28, 0xf0;
    int enemyCount  : "mono-2.0-bdwgc.dll", 0x007280F8, 0x70, 0xf28, 0xe4;
}

startup
{
    // Settings
    settings.Add("each16", true, "Split at each 16 pages.");
    settings.Add("each8", false, "Split at each 8 pages.");
    settings.Add("each4", false, "Split at each 4 pages.");
    settings.Add("each1", false, "Split at each page.");
}

init
{
    var module = modules.First();
	print("ModuleMemorySize : " + module.ModuleMemorySize.ToString());
    print("FileVersion \t: " + module.FileVersionInfo.FileVersion);
    print("ProcessName \t: " + game.ProcessName.ToLower());

    // MD5 code by CptBrian.
    string MD5Hash;
    using (var md5 = System.Security.Cryptography.MD5.Create())
    using (var s = File.Open(modules.First().FileName, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
    {
        MD5Hash = md5.ComputeHash(s).Select(x => x.ToString("X2")).Aggregate((a, b) => a + b);
    }
    print("MD5hash : " + MD5Hash);
}

// ------------------------------------------------------------ //
// 			Action
// ------------------------------------------------------------ //

start
{
    if (current.state == 2)
    {
        print("-- start GAMESTART --");
        return true;
    }
    if ((current.state == 1) && (old.state != 1))
    {
        print("-- start AREA --");
        return true;
    }
}

reset
{
    if (timer.Run.CategoryName != "Death%")
    {
        if ((current.state == 4) && (old.state != 4))
        {
            print("-- reset --");
            return true;
        }
    }
}

split
{
    // Death%
    if (timer.Run.CategoryName == "Death%")
    {
        if ((current.state == 4) && (old.state != 4))
        {
            print("-- stop Death% --");
            return true;
        }
        return false;
    }

    if (current.page <= 1)
    {
        return false;
    }

    // stop
    if ((current.page == 64) && (current.enemyCount <= 0) && (old.enemyCount > 0))
    {
        print("-- stop --");
        return true;
    }

    // split
    if (current.page > old.page)
    {
        if (settings["each1"])
        {
            print("-- split each1--");
            return true;
        }
        if (settings["each4"] && (current.page % 4 == 1))
        {
            print("-- split each4--");
            return true;
        }
        if (settings["each8"] && (current.page % 8 == 1))
        {
            print("-- split each8--");
            return true;
        }
        if (settings["each16"] && (current.page % 16 == 1))
        {
            print("-- split each16--");
            return true;
        }
    }
}

// ------------------------------------------------------------ //
// 			EOF
// ------------------------------------------------------------ //
