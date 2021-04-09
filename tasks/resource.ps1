[CmdletBinding()]
Param(
  [Parameter(Mandatory = $False)]
  [String]
  $resource_type
)
$puppetPath = 'C:\Program Files\Puppet Labs\Puppet\bin'
If (Test-Path -Path $puppetPath)
{
  Set-Location $puppetPath
  If ([String]::IsNullOrEmpty($resource_type))
  {
    Write-Output 'Please specify one of the following resources.'
    & puppet.bat describe --list
  }
  Else
  {
    $parmArray = $resource_type.Split(' ')
    & puppet.bat resource $parmArray
  }
}
Else
{
  Write-Output 'Could not find path to puppet.'
}