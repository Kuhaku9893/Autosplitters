// ver.004

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
	
	// Sig scan thread
	// Bloodroots.asl を参考にしているが、メモリウォッチャーの部分がまだちょっと違う
	vars.tokenSource = new CancellationTokenSource();
	vars.token = vars.tokenSource.Token;
	vars.threadScan = new Thread(() =>
	{
		// Platformer.MainMenuManager.Awake()+b8
		SigScanTarget scanTargetMainMenu = new SigScanTarget(0x1, 
			"B8 ?? ?? ?? ?? 89 38 C6 87 ?? ?? ?? ?? 01 8D 45 9C 89 04 24"
		);
		
		// Platformer.UIManager.Awake()+500
		SigScanTarget scanTargetUIM = new SigScanTarget(0x2, 
			"8B 05 ?? ?? ?? ?? 89 04 24 39 00 E8 ?? ?? ?? ?? 8D 65 F8"
		);
		
		// MasterScript.Awake()+b
		SigScanTarget scanTargetMasterScript = new SigScanTarget(0x1, 
			"B8 ?? ?? ?? ?? 89 38 33 F6 EB 27 8B C0"
		);
		
		IntPtr ptrMainMenu = IntPtr.Zero;
		IntPtr ptrUIM = IntPtr.Zero;
		IntPtr ptrMasterScript = IntPtr.Zero;
		
		while (!vars.token.IsCancellationRequested)
		{
			print("[asl] Sig Scan");
			foreach (var page in game.MemoryPages())
			{
				var scanner = new SignatureScanner(game, page.BaseAddress, (int)page.RegionSize);
				
				if (ptrMainMenu == IntPtr.Zero && 
					(ptrMainMenu = scanner.Scan(scanTargetMainMenu)) != IntPtr.Zero
				)
					print("MainMenu Found : " + ptrMainMenu.ToString("x"));

				if (ptrUIM == IntPtr.Zero && 
					(ptrUIM = scanner.Scan(scanTargetUIM)) != IntPtr.Zero
				)
					print("UIManager Found : " + ptrUIM.ToString("x"));

				if (ptrMasterScript == IntPtr.Zero && 
					(ptrMasterScript = scanner.Scan(scanTargetMasterScript)) != IntPtr.Zero
				)
					print("MasterScript Found : " + ptrMasterScript.ToString("x"));
				
				if (ptrMainMenu != IntPtr.Zero &&
					ptrUIM != IntPtr.Zero &&
					ptrMasterScript != IntPtr.Zero
				)
					break;
			}
			
			// MainMenuManager
			if (ptrMainMenu != IntPtr.Zero)
			{
				vars.mainMenuDepth = new MemoryWatcher<int>(new DeepPointer(ptrMainMenu, 0x0, 0x90));
				vars.mainMenuSelect = new MemoryWatcher<int>(new DeepPointer(ptrMainMenu, 0x0, 0xa8));
			}
			
			// UIManager
			if (ptrUIM != IntPtr.Zero)
			{
				vars.hp = new MemoryWatcher<float>(new DeepPointer(ptrUIM, 0x0, 0x1b0));
				vars.bossExist = new MemoryWatcher<bool>(new DeepPointer(ptrUIM, 0x0, 0x1c8));
				vars.bossHp = new MemoryWatcher<float>(new DeepPointer(ptrUIM, 0x0, 0x1cc));
				vars.bullet = new MemoryWatcher<int>(new DeepPointer(ptrUIM, 0x0, 0x1c4));
			}
			
			// MasterScript
			if (ptrMasterScript != IntPtr.Zero)
			{
				vars.nowPause = new MemoryWatcher<bool>(new DeepPointer(ptrMasterScript, 0x0, 0x8a));
			}
			
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
			
			Thread.Sleep(1000);
		}
		print("[asl] Exit thread scan");
	});
	vars.threadScan.Start();
}

// ------------------------------------------------------------ //
// 			Action
// ------------------------------------------------------------ //

update
{
	if (version == "ver unknown")
		return false;
	
	if (vars.threadScan.IsAlive)
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
