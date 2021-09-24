#Author: Michael Myerson mlmyerson@gmail.com
#Last Updated 20111122
#Dev Details: developed on windows 7 using powershell 2.0, tweaked some code from http://zokoloco.blogspot.com/2011/03/key-logger-for-special-project-using.html
#What is it?: Run this program as a background process in Windows. When you press the key-combination for a given command, it will execute the command regardless of focus. Uses user32.dll and other
#	LL goodness. Enjoy
#Extra Notes: the numbers 75 and 76 are virtual key codes for k and l respectively
#Feel free to use for whatever open-source stuff you do, make sure you include the most recent GNU GPL and give me credit where you use my code
#Special thanks to Mr. Braitmaiere for the code

$signature = @'
[DllImport("user32.dll", CharSet=CharSet.Auto, ExactSpelling=true)]
public static extern short GetKeyState(int virtualKeyCode);
'@
$getKeyState = Add-Type –memberDefinition $signature -name “Win32GetKeyState” -namespace Win32Functions –passThru
$capsToggle = [console]::capslock
$numToggle = [console]::numberlock
$shell = new-object -com wscript.shell

$charCheck = @{75 = 0; 76 = 0} #first value is virtual key code, second value is last keyPress state
$hashChange = $charCheck
$cmdLength = 8
$waitTime = 250
$exit = "false"
$active = "true"


Function Initialize ()
{
	#set capslock and numlock to off if on
	if ($capstoggle -eq "True")
	{
		$shell.sendkeys("{CAPSLOCK}")
	}

	# if ($numToggle -eq "True")
	# {
		# $shell.sendkeys("{NUMLOCK}")
	# }
	
	#caps lock blinks three times, script is started
	for ($i = 0; $i -lt 6; $i++)
	{
		$shell.sendkeys("{CAPSLOCK}")
		start-sleep -m $waitTime
	}
}

Function Input ( )
{
	$userin = ""

	while ($userin.length -lt $cmdLength)
	{
		foreach ($vkey in $($charCheck.keys))
		{
			$check = $getKeyState::GetKeyState($vkey) -band 0x01 
			
			if ($check -ne $charCheck.get_item($vkey))
			{
				$userin += [char]$vkey
			}
			
			$hashChange.set_item($vkey, $check)
		}
		
		$charCheck = $hashChange
	}
	
	$userin
}

#interpret a command
Function PerformCommand ($command, $isActive)
{	
	#active commands, only run if $active = "true"
	if ($isActive -eq "true")
	{
		switch ($command)
		{
			############SYSTEM COMMANDS#################
			#reset
			kkkkkkkk
			{ 
				$shell.sendkeys("{CAPSLOCK}")
				start-sleep -m $waitTime
				$shell.sendkeys("{CAPSLOCK}")
			}
		
			#de/activate
			lklklklk { 1 }
			############################################
			
			#calculator
			kkkkkkkl
			{
				calc
			}
			
			#notepad
			kkkkkklk
			{
				notepad
			}
			
			kkkkkkll
			#open browser
			{
				Invoke-Item C:\Users\Michael\AppData\Local\Google\Chrome\Application\chrome.exe
			}
			
			#exit
			llllllll { 2 }
		}
	}
	else
	{
		switch ($command)
		{
			#reset
			kkkkkkkk
			{ 
				$shell.sendkeys("{CAPSLOCK}")
				start-sleep -m $waitTime
				$shell.sendkeys("{CAPSLOCK}")
			}
			
			#exit
			lklklklk { 1 }
		}
	}
	
	#immutable commands, can be activated at any time
	switch ($command)
	{
		#reset
		kkkkkkkk
		{ 
			$shell.sendkeys("{CAPSLOCK}")
			start-sleep -m $waitTime
			$shell.sendkeys("{CAPSLOCK}")
		}
		
		#de/activate
		lklklklk { "active" }
	}
}

Initialize

#execution loop: input, process, output : until exit
while ($exit -ne "true")
{
	$commandBlock = Input
	$metaCmd = PerformCommand $commandBlock $active
	
	switch ($metaCmd)
	{
		1 { $active = !$active }
		2 { $exit = !$exit }
	}
	
	$metaCmd = ""
}
