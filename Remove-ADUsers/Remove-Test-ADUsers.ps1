Import-Module ActiveDirectory

function Remove-TestADUser {
    param (
        [string]$Sam
    )

    try {
        $User = Get-ADUser -Identity $Sam -Properties DistinguishedName, Enabled -ErrorAction Stop
    }
    catch {
        Write-Host "Utilisateur introuvable : $Sam" -ForegroundColor Red
        return [PSCustomObject]@{
            Username = $Sam
            Status   = "Introuvable"
        }
    }

    Write-Host "`nUtilisateur trouvé :" -ForegroundColor Cyan
    Write-Host "Username : $Sam"
    Write-Host "DN       : $($User.DistinguishedName)"
    Write-Host "Enabled  : $($User.Enabled)"

    $Confirm = Read-Host "Confirmer la suppression définitive de $Sam ? O/N"

    if ($Confirm -ne "O" -and $Confirm -ne "o") {
        Write-Host "Suppression annulée pour $Sam." -ForegroundColor Yellow
        return [PSCustomObject]@{
            Username = $Sam
            Status   = "Annulé"
        }
    }

    try {
        Remove-ADUser -Identity $Sam -Confirm:$false -ErrorAction Stop
        Write-Host "Compte supprimé : $Sam" -ForegroundColor Green

        return [PSCustomObject]@{
            Username = $Sam
            Status   = "Supprimé"
        }
    }
    catch {
        Write-Host "Erreur suppression $Sam : $($_.Exception.Message)" -ForegroundColor Red

        return [PSCustomObject]@{
            Username = $Sam
            Status   = "Erreur"
        }
    }
}

$Results = @()

Write-Host "=== Suppression de comptes AD ===" -ForegroundColor Cyan
Write-Host "1. Supprimer 1 utilisateur"
Write-Host "2. Supprimer plusieurs utilisateurs"

$Mode = Read-Host "Choisir 1 ou 2"

if ($Mode -eq "1") {
    $Sam = Read-Host "Entrer le USERNAME du compte à supprimer"

    $Results += Remove-TestADUser -Sam $Sam
}
elseif ($Mode -eq "2") {
    $Count = Read-Host "Combien d'utilisateurs voulez-vous supprimer ?"

    for ($i = 1; $i -le [int]$Count; $i++) {
        Write-Host "`n=== Utilisateur $i / $Count ===" -ForegroundColor Cyan
        $Sam = Read-Host "Entrer le USERNAME du compte $i"

        $Results += Remove-TestADUser -Sam $Sam
    }
}
else {
    Write-Host "Choix invalide. Relancer le script." -ForegroundColor Red
    exit
}

Write-Host "`n=== Résumé ===" -ForegroundColor Cyan
$Results | Format-Table Username, Status -AutoSize
