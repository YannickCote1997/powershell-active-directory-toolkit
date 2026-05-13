# PowerShell AD Lifecycle Toolkit

A collection of PowerShell scripts designed to automate common Active Directory user lifecycle tasks.

This toolkit focuses on reducing repetitive manual work, improving consistency, minimizing human error, and improving operational efficiency in enterprise IT environments.

---

# Features

- Active Directory user creation automation
- Secure password generation
- Password reset workflows
- Account unlock automation
- Bulk user management
- Group membership cloning
- Microsoft 365 license group handling
- Active Directory account deletion
- Consultant account expiration management
- Interactive PowerShell prompts
- Enterprise-oriented automation workflows

---

# Repository Structure

```text
PowerShell-AD-Lifecycle-Toolkit/
│
├── Create-AD-Users/
│   ├── Create-AD-Users.ps1
│   └── README.md
│
├── Reset-AD-Password/
│   ├── Reset-AD-Password.ps1
│   └── README.md
│
├── Remove-AD-Users/
│   ├── Remove-AD-Users.ps1
│   └── README.md
│
└── README.md
```

---

# Scripts Included

## Create AD Users

Path:

```text
Create-AD-Users/Create-AD-Users.ps1
```

### Features

- Create one or multiple Active Directory users
- Copy group memberships from a source user
- Automatically place users in the same OU as the source account
- Generate secure 15-character passwords automatically
- Detect Microsoft 365 license groups
- Optionally remove M365 license groups before synchronization
- Display final generated passwords in summary table
- Validate if username already exists
- Bulk onboarding support

### Example Workflow

```text
1. Choose:
   - Create one user
   - Create multiple users

2. Enter source/template account

3. Enter:
   - First Name
   - Last Name
   - Username

4. Script automatically:
   - Generates secure password
   - Creates account
   - Copies groups
   - Places account in correct OU
   - Displays summary
```

---

## Reset AD Password

Path:

```text
Reset-AD-Password/Reset-AD-Password.ps1
```

### Features

- Reset Active Directory passwords
- Generate secure 15-character passwords automatically
- Unlock account if locked
- Different logic depending on account type:
  - ADMIN
  - CONSULTANT
  - MOD
- Configure password expiration settings
- Configure password change settings
- Extend consultant account expiration dates automatically
- Display generated password at end of execution

### Account Types

#### ADMIN

- Reset password
- Unlock account
- Disable:
  - Password Never Expires
  - User Cannot Change Password

#### MOD

Same behavior as ADMIN.

#### CONSULTANT

- Reset password
- Unlock account
- Enable:
  - Password Never Expires
  - User Cannot Change Password
- Display current expiration date
- Optionally extend expiration date by 6 months

### Example Workflow

```text
1. Select account type
2. Enter username
3. Script automatically:
   - Generates password
   - Resets password
   - Unlocks account
   - Applies account settings
   - Extends expiration if needed
4. Displays generated password
```

---

## Remove AD Users

Path:

```text
Remove-AD-Users/Remove-AD-Users.ps1
```

### Features

- Remove one or multiple Active Directory users
- Validate if account exists before deletion
- Display account information before removal
- Confirmation prompt before deletion
- Bulk account deletion support
- Summary table after execution
- Error handling using try/catch
- Uses DistinguishedName/ObjectGUID for reliable deletion

### Example Workflow

```text
1. Choose:
   - Remove one user
   - Remove multiple users

2. Enter username(s)

3. Script:
   - Validates account existence
   - Displays account details
   - Requests confirmation
   - Removes account
   - Displays final summary
```

---

# Technologies Used

- PowerShell
- Active Directory PowerShell Module
- Windows Server Active Directory
- RSAT Tools

---

# Requirements

- Windows machine joined to domain
- RSAT installed
- Active Directory PowerShell module
- Proper Active Directory permissions
- PowerShell execution policy allowing scripts

---

# Security Notes

These scripts are intended for authorized administrative use only.

Always:
- Test scripts in lab environments first
- Validate permissions before execution
- Review scripts before production usage
- Follow your organization's security policies

---

# Purpose

This repository demonstrates practical enterprise automation concepts for:

- IT Support
- Helpdesk operations
- Junior System Administration
- Active Directory administration
- User onboarding/offboarding
- Account lifecycle management
- IT process standardization
- PowerShell automation

---

# Future Improvements

Possible future additions:

- Microsoft Graph API integration
- Exchange Online automation
- Azure / Entra ID integration
- Logging system
- GUI interface
- CSV import/export
- Audit reports
- Automatic mailbox handling
- Group comparison tools

---

# Disclaimer

This project is provided for educational and administrative automation purposes only.

The author is not responsible for misuse, production outages, or improper execution of these scripts.

Always validate scripts in a controlled environment before production deployment.
