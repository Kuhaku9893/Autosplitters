// ver.001

// ------------------------------------------------------------ //
// 			Initialization
// ------------------------------------------------------------ //

state("Underparty", "v.1.1.6 D7")
{
	// memSize : 847872
	int titleMenu: "UnityPlayer.dll", 0x012A4C5C, 0xa24, 0x1c, 0x0c, 0x18, 0x90;
	int selectMenu: "UnityPlayer.dll", 0x012A4C5C, 0xa24, 0x1c, 0x0c, 0x18, 0xa8;
}

startup
{
	// sig scan
	// Platformer.UIManager.Awake()+500
	vars.scanTargetUIM = new SigScanTarget(2, 
		"8B 05 ?? ?? ?? ?? 89 04 24 39 00 E8 ?? ?? ?? ?? 8D 65 F8"
	);
	
	// for info
	vars.tcss = new List<System.Windows.Forms.UserControl>();
	foreach (LiveSplit.UI.Components.IComponent component in timer.Layout.Components) {
		if (component.GetType().Name == "TextComponent")
		{
			vars.tc = component;
			vars.tcss.Add(vars.tc.Settings);
			print("[ASL] Found text component at " + component);
		}
	}
	print("[ASL] *Found " + vars.tcss.Count.ToString() + " text component(s)*");

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
	
	var ptr = IntPtr.Zero;
	foreach (var page in game.MemoryPages(true).Reverse())
	{
		var scanner = new SignatureScanner(game, page.BaseAddress, (int)page.RegionSize);
		
		if (ptr == IntPtr.Zero)
			ptr = scanner.Scan(vars.scanTarget);
		else
			break;
	}
	
	if (ptr == IntPtr.Zero)
	{
		Thread.Sleep(1000);
		print("ptr == IntPtr.Zero");
		throw new Exception();
	}
	else
	{
		print("ptr : " + ptr.ToString("x"));
	}
	var addr = BitConverter.ToInt32(game.ReadBytes(ptr, 4), 0);
	print("addr : " + addr.ToString("x"));
	var addr2 = BitConverter.ToInt32(game.ReadBytes((IntPtr)addr, 4), 0);
	print("addr2 : " + addr2.ToString("x"));
	var addr3 = BitConverter.ToInt16(game.ReadBytes((IntPtr)addr2 + 0x1c4, 2), 0);
	print("addr3 : " + addr3.ToString());
	
	vars.hp = new MemoryWatcher<float>((IntPtr)addr2 + 0x1b0);
	vars.bossExist = new MemoryWatcher<bool>((IntPtr)addr2 + 0x1c8);
	vars.bossHp = new MemoryWatcher<float>((IntPtr)addr2 + 0x1cc);
	vars.bossHpRed = new MemoryWatcher<float>((IntPtr)addr2 + 0x1d0);
	vars.bullet = new MemoryWatcher<int>((IntPtr)addr2 + 0x1c4); // これはOK
	// vars.bullet2 = new MemoryWatcher<int>(new DeepPointer(ptr, 0x1c4)); // これはダメ
	print("-- mem wather in init--");
	print("Hp : " + vars.hp.Current);
	print("bullet : " + vars.bullet.Current);
	print("bossExist : " + vars.bossExist.Current);
	print("bossHp : " + vars.bossHp.Current);
	print("bossHpRed : " + vars.bossHpRed.Current);
	
	vars.watchers = new MemoryWatcherList()
	{
		vars.hp,
		vars.bossExist,
		vars.bossHp,
		vars.bossHpRed,
		vars.bullet
	};

	vars.startFlg = false;
	vars.resetFlg = false;
	vars.splitFlg = false;
	vars.infoRefreshFlg = false;
	// vars.scanFlg = false;
}

// ------------------------------------------------------------ //
// 			Action
// ------------------------------------------------------------ //

