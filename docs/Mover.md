# Employee Mover Process

## Overview

The Employee Mover process automates employee transfers within the organization.

The solution updates employee information, changes department-specific access, and maintains accurate organizational data in Microsoft Entra ID.

---

## Workflow

1. Read employee information from **02-EmployeeTransfers.csv**
2. Validate employee information
3. Authenticate to Microsoft Graph
4. Locate existing user
5. Update user attributes
6. Update department
7. Update office location
8. Update company information
9. Update manager
10. Remove previous security group
11. Assign new security group
12. Generate movement report
13. Write execution log

---

## Output

- Updated user attributes
- Updated manager
- Updated security group
- MoveReport.csv
- Provisioning.log

---

## Microsoft Graph Operations

- Locate User
- Update User
- Remove Group Membership
- Add Group Membership
- Update Manager

---

## Benefits

- Automated employee transfers
- Consistent identity management
- Accurate organizational information
- Improved auditability