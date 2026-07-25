# Access Control Model

## Overview

Apex Innovations follows a Role-Based Access Control (RBAC) model to manage access to enterprise resources.

Instead of granting permissions directly to every employee, access is assigned based on job responsibilities and department membership.

---

## Access Flow

User
↓

Department

↓

Security Group

↓

Enterprise Application

↓

Application Role

↓

Business Resource

---

## Department Security Groups

| Department | Security Group |
|------------|----------------|
| HR | SG-HR |
| Finance | SG-Finance |
| IT | SG-IT |
| Infrastructure | SG-Infrastructure |
| Cybersecurity | SG-Cybersecurity |
| Sales | SG-Sales |
| Marketing | SG-Marketing |
| Management | SG-Management |

---

## Enterprise Applications

| Application | Assigned Users |
|-------------|----------------|
| Apex HR Portal | HR Department |
| Apex Finance System | Finance Department |
| Apex IT Service Desk | IT & Infrastructure |
| Apex SOC Dashboard | Cybersecurity |
| Apex CRM | Sales |
| Apex Marketing Hub | Marketing |

---

## Security Principles

The identity environment follows these principles:

- Role-Based Access Control (RBAC)
- Least Privilege
- Separation of Duties
- Department-Based Access
- Manager Hierarchy
- Joiner, Mover and Leaver lifecycle

---

## Lab Note

Microsoft Entra ID Free does not support assigning Security Groups directly to Enterprise Applications.

For this project, users are assigned directly to enterprise applications while department-based Security Groups are maintained separately.

In a production Microsoft Entra ID Premium environment, Security Groups would be assigned to Enterprise Applications instead of individual users.