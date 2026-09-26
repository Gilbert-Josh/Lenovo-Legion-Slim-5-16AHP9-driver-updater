# Driver Checker v1.0.1
# Windows 11 / PowerShell 5.1 compatible
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12
$NvidiaApi='https://gfwsl.geforce.com/services_toolkit/services/com/nvidia/services/AjaxDriverService.php'
$NvidiaOfficial='https://www.nvidia.com/en-gb/geforce/drivers/'
$AmdOfficial='https://www.amd.com/en/support/download/drivers.html/processors/ryzen/ryzen-8000-series/amd-ryzen-7-8845hs.html'
$LenovoOfficial='https://pcsupport.lenovo.com/gb/en/products/laptops-and-netbooks/legion-series/legion-slim-5-16ahp9/downloads'

function Gpus { @(Get-CimInstance Win32_VideoController | ? Name -notmatch 'Microsoft Basic Display') }
function LatestNvidia {
  $u=$NvidiaApi+'?func=DriverManualLookup&psid=129&pfid=1007&osID=135&languageCode=1033&beta=0&isWHQL=1&dch=1&dltype=1&sort1=0&numberOfResults=1'
  try {
    $r=Invoke-RestMethod $u -Headers @{'User-Agent'='DriverChecker/1.0'} -TimeoutSec 20
    $i=$r.IDS[0].downloadInfo
    if($i.Version){ [pscustomobject]@{Version=[string]$i.Version;Url=[string]$i.DownloadURL} }
  } catch { $null }
}
function Greater($a,$b){try{return [version]$a -gt [version]$b}catch{return $false}}

$cs=Get-CimInstance Win32_ComputerSystem
$os=Get-CimInstance Win32_OperatingSystem
$bios=Get-CimInstance Win32_BIOS
$nv=Gpus | ? Name -match 'NVIDIA GeForce RTX 4060 Laptop GPU' | select -First 1
$amd=Gpus | ? Name -match 'AMD Radeon 780M' | select -First 1

# Map NVIDIA WMI driver versions to the public NVIDIA driver number.
$nvMap=@{
  '32.0.16.1656'='616.56'
  '32.0.16.1714'='617.14'
}
$nvPublic=if($nv -and $nvMap.ContainsKey([string]$nv.DriverVersion)){$nvMap[[string]$nv.DriverVersion]}else{$null}

$form=New-Object Windows.Forms.Form
$form.Text='Driver Checker'
$form.Size=New-Object Drawing.Size(1120,700)
$form.MinimumSize=New-Object Drawing.Size(1120,700)
$form.StartPosition='CenterScreen'
$form.Font=New-Object Drawing.Font('Segoe UI',10)
$form.AutoScaleMode='Dpi'

$t=New-Object Windows.Forms.Label
$t.Text='Driver Checker'
$t.Font=New-Object Drawing.Font('Segoe UI',22,[Drawing.FontStyle]::Bold)
$t.Location=New-Object Drawing.Point(25,18)
$t.AutoSize=$true
$form.Controls.Add($t)

$s=New-Object Windows.Forms.Label
$s.Text='Official sources  •  Safe attended updates  •  No background service  •  No telemetry'
$s.Location=New-Object Drawing.Point(29,62)
$s.Size=New-Object Drawing.Size(1020,25)
$s.AutoSize=$false
$s.ForeColor=[Drawing.Color]::DimGray
$form.Controls.Add($s)

$info=New-Object Windows.Forms.Label
$info.Text=('LENOVO '+$cs.Model+'   •   BIOS '+$bios.SMBIOSBIOSVersion+'   •   '+$os.Caption+' build '+$os.BuildNumber)
$info.Location=New-Object Drawing.Point(30,95)
$info.Size=New-Object Drawing.Size(1030,30)
$info.AutoEllipsis=$true
$form.Controls.Add($info)

$grid=New-Object Windows.Forms.DataGridView
$grid.Location=New-Object Drawing.Point(25,135)
$grid.Size=New-Object Drawing.Size(1045,330)
$grid.ReadOnly=$true
$grid.RowHeadersVisible=$false
$grid.AllowUserToAddRows=$false
$grid.AllowUserToDeleteRows=$false
$grid.AllowUserToResizeRows=$false
$grid.MultiSelect=$false
$grid.SelectionMode='FullRowSelect'
$grid.AutoSizeRowsMode='None'
$grid.RowTemplate.Height=34
$grid.ColumnHeadersHeight=38
$grid.ColumnHeadersDefaultCellStyle.Font=New-Object Drawing.Font('Segoe UI',10,[Drawing.FontStyle]::Bold)
$grid.DefaultCellStyle.Font=New-Object Drawing.Font('Segoe UI',10)
$grid.DefaultCellStyle.WrapMode='False'
[void]$grid.Columns.Add('Component','Component')
[void]$grid.Columns.Add('Installed','Installed')
[void]$grid.Columns.Add('Latest','Latest')
[void]$grid.Columns.Add('Status','Status')
[void]$grid.Columns.Add('Action','Action')
$grid.Columns[0].Width=245
$grid.Columns[1].Width=210
$grid.Columns[2].Width=190
$grid.Columns[3].Width=185
$grid.Columns[4].Width=210
$form.Controls.Add($grid)

