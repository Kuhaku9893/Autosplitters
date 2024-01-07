// ver 0.0.8

// ------------------------------------------------------------ //
// 			Initialization
// ------------------------------------------------------------ //

state("Underparty", "v.1.1.6 D7")
{
	// memSize : 847872
}
state("Underparty", "v.2.0.1")
{
	// memSize : 851968
}

startup
{
	settings.Add("stop", false, "Timer stop at the Result screen.");
	settings.SetToolTip("stop", "Timer stop 33 sec after Final Boss is defeated.");
	
	// sig scan target

	// Platformer.MainMenuManager.Awake()+b8 0x1, 0x0
	// 0x90 Main Menu depth
	// 0xa8 Main Menu select
	vars.scanTargetMainMenu = new SigScanTarget(0x1, 
		"B8 ?? ?? ?? ?? 89 38 C6 87 ?? ?? ?? ?? 01 8D 45 9C 89 04 24"
	);
	
	// Platformer.UIManager.Awake()+500 0x2, 0x0
	// 0x1b0 HP
	// 0x1c4 bullet
	// 0x1c8 BossGaugeExist
	// 0x1cc BossHP
	vars.scanTargetUIM = new SigScanTarget(0x2, 
		"8B 05 ?? ?? ?? ?? 89 04 24 39 00 E8 ?? ?? ?? ?? 8D 65 F8"
	);
	
	// MasterScript.Awake()+b 0x1, 0x0
	// 0x89 nowGameOver
	// 0x8a nowPause
	vars.scanTargetMasterScript = new SigScanTarget(0x1, 
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
		case 851968:
			version = "v.2.0.1";
			vars.gameVer = version;
			break;
		default:
			break;
	}
	
	// Sig scan
	IntPtr ptrMainMenu = IntPtr.Zero;
	foreach (var page in game.MemoryPages(true).Reverse())
	{
		var scanner = new SignatureScanner(game, page.BaseAddress, (int)page.RegionSize);
		
		if (ptrMainMenu == IntPtr.Zero && 
			(ptrMainMenu = scanner.Scan(vars.scanTargetMainMenu)) != IntPtr.Zero
		)
			print("ptrMainMenu : " + ptrMainMenu.ToString("x"));

		if (ptrMainMenu != IntPtr.Zero)
			break;
	}
	
	if (ptrMainMenu != IntPtr.Zero)
	{
		print("-- Sig scan in init success --");

		vars.mainMenuDepth = new MemoryWatcher<int>(new DeepPointer(ptrMainMenu, 0x0, 0x90));
		vars.mainMenuSelect = new MemoryWatcher<int>(new DeepPointer(ptrMainMenu, 0x0, 0xa8));
	}
	else
	{
		Thread.Sleep(1000);
		throw new Exception("-- Sig scan in init fail --");
	}
	
	vars.watchers = new MemoryWatcherList()
	{
		vars.mainMenuDepth,
		vars.mainMenuSelect
	};
	
	// Sig scan thread
	vars.tokenSource = new CancellationTokenSource();
	vars.token = vars.tokenSource.Token;
	vars.threadScan = new Thread(() =>
	{
		IntPtr ptrUIM = IntPtr.Zero;
		IntPtr ptrMasterScript = IntPtr.Zero;
		
		while (!vars.token.IsCancellationRequested)
		{
			print("-- Sig scan in thread --");
			foreach (var page in game.MemoryPages())
			{
				var scanner = new SignatureScanner(game, page.BaseAddress, (int)page.RegionSize);
				
				if (ptrUIM == IntPtr.Zero && 
					(ptrUIM = scanner.Scan(vars.scanTargetUIM)) != IntPtr.Zero
				)
					print("UIManager : " + ptrUIM.ToString("x"));
				
				if (ptrMasterScript == IntPtr.Zero && 
					(ptrMasterScript = scanner.Scan(vars.scanTargetMasterScript)) != IntPtr.Zero
				)
					print("ptrMasterScript : " + ptrMasterScript.ToString("x"));
				
				if (ptrUIM != IntPtr.Zero && ptrMasterScript != IntPtr.Zero)
					break;
			}
			
			if (ptrUIM != IntPtr.Zero && ptrMasterScript != IntPtr.Zero)
			{
				vars.bossExist = new MemoryWatcher<bool>(new DeepPointer(ptrUIM, 0x0, 0x1c8));

				vars.nowGameOver = new MemoryWatcher<bool>(new DeepPointer(ptrMasterScript, 0x0, 0x89));
				vars.nowPause = new MemoryWatcher<bool>(new DeepPointer(ptrMasterScript, 0x0, 0x8a));

				vars.watchersInGame = new MemoryWatcherList()
				{
					vars.bossExist,
					vars.nowGameOver,
					vars.nowPause
				};
				print("-- Sig scan in thread done --");
				break;
			}
			Thread.Sleep(1000);
		}
		print("-- Exit thread scan --");
	});
	vars.threadScan.Start();
	
	// vars
}

