// ver.0.0.3
// unity-helpを試す

// ------------------------------------------------------------ //
//             Initialization
// ------------------------------------------------------------ //

state("今日は左と上の数字を見てマス目を塗りつぶすアレを無限にやりたい！")
{
}

startup
{
    Assembly.Load(File.ReadAllBytes("Components/unity-help")).CreateInstance("Unity");
    
    settings.Add("each10", false, "10問ごとにスプリット");
    settings.Add("each5", false, "5問ごとにスプリット");
    settings.Add("each1", true, "1問ごとにスプリット");
}

init
{
    vars.score = vars.Helper.Make<int>("PicrossManager", 0, "k_BackingFiled", "_scoreTotal");
}

// ------------------------------------------------------------ //
//             Action
// ------------------------------------------------------------ //

update
{
    if (vars.score.Current != vars.score.Old)
    {
        print("score : " + vars.score.Old + " -> " + vars.score.Current);
    }
}

start
{
    // return current.timeTotal > old.timeTotal;
}
onStart
{
    print("-- start --");
}

reset
{
    // return current.scoreTotal == 0 && current.timeTotal == 0f;
}
onReset
{
    print("-- reset --");
}

split
{
    /*
    if (current.scoreTotal <= old.scoreTotal)
        return false;
    
    if (settings["each1"])
    {
        return true;
    }
    if (settings["each5"])
    {
        return current.scoreTotal % 5 == 0;
    }
    if (settings["each10"])
    {
        return current.scoreTotal % 10 == 0;
    }
    */
}
onSplit
{
    print("-- split --");
}

isLoading
{
    return true;
}
gameTime
{
    return TimeSpan.Zero; // TimeSpan.FromSeconds(current.timeTotal);
}

// ------------------------------------------------------------ //
//             EOF
// ------------------------------------------------------------ //
