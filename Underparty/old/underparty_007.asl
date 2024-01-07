// ver.007

// ------------------------------------------------------------ //
// 			Initialization
// ------------------------------------------------------------ //
// PlayTime の取得に失敗している
// 一応動きはするが、本来64bitのポインタを32bitと見なしているため
// 常に正しい参照ができるとは限らない
// 現状、実用上動作する最新版は006


state("Underparty", "v.1.1.6 D7")
{
	// memSize : 847872
}

startup
{
	// note
	settings.Add("info", false, "Show ready to Split to the Text Component.");
	settings.SetToolTip("info", "Add the Text Component if this setting cheked.");
	
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
	
	// SAVE.SaveSlot_AllData()+7b 0x2, 0x0
	// 0x8 SaveData 0x8
	//  0x10 Slot0
	//  0x14 Slot1
	//  0x18 Slot2
	//   0x88 DeathCnt
	//   0x8c HitsCnt
	//   0x90 PlalyTime float sec
	//   0x94 killCnt
	vars.scanTargetSave = new SigScanTarget(0x2, 
		"8B 05 ?? ?? ?? ?? 8B 40 08 8B 4D 08 39 48 0C 0F 86 ?? ?? ?? ?? 8D 44 88 10 8B 00 85 C0"
	);
	
	// for info
	vars.tcss = new List<System.Windows.Forms.UserControl>();
	foreach (LiveSplit.UI.Components.IComponent component in timer.Layout.Components) {
		if (component.GetType().Name == "TextComponent")
		{
			vars.tc = component;
			vars.tcss.Add(vars.tc.Settings);
			print("-- Found text component at " + component);
		}
	}
	print("-- *Found " + vars.tcss.Count.ToString() + " text component(s)*");
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
		IntPtr ptrSave = IntPtr.Zero;
		
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
				
				if (ptrSave == IntPtr.Zero && 
					(ptrSave = scanner.Scan(vars.scanTargetSave)) != IntPtr.Zero
				)
					print("ptrSave : " + ptrSave.ToString("x"));
					
				if (ptrUIM != IntPtr.Zero && 
					ptrMasterScript != IntPtr.Zero && 
					ptrSave != IntPtr.Zero
				)
					break;
			}
			
			if (ptrUIM != IntPtr.Zero && 
				ptrMasterScript != IntPtr.Zero && 
				ptrSave != IntPtr.Zero
			)
			{
				vars.hp = new MemoryWatcher<float>(new DeepPointer(ptrUIM, 0x0, 0x1b0));
				vars.bossExist = new MemoryWatcher<bool>(new DeepPointer(ptrUIM, 0x0, 0x1c8));
				vars.bossHp = new MemoryWatcher<float>(new DeepPointer(ptrUIM, 0x0, 0x1cc));
				vars.bullet = new MemoryWatcher<int>(new DeepPointer(ptrUIM, 0x0, 0x1c4));

				vars.nowGameOver = new MemoryWatcher<bool>(new DeepPointer(ptrMasterScript, 0x0, 0x8a));
				vars.nowPause = new MemoryWatcher<bool>(new DeepPointer(ptrMasterScript, 0x0, 0x8a));

				vars.playTime = new MemoryWatcher[3];
				vars.playTime[0] = new MemoryWatcher<float>(new DeepPointer(ptrSave, DeepPointer.DerefType.Bit32, 0x0, 0x8, 0x10, 0x90));
				vars.playTime[1] = new MemoryWatcher<float>(new DeepPointer(ptrSave, DeepPointer.DerefType.Bit32, 0x0, 0x8, 0x14, 0x90));
				vars.playTime[2] = new MemoryWatcher<float>(new DeepPointer(ptrSave, DeepPointer.DerefType.Bit32, 0x0, 0x8, 0x18, 0x90));
				
				vars.watchersInGame = new MemoryWatcherList()
				{
					vars.hp,
					vars.bullet,
					vars.bossExist,
					vars.bossHp,
					vars.nowGameOver,
					vars.nowPause,
					vars.playTime[0],
					vars.playTime[1],
					vars.playTime[2]
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
	vars.slot = -1; // current save slot
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
	
	// save slot の特定
	if (!vars.threadScan.IsAlive && vars.slot == -1)
	{
		for (int i = 0; i < 3; i++)
		{
			if (vars.playTime[i].Current > vars.playTime[i].Old)
			{
				vars.slot = i;
				break;
			}
		}
	}
	
	// ロード直後のsplit制御用
	if (vars.mainMenuDepth.Current == 1 && vars.mainMenuSelect.Current == 1 && vars.mainMenuSelect.Old == 0)
		vars.loadCoolDown = 60*2;
	
	// DEBUG
	if (false)
	{
		print("-- mem watcher --");
		print("depth : " + vars.mainMenuDepth.Current);
		print("select : " + vars.mainMenuSelect.Current);
	}
	if (false && !vars.threadScan.IsAlive)
	{
		print("-- mem watcher in game --");
		print("Hp : " + vars.hp.Current);
		print("bossExist : " + vars.bossExist.Current);
		print("bossHp : " + vars.bossHp.Current);
		print("nowGameOver : " + vars.nowGameOver.Current);
		print("nowPause : " + vars.nowPause.Current);
	}
	if (true && !vars.threadScan.IsAlive)
	{
		print("-- mem watcher save data --");
		print("slot : " + vars.slot);
		print("playTime[0] : " + vars.playTime[0].Current);
		print("playTime[1] : " + vars.playTime[1].Current);
		print("playTime[2] : " + vars.playTime[2].Current);
	}

	// show info
	string lavel = "Leady to Split";
	
	bool flg = !vars.threadScan.IsAlive;
	string value = flg.ToString();
	
	if (vars.tcss.Count > 0 && settings["info"])
	{
		vars.tcss[0].Text1 = lavel;
		vars.tcss[0].Text2 = value;
	}
	else
	{
		print(lavel + " : " + value);
	}
}

// Start : Select Difficulty at Main Menu
start
{
    if (vars.mainMenuDepth.Current == 6 && vars.mainMenuDepth.Old != 1 && vars.mainMenuSelect.Current == 1 && vars.mainMenuSelect.Old == 0)
    {
		print("==================== start ====================");
		vars.slot = -1;
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
		vars.slot = -1;
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

	if (!vars.bossExist.Current && vars.bossExist.Old)
	{
		if(!vars.nowGameOver.Current && !vars.nowPause.Current)
		{
			print("==================== split ====================");
			return true;
		}
	}
	
	if (settings["stop"] && timer.CurrentSplitIndex == (timer.Run.Count() - 1))
	{
		if (timer.Run.Count() > 1)
		{
			TimeSpan ts = (timer.CurrentTime.RealTime - timer.Run[timer.Run.Count() - 2].SplitTime.RealTime) ?? TimeSpan.Zero;
			print("ts : " + ts.TotalMilliseconds.ToString());
			if (ts.TotalMilliseconds >= 33030)
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

isLoading
{
	return true;
}
gameTime
{
	if (vars.slot != -1)
	{
		return TimeSpan.FromSeconds(vars.playTime[vars.slot].Current);
	}
	return TimeSpan.Zero;
}

// ------------------------------------------------------------ //
// 			EOF
// ------------------------------------------------------------ //
