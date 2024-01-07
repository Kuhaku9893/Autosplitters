state("Marufusha", "ver1.0.0.2")
{
    // memSize : 667648
}

startup
{
	// settings
	for (int index = 1; index < 10; ++index)
	{
		settings.Add("day" + (index * 10).ToString(), true, "Day " + (index * 10).ToString());
	}

    // init for start
    vars.ResetVars = (EventHandler)((s, e) => {
        vars.oldDay = 0;
        vars.currentDay = 0;
    });
    timer.OnStart += vars.ResetVars;
}

init
{
	// ver check
    var module = modules.First();
	print("ModuleMemorySize : " + module.ModuleMemorySize.ToString());
    switch (module.ModuleMemorySize)
	{
		case 667648:
			version = "ver1.0.0.2";
			break;
		default:
        	version = "ver unknown";
			break;
	}

    // for init
    vars.oldDay = 0;
    vars.currentDay = 0;

    vars.oldSalary = 0;
}

update
{
    // vars.needStart = false;
    vars.needSplit = false;
    vars.needReset = false;

    using(Microsoft.Win32.RegistryKey regKey = Microsoft.Win32.Registry.CurrentUser.OpenSubKey(@"Software\hinyari9\Marufusha"))
    {
        int salary = 0;
        int level = 0;
        int stage = 0;

        foreach (string name in regKey.GetValueNames())
        {
            if (name.StartsWith("basicSalary_"))
            {
                try
                {
                    salary = (int)regKey.GetValue(name);
                }
                catch (System.Exception)
                {
                    continue;
                }
                // print("salary : " + salary.ToString());
            }
            if (name.StartsWith("Level_"))
            {
                try
                {
                    level = (int)regKey.GetValue(name);
                }
                catch (System.Exception)
                {
                    continue;
                }
                // print("level : " + level.ToString());
            }
            if (name.StartsWith("stage_"))
            {
                try
                {
                    stage = (int)regKey.GetValue(name);
                }
                catch (System.Exception)
                {
                    continue;
                }
                // print("stage : " + stage.ToString());
            }
        } // end foreach
        
        if (salary < vars.oldSalary)
        {
            vars.needReset = true;
        }
        vars.oldSalary = salary;

        int day = 0;
        int oldday = 0;

        int tempDay = (stage - 1) * 40 + level;
        if (vars.currentDay < tempDay)
        {
            vars.oldDay = vars.currentDay;
            vars.currentDay = tempDay;

            // print("day : " + tempDay.ToString());
        }
        else
        {
            vars.oldDay = vars.currentDay;
        }

        for (int index = 1; index < 10; index++)
        {
            if (vars.currentDay == (index * 10 + 1) && vars.oldDay == (index * 10))
                vars.needSplit = settings["day" + (index * 10)];
        }

    } // end useing
}

reset
{
    return vars.needReset;
}

split
{
    return vars.needSplit;
}

shutdown
{
    timer.OnStart -= vars.ResetVars;
}