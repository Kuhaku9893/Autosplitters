// ver0.0.2

// ------------------------------------------------------------ //
// 			Initialization
// ------------------------------------------------------------ //

state("Witch'sRhythmPuzzle")
{
    // memSize : 827392
    // filever : 2020.3.45.6687953
}

startup
{
    Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
    vars.Helper.LoadSceneManager = true;

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
			version = "ver1.02";
			break;
		default:
			version = "unknown";
			break;
	}

    // vars init
    vars.clearedStageMap = new Dictionary<string, bool>();

    vars.Helper.TryLoad = (Func<dynamic, bool>)(mono =>
    {
        // for start, split
        var b = mono["tonibanmen"];
        vars.Helper["stage"] = mono.Make<int>(b, "stage");
        vars.Helper["hard"] = mono.Make<int>(b, "hard");
        vars.Helper["nonstop"] = mono.Make<int>(b, "nonstop");
        vars.Helper["kachimakemoji"] = mono.Make<int>(b, "kachimakemoji");

        return true;
    });
}

// ------------------------------------------------------------ //
// 			Action
// ------------------------------------------------------------ //

update
{
	if (version == "unknown")
		return false;

    current.SceneName = vars.Helper.Scenes.Active.Name;

#if false
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
    
    if (current.nonstop == 0)
    {
        foreach (string stageId in vars.stageName_all.Keys)
        {
            // print("-- onStart Add : " + stageId);
            vars.clearedStageMap.Add(stageId, false);
        }
    }
    else
    {
        foreach (string stageId in vars.stageName_nonstop.Keys)
        {
            // print("-- onStart Add : " + stageId);
            vars.clearedStageMap.Add(stageId, false);
        }
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
// 			EOF
// ------------------------------------------------------------ //
