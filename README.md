![Houston banner](assets/banner-v1.png)

# Houston

[![CI](https://github.com/DiogoS7/Houston/actions/workflows/ci.yml/badge.svg)](https://github.com/DiogoS7/Houston/actions/workflows/ci.yml)

*Houston, we have a solution.*

A consulting delivery platform built on Microsoft Power Platform. Houston follows an engagement through its whole lifecycle: staffing the team, scoping the work, delivering it and stabilising it after go-live.

## Modules

| Module | What it does | Release |
|---|---|---|
| **Bench** | Consultant staffing, timesheets and utilisation | v1.0 |
| **SkillPath** | Skills matrix and certification tracking | v1.1 |
| **ScopeGuard** | Requirements and change request management | v1.2 |
| **Hypercare** | Post go-live incident tracking with SLAs | v1.3 |
| **Cross-module** | Skill-gap alerts, effort per requirement | v2.0 |

All modules share one Dataverse data model: Consultants, Clients, Engagements and Skills.

## v1.0 – Bench

| | |
|---|---|
| ![Home](screenshots/v1.0/01-home.png) | ![Bench Board](screenshots/v1.0/03-bench-board.png) |
| **Home** – the week at a glance, live Power BI tile and in-app alerts | **Bench Board** – allocation per consultant for the next 6 weeks |
| ![My Timesheet](screenshots/v1.0/02-my-timesheet.png) | ![Bench forecast](screenshots/v1.0/05-bi-bench-forecast.png) |
| **My Timesheet** – log hours and submit for approval | **Power BI** – bench forecast against target |
| ![Approval flow](screenshots/v1.0/07-flow-approval.png) | ![Approval request](screenshots/v1.0/09-approval-request.png) |
| **Power Automate** – timesheet approval flow | **Approvals** – the manager's approval request |

More in [`screenshots/v1.0`](screenshots/v1.0) and the [v1.0 release notes](docs/releases/v1.0.md).

## Tech stack

- **Power Apps** (canvas app) – the user interface
- **Microsoft Dataverse** – data model and security
- **Power Automate** – approvals, reminders and alerts
- **Power BI** – utilisation, bench forecast and skills analytics, embedded in the app
- **Power Platform CLI** + **GitHub Actions** – solution source control and CI

## Repository structure

```
├── assets/          README and portfolio images
├── data/            Seed data (fictional) for the Dataverse tables
├── docs/            Business analysis: problem statement, user stories, data model, process flows
│   └── releases/    Release notes per version
├── powerbi/         Power BI report as a Power BI Project (.pbip)
├── screenshots/     Screenshots per release
├── scripts/         Setup-Houston.ps1: builds the Dataverse data model and loads the seed data
└── solution/        Unpacked Dataverse solution (source)
```

## Getting started

1. Get a free [Power Apps Developer Plan](https://powerapps.microsoft.com/developerplan) environment.
2. Install the [Power Platform Tools](https://marketplace.visualstudio.com/items?itemName=microsoft-IsvExpTools.powerplatform-vscode) extension for VS Code.
3. Pack and import the solution (tables, app and flows):
   ```
   pac auth create --environment https://<your-org>.crm4.dynamics.com
   pac solution pack --zipfile out/Houston.zip --folder solution
   pac solution import --path out/Houston.zip
   ```
4. Load the seed data from `data/` (or build everything from scratch with `scripts\Setup-Houston.ps1 -OrgUrl https://<your-org>.crm4.dynamics.com`).
5. Turn on the three flows in the solution and set the approver in *Houston - Timesheet approval* to a user in your tenant.
6. Open `powerbi/` in Power BI Desktop and point the Dataverse connection at your environment.

## Documentation

- [Problem statement](docs/problem-statement.md)
- [User stories – v1.0 Bench](docs/user-stories.md) · [v1.1 SkillPath](docs/user-stories-v1.1.md)
- [Data model](docs/data-model.md)
- [Process flows](docs/process-flows.md)
- [Release notes](docs/releases/)

## Author

**Diogo Santos** · [LinkedIn](https://www.linkedin.com/in/diogo-santos-b22801243) · [GitHub](https://github.com/DiogoS7)

## License

[MIT](LICENSE)
