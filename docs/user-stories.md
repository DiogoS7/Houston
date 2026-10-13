# User stories – v1.0 (Bench)

Priorities use MoSCoW: **M**ust, **S**hould, **C**ould, **W**on't (this release).

## Consultant

| ID | Story | Priority |
|---|---|---|
| B-01 | As a consultant, I want to log hours per engagement and day so that my time is recorded accurately. | M |
| B-02 | As a consultant, I want to submit my weekly timesheet so that my manager can approve it. | M |
| B-03 | As a consultant, I want to see my current and upcoming assignments so that I know where I'm working. | M |
| B-04 | As a consultant, I want a reminder on Friday if I haven't submitted so that I don't miss the deadline. | S |
| B-05 | As a consultant, I want to keep my skills and proficiency up to date so that I'm staffed on the right work. | S |

**Acceptance criteria – B-02**
- A timesheet can only be submitted when it has at least one time entry.
- After submission, the timesheet is read-only until it is approved or rejected.
- The status changes from Draft to Submitted, and the approval flow starts.

## Practice manager

| ID | Story | Priority |
|---|---|---|
| B-06 | As a manager, I want to approve or reject timesheets with a comment so that hours are validated. | M |
| B-07 | As a manager, I want to see who is under-allocated in the next 8 weeks so that I can staff them before they hit the bench. | M |
| B-08 | As a manager, I want to assign a consultant to an engagement with an allocation % so that staffing is recorded. | M |
| B-09 | As a manager, I want a weekly alert about upcoming bench time so that I don't have to check manually. | S |
| B-10 | As a manager, I want to find consultants by skill and level so that I staff the right people. | S |

**Acceptance criteria – B-06**
- The manager receives an approval request when a timesheet is submitted.
- Approving sets the status to Approved; rejecting sets it to Rejected and returns the comment to the consultant.
- The approver and decision date are stored on the timesheet.

**Acceptance criteria – B-07**
- The Bench Board shows each consultant's total allocation per week for the next 8 weeks.
- Weeks below the consultant's target utilisation are highlighted.

## Leadership

| ID | Story | Priority |
|---|---|---|
| B-11 | As a leader, I want to see billable utilisation by practice and week so that I can spot trends. | M |
| B-12 | As a leader, I want to compare the skills engagements need with the skills we have so that I can plan hiring and training. | C |

## Won't (v1.0)

- Invoicing from approved hours
- Leave and holiday management
- Mobile offline time entry
