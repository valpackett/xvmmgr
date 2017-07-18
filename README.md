# XVMMgr [![unlicense](https://img.shields.io/badge/un-license-green.svg?style=flat)](http://unlicense.org)

![Screenshot](https://i.imgur.com/ZwqYXP1.png)

A simple tray icon program for integrating a UNIX system running on VirtualBox or Hyper-V into the Windows desktop:

- at launch, starts [VcXsrv](https://sourceforge.net/projects/vcxsrv/) (at exit, quits it)
- on left click, starts your VM if it's not started
- has a right click menu for launching X apps from the VM using `plink`

## Usage

You'll need VcXsrv, VirtualBox or Hyper-V, and PuTTY. Generate a private key with PuTTY, save it without encrypting with a password.

First, install the module:

```powershell
mkdir -Force $HOME\Documents\WindowsPowerShell\Modules\XVMMgr
cp .\xvmmgr.psm1 $HOME\Documents\WindowsPowerShell\Modules\XVMMgr\XVMMgr.psm1
```

Then write a script like this:

```powershell
Import-Module XVMMgr

XVMMgr @{
    VMName = 'YOUR VM NAME';
    # Hypervisor = 'Hyper-V'; # Just ignore the field for VirtualBox
    SSHHost = 'user@vmhostname-or-ip.lan';
    SSHPrivateKey = 'C:\Users\user\path\to\unencryptedPrivateKeyForVM.ppk'; # No spaces in the path!
    Commands = @(
        @{Name = 'Terminal'; Command = 'st'},
        @{Name = 'glxgears'; Command = 'glxgears'}
        # ...
    )
}
```

To run it in the background, you'll need a VBScript file to call your PowerShell script. Yes, this seems to be the easiest way to do this. Oh Windows.

```visualbasic
Set objShell = WScript.CreateObject("WScript.Shell")
objShell.Run("powershell.exe -File C:\Users\user\path\to\mgr.ps1"), 0, True
```

You can put that `.vbs` script into your autostart folder (which is `$HOME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup`, and you can go there quickly by opening `shell:startup` in either the Win+R run dialog or the explorer path bar).


By the way: do not install VirtualBox guest OpenGL/X11 drivers.

## License

This is free and unencumbered software released into the public domain.  
For more information, please refer to the `UNLICENSE` file or [unlicense.org](http://unlicense.org).
