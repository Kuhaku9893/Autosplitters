// ver.0.1.3

// ------------------------------------------------------------ //
//             Initialization
// ------------------------------------------------------------ //

state("今日は左と上の数字を見てマス目を塗りつぶすアレを無限にやりたい！", "1.5.3")
{
    // memSize : 692224
    // fileVer : 6000.0.43.9905963
    // MD5hash : 6331466E8657E4B9A01CBF2F0FADB9AE
    int scoreTotal:  "GameAssembly.dll", 0x02B6A0E0, 0xb8, 0x0, 0x68;
    int stageData:   "GameAssembly.dll", 0x02B6A0E0, 0xb8, 0x0, 0x2e8;
    float timeTotal: "GameAssembly.dll", 0x02B6A0E0, 0xb8, 0x0, 0x228, 0x20, 0x20;
}
state("今日は左と上の数字を見てマス目を塗りつぶすアレを無限にやりたい！", "1.6.0-1.6.1")
{
    // memSize : 692224
    // fileVer : 6000.0.43.9905963
    // MD5hash : 7592941E4F1381E59FE16CF9BFADAFAB
    int scoreTotal:  "GameAssembly.dll", 0x02B783C8, 0xb8, 0x0, 0x68;
    int stageData:   "GameAssembly.dll", 0x02B783C8, 0xb8, 0x0, 0x2f0;
    float timeTotal: "GameAssembly.dll", 0x02B783C8, 0xb8, 0x0, 0x230, 0x20, 0x20;
}
state("今日は左と上の数字を見てマス目を塗りつぶすアレを無限にやりたい！", "1.6.2")
{
    // memSize : 692224
    // fileVer : 6000.0.43.9905963
    // MD5hash : 98067187B4FD6E6B2BF1D5A45130F2BF

    int scoreTotal:  "GameAssembly.dll", 0x02B783C8, 0xb8, 0x0, 0x68;
    int stageData:   "GameAssembly.dll", 0x02B783C8, 0xb8, 0x0, 0x2f0;
    double timeTotal: "GameAssembly.dll", 0x02B783C8, 0xb8, 0x0, 0x230, 0x20, 0x28;
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
    var gameDir = Path.GetDirectoryName(module.FileName);
    var dataDir = Path.GetFileNameWithoutExtension(module.FileName) + "_Data";
    string gmdPath = Path.Combine(gameDir, dataDir, "il2cpp_data", "Metadata", "global-metadata.dat");
    string MD5Hash;
    using (var md5 = System.Security.Cryptography.MD5.Create())
    using (var s = File.Open(gmdPath, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
    {
        MD5Hash = md5.ComputeHash(s).Select(x => x.ToString("X2")).Aggregate((a, b) => a + b);
    }
    print("MD5Hash : " + MD5Hash);

    switch (MD5Hash)
    {
        case "6331466E8657E4B9A01CBF2F0FADB9AE":
            version = "1.5.3";
            break;
        case "7592941E4F1381E59FE16CF9BFADAFAB":
            version = "1.6.0-1.6.1";
            break;
        case "98067187B4FD6E6B2BF1D5A45130F2BF":
            version = "1.6.2";
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
    return current.stageData > 0 && old.stageData == 0;
}
onStart
{
    print("-- start --");
}

reset
{
    return current.stageData == 0;
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
