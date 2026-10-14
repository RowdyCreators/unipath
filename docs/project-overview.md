# UniPath project overview

This document consolidates the product decisions, demo scope, technology choices, team structure, and implementation workflow discussed during planning. It describes the agreed direction, not functionality already implemented.

The [MVP specification](https://github.com/RowdyCreators/unipath/issues/1) and its linked tickets are the implementation references. GitHub is authoritative for current ticket status, ownership labels, acceptance criteria, and blockers. Counts in this document are a planning snapshot, not a live progress report.

## Project descriptions

### One sentence

UniPath helps international students find affordable US universities and navigate undergraduate applications.

### Three sentences

UniPath is an independent tool that helps international students explore US universities based on their intended major, budget, and preferences. It explains university costs and scholarship eligibility, provides application checklists, and links students to official visa resources. Students can save universities, track their progress, and connect with others through university-specific discussion forums.

## Purpose and audience

UniPath helps international students exploring first-year undergraduate study in the United States. Students may still be deciding which universities fit them and need help understanding costs, funding opportunities, and the application process.

The first version prioritizes:

- Intended major and total annual budget.
- Documented scholarship opportunities and eligibility requirements.
- Clear university-specific application information.
- Saved research and application progress.
- University-specific conversations with other students.

UniPath is an independent student tool. School-paid placement, referral-driven rankings, and a monetization model are not part of the demo. Recommendations should explain the student's fit rather than imply institutional endorsement.

Transfer students and graduate applicants are deferred. The MVP is English-only. There is no age gate in the demo; age policy and safeguards for minors remain unresolved requirements before public deployment.

## Delivery target and capacity

The immediate target is a viable demo for a seven-week group project between university students. Public deployment is a later goal, not the acceptance target for these seven weeks.

The team has approximately seven people:

| Subteam | People | Main responsibility |
| --- | ---: | --- |
| Backend | 3 | Flask, PostgreSQL, authentication, permissions, persistence, and algorithm adapters |
| Frontend | 2 | HTML/CSS/JavaScript screens and interactions using Vite |
| Algorithms | 2 | College search, scholarship criteria, cost logic, and curated university records |

Each person expects to contribute about 30 minutes a day. Over seven weeks, that is roughly 170 person-hours if weekends count, before meetings, source verification, debugging, review, and integration.

Tickets target approximately 30-minute sessions once their prerequisites are available. This is a sizing goal, not a promise. Initial environment setup, authentication, and university-data verification may take longer. If a ticket grows, record a checkpoint and propose a smaller follow-up instead of silently expanding its scope.

No fixed calendar deadline or detailed weekly schedule was agreed. Protect the complete signup-to-results journey when deciding what to prioritize.

## Complete student journey

The main demo journey is:

1. Create an account through managed authentication.
2. Complete the questionnaire.
3. Receive explained university suggestions.
4. Select a university and inspect detailed fit, cost, scholarship, and application information.
5. Compare universities and save a shortlist.
6. Mark application checklist tasks complete.
7. Read, create, and reply to permitted university discussions.
8. Return later or edit answers without losing saved progress.

University recommendations appear before the student chooses a school to inspect. Selection opens detailed results; the student is not required to choose a university blindly before receiving suggestions.

Visitors may browse public university information. Saving answers, maintaining a shortlist, tracking progress, and participating in discussions require an account. Reading discussions also requires saving the corresponding university.

## Questionnaire

### Required answers

| Field | Meaning |
| --- | --- |
| Intended major | One of the four supported demo majors |
| Annual budget | Total annual spending limit in US dollars, not tuition alone |
| Intended entry term | The cycle used to interpret dated costs and requirements |
| Citizenship | At least one country of citizenship; multiple citizenships are supported |

The requested "country of origin" field was clarified as citizenship, not birthplace or current residence. Citizenship affects scholarship assessment only when a published rule explicitly requires it. It must not be used to infer grades, finances, language proficiency, or visa eligibility.

Budget must be finite and nonnegative. Required and invalid answers receive clear feedback, with server-side validation as well as browser validation.

### Optional answers

- Whether financial aid is necessary or preferred.
- Location preferences, including no preference.
- Campus-size preferences, including no preference.
- Academic grades together with their grading scale.
- SAT/ACT status and scores if available.
- Supported English-test status and scores if available.

Students must be able to complete the questionnaire without optional academic information. Unknown scores are not zero, and missing information is not automatically a failed scholarship requirement.

Do not invent GPA conversions. A grading scale the system cannot interpret produces a limitation or a request for more information.

The MVP does not collect essays, passport scans, financial documents, detailed family financial records, birthplace, or residence for a personalized visa assessment.

## University catalog

### Supported majors

- Computer science.
- Engineering.
- Business.
- Biology.

The agreed upper bound is up to five universities per major. For the first demo, the ticket plan starts with two universities per major. Universities may overlap across major lists, and the same university must retain one stable identity rather than becoming duplicate records.

The early idea of several top universities in every state was replaced by this smaller major-specific catalog. Complete state or nationwide coverage is not required.

Use curated, highly ranked examples for the demo without claiming they are universally the five best institutions for a subject. Any explicit ranking claim needs an identified source and year. A broader, more balanced catalog is a future goal.

### Data to curate

Each university record should contain the applicable known information:

- University identity, supported majors, location, and campus characteristics.
- Tuition, fees, housing, food, insurance, and other published annual expenses.
- Cost completeness, currency, and applicable year or entry cycle.
- Application requirements and known deadlines.
- Scholarship and aid policies, supported criteria, amounts, and conditions.
- Official source links and verification dates.

Manually curate structured records. Preload the records before the presentation. The demo does not require scraping, live university-site retrieval, or a university-data editing dashboard.

Unknown facts remain unknown. Missing expenses are not zero. A dated policy or cost record is not silently treated as current for another entry term.

## College-search and affordability logic

The algorithms team owns the decisions. Flask supplies stored inputs and returns results; the frontend renders explanations rather than reproducing search rules in JavaScript.

The matching policy is:

1. Match universities offering the selected supported major.
2. Prioritize known complete annual costs within the student's budget before aid.
3. Show known over-budget alternatives separately with visible funding gaps.
4. Distinguish unknown or incomplete costs from known affordability.
5. Use location and campus preferences to order otherwise comparable options.
6. Explain why each university appears.

Identical inputs should yield deterministic ordering. No arbitrary criteria score should be presented as an admission or scholarship probability.

If the catalog has no suitable match, say so. If no university is known to be affordable, say so while allowing clearly labeled over-budget or cost-unknown alternatives. Do not force a misleading recommendation.

### Costs and funding scenarios

Show the estimated annual cost before aid first. A scholarship-adjusted cost is a separate conditional scenario with its assumptions visible.

A matched automatic-award policy can support such a scenario when annual amount, currency, cycle, and other inputs are compatible. It is still subject to institutional conditions. Do not assume unsupported award stacking, renewal, or full coverage.

Competitive awards must not reduce default costs or make a school appear affordable as though the student has already won funding.

## Scholarship assessment

Budget and scholarship support are central to the product. The final MVP assesses published requirements, not the probability of winning an award.

### Result categories

| Category | Meaning |
| --- | --- |
| Criteria matched | All applicable documented criteria can be evaluated as satisfied |
| More information needed | The system cannot evaluate all applicable criteria and has not established an unmet criterion |
| Criteria not matched | A documented criterion is demonstrably unmet |

Explain unmet requirements and missing information. When a result has both an unmet criterion and unknown information, show both rather than concealing the limitation.

### Award types

| Type | What the MVP can show | What it must not claim |
| --- | --- | --- |
| Automatic merit award | A conditional match against supported published rules and the documented amount | An unconditional award promise or a winning percentage |
| Competitive scholarship | Published eligibility, coverage, deadlines, conditions, and an explained criteria assessment | Personalized selection odds, including "probable," "maybe," or "improbable" |
| Need-based aid | Published policy and official assessment resources or calculators with their limitations | An award determined from the student's budget alone |

Meeting eligibility does not establish competitive selection likelihood. That likelihood remains unknown.

The earlier request for questionnaire-derived scholarship chances, including qualitative likelihood labels, was replaced by the three criteria categories above. Demo inaccuracy is not a justification for presenting invented probabilities as financial guidance.

### Research behind this decision

A bounded check of official sources found examples of different funding policies:

- [University of Alabama international freshman scholarships](https://afford.ua.edu/scholarships/oos-international-freshman/) illustrates published automatic merit thresholds and institutional conditions.
- [American University's Emerging Global Leader Scholarship](https://www.american.edu/admissions/international/au-egls-apply.cfm) illustrates competitive eligibility and coverage, without evidence sufficient for individualized winning odds in the inspected material.
- [Harvard's financial-aid policy](https://college.harvard.edu/financial-aid/how-aid-works) and [net-price calculator](https://college.harvard.edu/financial-aid/net-price-calculator) illustrate need-based policy and estimate limitations rather than merit-award predictions.

These examples do not require those universities to be included in the catalog. The research was not an exhaustive claim that predictive data exists nowhere. Exact policy terms, award counts, costs, and deadlines must be checked again for the relevant cycle when records are curated.

Historical program-level applicant counts must not be mixed with current award counts or interpreted as an individual's chance. Validated predictions would need suitable outcome evidence and evaluation beyond this MVP.

## Application and visa guidance

Provide predefined, source-linked university application checklists relevant to the student's intended entry term. Track completion separately for each account and saved university.

If current-cycle information or a particular situation is unsupported, state the limitation and link to the official resource. Do not invent a requirement or silently reuse another cycle's deadline.

Visa guidance is general and linked to official resources. The MVP does not branch into citizenship-specific or residence-specific immigration advice. Major-specific catalog lists do not determine visa requirements.

No AI-generated advice, personalized immigration eligibility decision, application submission, or visa/admission guarantee is included.

## Editing answers and preserving progress

Students can revisit their questionnaire after seeing results.

After a successful edit:

- Recalculate university matching and scholarship assessment from the new saved answers.
- Preserve saved universities and their discussion-access relationships.
- Flag saved universities that no longer fit the major or budget.
- Preserve completed checklist tasks.
- Mark affected requirements for review if a relevant change alters their applicability.
- Leave unrelated completion state intact. A budget edit must not erase application progress.

Failed saves must not be displayed as successful. The browser must refresh returned state rather than inventing an updated assessment locally.

## University discussions

Discussions are university-specific. Students can create topics about relevant issues rather than choosing from a fixed, exhaustive topic list. A general cross-university forum and private messages are not part of the MVP.

Saving or bookmarking a university is one free relationship used both for the shortlist and discussion access. There is no paid subscription gate.

### Topic types and access

| Account state for the selected university | Read discussions | Create/reply to ordinary topics | Create/reply to verified topics |
| --- | --- | --- | --- |
| Visitor or university not saved | No | No | No |
| University saved, account unverified | Yes | Yes | No |
| University saved, email verified for that university | Yes | Yes | Yes |

Verification must be associated with the specific university, not merely any `.edu` address. Access to a mailbox does not prove current enrollment, expertise, correct advice, or official representation.

Flask enforces these rules on actual requests. Disabled browser buttons are not sufficient authorization.

### Demo verification and real interaction

Live university-email verification is deferred. A clearly identified seeded account has a server-side verification association for the demonstrated university and can create and reply to both topic types.

New accounts remain unverified. Typing an `.edu` email, supplying a badge in a request, or changing browser state does not grant verification. Do not create a public shortcut for assigning verified status.

Seeded discussion content avoids an empty forum, but new topic creation and replies are real persisted interactions. Preserve authorship and ordering.

Unsaving a university revokes discussion access without deleting historical contributions. Saving again restores access allowed by the account's existing verification state.

### Basic filtering

Use a small configured keyword policy to warn about suspicious topic or reply text before publication.

- Identify the keyword or phrase that triggered the warning.
- Allow the author to edit and resubmit.
- Allow explicit continuation with otherwise valid text.
- Reject empty, whitespace-only, and oversized content on the server as well as in the browser.
- Keep authorization and content validation in force after continuation.

The warning must not pretend to reliably distinguish scams from someone discussing a scam.

Reporting, manual moderator tools, removals, suspensions, advanced filtering, and college-representative moderation are deferred. Those are public-deployment concerns, not solved by a keyword warning.

## Technology stack and runtime

| Area | Agreed technology or constraint |
| --- | --- |
| Frontend | Plain HTML, CSS, and JavaScript |
| Frontend tooling | Vite |
| Frontend package manager | npm |
| Backend | Python with Flask |
| Search and scholarship decisions | Python modules called by Flask |
| Database | Hosted PostgreSQL, the application data's single source of truth |
| Authentication | Managed authentication; provider selection belongs to the auth contract ticket |
| Demo runtime | Frontend and Flask on an internet-connected laptop |
| University information | Preloaded curated records, not live scraping |

Keep algorithm modules independent of HTTP handling, authentication SDKs, and database access. Callers supply applicant, university, and policy data plus an explicit date when evaluation is date-sensitive.

Flask validates identity, reads stored records, calls the module, and returns explained results. The browser renders those results and sends user actions back to Flask.

Hosted PostgreSQL requires connectivity. The accepted demo is online; offline storage and synchronization were explicitly deferred. Test data must be isolated from the hosted presentation database.

### Logical records

The implementation needs explicit relationships for:

- Authentication identity and application account.
- Questionnaire answers.
- Universities, supported majors, costs, sources, and applicable cycles.
- Scholarship and aid policies.
- Saved universities.
- Application requirements and account-specific checklist progress/review state.
- University-specific email-verification associations.
- Topics and replies with authorship and ordering.

These are logical requirements, not an assertion that a database schema already exists. Exact storage layout and HTTP endpoint paths are implementation choices constrained by the agreed contracts.

## Three-subteam implementation model

The initial 54 tickets were end-to-end vertical slices. They were restructured so three subteams can work independently while retaining real integration gates.

| Subteam | Owns | Does not own |
| --- | --- | --- |
| Frontend | Forms, navigation, display, HTTP client behavior, loading/errors, shortlist/checklist/forum interactions | Search rules, scholarship eligibility decisions, server permissions, persistence |
| Backend | Flask operations, PostgreSQL records, identity, validation, permissions, persistence, import/content operations, module adapters | Browser screens or duplicated ranking/eligibility decisions |
| Algorithms | Pure callable search/funding logic, deterministic explanations, and contract-valid curated college records | Flask request handling, authentication, PostgreSQL access, or browser screens |

### Contracts and independent work

Small feature-specific contract tickets establish:

- Authentication identity and session handoff.
- Questionnaire reads, updates, validation, and unknown states.
- Curated university record exchange.
- Search inputs and explained results.
- Scholarship rules, assessments, and conditional scenarios.
- Shortlist operations.
- Checklist requirements, completion, and review state.
- Discussion operations, capabilities, content limits, and warning confirmation.

Frontend can use agreed HTTP fixtures in explicitly enabled development/test mode without waiting for completed backend endpoints. Algorithms can use sample applicant/catalog/policy records without Flask or a live database. Backend can implement persistence and operations from the contracts, then connect completed callable modules.

Do not silently fall back to fixtures after a real request fails. A fixture-backed screen is a team-local deliverable, not proof that the integrated feature works.

### Current ticket organization

The refactor preserved all 54 existing issue numbers and added 36 contract/counterpart tickets, for 90 team-owned tickets. All implementation tickets use `ready-for-human` and one ownership label.

| Ownership label | Tickets at refactor | Starting ticket |
| --- | ---: | --- |
| `team:frontend` | 32 | [#56: Start the Vite frontend and browser checks](https://github.com/RowdyCreators/unipath/issues/56) |
| `team:backend` | 35 | [#2: Start Flask with a PostgreSQL-backed university read](https://github.com/RowdyCreators/unipath/issues/2) |
| `team:algorithms` | 23 | [#57: Start a callable Python search module](https://github.com/RowdyCreators/unipath/issues/57) |

The counts include contract tasks and frontend-led integration coordination. Ownership labels do not assign individual teammates automatically.

The three starting tickets are independent. Initial contract work can also begin in [#58](https://github.com/RowdyCreators/unipath/issues/58), [#59](https://github.com/RowdyCreators/unipath/issues/59), [#60](https://github.com/RowdyCreators/unipath/issues/60), and [#61](https://github.com/RowdyCreators/unipath/issues/61).

The refactored graph has 204 native blocking relationships and was checked for cycles. Work from the frontier: a ticket may start when its actual blockers are completed. `ready-for-human` describes implementation ownership; it does not mean a blocked ticket is immediately startable.

Use the live tracker views for current work:

- [Frontend tickets](https://github.com/RowdyCreators/unipath/issues?q=is%3Aissue+is%3Aopen+label%3A%22team%3Afrontend%22).
- [Backend tickets](https://github.com/RowdyCreators/unipath/issues?q=is%3Aissue+is%3Aopen+label%3A%22team%3Abackend%22).
- [Algorithms tickets](https://github.com/RowdyCreators/unipath/issues?q=is%3Aissue+is%3Aopen+label%3A%22team%3Aalgorithms%22).

The parent spec's title, body, state, and labels were left unchanged during ticket restructuring.

## Testing approach

The agreed primary acceptance seam is the application's public interface, exercised through browser-level integration tests of the real frontend and Flask application against isolated PostgreSQL data.

Test externally observable results, not private helper calls, database query structure, arbitrary ranking weights, or incidental DOM implementation details.

The three-team structure also permits focused handoff checks:

| Work | Team-local verification |
| --- | --- |
| Contracts | Valid, unknown, and relevant failure payloads with agreed field/error meanings |
| Frontend | Visible behavior and requests against agreed development/test HTTP fixtures |
| Backend | Public Flask operations with isolated PostgreSQL and supported test identities |
| Algorithms | Public callable/record outputs from deterministic sample inputs |
| Integration | Real browser, Flask, PostgreSQL, and algorithm behavior together |

Team-local checks supplement, rather than replace, the primary real-stack acceptance tests. Do not introduce test-only public permission-granting shortcuts.

### Required behavioral coverage

- Signup, returning sign-in, sign-out, and the complete questionnaire-to-results journey.
- Required and optional inputs, multiple citizenships, invalid values, missing test scores, and unsupported grade scales.
- Major matching, budget equality, over-budget gaps, unknown/incomplete costs, no match, and no known affordable option.
- Preference ordering and visible fit explanations.
- Source/date visibility and entry-cycle limitations.
- Automatic criteria matched/not matched/unknown, competitive eligibility with unknown likelihood, and need-based policy limitations.
- Explicit nationality rules, English-test criteria, deadlines, and conditional cost assumptions.
- Comparison, saved-school persistence, answer edits, recalculation, and mismatch warnings.
- Per-school task completion, preserved progress, and review flags only for affected requirements.
- Topic/reply persistence and ordinary versus university-specific verified permissions.
- Direct-request rejection for another account's private data, unsaved universities, ordinary accounts posting in verified topics, wrong-university verification, and forged verification claims.
- Keyword warnings, editing, explicit continuation, and empty/oversized submission rejection.
- Access revocation after unsaving without deleting contributions.

Use fictional applicants, deterministic university/policy fixtures, and a clearly disclosed seeded university-verification association. Tests must not depend on live university websites or mutate hosted demo data. Date-sensitive rules receive explicit test dates.

At initial exploration, the repository had no application or test suite and its CI build/lint/test steps were placeholders. Replace placeholder passes with actual checks as tooling is introduced; a green placeholder workflow is not acceptance evidence.

## Demo acceptance and integration gates

The live presentation must demonstrate a complete signup-to-university-results journey. It should also demonstrate comparison, answer editing, saved universities, checklist progress, and persistent discussion interactions against seeded content.

The acceptance gates are:

- [#54: Integrate and rehearse the real signup-to-results journey](https://github.com/RowdyCreators/unipath/issues/54).
- [#55: Integrate and rehearse real progress and university discussions](https://github.com/RowdyCreators/unipath/issues/55).

Frontend leads these rehearsals with backend and algorithms support. Use the actual application and callable logic, not fixed HTTP or search responses. Seeded content and the disclosed account verification fixture are allowed, but must not be presented as live verification or a real populated community.

Record repeatable rehearsal steps and concrete failures. Team-local tickets being closed does not by itself prove the complete journey works.

## Out of scope and future work

The following are deferred, not silently assumed to be implemented:

- Transfer and graduate admissions.
- Majors beyond the four demo subjects.
- Nationwide/every-state coverage and a complete ranking product.
- A broader, more balanced catalog beyond the initial curated selections.
- Validated scholarship-winning probabilities, admission predictions, and trained machine-learning models.
- AI-generated application or immigration advice.
- Personalized citizenship/residence-specific visa eligibility or legal advice.
- Application filling/submission, essay review, and sensitive document uploads.
- Detailed family financial-data collection or a homegrown need-based aid calculator.
- Automated scraping, live university-site retrieval, and a data-editing dashboard.
- Live university-email verification and verified official representative roles.
- Reporting, manual moderation tools, removals/suspensions, and advanced scam detection.
- College representatives moderating their university discussions.
- General forums, private messaging, payments, and paid subscriptions.
- Offline operation and local/hosted database synchronization.
- Multilingual support.
- Age verification and a demo age gate; age policy and safeguards for minors before public release.
- Public deployment and production-scale reliability claims.

Public release remains a later goal. It needs current verified data, real verification and moderation decisions, a minors/privacy policy, secure operations, and the repository's licensing question resolved. The current repository has no license file; follow the warning in the README before publishing or sharing code outside the organization.

## How earlier decisions changed

| Earlier idea | Final agreed MVP direction |
| --- | --- |
| Help all international admissions paths | First-year undergraduate applicants only |
| Several top universities in every state | Four major-specific lists, initially two universities per major, up to five |
| Estimate scholarship-winning chances | Explain published criteria using three categories; competitive likelihood unknown |
| "Probable / maybe / improbable" scholarship labels | Criteria matched / more information needed / criteria not matched |
| Personalize visa guidance by every citizenship/residence situation | General official-source visa guidance; personalize school application information |
| A broad/general forum with university tags | University-specific discussions only |
| Subscription or bookmark gate | One free saved-university relationship controls shortlist and discussion access |
| Any `.edu` verification | Verification associated with the specific university |
| Live university-email verification for the demo | Disclosed server-side seeded verification for a demo account |
| A minimum age of 16 | No demo age gate; public age policy remains deferred |
| Hosted site for the presentation | Internet-connected laptop frontend/API with hosted PostgreSQL |
| Offline laptop operation | Online demo; no synchronization system |
| Manual moderation in the MVP | Keyword warnings and basic content validation only; moderation deferred |
| One end-to-end implementation owner per ticket | Three team-owned work streams with contracts and real integration gates |

## Repository and engineering workflow

The repository is [RowdyCreators/unipath](https://github.com/RowdyCreators/unipath). The agreed workflow is recorded in [CONTRIBUTING.md](../CONTRIBUTING.md):

- Work on short-lived branches from `main`.
- Use Conventional Commit PR titles.
- Prefer small PRs, targeting fewer than roughly 400 changed lines where practical.
- Run relevant local checks and require green CI plus code-owner approval.
- Resolve review discussions and squash merge.
- Do not push directly to `main`.

Project instruction and skill configuration files are:

- [AGENTS.md](../AGENTS.md): development instructions, technology stack, and conditional pointers to skill configuration.
- [Issue tracker configuration](agents/issue-tracker.md): GitHub Issues conventions using `gh`.
- [Triage label mapping](agents/triage-labels.md): the five canonical roles and their tracker names.
- [Domain documentation rules](agents/domain.md): root glossary and ADR consumer rules.

The configured triage roles are `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, and `wontfix`. Current implementation tickets use `ready-for-human`, plus their team ownership label. Configuration of the five roles is not a claim that every role's GitHub label has already been created.

Issues and specs live in GitHub Issues, not local Markdown ticket files. Pull requests are not configured as a separate feature-request triage queue.

The domain layout is single-context: root `GLOSSARY.md` and `docs/adr/` when those are introduced. Read the glossary and relevant ADRs when present, use their vocabulary, and explicitly flag conflicts. Their absence does not require creating empty domain documents.

The repository was explored as a governance scaffold, with no application implementation to preserve. This planning work created configuration, specifications, and tickets; it did not implement the product.

## Implementation choices still open

These are delegated choices within the agreed scope, not reasons to reopen the product interview:

- Managed-auth provider and its supported test-account flow.
- Exact universities selected for the initial major lists.
- Specific storage layout and HTTP operation paths consistent with the contracts.
- Browser-test runner and detailed startup commands.
- Supported test types, score representations, and grading scales that can actually be evaluated.
- Documented finite topic/reply limits and the small keyword-warning list.
- Individual ticket assignees and fixed calendar milestones.
- Hosting/security arrangements for a later public deployment.

Choose these without weakening permissions, inventing scholarship likelihood, expanding the catalog beyond the demo's capacity, or replacing real integration acceptance with fixture-only demonstrations.
