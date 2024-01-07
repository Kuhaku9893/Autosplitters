// ver.003

// ------------------------------------------------------------ //
// 			Initialization
// ------------------------------------------------------------ //

state("Underparty", "v.1.1.6 D7")
{
	// memSize : 847872
}

startup
{
	// sig scan
	
	// Platformer.MainMenuManager.Awake()+b8
	vars.scanTargetMainMenu = new SigScanTarget(1, 
		"B8 ?? ?? ?? ?? 89 38 C6 87 ?? ?? ?? ?? 01 8D 45 9C 89 04 24"
	);
	
	// Platformer.UIManager.Awake()+500
	vars.scanTargetUIM = new SigScanTarget(2, 
		"8B 05 ?? ?? ?? ?? 89 04 24 39 00 E8 ?? ?? ?? ?? 8D 65 F8"
	);
	
	// MasterScript.Awake()+b
	vars.scanTargetMasterScript = new SigScanTarget(1, 
		"B8 ?? ?? ?? ?? 89 38 33 F6 EB 27 8B C0"
	);
}

init
{
	var module = modules.First();
	vars.gameVer = "ver unknown";
	print("ModuleMemorySize : " + module.ModuleMemorySize.ToString());
	switch (module.ModuleMemorySize)
	{
		case 847872:
			version = "v.1.1.6 D7";
			vars.gameVer = version;
			break;
		default:
			break;
	}
	
	// Sig scan
	IntPtr ptrMainMenu = IntPtr.Zero;
	IntPtr ptrUIM = IntPtr.Zero;
	IntPtr ptrMasterScript = IntPtr.Zero;
	foreach (var page in game.MemoryPages(true).Reverse())
	{
		var scanner = new SignatureScanner(game, page.BaseAddress, (int)page.RegionSize);
		
		if (ptrMainMenu == IntPtr.Zero)
			ptrMainMenu = scanner.Scan(vars.scanTargetMainMenu);

		if (ptrUIM == IntPtr.Zero)
			ptrUIM = scanner.Scan(vars.scanTargetUIM);
		
		if (ptrMasterScript == IntPtr.Zero)
			ptrMasterScript = scanner.Scan(vars.scanTargetMasterScript);
		
		if (ptrMainMenu != IntPtr.Zero && ptrUIM != IntPtr.Zero && ptrMasterScript != IntPtr.Zero)
			break;
	}
	
	// MainMenuManager
	if (ptrMainMenu == IntPtr.Zero)
	{
		Thread.Sleep(1000);
		print("-- Sig scan fail --");
		print("ptrMainMenu : " + ptrMainMenu.ToString("x"));
		throw new Exception();
	}
	else
	{
		print("-- Sig scan success --");
		print("ptrMainMenu : " + ptrMainMenu.ToString("x"));

		vars.mainMenuDepth = new MemoryWatcher<int>(new DeepPointer(ptrMainMenu, 0x0, 0x90));
		vars.mainMenuSelect = new MemoryWatcher<int>(new DeepPointer(ptrMainMenu, 0x0, 0xa8));
	}
	
	// UIManager
	if (ptrUIM == IntPtr.Zero)
	{
		Thread.Sleep(1000);
		print("-- Sig scan fail --");
		print("ptrUIM : " + ptrUIM.ToString("x"));
		throw new Exception();
	}
	else
	{
		print("-- Sig scan success --");
		print("ptrUIM : " + ptrUIM.ToString("x"));

		vars.hp = new MemoryWatcher<float>(new DeepPointer(ptrUIM, 0x0, 0x1b0));
		vars.bossExist = new MemoryWatcher<bool>(new DeepPointer(ptrUIM, 0x0, 0x1c8));
		vars.bossHp = new MemoryWatcher<float>(new DeepPointer(ptrUIM, 0x0, 0x1cc));
		vars.bullet = new MemoryWatcher<int>(new DeepPointer(ptrUIM, 0x0, 0x1c4));
	}

	// MasterScript
	if (ptrMasterScript == IntPtr.Zero)
	{
		Thread.Sleep(1000);
		print("-- MasterScript Sig scan fail --");
		print("ptrMasterScript : " + ptrMasterScript.ToString("x"));
		throw new Exception();
	}
	else
	{
		print("-- MasterScript Sig scan success --");
		print("ptrMainMenu : " + ptrMainMenu.ToString("x"));

		vars.nowPause = new MemoryWatcher<bool>(new DeepPointer(ptrMasterScript, 0x0, 0x8a));
	}
	
	print("-- mem wather in init--");
	print("depth : " + vars.mainMenuDepth.Current);
	print("select : " + vars.mainMenuSelect.Current);
	print("Hp : " + vars.hp.Current);
	print("bullet : " + vars.bullet.Current);
	print("bossExist : " + vars.bossExist.Current);
	print("bossHp : " + vars.bossHp.Current);
	print("nowPause : " + vars.nowPause.Current);
	
	vars.watchers = new MemoryWatcherList()
	{
		vars.mainMenuDepth,
		vars.mainMenuSelect,
		vars.hp,
		vars.bullet,
		vars.bossExist,
		vars.bossHp,
		vars.nowPause
	};
}

// ------------------------------------------------------------ //
// 			Action
// ------------------------------------------------------------ //

update
{
	if (version == "ver unknown")
		return false;
	
	vars.watchers.UpdateAll(game);
	if (false)
	{
		print("-- mem wather --");
		print("depth : " + vars.mainMenuDepth.Current);
		print("select : " + vars.mainMenuSelect.Current);
		print("Hp : " + vars.hp.Current);
		print("bossExist : " + vars.bossExist.Current);
		print("bossHp : " + vars.bossHp.Current);
		print("nowPause : " + vars.nowPause.Current);
	}
}

// Start : Select Difficulty at Main Menu
start
{
    if(vars.mainMenuDepth.Current == 6 && vars.mainMenuDepth.Old != 1 && vars.mainMenuSelect.Current == 1 && vars.mainMenuSelect.Old == 0)
    {
		print("-- start --");
		return true;
    }
	return false;
}

// Reset : Return to Select Difficulty Menu
reset
{
	if(vars.mainMenuDepth.Current == 6 && vars.mainMenuDepth.Old == 1)
	{
		print("-- reset --");
		return true;
	}
	return false;
}

// Split : Defeat each Boss
split
{
	if(!vars.bossExist.Current && vars.bossExist.Old)
	{
		if(vars.hp.Current > 0 && !vars.nowPause.Current)
		{
			print("-- change subChap --");
			return true;
		}
	}
	return false;
}

// ------------------------------------------------------------ //
// 			EOF
// ------------------------------------------------------------ //
