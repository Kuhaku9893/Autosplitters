// ver.0.1.0

// ------------------------------------------------------------ //
//             Initialization
// ------------------------------------------------------------ //

state("今日は左と上の数字を見てマス目を塗りつぶすアレを無限にやりたい！", "1.5.3")
{
    // memSize : 692224
    // fileVer : 6000.0.43.9905963
    // MD5hash : 42E5942382D16E991721773C55800AC8
    int scoreTotal:     "GameAssembly.dll", 0x02B6A0E0, 0xb8, 0x0, 0x68;
    float timeTotal:  "GameAssembly.dll", 0x02B6A0E0, 0xb8, 0x0, 0x228, 0x20, 0x20;
}

startup
{
    settings.Add("each10", false, "10問ごとにスプリット");
    settings.Add("each5", false, "5問ごとにスプリット");
    settings.Add("each1", true, "1問ごとにスプリット");
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
        case "42E5942382D16E991721773C55800AC8":
            version = "1.5.3";
            break;
        default:
            version = "unknown";
            break;
    }
}

// ------------------------------------------------------------ //
//             Action
// ------------------------------------------------------------ //

update
{
    if (version == "unknown")
        return false;
}

start
{
    return current.timeTotal > old.timeTotal;
}
onStart
{
    print("-- start --");
}

reset
{
    return current.scoreTotal == 0 && current.timeTotal == 0f;
}
onReset
{
    print("-- reset --");
}

split
{
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
    return TimeSpan.FromSeconds(current.timeTotal);
}

// ------------------------------------------------------------ //
//             EOF
// ------------------------------------------------------------ //
