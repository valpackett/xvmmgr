Add-Type -AssemblyName "System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089"
Add-Type -AssemblyName "System.Drawing, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a"

function RunPlink ([object]$Config, [string]$cmd) {
    return Start-Process 'C:\Program Files\VcXsrv\plink.exe' -ArgumentList '-ssh',$Config.SSHHost,'-X','-2','-C','-i',$Config.SSHPrivateKey,$cmd -WindowStyle Hidden -PassThru
}

function XVMMgr ([object]$Config, [string]$SSHHost, [string]$SSHPrivateKeyPath, [array]$Commands) {
    Stop-Process -ProcessName VcXsrv -ErrorAction SilentlyContinue

    $VBox = New-Object -ComObject VirtualBox.VirtualBox
    $VBoxSession = New-Object -ComObject VirtualBox.Session
    $VBoxBox = $VBox.FindMachine($Config.VMName)

    $Ctx = New-Object System.Windows.Forms.ApplicationContext
    $Processes = New-Object System.Collections.Generic.List[System.Object]
    $Processes.Add((Start-Process 'C:\Program Files\VcXsrv\vcxsrv.exe' -ArgumentList '-multiwindow','-wgl','-notrayicon','-xkboptions','compose:ralt' -PassThru))

    $NotifyIcon = New-Object System.Windows.Forms.NotifyIcon
    $NotifyIcon.Visible = $True
    $NotifyIcon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon('C:\Program Files\Oracle\VirtualBox\VirtualBox.exe')
    $NotifyIcon.ContextMenu = New-Object System.Windows.Forms.ContextMenu
    $NotifyIcon.add_Click({
        if ($_.Button -eq [System.Windows.Forms.MouseButtons]::Left -and $VBoxBox.State -lt 5) {
            $VBoxBox.LaunchVMProcess($VBoxSession, 'headless', '')
        }
    })

    $MenuItemExit = New-Object System.Windows.Forms.MenuItem
    $MenuItemExit.Text = "Exit"
    $MenuItemExit.add_Click({
        $Ctx.ExitThread()
    })
    $NotifyIcon.ContextMenu.MenuItems.AddRange($MenuItemExit)

    foreach ($Cmd in $Config.Commands) {
        $MenuItem = New-Object System.Windows.Forms.MenuItem
        $MenuItem.Text = $Cmd.Name
        $MenuItem.add_Click({
            $Processes.Add((RunPlink $Config $Cmd.Command))
        })
        $NotifyIcon.ContextMenu.MenuItems.AddRange($MenuItem)
    }

    [System.Windows.Forms.Application]::add_ApplicationExit({
        foreach ($Proc in $Processes) {
            Stop-Process $Proc
        }
    })
    [void][System.Windows.Forms.Application]::Run($Ctx)
}