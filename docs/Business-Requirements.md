# Business Requirements

## 1. Project Overview

Modern organizations manage employee identities through a Joiner, Mover, and Leaver (JML) lifecycle. Performing these activities manually can result in delays, inconsistent configurations, and security risks.

This project automates the employee identity lifecycle using Microsoft Entra ID and Microsoft Graph API. The solution provisions new employees, updates existing employee information, and securely deprovisions departing employees through modular PowerShell automation.

---

## 2. Business Problem

Many organizations still perform identity administration manually, resulting in:

- Delayed user provisioning
- Incorrect group assignments
- Inconsistent user attributes
- Human errors
- Lack of centralized reporting
- Limited audit visibility

---

## 3. Business Objectives

The project aims to:

- Automate employee onboarding (Joiner)
- Automate employee department transfers (Mover)
- Automate employee offboarding (Leaver)
- Reduce manual administrative effort
- Improve identity consistency
- Generate reports for auditing purposes
- Maintain centralized logging
- Demonstrate enterprise IAM automation using Microsoft Entra ID

---

## 4. Functional Requirements

### Employee Joiner

- Create new employee accounts
- Configure user profile attributes
- Assign manager
- Assign security groups
- Generate provisioning reports
- Write audit logs

### Employee Mover

- Update user attributes
- Update department
- Update office location
- Update company information
- Change security group membership
- Update reporting manager
- Generate movement reports

### Employee Leaver

- Disable user accounts
- Revoke active sign-in sessions
- Remove security group memberships
- Generate offboarding reports
- Write audit logs

---

## 5. Non-Functional Requirements

The solution should:

- Authenticate securely using Microsoft Graph API
- Follow a modular PowerShell architecture
- Support reusable automation modules
- Process CSV input files
- Generate CSV reports
- Maintain execution logs
- Provide clear error handling

---

## 6. Expected Business Benefits

The solution provides:

- Faster employee lifecycle processing
- Reduced manual administration
- Improved consistency
- Better audit readiness
- Centralized reporting
- Standardized identity management