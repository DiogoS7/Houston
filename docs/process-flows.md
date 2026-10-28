# Process flows

All three flows live in the Houston solution and use the Dataverse connector. Notifications are written to the **Alert** table and appear in the Home screen's notification panel (no mailbox is needed).

## v1.0 – Bench

### 1. Timesheet approval

**Flow:** Houston - Timesheet approval
**Trigger:** a timesheet's Approval Status changes to Submitted.

```mermaid
flowchart LR
    A[Consultant submits timesheet] --> B[Get consultant and their manager]
    B --> C[Start and wait for an approval]
    C -->|Approve| D[Status = Approved<br/>store approver + decision date]
    C -->|Reject| E[Status = Rejected<br/>store reviewer comment]
    E --> G[Consultant edits and resubmits]
    G --> A
```

Approval requests are answered in Power Automate → **Approvals** (or the Teams Approvals app).

### 2. Friday timesheet reminder

**Flow:** Houston - Friday timesheet reminder
**Trigger:** scheduled, every Friday at 15:00 (Europe/Lisbon).

```mermaid
flowchart LR
    A[Every Friday 15:00] --> B[List consultants]
    B --> C[List this week's timesheets<br/>not in Draft]
    C --> D[Filter: consultants with<br/>no submitted timesheet]
    D --> E[Add a Timesheet reminder<br/>alert for each one]
```

### 3. Weekly bench alert

**Flow:** Houston - Weekly bench alert
**Trigger:** scheduled, every Monday at 08:00 (Europe/Lisbon).

```mermaid
flowchart LR
    A[Every Monday 08:00] --> B[Check date = Monday<br/>4 weeks ahead]
    B --> C[For each consultant:<br/>sum allocations active that week]
    C --> D{Allocation below<br/>target utilisation?}
    D -->|No| E[Skip]
    D -->|Yes| F[Add a Bench alert<br/>for their manager]
```

The loop runs with concurrency 1 so the running Allocation total isn't shared between consultants.

## v1.1 – SkillPath

### 4. Certification verification

**Flow:** Houston - Certification verification
**Trigger:** a consultant certification's status changes to Passed while Verified is No.

```mermaid
flowchart LR
    A[Consultant records a<br/>passed certification] --> B[Get consultant, manager<br/>and certification]
    B --> C[Start and wait for an approval]
    C -->|Approve| D[Verified = Yes<br/>expiry = achieved + validity]
    C -->|Reject| E[Status = In progress<br/>reviewer comment]
    D --> F[Certification alert<br/>to the consultant]
    E --> F
```

If the certification's validity is 0, the expiry date is left empty (it never expires).

### 5. Certification expiry check

**Flow:** Houston - Certification expiry check
**Trigger:** scheduled, every day at 07:00 (Europe/Lisbon).

```mermaid
flowchart LR
    A[Every day 07:00] --> B[List passed certifications<br/>expiring in exactly 60, 30 or 7 days]
    B --> C[Certification alert to the<br/>consultant and their manager]
    A --> D[List passed certifications<br/>whose expiry date is before today]
    D --> E[Status = Expired]
    E --> F[Certification alert to the<br/>consultant and their manager]
```

Checking exact day counts once a day means each person gets three warnings and never the same one twice.

### 6. Skills review reminder

**Flow:** Houston - Skills review reminder
**Trigger:** scheduled, on the 1st of every month at 09:00 (Europe/Lisbon).

```mermaid
flowchart LR
    A[1st of the month 09:00] --> B[List consultants whose Skills Reviewed<br/>date is empty or more than 90 days ago]
    B --> C[Skills review alert<br/>for each one]
```

Saving skills on the *My Skills* screen sets Skills Reviewed to today, so the reminder stops on its own.
