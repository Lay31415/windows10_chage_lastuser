do {
    $username = Read-Host "ユーザー名を入力してください"
    write-host ""
    $objUser = New-Object System.Security.Principal.NTAccount($username)
    try {
        $objSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier])
    } catch {
        Write-Host "ユーザー名が存在しません。もう一度入力してください。"
        write-host ""
        $objSID = $null
    }
} until ($objSID)

$strSID = $objSID.value
$strUsername = $objSID.Translate([System.Security.Principal.NTAccount]).value

$strFilter = "(&(objectCategory=User)(objectClass=Person)(objectSID=$strSID))"
$objSearcher = New-Object System.DirectoryServices.DirectorySearcher
$objSearcher.Filter = $strFilter
$objSearcher.SearchScope = "Subtree"
$colPropList = @("displayName")
foreach ($i in $colPropList) {$objSearcher.PropertiesToLoad.Add($i) > $null}
$colResults = $objSearcher.FindAll()

foreach ($objResult in $colResults)
{
    $objItem = $objResult.Properties
    $strDisplayName = $objItem.displayname
}

write-host "Domain  Name: $strUsername"
write-host "Display Name: $strDisplayName"
write-host "SID         : $strSID"

write-host ""

write-host "LastLoggedOnDisplayName: " -NoNewline
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI" /v LastLoggedOnDisplayName /t REG_SZ /d $strDisplayName /f

write-host "LastLoggedOnSAMUser    : " -NoNewline
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI" /v LastLoggedOnSAMUser /t REG_SZ /d $strUsername /f

write-host "LastLoggedOnUser       : " -NoNewline
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI" /v LastLoggedOnUser /t REG_SZ /d $strUsername /f

write-host "LastLoggedOnUserSID    : " -NoNewline
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI" /v LastLoggedOnUserSID /t REG_SZ /d $strSID /f

write-host ""
