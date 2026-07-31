# xp-mpsip

POC for Management of Partners Stakes Incentives in Project

---

## Folder Structure

```
repo/
├── src/        # Source code
├── docs/       # Documentation
│   └── prd/    # Product Requirement Documents
└── publish/    # Release artifacts
```

---

## Development Workflow

All development is **PRD-driven**. Every feature, change, or improvement starts with a PRD file.

### Workflow Steps

1. **Owner** creates a PRD under `docs/prd/{nn}-{concern}/prd-{nn}-{nn}.md`
2. **Agent** reads the PRD and resolves ambiguity via Q&A
3. **Agent** updates the PRD with:
   - An **Initial Verbatim** section (original PRD content, unmodified)
   - A **Plan** section (implementation plan, approved by owner)
4. **Owner** approves the plan
5. **Agent** implements the changes
6. **Owner** explicitly requests a commit and/or push — never automatic

### PRD Naming Conventions

| Pattern | Description |
|---------|-------------|
| `docs/prd/{nn}-{concern}/` | Folder for a concern; `{nn}` is zero-padded, `{concern}` is a short label |
| `prd-{nn}-{00}.md` | **Concern summary** — overview of all PRDs in the concern |
| `prd-{nn}-{nn}.md` | Individual PRD |

Concern domains include (but are not limited to): Idea, Workflow, Product Management, Application Architecture, Design, Prototype, Modules, Services and Features, Testing, Deployment, DevOps, Reviews, Documentation.

---

## Versioning

- Scheme: **Semantic versioning** — `v{major}.{minor}.{patch}` (e.g. `v0.1.0`)
- Every revision is triggered by a PRD
- Commits are tagged with the version number
- Tags are replicated when pushed to origin

---

## Repository Rules

- **Branching**: Agent always asks whether to use the current branch or create a new one before making changes
- **No auto-commit**: Agent asks before committing; commits only when explicitly requested
- **No auto-push**: Agent asks before pushing; pushes only when explicitly requested
- **Tagged commits**: Every commit is tagged with its version number
