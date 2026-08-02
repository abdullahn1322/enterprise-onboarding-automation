# Employee Joiner Process

## Overview

The Employee Joiner process automates user provisioning in Microsoft Entra ID using Microsoft Graph API.

The automation creates a new employee account, configures user attributes, assigns organizational access, and records the operation through reports and logs.

---

## Workflow

1. Read employee information from **01-NewEmployees.csv**
2. Validate mandatory fields
3. Authenticate to Microsoft Graph
4. Create Microsoft Entra ID user
5. Configure user attributes
6. Assign manager
7. Assign department security group
8. Generate provisioning report
9. Write execution log

---

## Input

CSV File:

```
01-NewEmployees.csv
```

Required fields include:

- UserPrincipalName
- DisplayName
- Department
- Job Title
- Office Location
- Company Name
- Manager
- Security Group

---

## Output

Successful execution results in:

- New Microsoft Entra ID user
- Assigned manager
- Department security group membership
- ProvisioningReport.csv
- Provisioning.log

---

## Microsoft Graph Operations

- Create User
- Update User Attributes
- Assign Manager
- Add Group Membership

---

## Benefits

- Automated onboarding
- Standardized user provisioning
- Reduced manual effort
- Improved consistency
- Centralized reporting