// ------------------------------------------------------------ //
// 			Action
// ------------------------------------------------------------ //

update
{
	if (version == "ver unknown")
		return false;
	
	vars.watchers.UpdateAll(game);

	if (!vars.threadScan.IsAlive)
		vars.watchersInGame.UpdateAll(game);
	
	// DEBUG
	if (true)
	{
		if (vars.mainMenuDepth.Changed)
			print("depth : " + vars.mainMenuDepth.Current);
		if (vars.mainMenuSelect.Changed)
			print("select : " + vars.mainMenuSelect.Current);
		
		if (!vars.threadScan.IsAlive)
		{
			if (vars.bossExist.Changed)
				print("bossExist : " + vars.bossExist.Current);
			if (vars.nowGameOver.Changed)
				print("nowGameOver : " + vars.nowGameOver.Current);
			if (vars.nowPause.Changed)
				print("nowPause : " + vars.nowPause.Current);
		}
	}
}

// Start : Select Difficulty at Main Menu
start
{
    if (vars.mainMenuDepth.Current == 6 && vars.mainMenuDepth.Old != 1 && vars.mainMenuSelect.Current == 1 && vars.mainMenuSelect.Old == 0)
    {
		print("==================== start ====================");
		return true;
    }
	return false;
}

// Reset : Return to Select Difficulty Menu
reset
{
	if (vars.mainMenuDepth.Current == 6 && vars.mainMenuDepth.Old == 1)
	{
		print("==================== reset ====================");
		return true;
	}
	return false;
}

// Split : Defeat each Boss
split
{
	if (vars.nowGameOver.Current || vars.nowPause.Current)
		return false;
	
	// dont split at right after start and load
	if ( !vars.bossExist.Current && vars.bossExist.Old &&
		((!vars.nowPause.Current && vars.nowPause.Old) ||
		 (!vars.nowGameOver.Current && vars.nowGameOver.Old))
	)
	{
		print("just have started, don't split");
		return false;
	}

	if (!vars.bossExist.Current && vars.bossExist.Old)
	{
		print("==================== split ====================");
		return true;
	}
	
	// stop at result screen
	if (settings["stop"] && timer.CurrentSplitIndex == (timer.Run.Count() - 1))
	{
		if (timer.Run.Count() > 1)
		{
			TimeSpan ts = (timer.CurrentTime.RealTime - timer.Run[timer.Run.Count() - 2].SplitTime.RealTime) ?? TimeSpan.Zero;
			print("ts : " + ts.TotalMilliseconds.ToString());
			if (ts.TotalMilliseconds >= 33030)
			{
				print("==================== stop ====================");
				return true;
			}
		}
	}
	return false;
}

exit
{
	vars.tokenSource.Cancel();
}
shutdown
{
	vars.tokenSource.Cancel();
}

// ------------------------------------------------------------ //
// 			EOF
// ------------------------------------------------------------ //
