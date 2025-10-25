// ver1.2.3

// ------------------------------------------------------------ //
//          Initialization
// ------------------------------------------------------------ //

state("game", "1.6.1-1.7.3")
{
    // memSize : 71569408
    // fileVer : 1.0.0.0
    // MD5hash : C0090444F92116762E796FB79A52BB54
    // MD5hash : 14B049860AC9CBF8F161E73C71B11CFD
    // MD5hash : B53E2EEA97094DFF70B1629FAF9EF2A5
    // MD5hash : B7DC72EFAB5C4F54F22ECC50A28F6F6B
    // MD5hash : 6C5A6DA36646B5D1C3E27D3B359110E3

    int scene :     "game.exe", 0x04225E20, 0x3b0, 0x178, 0x18, 0x68, 0x28, 0x8;
    int ending :    "game.exe", 0x04225E20, 0x2b0, 0x178, 0x78, 0x68, 0x28, 0x20;
    int stage :     "game.exe", 0x04225E20, 0x2b0, 0x178, 0x58, 0x68, 0x28, 0x8;
    int pauseType : "game.exe", 0x04225E20, 0x3b0, 0x178, 0x18, 0x68, 0x28, 0x20;

    int igt :       "game.exe", 0x04225E20, 0x2b0, 0x178, 0x38, 0x68, 0x28, 0x8;
    bool isBattle : "game.exe", 0x04225E20, 0x2b0, 0x178, 0x38, 0x68, 0x28, 0x38;
}
state("game", "1.8.0")
{
    // memSize : 50774016
    // fileVer : 1.0.0.0
    // MD5hash : 234F4708B433222E587ACDFB69D1BB38

    int scene :     "game.exe", 0x02D4F1C0, 0x448, 0x1c0, 0x10, 0x68, 0x28, 0x1d0;
    int ending :    "game.exe", 0x02D4F1C0, 0x348, 0x1c0, 0x78, 0x68, 0x28, 0x20;
    int stage :     "game.exe", 0x02D4F1C0, 0x348, 0x1c0, 0x58, 0x68, 0x28, 0x8;
    int pauseType : "game.exe", 0x02D4F1C0, 0x448, 0x1c0, 0x18, 0x68, 0x28, 0x8;

    int igt :       "game.exe", 0x02D4F1C0, 0x348, 0x1c0, 0x38, 0x68, 0x28, 0x8;
    bool isBattle : "game.exe", 0x02D4F1C0, 0x348, 0x1c0, 0x38, 0x68, 0x28, 0x68;
}
state("game", "1.9.0")
{
    // memSize : 49123328
    // fileVer : 1.0.0.0
    // MD5Hash : E8723020BDD5DC7189F3780DC3D07D5C

    int scene :     "game.exe", 0x02BEE090, 0x488, 0x1d0, 0x08, 0x68, 0x28, 0x1e8;
    int ending :    "game.exe", 0x02BEE090, 0x398, 0x1d0, 0x78, 0x68, 0x28, 0x20;
    int stage :     "game.exe", 0x02BEE090, 0x398, 0x1d0, 0x58, 0x68, 0x28, 0x8;
    int pauseType : "game.exe", 0x02C25C68, 0x60, 0x288, 0x68, 0x28, 0x8;

    int igt :       "game.exe", 0x02BEE090, 0x398, 0x1d0, 0x38, 0x68, 0x28, 0x8;
    bool isBattle : "game.exe", 0x02BEE090, 0x398, 0x1d0, 0x38, 0x68, 0x28, 0x68;
}
state("game", "1.9.1")
{
    // memSize : 49123328
    // fileVer : 1.0.0.0
    // MD5Hash : BA33C0B994050660CB3B14DA7F73EC9F

    int scene :     "game.exe", 0x02BEE090, 0x488, 0x1d0, 0x08, 0x68, 0x28, 0x200;
    int ending :    "game.exe", 0x02BEE090, 0x398, 0x1d0, 0x78, 0x68, 0x28, 0x20;
    int stage :     "game.exe", 0x02BEE090, 0x398, 0x1d0, 0x58, 0x68, 0x28, 0x8;
    int pauseType : "game.exe", 0x02BEE090, 0x488, 0x1d0, 0x28, 0x68, 0x28, 0x8;

    int igt :       "game.exe", 0x02BEE090, 0x398, 0x1d0, 0x38, 0x68, 0x28, 0x8;
    bool isBattle : "game.exe", 0x02BEE090, 0x398, 0x1d0, 0x38, 0x68, 0x28, 0x68;
}
state("game", "1.10.0")
{
    // memSize : 49123328
    // fileVer : 1.0.0.0
    // MD5Hash : 094B70001A212DB5DE1773DF38AB1C83

    int scene :     "game.exe", 0x02BEE090, 0x488, 0x1d0,  0x0, 0x68, 0x28, 0x50;
    int ending :    "game.exe", 0x02BEE090, 0x398, 0x1d0, 0x80, 0x68, 0x28, 0x20;
    int stage :     "game.exe", 0x02BEE090, 0x398, 0x1d0, 0x60, 0x68, 0x28, 0x8;
    int pauseType : "game.exe", 0x02C25C70,  0x60, 0x288, 0x68, 0x28, 0x8;

    int igt :       "game.exe", 0x02BEE090, 0x398, 0x1d0, 0x40, 0x68, 0x28, 0x8;
    bool isBattle : "game.exe", 0x02BEE090, 0x398, 0x1d0, 0x40, 0x68, 0x28, 0x68;
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

    vars.sceneInitialStart = 15;
    switch (MD5Hash)
    {
        case "C0090444F92116762E796FB79A52BB54":
        case "14B049860AC9CBF8F161E73C71B11CFD":
        case "B53E2EEA97094DFF70B1629FAF9EF2A5":
        case "B7DC72EFAB5C4F54F22ECC50A28F6F6B":
        case "6C5A6DA36646B5D1C3E27D3B359110E3":
            version = "1.6.1-1.7.3";
            vars.sceneInitialStart = 10;
            break;
        case "234F4708B433222E587ACDFB69D1BB38":
            version = "1.8.0";
            vars.sceneInitialStart = 11;
            break;
        case "E8723020BDD5DC7189F3780DC3D07D5C":
            version = "1.9.0";
            vars.sceneInitialStart = 11;
            break;
        case "BA33C0B994050660CB3B14DA7F73EC9F":
            version = "1.9.1";
            vars.sceneInitialStart = 11;
            break;
        case "094B70001A212DB5DE1773DF38AB1C83":
            version = "1.10.0";
            break;
        default:
            version = "Unknown";
            break;
    }

    // vars
    vars.isFullGame = true;

    vars.splitedStage = new HashSet<int>();
    vars.splitedEnding = new HashSet<int>();
    vars.isFirstEventBattle = false;

    vars.isAsyncIgt = false;
    vars.totalIgt = 0;
    vars.isCarryoverTotalIgt = false;
    vars.igtThisEnd = 0;
    vars.isCarryoverIgtThisEnd = false;
}

