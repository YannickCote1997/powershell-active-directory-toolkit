# Remove Test AD Users

PowerShell script used to safely remove one or multiple test users from an Active Directory environment.

This script is designed for lab, testing, and cleanup scenarios where temporary AD accounts need to be removed quickly and consistently.

---

## Features

- Remove a single Active Directory user
- Remove multiple Active Directory users in one execution
- Validate if the user exists before deletion
- Display user details before deletion
- Confirmation prompt before each deletion
- Error handling with try/catch
- Final summary table showing deletion status

---

## Use Cases

- Cleaning up test accounts
- Removing lab users
- Active Directory testing environments
- Helpdesk and SysAdmin automation practice
- User lifecycle automation demo

---

## Technologies Used

- PowerShell
- Active Directory PowerShell Module
- Windows Server Active Directory

---

## Requirements

- Windows machine with RSAT tools installed
- Active Directory PowerShell module
- Proper permissions to delete AD users
- Domain-connected environment

---

## Example Workflow

```text
=== Suppression de comptes AD TEST ===

1. Supprimer 1 utilisateur
2. Supprimer plusieurs utilisateurs

Choisir 1 ou 2: 2

Combien d'utilisateurs voulez-vous supprimer ?: 3

Utilisateur 1 / 3
Entrer le USERNAME / SAMAccountName du compte 1: test.user1

Utilisateur trouvé:
Username : test.user1
DN       : CN=test.user1,OU=Test Users,DC=company,DC=local
Enabled  : True

Confirmer la suppression définitive de test.user1 ? O/N: O
Compte supprimé : test.user1
