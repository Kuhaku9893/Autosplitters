// ver.1.1.2

// ------------------------------------------------------------ //
//             Initialization
// ------------------------------------------------------------ //

state("Typoman", "ver1.10")
{
    // memSize : 23171072
    int chapter: "Typoman.exe", 0x0135A9E0, 0xC, 0x10, 0x98, 0xD8, 0x40;
    int segment: "Typoman.exe", 0x0135A9E0, 0xC, 0x10, 0x98, 0xD8, 0x44;
    bool ismenuActive: "Typoman.exe", 0x0140DDE8, 0x8, 0x8, 0x10, 0x20, 0x29;
    bool isGameMode: "Typoman.exe", 0x0140DDE8, 0x8, 0x10, 0x20, 0x384;
}

startup
{
    // chap.0 : 0, 2 - 8
    settings.Add("chapter0", true, "Prologue (8 segments)");
    settings.Add("0-0", true, "0-1", "chapter0");
    for (var index = 2; index < 8; ++index)
    {
        settings.Add("0-" + index.ToString(), true,
                     "0-" + index.ToString(), "chapter0");
    }
    settings.SetToolTip("chapter0",
                        "Split \"Prologue\" equals split at the end of 0-8");

    // chap.1 : 0 - 9
    settings.Add("chapter1", true, "Chapter.1 (10 segments)");
    for (var index = 0; index < 9; ++index)
    {
        settings.Add("1-" + index.ToString(), true,
                     "1-" + (index+1).ToString(), "chapter1");
    }
    settings.SetToolTip("chapter1",
                        "Split \"Chapter.1\" equals split at the end of 1-10");

    // chap.2 : 0 - 15
    settings.Add("chapter2", true, "Chapter.2 (16 segments)");
    for (var index = 0; index < 15; ++index)
    {
        var str = "";
        var flg = true;
        switch (index)
        {
            case 0:
                str = " (cut scene only)";
                break;
            case 2:
                str = " (very short segment)";
                // flg = false;
                break;
            default:
                break;
        }
        settings.Add("2-" + index.ToString(), flg,
                     "2-" + (index+1).ToString() + str, "chapter2");
    }
    settings.SetToolTip("chapter2",
                        "Split \"Chapter.2\" equals split at the end of 1-16");

    // chap.3 : 0 - 12
    settings.Add("chapter3", true, "Chapter.3 (13 segments)");
    for (var index = 0; index < 12; ++index)
    {
        settings.Add("3-" + index.ToString(), true,
                     "3-" + (index+1).ToString(), "chapter3");
    }
    settings.SetToolTip("chapter3",
                        "Split \"Chapter.3\" equals split at the end of 1-13" +
                        ", and final split should manually");
    
    // Sig scan target
    // FenrirFight.Awake()+d 0x1, 0x0
    // 0x118 phase 4:the boss beated
    vars.scanTargetBoss = new SigScanTarget(0x1, 
        "B8 ?? ?? ?? ?? 48 89 30 48 8B CE BA ?? ?? ?? ?? 48 83 EC 20"
    );
}

init
{
    print("ModuleMemorySize : " + modules.First().ModuleMemorySize.ToString());
    switch (modules.First().ModuleMemorySize)
    {
        case 23171072:
            version = "ver1.10";
            break;
        default:
            version = "";
            break;
    }

    // Sig scan thread
    vars.tokenSource = new CancellationTokenSource();
    vars.token = vars.tokenSource.Token;
    vars.threadScan = new Thread(() =>
    {
        IntPtr ptrBoss = IntPtr.Zero;
        
        while (!vars.token.IsCancellationRequested)
        {
            print("-- Sig scan in thread --");
            foreach (var page in game.MemoryPages())
            {
                var scanner = new SignatureScanner(game, page.BaseAddress, (int)page.RegionSize);
                
                if (ptrBoss == IntPtr.Zero && 
                    (ptrBoss = scanner.Scan(vars.scanTargetBoss)) != IntPtr.Zero
                )
                    print("Boss : " + ptrBoss.ToString("x"));
                
                if (ptrBoss != IntPtr.Zero)
                    break;
            }
            
            if (ptrBoss != IntPtr.Zero)
            {
                vars.phase = new MemoryWatcher<int>(new DeepPointer(ptrBoss, DeepPointer.DerefType.Bit32, 0x0, 0x118));

                vars.watchersInGame = new MemoryWatcherList()
                {
                    vars.phase
                };
                print("-- Sig scan in thread done --");
                break;
            }
            Thread.Sleep(1000);
        }
        print("-- Exit thread scan --");
    });
    
    // vars init
    vars.chapter = 0;
    vars.segment = 0;
    
    // for sig scan
    vars.scanStartedFlg = false;
    
    // for timer stop
    vars.inPhase4Time = TimeSpan.Zero;
    vars.split_3_13_fg = false;
}

