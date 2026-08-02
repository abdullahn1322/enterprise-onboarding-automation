# Role-Based Access Control (RBAC) Design

## Overview

The project follows a Role-Based Access Control (RBAC) approach by assigning department-specific security groups to users during identity lifecycle events.

Although Azure role assignments are not automated in this implementation, security group membership is managed automatically through Microsoft Graph API.

---

## Security Groups

The following security groups are used:

- SG-IT
- SG-HR
- SG-Finance

---

## Joiner

New employees receive the appropriate department security group based on HR input.

Example:

HR Employee

↓

Department = IT

↓

Assigned Group = SG-IT

---

## Mover

Department changes trigger security group updates.

Example:

SG-IT

↓

SG-HR

---

## Leaver

When employees leave the organization:

- User account disabled
- Active sessions revoked
- Department security group removed

---

## Future Enhancements

Future versions may include:

- Microsoft Entra RBAC role assignments
- Privileged Identity Management (PIM)
- Administrative Unit automation