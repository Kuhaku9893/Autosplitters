// ver0.1.0

// ------------------------------------------------------------ //
// 			Initialization
// ------------------------------------------------------------ //

/*
state("game", "1.6.1")
{
    // memSize : 71569408
    // filever : 1.0.0.0
    // MD5hash : C0090444F92116762E796FB79A52BB54
}
state("game", "1.7.0")
{
    // memSize : 71569408
    // filever : 1.0.0.0
    // MD5hash : 14B049860AC9CBF8F161E73C71B11CFD
}
state("game", "1.7.1")
{
    // memSize : 71569408
    // filever : 1.0.0.0
    // MD5hash : B53E2EEA97094DFF70B1629FAF9EF2A5
}
state("game", "1.7.2")
{
    // memSize : 71569408
    // filever : 1.0.0.0
    // MD5hash : B7DC72EFAB5C4F54F22ECC50A28F6F6B
}
state("game", "1.7.3")
{
    // memSize : 71569408
    // filever : 1.0.0.0
    // MD5hash : 6C5A6DA36646B5D1C3E27D3B359110E3
}
*/
state("game")
{
    int scene :     "game.exe", 0x04225E20, 0x3b0, 0x178, 0x18, 0x68, 0x28, 0x8;
    int ending :    "game.exe", 0x04225E20, 0x2b0, 0x178, 0x78, 0x68, 0x28, 0x20;
    int stage :     "game.exe", 0x04225E20, 0x2b0, 0x178, 0x58, 0x68, 0x28, 0x8;
    int pauseType : "game.exe", 0x04225E20, 0x3b0, 0x178, 0x18, 0x68, 0x28, 0x20;

    int igt :       "game.exe", 0x04225E20, 0x2b0, 0x178, 0x38, 0x68, 0x28, 0x8;
    bool isBattle : "game.exe", 0x04225E20, 0x2b0, 0x178, 0x38, 0x68, 0x28, 0x38;
    // bool isBattleStarted :  "game.exe", 0x04225E20, 0x2b0, 0x178, 0x30, 0x68, 0x28, 0x8;
    // bool isBattleEnded   :  "game.exe", 0x04225E20, 0x2b0, 0x178, 0x30, 0x68, 0x28, 0x20;
}

startup
{
    vars.endingDictionary = new Dictionary<int, string>()
    {
        {0, "U-END"},
        {1, "F-END"},
        {2, "B-END"},
        {3, "A-END"},
        {4, "L-END"},
    };
    
    // Settings
    settings.Add("stage", false, "Split : Day");
    settings.Add("each5", false, "Each Boss", "stage");
    settings.Add("each1", false, "All Days", "stage");
    settings.Add("eventBattle", false, "First Event Battle", "stage");

    settings.Add("ending", true, "Split : Ending");
    settings.Add(vars.endingDictionary[0], true, vars.endingDictionary[0], "ending");
    settings.Add(vars.endingDictionary[1], true, vars.endingDictionary[1], "ending");
    settings.Add(vars.endingDictionary[2], true, vars.endingDictionary[2], "ending");
    settings.Add(vars.endingDictionary[3], true, vars.endingDictionary[3], "ending");
    settings.Add(vars.endingDictionary[4], true, vars.endingDictionary[4], "ending");

    settings.Add("category", false, "Manual Category Setting.");
    settings.Add("x-end", true, "X-END Category Mode. (Levels Run)", "category");

    settings.Add("interpolatedIgt", true, "Display interpolated IGT.");
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

    /*
    switch (MD5Hash)
    {
        case "C0090444F92116762E796FB79A52BB54":
            version = "1.6.1";
            break;
        case "14B049860AC9CBF8F161E73C71B11CFD":
            version = "1.7.0";
            break;
        case "B53E2EEA97094DFF70B1629FAF9EF2A5":
            version = "1.7.1";
            break;
        case "B7DC72EFAB5C4F54F22ECC50A28F6F6B":
            version = "1.7.2";
            break;
        case "6C5A6DA36646B5D1C3E27D3B359110E3":
            version = "1.7.3";
            break;
        default:
            version = "Unknown";
            break;
    }
    */

    // vars
    vars.isFullGame = true;

    vars.splitedStage = new HashSet<int>();
    vars.splitedEnding = new HashSet<int>();
    vars.isFirstEventBattle = false;

    vars.totalIgt = 0;
    vars.isAsyncIgt = false;
    vars.isCarryoverIgt = false;
}

// ------------------------------------------------------------ //
// 			Action
// ------------------------------------------------------------ //

update
{
    /*
	if (version == "unknown")
		return false;
    */

    // カテゴリの動作モード
    if (settings["category"])
    {
        vars.isFullGame = !settings["x-end"];
    }
    else
    {
        vars.isFullGame = timer.Run.CategoryName.ToLower().Contains("all");
    }

    // エンディング表示時の処理
    if (current.scene == 5 && old.scene != 5)
    {
        vars.splitedStage.Clear();
        vars.isCarryoverIgt = true;
    }

    // 初回のイベント戦闘フラグ
    if (current.scene == 10)
        vars.isFirstEventBattle = true;

    // igtの同期判定
    // falseの時はタイム補間
    vars.isAsyncIgt = true;
    if (settings["interpolatedIgt"])
    {
        vars.isAsyncIgt = !(current.isBattle && current.scene == 1 && current.pauseType == 0);
    }

    // igt積み立て
    if ((current.igt == 0 && old.igt > 0) && vars.isCarryoverIgt)
    {
        print("-- igt 積み立て " + vars.totalIgt + " + " + old.igt + "--");
        vars.totalIgt += old.igt;
        vars.isCarryoverIgt = false;
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
    vars.isFirstEventBattle = false;

    vars.totalIgt = 0;
    vars.isCarryoverIgt = false;
}

reset
{
    if (current.pauseType == 4 && old.pauseType != 4)
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
        print("-- stop L-END --");
        return settings[vars.endingDictionary[current.ending]];
    }

    // stop or split
    if (current.scene == 5 && old.scene != 5)
    {
        if (vars.isFullGame && current.ending == 4)
            return false;

        if (!vars.splitedEnding.Contains(current.ending))
        {
            print("-- stop or split ending --");

            vars.splitedEnding.Add(current.ending);
            return settings[vars.endingDictionary[current.ending]];
        }
        return false;
    }

    // stage

    if (vars.isFirstEventBattle)
    {
        // 初回のイベント戦闘

        if (current.scene != 1 && old.scene == 1)
        {
            print("-- split First Event Battle --");
            vars.isFirstEventBattle = false;
            return settings["eventBattle"];
        }
    }
    else if (current.stage == old.stage + 1)
    {
        // 通常のラップ

        if (current.stage <= 1)
            return false;

        if (current.ending != 2 && current.stage > 20)
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

isLoading
{
    return vars.isAsyncIgt;
}
gameTime
{
    if (vars.isAsyncIgt)
    {
        return TimeSpan.FromMilliseconds(vars.totalIgt + current.igt);
    }
}

// ------------------------------------------------------------ //
// 			EOF
// ------------------------------------------------------------ //
