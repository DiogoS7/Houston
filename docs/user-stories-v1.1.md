# User stories – v1.1 (SkillPath)

Priorities use MoSCoW: **M**ust, **S**hould, **C**ould, **W**on't (this release). Three stories carry over from v1.0, where they were not delivered: B-05 (S-01), B-10 (S-06) and B-08 (S-09).

## Consultant

| ID | Story | Priority |
|---|---|---|
| S-01 | As a consultant, I want to keep my skills and proficiency up to date so that I'm staffed on the right work. *(was B-05)* | M |
| S-02 | As a consultant, I want to plan a certification with a target date so that my manager knows what I'm working towards. | M |
| S-03 | As a consultant, I want to record a certification when I pass it, with a link to the badge, so that my manager can verify it. | M |
| S-04 | As a consultant, I want a reminder before my certification expires so that I renew it in time. | M |
| S-05 | As a consultant, I want a reminder when I haven't reviewed my skills for 90 days so that my profile stays current. | S |

**Acceptance criteria – S-01**
- The consultant can add a skill, change its proficiency (1–5) and its last-used date, and remove a skill.
- Saving the skills sets the consultant's *Skills Reviewed* date to today.

**Acceptance criteria – S-03**
- A certification can only be set to Passed with an achieved date that is not in the future.
- Setting it to Passed starts the verification approval; until it is approved, it shows as *Awaiting verification*.
- When it is approved, the expiry date is set to the achieved date plus the certification's validity (no expiry if the validity is 0).

**Acceptance criteria – S-04**
- The consultant and their manager get an alert 60, 30 and 7 days before the expiry date.
- On the day after expiry, the status changes to Expired and both get an alert.

## Practice manager

| ID | Story | Priority |
|---|---|---|
| S-06 | As a manager, I want to find consultants by skill and minimum level so that I staff the right people. *(was B-10)* | M |
| S-07 | As a manager, I want a skills matrix of my team so that I see strengths and gaps at a glance. | M |
| S-08 | As a manager, I want to verify certifications my team records so that the records can be trusted. | S |
| S-09 | As a manager, I want to assign a consultant to an engagement with an allocation %, choosing from people who have the required skills, so that staffing is recorded in one place. *(was B-08)* | M |
| S-10 | As a manager, I want an alert when a certification in my team is about to expire so that I can plan the renewal. | S |

**Acceptance criteria – S-06**
- The manager picks a skill and a minimum level and sees the matching consultants, sorted by proficiency.
- Each result shows the consultant's practice, their allocation for the next 4 weeks and their certifications for that skill.

**Acceptance criteria – S-09**
- The assignment form lists the engagement's required skills; consultants who meet a required level are shown first.
- Allocation must be between 1 and 100, and the end date can't be before the start date.
- A warning is shown when the new assignment takes the consultant above 100% in any week.

## Leadership

| ID | Story | Priority |
|---|---|---|
| S-11 | As a leader, I want to see certification coverage by practice, the learning pipeline and upcoming expiries so that I can protect our partner status. | M |
| S-12 | As a leader, I want to compare the skills engagements need with the skills and certifications we have so that I can plan hiring and training. *(extends B-12)* | C |

## Won't (v1.1)

- Training budgets, exam vouchers and costs
- Integration with Microsoft Learn, Trailhead or Credly
- Learning paths and course content
