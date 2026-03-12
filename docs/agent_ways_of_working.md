# Coding agents: ways of working

This document provides project-level instructions and context for coding agents, ensuring adherence to GDS development standards and practices.

## Core Principles

- **Secure by Design**: Prioritize security at every stage. Follow OWASP Top Ten guidelines.
- **High Quality**: Deliver stable, readable, and well-tested code.
- **Transparency**: Use clear commit messages, detailed PRs, and document architectural decisions.

## Workflow & Task Management

- **Prerequisites**: Ensure you have a clear understanding of requirements and acceptance criteria before starting work.
- **Branching**:
  - Always create a new branch for each task.
  - Naming convention: `[ticket-number]/[short-description]` or `[type]/[ticket-number]-[short-description]` (e.g., `123/add-login-validation`).
  - Avoid using personal names in branch identifiers.
- **TDD (Test-Driven Development)**:
  - Develop code and tests concurrently.
  - Aim for full test coverage.
  - Ensure the test suite passes before every commit.

## Version Control (Git)

- **Atomic Commits**: Make small, focused, and self-contained commits.
- **Commit Messages**:
  - Use the imperative mood (e.g., "Add validation" not "Added validation").
  - Explain _what_, _why_, and _how_.
  - Reference ticket numbers if available.
- **History Management**:
  - Regularly rebase on the main development branch.
  - Tidy up commit history (e.g., via interactive rebase) before requesting a code review.
  - Prevent accidental commitment of sensitive data (API keys, credentials).

## Code Review & Pull Requests

- **Mandatory Review**: All production code changes require review by at least two people (author + reviewer).
- **PR Content**:
  - Link to the relevant ticket.
  - Describe the problem and the solution.
  - Highlight any specific difficulties or trade-offs.
  - Include screenshots for UI changes.
  - Clarify met acceptance criteria and any follow-up work.

## Deployment & CI/CD

- **Continuous Delivery**: Automate builds, tests, and deployments (e.g., via GitHub Actions).
- **Versioning**:
  - Application code: No explicit versioning required.
  - Reusable components (libraries, gems, plugins): Must follow [Semantic Versioning](https://semver.org/).

## Documentation

- **Changelog**: Maintain a `CHANGELOG.md` in the repository root for versioned components, following [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
- **ADRs**: Document significant architectural decisions using Architectural Decision Records (ADRs).

---

## Code Style

### Line Length

While not enforced by RuboCop, prefer the following:

- **Multi-line blocks**: Wrap by column 85
- **Single-line expressions**: Allow up to column 100

The goal is readability - wrap early enough to avoid horizontal scrolling
while avoiding unnecessary line breaks that hurt clarity.

When staging changes, always consider whether formatting adjustments belong
in the current commit or should be applied to earlier commits via interactive
rebase to maintain atomic, self-contained commits.

---

## Agent-Specific Instructions

When working in this repository, you **must**:

1. **Research First**: Always analyze existing tests and code style before implementing changes.
2. **Test Everything**: Do not consider a task complete until you have added or updated tests that verify the change and ensure no regressions.
3. **Commit Atomically**: Do not bundle unrelated changes. Use `git add -p` logic to stage only what is necessary for a specific commit.
4. **Rebase Frequently**: Before proposing a change, ensure your branch is rebased on the latest `main`.
5. **Detailed Explanations**: When explaining your work, focus on the "why" and "how" behind your technical decisions.
6. **Security Audit**: Proactively check for OWASP Top Ten vulnerabilities in any code you write or modify.
7. **No Secrets**: Never output or commit anything that looks like a secret or credential.
