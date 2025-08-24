// ver.1.1.3

// ------------------------------------------------------------ //
//             Initialization
// ------------------------------------------------------------ //

state("Typoman", "ver1.10")
{
    // memSize : 23171072
    int chapter:        "Typoman.exe", 0x0135A9E0, 0xC, 0x10, 0x98, 0xD8, 0x40;
    int segment:        "Typoman.exe", 0x0135A9E0, 0xC, 0x10, 0x98, 0xD8, 0x44;
    bool isMenuActive:  "Typoman.exe", 0x0140DDE8, 0x8, 0x8, 0x10, 0x20, 0x29;
    bool isGameMode:    "Typoman.exe", 0x0140DDE8, 0x8, 0x10, 0x20, 0x384;
    int bossPhase:      "Typoman.exe", 0x0135A9E0, 0xC, 0x388, 0x98, 0x450, 0x108;
    bool forceRuinning: "Typoman.exe", 0x0135A9E0, 0xC, 0x388, 0x98, 0x450, 0x18, 0x485;
}
state("Typoman", "ver1.12")
{
    // memSize : 671744
    int chapter:        "UnityPlayer.dll", 0x0145F2D8, 0x150, 0x1D8, 0x0, 0x18, 0x40;
    int segment:        "UnityPlayer.dll", 0x0145F2D8, 0x150, 0x1D8, 0x0, 0x18, 0x44;
    bool isMenuActive:  "UnityPlayer.dll", 0x0145F2D8, 0x150, 0x1D8, 0x0, 0x18, 0x1;
    bool isGameMode:    "UnityPlayer.dll", 0x0145F2D8, 0x150, 0x1D8, 0x384;
    int bossPhase:      "UnityPlayer.dll", 0x0145F2D8, 0x150, 0x1D8, 0x20, 0x0, 0x18, 0x108;
    bool forceRuinning: "UnityPlayer.dll", 0x0145F2D8, 0x150, 0x1D8, 0x20, 0x0, 0x18, 0x18, 0x48D;
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
}

init
{
    print("ModuleMemorySize : " + modules.First().ModuleMemorySize.ToString());
    switch (modules.First().ModuleMemorySize)
    {
        case 23171072:
            version = "ver1.10";
            break;
        case 671744:
            version = "ver1.12";
            break;
        default:
            version = "";
            break;
    }

    // vars init
    vars.chapter = 0;
    vars.segment = 0;
}

// ------------------------------------------------------------ //
//             Action
// ------------------------------------------------------------ //

update
{
    if (version == "")
        return false;

    // Move from menu screen to game screen
    if(!current.isMenuActive && current.isGameMode && !old.isGameMode)
    {
        vars.chapter = current.chapter;
        vars.segment = current.segment;
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
       && !current.isMenuActive && old.isMenuActive);
}
onStart
{
    vars.chapter = 0;
    vars.segment = 0;

    print("-- start --");
}

// Reset when select Chapter0-0 at the chapter selection menu
reset
{
    if(current.chapter == 0 && current.segment == 0
       && current.isMenuActive && !current.isGameMode)
    {
        print("-- reset --");
        return true;
    }
}

// Split when changes Chapter or Segment
split
{
    if(!current.isMenuActive)
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
    if(current.bossPhase == 4)
    {
        if(old.bossPhase == 3)
        {
            print("-- beat the Boss --");
        }
        
        if(current.forceRuinning && !old.forceRuinning)
        {
            if(settings["chapter" + vars.chapter.ToString()])
                return true;
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