update
{
	if (version == "ver unknown")
		return false;
	
	if (current.titleMenu == 1 && old.titleMenu == 0)
	{
		print("-- scan in update--");
		var ptr = IntPtr.Zero;
		foreach (var page in game.MemoryPages(true).Reverse())
		{
			var scanner = new SignatureScanner(game, page.BaseAddress, (int)page.RegionSize);
			
			if (ptr == IntPtr.Zero)
				ptr = scanner.Scan(vars.scanTarget);
			else
				break;
		}
		
		if (ptr == IntPtr.Zero)
		{
			Thread.Sleep(1000);
			print("ptr == IntPtr.Zero");
			throw new Exception();
		}
		else
		{
			print("ptr : " + ptr.ToString("x"));
			// vars.scanFlg = false;
		}
		var addr = BitConverter.ToInt32(game.ReadBytes(ptr, 4), 0);
		print("addr : " + addr.ToString("x"));
		var addr2 = BitConverter.ToInt32(game.ReadBytes((IntPtr)addr, 4), 0);
		print("addr2 : " + addr2.ToString("x"));
		
		vars.hp = new MemoryWatcher<float>((IntPtr)addr2 + 0x1b0);
		vars.bossExist = new MemoryWatcher<bool>((IntPtr)addr2 + 0x1c8);
		vars.bossHp = new MemoryWatcher<float>((IntPtr)addr2 + 0x1cc);
		vars.bossHpRed = new MemoryWatcher<float>((IntPtr)addr2 + 0x1d0);
		vars.bullet = new MemoryWatcher<int>((IntPtr)addr2 + 0x1c4); // これはOK

		print("-- mem wather --");
		print("Hp : " + vars.hp.Current);
		print("bullet : " + vars.bullet.Current);
		print("bossExist : " + vars.bossExist.Current);
		print("bossHp : " + vars.bossHp.Current);
		print("bossHpRed : " + vars.bossHpRed.Current);
		
		vars.watchers = new MemoryWatcherList()
		{
			vars.hp,
			vars.bossExist,
			vars.bossHp,
			vars.bossHpRed,
			vars.bullet
		};
	}
	
	vars.watchers.UpdateAll(game);
	if (true)
	{
		print("title : " + current.titleMenu);
		print("-- mem wather --");
		print("Hp : " + vars.hp.Current);
		print("bossExist : " + vars.bossExist.Current);
		print("bossHp : " + vars.bossHp.Current);
	}

	string infoMsg = "Info";
	string subMsg1 = "Bullet";
	string subMsg2 = vars.bullet.Current.ToString();
	
	vars.startFlg = false;
	vars.resetFlg = false;
	vars.splitFlg = false;
	vars.infoRefreshFlg = false;

	// start
    if(current.titleMenu == 6 && old.titleMenu != 1 && current.selectMenu == 1 && old.selectMenu == 0)
    {
		vars.mainChap = 0;
		vars.subChap = 0;
		vars.startFlg = true;
		
		infoMsg = "-- start --";
		vars.infoRefreshFlg = true;
    }
    
    // reset
	if(current.titleMenu == 6 && old.titleMenu == 1)
	{
		vars.resetFlg = true;
		
		infoMsg = "-- reset --";
		vars.infoRefreshFlg = true;
	}
	
	// split
	if(!vars.bossExist.Current && vars.bossExist.Old)
	{
		if(vars.hp.Current > 0 /* && ポーズしていない*/)
		{
			infoMsg = "-- change subChap --";
			vars.infoRefreshFlg = true;
		}
	}

	
	// show info
	/*
	if(vars.infoRefreshFlg)
	{
		if (vars.tcss.Count > 1)
		{
			vars.tcss[0].Text1 = infoMsg;
			vars.tcss[0].Text2 = vars.gameVer;
			vars.tcss[1].Text1 = subMsg1;
			vars.tcss[1].Text2 = subMsg2;
		}
		else
		{
			print(infoMsg + " | " + vars.gameVer);
			print(subMsg1 + " | " + subMsg2);
		}
	}
	*/
}

// Start when select Difficulty at Menu
start{return vars.startFlg;}

// Reset when return to Difficulty Menu
reset{return vars.resetFlg;}

// Split when defeat each Bosses
split{return vars.splitFlg;}

// ------------------------------------------------------------ //
// 			EOF
// ------------------------------------------------------------ //
