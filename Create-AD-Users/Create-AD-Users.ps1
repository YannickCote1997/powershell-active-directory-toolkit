Import-Module ActiveDirectory

$UPNSuffix = "local" ← Nom de domaine de la compagnie
$LicenseGroupName = "Acces Lic-Microsoft-E5-Full" ← Nom du ou DES groupes à enlever

function New-ComplexPassword {
    param (
        [int]$Length = 15
    )

    $upper   = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    $lower   = "abcdefghijklmnopqrstuvwxyz"
    $numbers = "0123456789"
    $special = "!@#$%&*?"

    $all = ($upper + $lower + $numbers + $special).ToCharArray()

    $password = @()
    $password += ($upper.ToCharArray()   | Get-Random)
    $password += ($lower.ToCharArray()   | Get-Random)
    $password += ($numbers.ToCharArray() | Get-Random)
    $password += ($special.ToCharArray() | Get-Random)

    for ($i = $password.Count; $i -lt $Length; $i++) {
        $password += $all | Get-Random
    }

    return -join ($password | Get-Random -Count $Length)
}

function Create-CopiedUser {
    param (
        [string]$SourceSam,
        [string]$FirstName,
        [string]$LastName,
        [string]$TargetSam
    )

    $ExistingUser = Get-ADUser -Filter "SamAccountName -eq '$TargetSam'" -ErrorAction SilentlyContinue

    if ($ExistingUser) {
        Write-Host "ERREUR : Le username $TargetSam existe déjà. User ignoré." -ForegroundColor Red
        return $null
    }

    $SourceUser = Get-ADUser -Identity $SourceSam -Properties MemberOf, DistinguishedName, Department, Title, Company, Manager, Office, Description

    if (-not $SourceUser) {
        Write-Host "Utilisateur source introuvable : $SourceSam" -ForegroundColor Red
        return $null
    }

    $SourceOU = ($SourceUser.DistinguishedName -split ",", 2)[1]
    $DisplayName = "$FirstName $LastName"
    $UPN = "$TargetSam@$UPNSuffix"

    $PlainPassword = New-ComplexPassword -Length 15
    $SecurePassword = ConvertTo-SecureString $PlainPassword -AsPlainText -Force

    Write-Host "`nCréation de $DisplayName dans $SourceOU..." -ForegroundColor Cyan

    try {
        New-ADUser `
            -Name $DisplayName `
            -GivenName $FirstName `
            -Surname $LastName `
            -DisplayName $DisplayName `
            -SamAccountName $TargetSam `
            -UserPrincipalName $UPN `
            -Path $SourceOU `
            -AccountPassword $SecurePassword `
            -Enabled $true `
            -ChangePasswordAtLogon $true `
            -Department $SourceUser.Department `
            -Title $SourceUser.Title `
            -Company $SourceUser.Company `
            -Office $SourceUser.Office `
            -Description "Créé à partir du modèle/source : $SourceSam" `
            -ErrorAction Stop

        Write-Host "User créé : $TargetSam" -ForegroundColor Green
    }
    catch {
        Write-Host "Erreur création user $TargetSam : $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }

    foreach ($GroupDN in $SourceUser.MemberOf) {
        try {
            Add-ADGroupMember -Identity $GroupDN -Members $TargetSam -ErrorAction Stop
        }
        catch {
            Write-Host "Erreur ajout groupe : $GroupDN" -ForegroundColor Yellow
        }
    }

    Write-Host "Groupes copiés depuis $SourceSam." -ForegroundColor Green

    try {
        $TargetUser = Get-ADUser -Identity $TargetSam -Properties MemberOf
        $LicenseGroup = Get-ADGroup -Identity $LicenseGroupName

        if ($TargetUser.MemberOf -contains $LicenseGroup.DistinguishedName) {
            Write-Host "Le user est membre du groupe licence : $LicenseGroupName" -ForegroundColor Yellow

            $RemoveLic = Read-Host "Voulez-vous retirer ce groupe de licence avant la sync ? O/N"

            if ($RemoveLic -eq "O" -or $RemoveLic -eq "o") {
                Remove-ADGroupMember -Identity $LicenseGroup -Members $TargetSam -Confirm:$false
                Write-Host "Groupe licence retiré pour $TargetSam." -ForegroundColor Green
            }
            else {
                Write-Host "Groupe licence conservé pour $TargetSam." -ForegroundColor Yellow
            }
        }
        else {
            Write-Host "Aucun groupe licence E5 détecté pour $TargetSam." -ForegroundColor Green
        }
    }
    catch {
        Write-Host "Erreur vérification licence : $($_.Exception.Message)" -ForegroundColor Yellow
    }

    return [PSCustomObject]@{
        Username = $TargetSam
        Name     = $DisplayName
        UPN      = $UPN
        Password = $PlainPassword
    }
}

$CreatedUsers = @()

Write-Host "=== Création utilisateur AD à partir d’un user source ===" -ForegroundColor Cyan
Write-Host "1. Créer 1 utilisateur"
Write-Host "2. Créer plusieurs utilisateurs"

$Mode = Read-Host "Choisir 1 ou 2"
$SourceSam = Read-Host "Entrer le USERNAME du user SOURCE à copier"

if ($Mode -eq "1") {
    $FirstName = Read-Host "Prénom du nouveau user"
    $LastName = Read-Host "Nom de famille du nouveau user"
    $TargetSam = Read-Host "USERNAME du nouveau user"

    $Result = Create-CopiedUser `
        -SourceSam $SourceSam `
        -FirstName $FirstName `
        -LastName $LastName `
        -TargetSam $TargetSam

    if ($Result) {
        $CreatedUsers += $Result
    }
}
elseif ($Mode -eq "2") {
    $Count = Read-Host "Combien d'utilisateurs voulez-vous créer ?"

    for ($i = 1; $i -le [int]$Count; $i++) {
        Write-Host "`n=== Utilisateur $i / $Count ===" -ForegroundColor Cyan

        $FirstName = Read-Host "Prénom du user $i"
        $LastName = Read-Host "Nom de famille du user $i"
        $TargetSam = Read-Host "USERNAME du user $i"

        $Result = Create-CopiedUser `
            -SourceSam $SourceSam `
            -FirstName $FirstName `
            -LastName $LastName `
            -TargetSam $TargetSam

        if ($Result) {
            $CreatedUsers += $Result
        }
    }
}
else {
    Write-Host "Choix invalide. Relancer le script." -ForegroundColor Red
}

Write-Host "`n=== Résumé des comptes créés ===" -ForegroundColor Cyan

if ($CreatedUsers.Count -gt 0) {
    $CreatedUsers | Format-Table Username, Name, UPN, Password -AutoSize
}
else {
    Write-Host "Aucun compte créé." -ForegroundColor Yellow
}
