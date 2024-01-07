// ver.002

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
			ptr = scanner.Scan(vars.scanTargetUIM);
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
	
	vars.bullet = new MemoryWatcher<int>((IntPtr)addr2 + 0x1c4); // Ç±ÇÍÇÕOK
	
	DeepPointer dp;
	dp = new DeepPointer(ptr, 0x0);
	IntPtr p;
	dp.Deref<IntPtr>(game, out p);
	print("dp : " +p.ToString("x"));
	dp = new DeepPointer(ptr, 0x0, 0x1c4);
	vars.bullet2 = new MemoryWatcher<int>(dp);
	
	// var ptr2 = (ptr - modules.First().BaseAddress.ToInt32()).ToInt32();
	// print("ptr2 : " + ptr2.ToString("x"));
	// vars.bullet2 = new MemoryWatcher<int>(new DeepPointer(ptr2, 0x1c4)); // Ç±ÇÍÇÕÉ_ÉÅ
	print("-- mem wather in init--");
	print("bullet : " + vars.bullet.Current);
	print("bullet2 : " + vars.bullet2.Current);
	
	vars.watchers = new MemoryWatcherList()
	{
		vars.bullet,
		vars.bullet2
	};

	vars.startFlg = false;
	vars.resetFlg = false;
	vars.splitFlg = false;
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
		print("bullet : " + vars.bullet.Current);
		print("bullet2 : " + vars.bullet2.Current);
	}

	vars.startFlg = false;
	vars.resetFlg = false;
	vars.splitFlg = false;
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
