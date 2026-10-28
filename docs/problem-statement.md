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

---

# v1.1: SkillPath

## The problem

v1.0 made staffing visible, but it still can't answer the third question well: **do we have the right skills?**

- Consultants' skills are recorded once and then go stale. Nobody knows when a profile was last reviewed.
- Certifications live in people's heads and LinkedIn profiles. Managers can't see who is certified in what, or who is working towards an exam.
- Role-based certifications (Microsoft, Salesforce) must be renewed every year. They lapse without anyone noticing, and the firm finds out when a client or partner programme asks for proof.
- When a new engagement needs, say, two Salesforce consultants at level 4, the manager searches by memory, and assignments are still created outside the app.

## Impact

- Staffing proposals that don't match the client's requirements
- Lapsed certifications that weaken partner status and bids
- No visibility of the team's learning pipeline, so training is not planned against demand

## Proposed solution (v1.1: SkillPath)

Extend Houston so that:

- consultants keep their skills and proficiency up to date, and are reminded when they haven't reviewed them for 90 days;
- consultants plan certifications, record them when they pass, and managers verify them through an approval;
- the system tracks expiry dates and alerts the consultant and their manager before a certification lapses;
- managers see a skills matrix of their team, find consultants by skill and level, and assign them to engagements from the app;
- Power BI shows certification coverage by practice, the learning pipeline and upcoming expiries.

## Success measures

| Measure | Target |
|---|---|
| Consultants who reviewed their skills in the last 90 days | ≥ 90% |
| Certifications that lapse without a warning | 0 |
| Warning before a certification expires | 60 days |
| Passed certifications verified by a manager | 100% |
| Time to find candidates for a skill and level | From hours to seconds |

## Scope

**In scope (v1.1):** certifications catalogue, consultant certifications with status and expiry, verification approval, expiry and skills-review alerts, skills matrix, search by skill, assignment from the app, certification reporting.

**Out of scope (v1.1):** training budgets and exam vouchers, integration with Microsoft Learn or Trailhead, learning paths and course content.
