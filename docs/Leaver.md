# Employee Leaver Process

## Overview

The Employee Leaver process automates secure employee offboarding.

The automation disables user accounts, revokes active sign-in sessions, removes security group memberships, and records the operation for auditing purposes.

---

## Workflow

1. Read employee information from **03-EmployeeLeavers.csv**
2. Validate employee information
3. Authenticate to Microsoft Graph
4. Locate existing user
5. Disable account
6. Revoke active sign-in sessions
7. Remove department security group
8. Generate leaver report
9. Write execution log

---

## Output

- Disabled Microsoft Entra ID account
- Revoked sign-in sessions
- Removed security groups
- LeaverReport.csv
- Provisioning.log

---

## Microsoft Graph Operations

- Locate User
- Disable Account
- Revoke Sign-In Sessions
- Remove Group Membership

---

## Benefits

- Secure offboarding
- Reduced security risks
- Consistent deprovisioning
- Audit-ready reporting