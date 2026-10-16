# Process flows – v1.0 (Bench)

All three flows live in the Houston solution and use the Dataverse connector. Notifications are written to the **Alert** table and appear in the Home screen's notification panel (no mailbox is needed).

## 1. Timesheet approval

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

## 2. Friday timesheet reminder

**Flow:** Houston - Friday timesheet reminder
**Trigger:** scheduled, every Friday at 15:00 (Europe/Lisbon).

```mermaid
flowchart LR
    A[Every Friday 15:00] --> B[List consultants]
    B --> C[List this week's timesheets<br/>not in Draft]
    C --> D[Filter: consultants with<br/>no submitted timesheet]
    D --> E[Add a Timesheet reminder<br/>alert for each one]
```

## 3. Weekly bench alert

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