// ------------------------------------------------------------ //
//             Action
// ------------------------------------------------------------ //

update
{
    if (version == "")
        return false;
    
    // Reach 3-12 at first time, scan start
    if (!vars.scanStartedFlg && current.isGameMode && 
        current.chapter == 3 && current.segment == 12)
    {
        vars.threadScan.Start();
        vars.scanStartedFlg = true;
    }
    
    // watcher update, if scan done
    if (vars.scanStartedFlg && !vars.threadScan.IsAlive)
        vars.watchersInGame.UpdateAll(game);

    if (((IDictionary<string, object>)vars).ContainsKey("phase"))
    {
        if (vars.phase.Changed)
            print("phase : " + vars.phase.Current);
    }

    // Move from menu screen to game screen
    if(!current.ismenuActive && current.isGameMode && !old.isGameMode)
    {
        vars.chapter = current.chapter;
        vars.segment = current.segment;
        vars.inPhase4Time = TimeSpan.Zero;
        vars.split_3_13_flg = false;
        print("-- ini in update --");
        print("game : " + current.chapter + "-" + current.segment);
        print("vars : " + vars.chapter + "-" + vars.segment);
    }
}

// Start when select Chapter0-0 from the main menu
// or the chapter selection menu
start
{
    return (current.chapter == 0 && current.segment == 0
       && !current.ismenuActive && old.ismenuActive);
}
onStart
{
    vars.chapter = 0;
    vars.segment = 0;
    vars.scanStartedFlg = false;
    vars.inPhase4Time = TimeSpan.Zero;
    vars.split_3_13_flg = false;

    print("-- start --");
}

// Reset when select Chapter0-0 at the chapter selection menu
reset
{
    if(current.chapter == 0 && current.segment == 0
       && current.ismenuActive && !current.isGameMode)
    {
        print("-- reset --");
        return true;
    }
}

// Split when changes Chapter or Segment
split
{
    if(!current.ismenuActive)
    {
        if(current.segment != old.segment || current.chapter != old.chapter)
        {
            print("vars : " + vars.chapter + "-" + vars.segment);
            print("game : " + current.chapter + "-" + current.segment);
        }
    }

    // when change Segment
    if(current.isGameMode && current.segment != old.segment) 
    {
        if(current.segment > vars.segment)
        {
            if(settings[vars.chapter.ToString() + "-" + vars.segment.ToString()])
                return true;
        }
    }

    // when change Chapter
    if(current.isGameMode && current.chapter != old.chapter) 
    {
        if(current.chapter > vars.chapter)
        {
            if(settings["chapter" + vars.chapter.ToString()])
                return true;
        }
    }
    
    // Boss
    if(current.isGameMode && current.chapter == 3 &&
       current.segment == 12 && !vars.threadScan.IsAlive)
    {
        // phase 3 to 4 , when hit the final attack to the boss
        // timer stop at hero not able to move
        // and it 0.5 sec after from the final attack
        if(vars.phase.Current == 4 && vars.phase.Old == 3)
        {
            vars.inPhase4Time = timer.CurrentTime.RealTime ?? TimeSpan.Zero;
            print("-- beat the Boss --");
        }
        
        if(vars.inPhase4Time.Milliseconds > 0 && !vars.split_3_13_flg)
        {
            TimeSpan timeCnt = (timer.CurrentTime.RealTime ?? TimeSpan.Zero)
                               - vars.inPhase4Time;
            // print("timeCnt : " + timeCnt.Milliseconds);
            if(timeCnt.Milliseconds >= 500)
            {
                vars.split_3_13_flg = true;
                
                if(settings["chapter" + vars.chapter.ToString()])
                    return true;
            }
        }
    }
}
onSplit
{
    // when change Segment
    if(current.segment > vars.segment)
    {
        vars.chapter = current.chapter;
        vars.segment = current.segment;
        print("vars : " + vars.chapter + "-" + vars.segment);
        print("-- segment --");
    }

    // when change Chapter
    if(current.chapter > vars.chapter)
    {
        vars.chapter = current.chapter;
        vars.segment = 0;
        print("vars : " + vars.chapter + "-" + vars.segment);
        print("-- chapter --");
    }

    print("-- split --");
}

// ------------------------------------------------------------ //
//             EOF
// ------------------------------------------------------------ //
