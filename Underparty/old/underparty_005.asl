// ver.005

// ------------------------------------------------------------ //
// 			Initialization
// ------------------------------------------------------------ //

state("Underparty", "v.1.1.6 D7")
{
	// memSize : 847872
}

startup
{
	// sig scan target

	// Platformer.MainMenuManager.Awake()+b8
	// Main Menu depth
	// Main Menu select
	vars.scanTargetMainMenu = new SigScanTarget(0x1, 
		"B8 ?? ?? ?? ?? 89 38 C6 87 ?? ?? ?? ?? 01 8D 45 9C 89 04 24"
	);
	
	// Platformer.UIManager.Awake()+500
	// HP
	// BossGaugeExist
	// BossHP
	vars.scanTargetUIM = new SigScanTarget(0x2, 
		"8B 05 ?? ?? ?? ?? 89 04 24 39 00 E8 ?? ?? ?? ?? 8D 65 F8"
	);
	
	// MasterScript.Awake()+b
	// nowPause
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
	
	if (ptrMainMenu == IntPtr.Zero)
	{
		Thread.Sleep(1000);
		print("-- Sig scan in init fail --");
		throw new Exception();
	}
	else
	{
		print("-- Sig scan in init success --");

		vars.mainMenuDepth = new MemoryWatcher<int>(new DeepPointer(ptrMainMenu, 0x0, 0x90));
		vars.mainMenuSelect = new MemoryWatcher<int>(new DeepPointer(ptrMainMenu, 0x0, 0xa8));
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
				vars.hp = new MemoryWatcher<float>(new DeepPointer(ptrUIM, 0x0, 0x1b0));
				vars.bossExist = new MemoryWatcher<bool>(new DeepPointer(ptrUIM, 0x0, 0x1c8));
				vars.bossHp = new MemoryWatcher<float>(new DeepPointer(ptrUIM, 0x0, 0x1cc));
				vars.bullet = new MemoryWatcher<int>(new DeepPointer(ptrUIM, 0x0, 0x1c4));

				vars.nowPause = new MemoryWatcher<bool>(new DeepPointer(ptrMasterScript, 0x0, 0x8a));

				vars.watchersInGame = new MemoryWatcherList()
				{
					vars.hp,
					vars.bullet,
					vars.bossExist,
					vars.bossHp,
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
	vars.loadCoolDown = 0;
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
	
	// ロード直後のsplit制御用
	if (vars.mainMenuDepth.Current == 1 && vars.mainMenuSelect.Current == 1 && vars.mainMenuSelect.Old == 0)
		vars.loadCoolDown = 60*2;
	
	// DEBUG
	if (false)
	{
		print("-- mem watcher --");
		print("depth : " + vars.mainMenuDepth.Current);
		print("select : " + vars.mainMenuSelect.Current);
		print("nowPause : " + vars.nowPause.Current);
		
		if (!vars.threadScan.IsAlive)
		{
			print("-- mem watcher in game --");
			print("Hp : " + vars.hp.Current);
			print("bossExist : " + vars.bossExist.Current);
			print("bossHp : " + vars.bossHp.Current);
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
	// ロード直後はsplit無効
	if (vars.loadCoolDown > 0)
	{
		vars.loadCoolDown--;
		print("cool dows : " + vars.loadCoolDown);
		return false;
	}

	if(!vars.bossExist.Current && vars.bossExist.Old)
	{
		if(vars.hp.Current > 0 && !vars.nowPause.Current)
		{
			print("==================== split ====================");
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
