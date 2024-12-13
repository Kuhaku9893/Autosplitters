// ver0.0.1

// ------------------------------------------------------------ //
// 			Initialization
// ------------------------------------------------------------ //

state("game", "1.6.1")
{
    // memSize : 71569408
    // filever : 1.0.0.0
    // MD5hash : C0090444F92116762E796FB79A52BB54
    
    int scene : "game.exe", 0x04225E20, 0x3b0, 0x178, 0x18, 0x68, 0x28, 0x8;
    int ending :"game.exe", 0x04225E20, 0x2b0, 0x178, 0x78, 0x68, 0x28, 0x20;
    int stage : "game.exe", 0x04225E20, 0x2b0, 0x178, 0x58, 0x68, 0x28, 0x8;
    int menu :  "game.exe", 0x04225E20, 0x3b0, 0x178, 0x18, 0x68, 0x28, 0x20;
    int igt :   "game.exe", 0x04225E20, 0x2b0, 0x178, 0x38, 0x68, 0x28, 0x8;
    bool isInBattle : "game.exe", 0x04225E20, 0x2b0, 0x178, 0x38, 0x68, 0x28, 0x38;
}

startup
{
    vars.endingDictionary = new Dictionary<int, string>()
    {
        {0, "u-end"},
        {1, "f-end"},
        {2, "b-end"},
        {3, "a-end"},
        {4, "l-end"},
    };
    
    // Settings
    settings.Add("stage", false, "Day");
    settings.Add("each5", true, "Each Boss", "stage");
    settings.Add("each1", false, "All Days", "stage");

    settings.Add("ending", true, "Ending");
    settings.Add(vars.endingDictionary[0], true, "U-END", "ending");
    settings.Add(vars.endingDictionary[1], true, "F-END", "ending");
    settings.Add(vars.endingDictionary[2], true, "B-END", "ending");
    settings.Add(vars.endingDictionary[3], true, "A-END", "ending");
    settings.Add(vars.endingDictionary[4], true, "L-END", "ending");

    settings.Add("category", false, "Manual Category Setting.");
    settings.Add("x-end", true, "X-END Category Mode. (Levels Run)", "category");
}

init
{
    var module = modules.First();
	print("ModuleMemorySize : " + module.ModuleMemorySize.ToString());
    print("FileVersion \t: " + module.FileVersionInfo.FileVersion);
    print("ProcessName \t: " + game.ProcessName);
    print("FileName \t: " + module.FileName.ToString());


    // MD5 code by CptBrian.
    string MD5Hash;
    using (var md5 = System.Security.Cryptography.MD5.Create())
    using (var s = File.Open(modules.First().FileName, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
    {
        MD5Hash = md5.ComputeHash(s).Select(x => x.ToString("X2")).Aggregate((a, b) => a + b);
    }
    print("MD5Hash : " + MD5Hash);

    switch (MD5Hash)
    {
        case "C0090444F92116762E796FB79A52BB54":
            version = "1.6.1";
            break;
        default:
            version = "Unknown";
            break;
    }

    // vars
    vars.splitedStage = new HashSet<int>();
    vars.splitedEnding = new HashSet<int>();
    vars.isFullGame = true;
    vars.totalIgt = 0;
    vars.canAsyncGameTime = false;
}

// ------------------------------------------------------------ //
// 			Action
// ------------------------------------------------------------ //

update
{
	if (version == "unknown")
		return false;
    
    // カテゴリの動作モード
    if (settings["category"])
    {
        vars.isFullGame = !settings["x-end"];
    }
    else
    {
        vars.isFullGame = timer.Run.CategoryName.Contains("All");
    }

    // IGT 同期判定
    vars.canAsyncGameTime = true;
    if (current.scene == 1)
    {
        if (current.isInBattle && (current.menu != 1 && current.menu != 2))
        {
            vars.canAsyncGameTime = false;
        }
    }
}

start
{
    if ((current.scene == 1 || current.scene == 10) && (old.scene == 0))
    {
        print("-- start --");
        return true;
    }
}
onStart
{
    vars.splitedStage.Clear();
    vars.splitedEnding.Clear();
    vars.totalIgt = 0;
}

reset
{
    if (current.menu == 4 && old.menu != 4)
    {
        print("-- reset setting --");
        return true;
    }

    if (!vars.isFullGame)
    {
        if (current.scene == 0 && old.scene != 0)
        {
            print("-- reset title --");
            return true;
        }
    }
}

split
{
    // ending
    
    // stop
    if (current.ending == 4 && old.ending != 4 && vars.isFullGame)
    {
        // Full game の L-END は重複ラップ可
        print("-- stop end-L --");
        return settings[vars.endingDictionary[current.ending]];
    }

    // stop or split
    if (current.scene == 5 && old.scene != 5)
    {
        if (!vars.splitedEnding.Contains(current.ending))
        {
            print("-- stop end --");

            vars.splitedEnding.Add(current.ending);
            return settings[vars.endingDictionary[current.ending]];
        }
        return false;
    }

    // stage
    if (current.stage > old.stage)
    {
        if (current.stage <= 1)
            return false;

        if (!settings["each5"] && !settings["each1"])
            return false;

        if (settings["each5"] && !settings["each1"])
        {
            if ((old.stage % 5 != 0) || (old.stage == 20))
                return false;
        }
        
        var stageId = old.stage;
        if (!vars.splitedStage.Contains(stageId))
        {
            print("-- split " + old.stage + " -> " + current.stage + " --");
            
            vars.splitedStage.Add(stageId);
            return true;
        }
    }
}
onSplit
{
    if (current.scene == 5 && old.scene != 5)
    {
        vars.splitedStage.Clear();
        vars.totalIgt += current.igt;
    }
}

isLoading
{
    return vars.canAsyncGameTime;
}

gameTime
{
    if (vars.canAsyncGameTime)
        return TimeSpan.FromMilliseconds(vars.totalIgt + current.igt);
}

// ------------------------------------------------------------ //
// 			EOF
// ------------------------------------------------------------ //
