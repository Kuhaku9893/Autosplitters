// This is semi auto splitter, you should stop manualy.
// This autosplitter can start, split and reset timer.

state("Typoman", "1.10")
{
	int mainChap: "Typoman.exe", 0x0135A9E0, 0xC, 0x388, 0x98, 0xD8, 0x40;
    int subChap: "Typoman.exe", 0x0135A9E0, 0xC, 0x10, 0x98, 0xD8, 0x44;
    int notMenuFlg: "Typoman.exe", 0x0140DDE8, 0x8, 0x28, 0x20, 0x5F4;
    int isGameModeFlg: "Typoman.exe", 0x0140DDE8, 0x8, 0x48, 0x30, 0x384;
}

init
{
	refreshRate = 60;
}

start
{
    if(current.mainChap == 0 && current.subChap == 0 && current.notMenuFlg == 1 && old.notMenuFlg ==0)
    {
		return true;
    }
}

reset
{
	if(current.notMenuFlg == 0 && current.isGameModeFlg == 0)
	{
		return true;
	}
} 

split
{
	if(current.isGameModeFlg == 1 && current.subChap != old.subChap) 
	{
		return true;
	}
}