$status=New-Object Windows.Forms.Label
$status.Text='Ready. Click Check for Updates.'
$status.Location=New-Object Drawing.Point(30,485)
$status.Size=New-Object Drawing.Size(1030,35)
$status.AutoEllipsis=$true
$form.Controls.Add($status)

if($nv){
  $iv=if($nvPublic){$nvPublic}else{$nv.DriverVersion}
  $initialStatus=if($nvPublic -eq '617.14'){'UP TO DATE'}elseif($nvPublic){'CHECK'}else{'CHECK'}
  [void]$grid.Rows.Add('NVIDIA RTX 4060 Laptop',$iv,'Click Check',$initialStatus,'Update NVIDIA')
}else{[void]$grid.Rows.Add('NVIDIA RTX 4060 Laptop','Not detected','—','Not detected','')}

if($amd){[void]$grid.Rows.Add('AMD Radeon 780M',$amd.DriverVersion,'26.8.1 WHQL','OEM comparison','AMD Official')}
[void]$grid.Rows.Add('Lenovo Legion 83DH',$bios.SMBIOSBIOSVersion,'Lenovo catalogue','Manual','Lenovo Official')
[void]$grid.Rows.Add('Windows 11',$os.BuildNumber,'Windows Update','Manual','Windows Update')

function Btn($text,$x){
  $b=New-Object Windows.Forms.Button
  $b.Text=$text
  $b.Location=New-Object Drawing.Point($x,540)
  $b.Size=New-Object Drawing.Size(190,45)
  $form.Controls.Add($b)
  $b
}
$check=Btn 'Check for Updates' 25
$update=Btn 'Update NVIDIA' 225
$ab=Btn 'AMD Official' 425
$lb=Btn 'Lenovo Official' 625
$wb=Btn 'Windows Update' 825

$latest=$null
$check.Add_Click({
  $check.Enabled=$false
  try{
    $status.Text='Checking official NVIDIA source...'
    [Windows.Forms.Application]::DoEvents()
    $latest=LatestNvidia
    $row=$grid.Rows|? {$_.Cells[0].Value -like 'NVIDIA*'}|select -First 1
    if($latest){
      $row.Cells[2].Value=$latest.Version
      if($nvPublic -and (Greater $latest.Version $nvPublic)){
        $row.Cells[3].Value='UPDATE AVAILABLE'
      }elseif($nvPublic -and $nvPublic -eq $latest.Version){
        $row.Cells[3].Value='UP TO DATE'
      }else{
        $row.Cells[3].Value='CHECK'
      }
      $status.Text='NVIDIA official result: '+$latest.Version
    }else{
      $row.Cells[2].Value='Unable to check'
      $row.Cells[3].Value='CHECK'
      $status.Text='NVIDIA check failed.'
    }
  }catch{
    $status.Text=$_.Exception.Message
  }finally{
    $check.Enabled=$true
  }
})

$update.Add_Click({
  if(-not $latest){$latest=LatestNvidia}
  if(-not $latest){
    [Windows.Forms.MessageBox]::Show('NVIDIA could not be checked.','NVIDIA update')
    Start-Process $NvidiaOfficial
    return
  }
  if([Windows.Forms.MessageBox]::Show(('Download and open official NVIDIA '+$latest.Version+' installer?'),'NVIDIA update','YesNo') -ne 'Yes'){return}
  $dir=Join-Path $env:TEMP 'DriverChecker'
  New-Item $dir -ItemType Directory -Force|Out-Null
  $file=Join-Path $dir ('NVIDIA-'+$latest.Version+'-notebook.exe')
  try{
    $status.Text='Downloading NVIDIA '+$latest.Version+'...'
    [Windows.Forms.Application]::DoEvents()
    Invoke-WebRequest $latest.Url -OutFile $file -UseBasicParsing -TimeoutSec 1800
    $sig=Get-AuthenticodeSignature $file
    if($sig.Status -ne 'Valid' -or $sig.SignerCertificate.Subject -notmatch 'NVIDIA'){
      Remove-Item $file -Force
      throw 'Digital signature verification failed.'
    }
    Start-Process $file
    $status.Text='NVIDIA installer opened.'
  }catch{
    [Windows.Forms.MessageBox]::Show('Update stopped: '+$_.Exception.Message,'NVIDIA update')
  }
})

$ab.Add_Click({
  [Windows.Forms.MessageBox]::Show('For Lenovo laptops, AMD recommends OEM-validated drivers. AMD updates are manual.','AMD laptop driver')
  Start-Process $AmdOfficial
})
$lb.Add_Click({Start-Process $LenovoOfficial})
$wb.Add_Click({Start-Process 'ms-settings:windowsupdate'})
[void]$form.ShowDialog()
