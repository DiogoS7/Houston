# Process flows – v1.0 (Bench)

## 1. Timesheet approval

**Trigger:** a timesheet's status changes to Submitted.

```mermaid
flowchart LR
    A[Consultant submits timesheet] --> B[Flow: get consultant's manager]
    B --> C[Send approval request]
    C -->|Approve| D[Status = Approved<br/>store approver + date]
    C -->|Reject| E[Status = Rejected<br/>store comment]
    D --> F[Notify consultant]
    E --> F
    E --> G[Consultant edits and resubmits]
    G --> A
```

## 2. Friday timesheet reminder

**Trigger:** scheduled, every Friday at 15:00 (Europe/Lisbon).

```mermaid
flowchart LR
    A[Every Friday 15:00] --> B[List active consultants]
    B --> C{Timesheet for this week<br/>Submitted or Approved?}
    C -->|Yes| D[Skip]
    C -->|No| E[Send reminder email]
```

## 3. Weekly bench alert

**Trigger:** scheduled, every Monday at 08:00 (Europe/Lisbon).

```mermaid
flowchart LR
    A[Every Monday 08:00] --> B[For each consultant:<br/>sum allocations, next 4 weeks]
    B --> C{Allocation below<br/>target utilisation?}
    C -->|No| D[Skip]
    C -->|Yes| E[Add to manager's digest]
    E --> F[Send one digest email per manager]
```