// ------------------------------------------------------------ //
//          Action
// ------------------------------------------------------------ //

update
{
    if (version == "Unknown")
        return false;

    // カテゴリの動作モード
    if (settings["category"])
    {
        vars.isFullGame = !settings["x-end"];
    }
    else
    {
        vars.isFullGame = timer.Run.CategoryName.ToLower().Contains("all");
    }

    // 初回のイベント戦闘フラグ
    if (current.scene == vars.sceneInitialStart)
    {
        vars.isFirstEventBattle = true;
    }

    // igtの同期判定
    // falseの時はタイム補間
    vars.isAsyncIgt = true;
    if (settings["interpolatedIgt"])
    {
        vars.isAsyncIgt = !(current.isBattle && current.scene == 1 && current.pauseType == 0);
    }

    // エンディング表示時の処理
    if (current.scene == 5 && old.scene != 5)
    {
        vars.splitedStage.Clear();
        vars.isCarryoverTotalIgt = true;
    }

    // 戦闘シーンから移行でこのエンドでの積み立てフラグをON
    if (current.scene != 1 && old.scene == 1)
    {
        vars.isCarryoverIgtThisEnd = true;

        if (version == "1.6.1-1.7.3")
        {
            vars.isCarryoverIgtThisEnd = false;
        }
    }

    // タイトル画面でこのエンドでの積み立てをリセット
    if (current.scene == 0 && !vars.isCarryoverTotalIgt)
    {
        vars.igtThisEnd = 0;
        vars.isCarryoverIgtThisEnd = false;
    }

    // igt積み立て
    if (current.igt == 0 && old.igt > 0)
    {
        if (vars.isCarryoverIgtThisEnd)
        {
            print("-- igt this end 積み立て " + vars.igtThisEnd + " + " + old.igt + "--");
            vars.igtThisEnd += old.igt;
            vars.isCarryoverIgtThisEnd = false;
        }
        if (vars.isCarryoverTotalIgt)
        {
            if (version == "1.6.1-1.7.3")
            {
                vars.igtThisEnd = old.igt;
            }

            print("-- total igt 積み立て " + vars.totalIgt + " + " + vars.igtThisEnd + "--");
            vars.totalIgt += vars.igtThisEnd;
            vars.igtThisEnd = 0;
            vars.isCarryoverTotalIgt = false;
        }
    }
}

start
{
    if ((current.scene == 1 || current.scene == vars.sceneInitialStart) && (old.scene == 0))
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
    vars.isCarryoverTotalIgt = false;
    vars.igtThisEnd = 0;
    vars.isCarryoverIgtThisEnd = false;
}

reset
{
    if (current.pauseType == 4 && old.pauseType != 4 && current.scene == 0)
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
        var totalMilliseconds = vars.totalIgt + vars.igtThisEnd + current.igt;
        return TimeSpan.FromMilliseconds(totalMilliseconds);
    }
}

// ------------------------------------------------------------ //
//          EOF
// ------------------------------------------------------------ //
