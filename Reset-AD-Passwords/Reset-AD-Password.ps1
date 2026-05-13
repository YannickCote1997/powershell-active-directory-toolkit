Import-Module ActiveDirectory

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

Write-Host "=== Reset mot de passe AD ===" -ForegroundColor Cyan
Write-Host "1. ADMIN"
Write-Host "2. CONSULTANT"
Write-Host "3. MOD"

$Choice = Read-Host "Choisir le type de compte 1, 2 ou 3"

switch ($Choice) {
    "1" { $AccountType = "ADMIN" }
    "2" { $AccountType = "CONSULTANT" }
    "3" { $AccountType = "MOD" }
    default {
        Write-Host "Choix invalide. Relancer le script." -ForegroundColor Red
        exit
    }
}

$Sam = Read-Host "Entrer le USERNAME du compte"

try {
    $User = Get-ADUser -Identity $Sam -Properties LockedOut, AccountExpirationDate, CannotChangePassword, PasswordNeverExpires, Enabled -ErrorAction Stop
}
catch {
    Write-Host "Utilisateur introuvable : $Sam" -ForegroundColor Red
    exit
}

$PlainPassword = New-ComplexPassword -Length 15
$SecurePassword = ConvertTo-SecureString $PlainPassword -AsPlainText -Force

Write-Host "`nCompte trouvé : $($User.Name)" -ForegroundColor Green
Write-Host "Type sélectionné : $AccountType" -ForegroundColor Yellow

try {
    Set-ADAccountPassword `
        -Identity $Sam `
        -NewPassword $SecurePassword `
        -Reset `
        -ErrorAction Stop

    Write-Host "Mot de passe changé." -ForegroundColor Green
}
catch {
    Write-Host "Erreur changement mot de passe : $($_.Exception.Message)" -ForegroundColor Red
    exit
}

if ($User.LockedOut -eq $true) {
    try {
        Unlock-ADAccount -Identity $Sam -ErrorAction Stop
        Write-Host "Compte déverrouillé." -ForegroundColor Green
    }
    catch {
        Write-Host "Erreur unlock compte : $($_.Exception.Message)" -ForegroundColor Yellow
    }
}
else {
    Write-Host "Compte non verrouillé." -ForegroundColor Green
}

if ($AccountType -eq "ADMIN" -or $AccountType -eq "MOD") {
    try {
        Set-ADUser `
            -Identity $Sam `
            -CannotChangePassword $false `
            -PasswordNeverExpires $false `
            -ChangePasswordAtLogon $true `
            -ErrorAction Stop

        Write-Host "Options appliquées pour $AccountType :" -ForegroundColor Cyan
        Write-Host "- User cannot change password : décoché"
        Write-Host "- Password never expires : décoché"
        Write-Host "- User must change password at next logon : coché"
    }
    catch {
        Write-Host "Erreur modification options password : $($_.Exception.Message)" -ForegroundColor Red
    }
}

if ($AccountType -eq "CONSULTANT") {
    try {
        $CurrentExpiration = $User.AccountExpirationDate

        if ($CurrentExpiration) {
            Write-Host "`nDate d'expiration actuelle : $CurrentExpiration" -ForegroundColor Yellow
        }
        else {
            Write-Host "`nAucune date d'expiration actuelle." -ForegroundColor Yellow
        }

        $NewExpiration = (Get-Date).AddMonths(6)

        $ConfirmExtend = Read-Host "Voulez-vous prolonger le compte jusqu'au $($NewExpiration.ToString('yyyy-MM-dd')) ? O/N"

        if ($ConfirmExtend -eq "O" -or $ConfirmExtend -eq "o") {
            Set-ADUser `
                -Identity $Sam `
                -CannotChangePassword $true `
                -PasswordNeverExpires $true `
                -AccountExpirationDate $NewExpiration `
                -ChangePasswordAtLogon $false `
                -ErrorAction Stop

            Write-Host "Options appliquées pour CONSULTANT :" -ForegroundColor Cyan
            Write-Host "- User cannot change password : coché"
            Write-Host "- Password never expires : coché"
            Write-Host "- User must change password at next logon : décoché"
            Write-Host "Le compte a été prolongé jusqu'au $($NewExpiration.ToString('yyyy-MM-dd'))." -ForegroundColor Green
        }
        else {
            Set-ADUser `
                -Identity $Sam `
                -CannotChangePassword $true `
                -PasswordNeverExpires $true `
                -ChangePasswordAtLogon $false `
                -ErrorAction Stop

            Write-Host "Expiration non modifiée." -ForegroundColor Yellow
            Write-Host "Options consultant appliquées sans prolongation." -ForegroundColor Cyan
        }
    }
    catch {
        Write-Host "Erreur modification compte consultant : $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n=== Résumé ===" -ForegroundColor Cyan
Write-Host "Compte      : $Sam"
Write-Host "Nom         : $($User.Name)"
Write-Host "Type        : $AccountType"
Write-Host "Password    : $PlainPassword" -ForegroundColor Green
