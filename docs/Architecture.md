# System Architecture

## Overview

The Enterprise Identity Lifecycle Automation solution follows a modular architecture designed to automate employee identity lifecycle operations using Microsoft Entra ID and Microsoft Graph API.

The solution is divided into reusable PowerShell modules that perform authentication, validation, user management, group assignment, manager assignment, logging, and reporting.

---

## Architecture Components

### HR Input

Employee information is provided through CSV files representing different lifecycle events:

- New Employees (Joiner)
- Employee Transfers (Mover)
- Employee Leavers (Leaver)

---

### PowerShell Automation Engine

The PowerShell scripts coordinate the automation process by:

- Reading CSV input files
- Authenticating to Microsoft Graph
- Validating employee information
- Calling reusable modules
- Writing reports
- Recording logs

---

### Microsoft Graph API

Microsoft Graph API acts as the communication layer between the automation scripts and Microsoft Entra ID.

The project uses REST API calls to:

- Create users
- Update users
- Assign managers
- Manage security groups
- Revoke sign-in sessions
- Disable user accounts

---

### Microsoft Entra ID

Microsoft Entra ID serves as the identity platform where employee accounts are managed.

The automation performs operations such as:

- User provisioning
- User updates
- Account disablement
- Security group management
- Manager assignment

---

### Reporting Module

Each lifecycle operation generates CSV reports containing processing results.

Reports include:

- Provisioning Report
- Move Report
- Leaver Report

---

### Logging Module

Execution logs are written for auditing and troubleshooting purposes.

Logs include:

- Authentication events
- Processing status
- Errors
- Successful operations

---

## Architecture Flow

HR CSV Files

↓

PowerShell Automation Engine

↓

Authentication Module

↓

Microsoft Graph API

↓

Microsoft Entra ID

↓

Users • Groups • Managers

↓

Reporting & Logging

---

## Design Principles

The solution follows these principles:

- Modular architecture
- Reusable PowerShell modules
- Separation of responsibilities
- Centralized reporting
- Secure authentication
- Maintainable code structure