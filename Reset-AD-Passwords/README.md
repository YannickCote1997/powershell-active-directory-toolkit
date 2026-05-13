# Active Directory Password Reset Automation

PowerShell script used to automate password resets and account management tasks in Active Directory environments.

---

## Features

### Secure Password Generation
- Automatically generates a strong 15-character password
- Includes:
  - Uppercase letters
  - Lowercase letters
  - Numbers
  - Special characters

---

## Account Types Supported

### ADMIN
Automatically:
- Resets password
- Unlocks account if locked
- Disables:
  - "User cannot change password"
  - "Password never expires"
- Removes forced password expiration settings

---

### MOD
Same behavior as ADMIN:
- Password reset
- Account unlock
- Security options reset

---

### CONSULTANT
Automatically:
- Resets password
- Unlocks account if locked
- Enables:
  - "User cannot change password"
  - "Password never expires"
- Displays current account expiration date
- Offers to extend account expiration by 6 months

Example:

```text
Current expiration date: 2026-05-15
Would you like to extend the account until 2026-11-15? Y/N
