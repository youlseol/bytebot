# Repository Guidelines

## Project Structure & Module Organization
- `packages/bytebot-agent`, `packages/bytebot-agent-cc`: NestJS agents (Prisma-enabled).
- `packages/bytebotd`: Desktop daemon (NestJS) and OS integrations.
- `packages/bytebot-ui`: Next.js UI and custom server.
- `packages/shared`: Reusable TypeScript types/utils consumed by other packages.
- `docker/`, `helm/`: Local compose and Kubernetes charts.
- `docs/`, `static/`, `.github/`: Documentation, assets, CI workflows.

## Build, Test, and Development Commands
- Install deps per package: `cd packages/<name> && npm install` (Node 20).
- UI (dev): `cd packages/bytebot-ui && npm run dev` (builds `shared`, starts server).
- Agent (dev): `cd packages/bytebot-agent && npm run start:dev` (builds `shared`).
- Daemon (dev): `cd packages/bytebotd && npm run start:dev`.
- Build: `npm run build` in each package (agents run Prisma generate when needed).
- Test: `npm test` or `npm run test:cov` (Jest).
- Full stack (Docker): `docker-compose -f docker/docker-compose.yml up -d`.

## Coding Style & Naming Conventions
- Language: TypeScript across packages; NestJS patterns (`*.module.ts`, `*.service.ts`, `*.controller.ts`, `dto/*.dto.ts`).
- Lint/format: ESLint 9 + Prettier 3 (configs in each package). Use 2-space indent; run `npm run lint` and `npm run format`.
- Files: prefer `kebab-case` for files, `PascalCase` for classes, `camelCase` for variables/functions.

## Testing Guidelines
- Framework: Jest (unit/integration). Tests end with `.spec.ts`; default root is `src/`.
- Run: `npm test`, watch: `npm run test:watch`, coverage: `npm run test:cov` (output in `coverage/`).
- Add tests alongside code (e.g., `src/computer-use/computer-use.service.spec.ts`). Target critical paths and DTO validation.

## Commit & Pull Request Guidelines
- Commits: concise, imperative subject (e.g., "Add", "Fix", "Update"). Common prefixes seen: `doc:`, dependency bumps, and feature verbs.
- Scope where helpful (e.g., `agent:`, `daemon:`). Reference issues in the body when applicable.
- PRs: clear description, linked issue, checklist of changes, test evidence. Include screenshots for UI changes and notes on config/migrations.

## Security & Configuration Tips
- Secrets: never commit keys. Use environment files (`packages/*/.env.example`, `docker/.env`).
- Models/Proxy: configure LiteLLM via `packages/bytebot-llm-proxy/litellm-config.yaml`.
- Database: for Prisma packages, run `npm run prisma:dev` (dev) or `npm run prisma:prod` (prod) before `start:prod`.
