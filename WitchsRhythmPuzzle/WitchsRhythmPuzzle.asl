// ver1.1.0
// ------------------------------------------------------------ //
//             Initialization
// ------------------------------------------------------------ //

state("Witch'sRhythmPuzzle")
{
    // memSize : 827392
    // filever : 2020.3.45.6687953

    int stage:          "UnityPlayer.dll", 0x014E0D64, 0x2c8, 0x368, 0x74, 0x84, 0x4, 0x38, 0x20;
    int hard:           "UnityPlayer.dll", 0x014E0D64, 0x2c8, 0x368, 0x74, 0x84, 0x4, 0x38, 0x34;
    int nonstop:        "UnityPlayer.dll", 0x014E0D64, 0x2c8, 0x368, 0x74, 0x84, 0x4, 0x38, 0x60;
    int kachimakemoji:  "UnityPlayer.dll", 0x014E0D64, 0x2c8, 0x368, 0x74, 0x84, 0x4, 0x38, 0x78;
}

startup
{
    // isHard - stage, name
    vars.stageName_all = new Dictionary<string, string>() {
        {"0-1",  "Entail(Normal)"},
        {"0-2",  "Tariff(Normal)"},
        {"0-3",  "Drove(Normal)"},
        {"0-4",  "Forge(Normal)"},
        {"0-5",  "Virgule(Normal)"},
        {"0-6",  "Yew(Normal)"},
        {"1-2",  "Tariff(Hard)"},
        {"1-3",  "Drove(Hard)"},
        {"1-4",  "Forge(Hard)"},
        {"1-5",  "Virgule(Hard)"},
        {"1-6",  "Yew(Hard)"},
        {"1-7",  "Sleek(Hard)"},
        {"1-8",  "Minnow(Hard)"},
        {"1-9",  "Boggart(Hard)"},
        {"1-10", "Ibis(Hard)"},
        // 1-10, ending
    };

    // stage, name
    vars.stageName_nonstop = new Dictionary<string, string>() {
        {"2",  "Tariff"},
        {"3",  "Drove"},
        {"4",  "Forge"},
        {"5",  "Virgule"},
        {"6",  "Yew"},
        {"7",  "Sleek"},
        {"8",  "Minnow"},
        {"9",  "Boggart"},
        {"1",  "Entail"},
        {"11", "Ibis"},
        // 12, ending
    };

    settings.Add("AllStages", true, "All Stages");
    foreach (KeyValuePair<string, string> stageName in vars.stageName_all)
    {
        settings.Add(stageName.Key, true, stageName.Value, "AllStages");
    }

    settings.Add("Nonstop", true, "Nonstop");
    foreach (KeyValuePair<string, string> stageName in vars.stageName_nonstop)
    {
        settings.Add(stageName.Key, true, stageName.Value, "Nonstop");
    }
}

init
{
    var module = modules.First();
    print("ModuleMemorySize : " + module.ModuleMemorySize.ToString());
    print("FileVersion \t: " + module.FileVersionInfo.FileVersion);
    print("ProcessName \t: " + game.ProcessName.ToLower());
    switch (module.ModuleMemorySize)
    {
        case 827392:
            version = "ver1.03";
            break;
        default:
            version = "unknown";
            break;
    }

    // Sig scan
    var UnityPlayer = modules.FirstOrDefault(m => m.ModuleName == "UnityPlayer.dll");
    var UnityPlayerScanner = new SignatureScanner(game, UnityPlayer.BaseAddress, UnityPlayer.ModuleMemorySize);

    var SceneManager = IntPtr.Zero;
    var SceneManagerSig = new SigScanTarget(1, "A1 ?? ?? ?? ?? 53 33 DB 89 45");
    SceneManagerSig.OnFound = (p, s, ptr) => p.ReadPointer(ptr);

    int scanAttempts = 0;
    while (scanAttempts++ < 50)
        if ((SceneManager = UnityPlayerScanner.Scan(SceneManagerSig)) != IntPtr.Zero) break;

    if (!(vars.SigFound = SceneManager != IntPtr.Zero)) return;

    Func<string, string> PathToName = (path) =>
    {
        if (String.IsNullOrEmpty(path) || !path.StartsWith("Assets/")) return null;
        else return System.Text.RegularExpressions.Regex.Matches(path, @".+/(.+).unity")[0].Groups[1].Value;
    };

    vars.UpdateScenes = (Action) (() =>
    {
        current.SceneName = PathToName(new DeepPointer(SceneManager, 0x2C, 0x0, 0xC, 0x0).DerefString(game, 26)) ?? old.SceneName;
    });

    // vars init
    vars.clearedStageMap = new Dictionary<string, bool>();
}

// ------------------------------------------------------------ //
//             Action
// ------------------------------------------------------------ //

update
{
    if (version == "unknown")
        return false;

    if (!vars.SigFound)
        return false;

    vars.UpdateScenes();

#if true
    // vars
    Action<string, string, string> LogString = (currentValue, oldValue, text) => 
    {
        if (currentValue != oldValue)
            print(text + " : " + currentValue);
    };
    Action<int, int, string> LogInt = (currentValue, oldValue, text) => 
    {
        if (currentValue != oldValue)
            print(text + " : " + currentValue);
    };
    LogString(current.SceneName, old.SceneName, "SceneName");
    LogInt(   current.stage,     old.stage,     "stage");
    LogInt(   current.hard,      old.hard,      "hard");
    LogInt(   current.nonstop,   old.nonstop,   "nonstop");
    LogInt(   current.kachimakemoji, old.kachimakemoji, "kachimakemoji");
#endif
}

onStart
{
    vars.clearedStageMap.Clear();
    
    var stageNames = vars.stageName_all.Keys;
    if (current.nonstop == 1)
    {
        stageNames = vars.stageName_nonstop.Keys;
    }
    foreach (string stageId in stageNames)
    {
        // print("-- onStart Add : " + stageId);
        vars.clearedStageMap.Add(stageId, false);
    }
}

start
{
    if (current.SceneName != "event" || old.SceneName == "event")
        return false;

    // all stages
    if (current.stage == 1 && current.nonstop == 0)
        return true;

    // nonstop
    if (current.stage == 2 && current.nonstop == 1)
        return true;
}

reset
{
    return (current.stage == 13);
}

split
{
    if (current.SceneName != "main")
        return false;

    // for split
    if ((current.kachimakemoji != 1) || (old.kachimakemoji != 0))
        return false;

    string stageId = "";
    if (current.nonstop == 0)
    {
        stageId = current.hard + "-" + current.stage;
    }
    else
    {
        stageId = old.stage.ToString();
    }
    // print("-- split stageId : " + stageId + " --");
    if (vars.clearedStageMap[stageId])
        return false;

    vars.clearedStageMap[stageId] = true;
    return settings[stageId];
}

// ------------------------------------------------------------ //
//             EOF
// ------------------------------------------------------------ //
