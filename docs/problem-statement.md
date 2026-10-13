# Problem statement

## Context

A mid-sized IT consultancy runs dozens of client engagements at once. Consultants move between projects, log their hours weekly and are staffed by practice managers. Today this runs on spreadsheets, email threads and memory.

## The problem

Practice managers cannot answer three basic questions quickly and with confidence:

1. **Who is available?** Bench time (consultants without billable work) is only discovered after it happens, when the hours are already lost.
2. **Are we utilised well?** Billable utilisation is calculated by hand at month end, so problems surface weeks too late.
3. **Do we have the right skills?** Staffing decisions rely on who the manager remembers, not on a shared view of skills and demand.

Timesheets add friction on both sides: consultants forget to submit, managers chase them by email, and approvals have no audit trail.

## Impact

- Lost revenue from unplanned bench time
- Late, error-prone utilisation reporting
- Staffing based on memory instead of data
- Administrative time spent chasing and consolidating timesheets

## Proposed solution (v1.0: Bench)

A Power Platform app where:

- consultants log and submit weekly timesheets against their engagements;
- managers approve timesheets through an automated workflow;
- the system reminds late submitters and alerts managers about upcoming bench time;
- an embedded Power BI report shows utilisation, the bench forecast and skills supply against demand.

## Success measures

| Measure | Target |
|---|---|
| Timesheets submitted on time | ≥ 90% |
| Time to produce the utilisation report | From days to real time |
| Bench visibility | 8 weeks ahead |
| Timesheet approvals with an audit trail | 100% |

## Scope

**In scope (v1.0):** consultants, clients, engagements, skills, assignments, timesheets, approval and reminder flows, utilisation reporting.

**Out of scope (v1.0):** invoicing, payroll, requirements management (ScopeGuard, v1.2), incident management (Hypercare, v1.3).

## Stakeholders

| Role | Interest |
|---|---|
| Consultant | Quick timesheet entry, clear view of assignments |
| Practice manager | Approvals, staffing, utilisation |
| Leadership | Utilisation and bench trends |
