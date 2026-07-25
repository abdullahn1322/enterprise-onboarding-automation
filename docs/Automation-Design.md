# Automation Design

## Purpose

This document defines the automation strategy for the Identity and Access Management (IAM) environment of Apex Innovations.

The objective is to reduce manual administrative tasks by automating common identity lifecycle operations using PowerShell and Microsoft Graph.

---

# Automation Objectives

The automation solution will:

- Automate user onboarding
- Automate employee transfers
- Automate user offboarding
- Generate identity reports
- Reduce manual administrative effort
- Improve consistency and accuracy
- Support Role-Based Access Control (RBAC)

---

# Automation Scope

The following processes will be automated.

| Process | Status |
|----------|--------|
| User Onboarding | Planned |
| User Update | Planned |
| Department Transfer | Planned |
| User Offboarding | Planned |
| User Reporting | Planned |
| Group Reporting | Planned |
| Application Assignment Reporting | Planned |

---

# Joiner Workflow

When HR submits a new employee request, the automation performs the following steps:

1. Read employee information
2. Create Microsoft Entra user
3. Populate user attributes
4. Assign manager
5. Add user to department security group
6. Generate temporary password
7. Produce onboarding report

---

# Mover Workflow

When an employee changes departments, the automation performs the following:

1. Update department attribute
2. Update job title
3. Remove previous security group membership
4. Add new security group membership
5. Verify manager assignment
6. Generate audit report

---

# Leaver Workflow

When an employee leaves the organization, the automation performs the following:

1. Disable user account
2. Remove security group memberships
3. Remove enterprise application access
4. Record offboarding activity
5. Generate offboarding report

---

# Planned PowerShell Scripts

| Script | Purpose |
|----------|----------|
| Create-NewEmployee.ps1 | Create new employee accounts |
| Update-Employee.ps1 | Update user information |
| Move-Employee.ps1 | Department transfer |
| Disable-Employee.ps1 | Offboard employees |
| Generate-UserReport.ps1 | Generate user inventory |
| Generate-GroupReport.ps1 | Export security group memberships |
| Generate-AppAssignmentReport.ps1 | Export enterprise application assignments |

---

# Technologies

- Microsoft Entra ID
- Microsoft Graph PowerShell SDK
- PowerShell
- Microsoft Graph API

---

# Expected Benefits

The automation solution provides:

- Faster onboarding
- Consistent identity management
- Reduced manual effort
- Standardized access management
- Improved audit readiness
- Better reporting capabilities