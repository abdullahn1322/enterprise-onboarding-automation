# Microsoft Graph API Endpoints

## Overview

The Enterprise Identity Lifecycle Automation solution uses Microsoft Graph REST API to manage user identities, security groups, and organizational relationships within Microsoft Entra ID.

---

## Authentication

### Obtain Access Token

POST

```
https://login.microsoftonline.com/{tenant-id}/oauth2/v2.0/token
```

Purpose:

Obtain OAuth 2.0 access token for Microsoft Graph.

---

## User Management

### Create User

POST

```
/v1.0/users
```

Used in:

- Employee Joiner

---

### Update User

PATCH

```
/v1.0/users/{user-id}
```

Used in:

- Employee Mover

---

### Get Users

GET

```
/v1.0/users
```

Used in:

- Joiner
- Mover
- Leaver

---

## Manager Management

### Assign Manager

PUT

```
/v1.0/users/{user-id}/manager/$ref
```

Used in:

- Joiner
- Mover

---

## Group Management

### Add User to Group

POST

```
/v1.0/groups/{group-id}/members/$ref
```

Used in:

- Joiner
- Mover

---

### Remove User from Group

DELETE

```
/v1.0/groups/{group-id}/members/{user-id}/$ref
```

Used in:

- Mover
- Leaver

---

## Session Management

### Revoke Sign-In Sessions

POST

```
/v1.0/users/{user-id}/revokeSignInSessions
```

Used in:

- Leaver

---

## Summary

Microsoft Graph API provides a secure REST interface for automating identity lifecycle operations within Microsoft Entra ID.