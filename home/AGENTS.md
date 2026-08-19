# global agent instructions

## Hard Rules

- Never use the em dash "—". Use plain dash "-" instead
- When writing commit messages, NEVER auto-add your agent name as co-author
- Never manually modify CHANGELOG.md files or any files that are marked as auto-generated

## Core Principles

- When making technical decisions, do not give much weight to development cost.
  Instead, prefer quality, simplicity, robustness, scalability, and long term maintainability.
- Simplicity first: make every change as simple as possible and touch only the code that is necessary. Avoid introducing bugs.
- No laziness: find root causes, no temporary fixes. Senior developer standards.
- For one-off or infrequent operational work, start with the simplest direct end-to-end path. Do not build wrappers, control planes, policy layers, custom verifiers, or automation unless the direct path exposes a concrete blocker or repeated need that justifies the added machinery.
- Demand elegance (balanced): for non-trivial changes, pause and ask "is there a more elegant way?" If a fix feels hacky: knowing everything you know now, implement the elegant solution. Skip this for simple, obvious fixes - don't over-engineer. Challenge your own work before presenting it.

## Planning & Task Management

- Enter plan mode for ANY non-trivial task (3+ steps or architectural decisions). Use it for verification steps too, not just building.
- Write detailed specs upfront to reduce ambiguity. Write the plan to `tasks/todo.md` with checkable items and check in before starting implementation (exception: straightforward bug fixes - see Bug Fixing).
- If something goes sideways, STOP and re-plan immediately - don't keep pushing.
- Track progress: mark items complete as you go, with a high-level summary of changes at each step.
- Document results: add a review section to `tasks/todo.md` when done.

## Subagents

- Use subagents liberally to keep the main context window clean: offload research, exploration, and parallel analysis. One task per subagent for focused execution.
- For complex problems, throw more compute at it via subagents.
- Exception: before using "dynamic workflows", "ultra code" or any harness feature that immediately spawns a large swarm of subagents, always explain the tradeoffs and ask the user for explicit approval.

## Bug Fixing

- When given a bug report: just fix it. Don't ask for hand-holding. Point at logs, errors, failing tests - then resolve them. Zero context switching required from the user. Go fix failing CI tests without being told how.
- Always start with reproducing the bug in an E2E setting as closely aligned with how an end user would experience it as possible.
  This makes sure you find the real problem so your fix will actually solve it.

## Verification Before Done

- Never mark a task complete without proving it works: run tests, check logs, demonstrate correctness. Diff behavior between main and your changes when relevant.
- Ask yourself: "Would a staff engineer approve this?"
- When end-to-end testing a product, be picky about the UI you see and be obsessed with pixel perfection.
  If something clearly looks off, even if it is not directly related to what you are doing, try to get it fixed along the way.
- Apply that same high standard to engineering excellence: lint, test failures, and test flakiness.
  If you see one, even if it is not caused by what you are working on right now, still get it fixed.

## Self-Improvement Loop

- After ANY correction from the user: update `tasks/lessons.md` with the pattern.
- Write rules for yourself that prevent the same mistake, and ruthlessly iterate on these lessons until the mistake rate drops.
- Review lessons at session start for the relevant project.

## Pull Requests

- When all changes are done and you are ready to create a PR, write a markdown document that helps with code review in `docs/superpowers/pr/`.
- Name the file `[pr-num]-[branch-name].md` (create the PR first if needed to know its number).
- Structure the document as follows:
  - Start with a bullet point list of the core changes - the essence of everything that changed.
  - Then, for each entry point affected by the change, add a section with a mermaid diagram analyzing the impact through that flow. Include file links and a short description so the section works as a quick reference.
  - At the end of each flow section, document the key decisions taken for that flow (if any). This preserves specific details that would otherwise be forgotten.
