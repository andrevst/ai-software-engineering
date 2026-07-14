# TypeScript Development Guidelines
**Version:** 2026-07-13 | **Stack:** FamilyHub — Next.js 15, Supabase, Zod, Jest, Sentry

---

## 1. Principles

TypeScript is a discipline, not a type annotation layer on JavaScript. These guidelines enforce correctness at the type level so runtime errors become compile-time errors.

**Core commitments:**
- `strict: true` always. No exceptions for new files.
- Types express intent. If a type needs a comment to explain it, the type is wrong.
- Errors are values. Throwing is for truly unrecoverable situations.
- Narrow early, widen never. Accept `unknown`, assert nothing.
- Dead code is worse than no code. Delete it.

---

## 2. Project Init

### tsconfig.json

```jsonc
// tsconfig.json — minimum required for strict TypeScript
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "lib": ["ES2022"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "forceConsistentCasingInFileNames": true,
    "skipLibCheck": false,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "resolveJsonModule": true,
    "esModuleInterop": true,
    "isolatedModules": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "**/*.test.ts", "**/*.spec.ts"]
}
```

`noUncheckedIndexedAccess` and `exactOptionalPropertyTypes` are not included in `strict: true` — add them explicitly. They eliminate entire categories of runtime bugs.

### package.json scripts

```json
{
  "scripts": {
    "build": "tsc --project tsconfig.json",
    "build:watch": "tsc --watch --project tsconfig.json",
    "typecheck": "tsc --noEmit",
    "lint": "eslint 'src/**/*.ts' --max-warnings 0",
    "test": "jest --passWithNoTests",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage --coverageThreshold='{\"global\":{\"lines\":80}}'",
    "test:integration": "jest --config jest.integration.config.ts",
    "clean": "rimraf dist"
  }
}
```

### CLI commands

```bash
# Initialize a new TypeScript project
npm init -y && npm install --save-dev typescript @types/node ts-node

# Generate default tsconfig
npx tsc --init

# Type-check only (no emit)
npx tsc --noEmit

# Compile to dist
npx tsc --project tsconfig.json

# Watch mode type-check
npx tsc --noEmit --watch

# Install strict ESLint for TypeScript
npm install --save-dev eslint @typescript-eslint/parser @typescript-eslint/eslint-plugin

# Run ESLint
npx eslint 'src/**/*.ts' --ext .ts

# Format with Prettier
npx prettier --write 'src/**/*.ts'

# Check types and lint in one pass (CI)
npx tsc --noEmit && npx eslint 'src/**/*.ts' --max-warnings 0
```

---

## 3. Structure

Flat within feature, grouped by domain. Avoid folders whose only job is `utils/`.

```
src/
  env.ts               # Zod-validated env, imported once at startup
  index.ts             # Entry point — loads env first, then services

  auth/
    auth.service.ts
    auth.types.ts
    auth.test.ts

  users/
    users.repository.ts
    users.service.ts
    users.types.ts
    users.test.ts

  shared/
    result.ts          # Result<T,E> type — used everywhere
    logger.ts          # Structured logger singleton
    db.ts              # Pool / client singleton
    errors.ts          # AppError hierarchy
    http.ts            # Typed HTTP client wrapper

tests/
  integration/
    users.integration.test.ts

  load/
    users.load.ts      # k6 script

jest.config.ts
jest.integration.config.ts
tsconfig.json
```

---

## 4. Docker

TypeScript compiles at build time. The container runs compiled JavaScript.

```dockerfile
# Dockerfile — multi-stage, TypeScript compiled before runtime image
FROM node:22-alpine AS builder
WORKDIR /app
COPY package*.json tsconfig.json ./
RUN npm ci --include=dev
COPY src ./src
RUN npm run build

FROM node:22-alpine AS runtime
ENV NODE_ENV=production
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev
COPY --from=builder /app/dist ./dist
USER node
CMD ["node", "dist/index.js"]
```

```bash
# Build the image
docker build -t familyhub-api:local .

# Run with env file
docker run --env-file .env.local familyhub-api:local

# Inspect compiled output size
docker run --rm familyhub-api:local du -sh /app/dist
```

`ts-node` does not belong in a production Docker image. Compile to JavaScript, run JavaScript.

---

## 5. Nomenclature

| Construct | Convention | Example |
|---|---|---|
| Variables, functions | `camelCase` | `getUserById` |
| Types, interfaces, classes | `PascalCase` | `UserProfile` |
| Constants (module-level) | `SCREAMING_SNAKE_CASE` | `MAX_RETRY_COUNT` |
| Files | `kebab-case` | `user-profile.ts` |
| Test files | `<subject>.test.ts` | `users.test.ts` |
| Enum members | `PascalCase` | `Status.Active` |
| Generic type parameters | Single uppercase letter or descriptive `T`-prefix | `T`, `TResult`, `TKey` |
| Boolean variables | `is`, `has`, `can`, `should` prefix | `isAuthenticated` |

```typescript
// GOOD: names are self-documenting
const MAX_RETRY_COUNT = 3;
type UserId = string & { readonly _brand: "UserId" };

function findUserById(id: UserId): Promise<Result<User, NotFoundError>> { ... }

// BAD: abbreviations and type-in-name antipatterns
const maxRt = 3;
type IUserInterface = { ... };
function getUsr(i: string): any { ... }
```

---

## 6. Types

### Strict null safety

```typescript
// GOOD: explicit about absence
function getUser(id: string): User | null {
  return users.find((u) => u.id === id) ?? null;
}

// BAD: returning undefined silently
function getUser(id: string): User {
  return users.find((u) => u.id === id)!; // non-null assertion = lying to compiler
}
```

### Discriminated unions

```typescript
// Model mutually exclusive states as a union — the discriminant is the `type` field
type AuthState =
  | { type: "unauthenticated" }
  | { type: "loading" }
  | { type: "authenticated"; user: User; token: string }
  | { type: "error"; message: string };

// Exhaustive check — compiler errors if a branch is unhandled
function render(state: AuthState): string {
  switch (state.type) {
    case "unauthenticated": return "Please log in";
    case "loading":         return "Loading...";
    case "authenticated":   return `Hello, ${state.user.name}`;
    case "error":           return `Error: ${state.message}`;
    // no default needed — TypeScript enforces exhaustiveness
  }
}
```

### Branded types

```typescript
// Prevent mixing IDs of different entity types at compile time
type UserId = string & { readonly _brand: "UserId" };
type FamilyId = string & { readonly _brand: "FamilyId" };

const toUserId = (raw: string): UserId => raw as UserId;

function getUser(id: UserId): User { ... }
// getUser(familyId) — compile error
```

### Utility types

```typescript
// Readonly at the boundary, mutable inside the function
function processUsers(users: ReadonlyArray<User>): ProcessedUser[] { ... }

// Pick only what you need from a large type
type UserSummary = Pick<User, "id" | "name" | "email">;

// Omit internal fields before sending to client
type PublicUser = Omit<User, "passwordHash" | "mfaSecret">;

// Record for typed dictionaries
const statusLabels: Record<Status, string> = {
  [Status.Active]: "Active",
  [Status.Inactive]: "Inactive",
  [Status.Suspended]: "Suspended",
};
```

### `unknown` over `any`

```typescript
// GOOD: unknown forces explicit narrowing
function parseJson(raw: string): unknown {
  return JSON.parse(raw);
}

const data = parseJson(input);
if (typeof data === "object" && data !== null && "id" in data) {
  // narrowed here
}

// BAD: any disables the type system entirely
function parseJson(raw: string): any {
  return JSON.parse(raw); // caller gets no type safety
}
```

---

## 7. Functions

### Pure functions

```typescript
// GOOD: pure — same input always yields same output, no side effects
function calculateDiscount(price: number, percent: number): number {
  return price * (1 - percent / 100);
}

// BAD: impure, depends on external mutable state
let discountRate = 0.1;
function calculateDiscount(price: number): number {
  return price * (1 - discountRate); // hidden dependency
}
```

### Explicit return types on exported functions

```typescript
// Always annotate return types on public API functions
// TypeScript can infer, but explicit types catch accidental type widening

export function createUser(input: CreateUserInput): Promise<Result<User, ValidationError>> {
  // ...
}
```

### Overloads

```typescript
// Use overloads when the return type depends on the input type
function findById(id: string): User | null;
function findById(id: string, strict: true): User;
function findById(id: string, strict?: boolean): User | null {
  const user = db.get(id);
  if (!user && strict) throw new Error(`User ${id} not found`);
  return user ?? null;
}
```

### Default parameters over optional chaining in signatures

```typescript
// GOOD: default parameters document expected values
function paginate(page = 1, limit = 20): PaginatedResult { ... }

// BAD: optional with no default forces callers to handle undefined
function paginate(page?: number, limit?: number): PaginatedResult { ... }
```

### Avoid variadic arguments for typed APIs

```typescript
// GOOD: destructured object — named, extensible, type-safe
function createPost({ title, body, authorId }: CreatePostInput): Promise<Post> { ... }

// BAD: positional arguments break when order changes
function createPost(title: string, body: string, authorId: string): Promise<Post> { ... }
```

---

## 8. Errors

TypeScript has no checked exceptions. Enforce discipline with Result types.

### Result type

```typescript
// src/shared/result.ts
export type Ok<T> = { readonly ok: true; readonly value: T };
export type Err<E> = { readonly ok: false; readonly error: E };
export type Result<T, E = Error> = Ok<T> | Err<E>;

export const ok = <T>(value: T): Ok<T> => ({ ok: true, value });
export const err = <E>(error: E): Err<E> => ({ ok: false, error });
```

```typescript
// Usage: recoverable errors are return values, not exceptions
async function fetchUser(id: string): Promise<Result<User, "NOT_FOUND" | "DB_ERROR">> {
  try {
    const user = await db.query("SELECT * FROM users WHERE id = $1", [id]);
    if (!user) return err("NOT_FOUND");
    return ok(user);
  } catch {
    return err("DB_ERROR");
  }
}

const result = await fetchUser(userId);
if (!result.ok) {
  // TypeScript knows result.error is "NOT_FOUND" | "DB_ERROR"
  logger.warn("fetchUser failed", { reason: result.error });
  return;
}
// TypeScript knows result.value is User here
console.log(result.value.name);
```

### Typed error hierarchy

```typescript
// src/shared/errors.ts
export class AppError extends Error {
  constructor(
    message: string,
    public readonly code: string,
    public readonly statusCode: number = 500,
    public readonly meta?: Record<string, unknown>
  ) {
    super(message);
    this.name = this.constructor.name;
    Error.captureStackTrace(this, this.constructor);
  }
}

export class ValidationError extends AppError {
  constructor(message: string, meta?: Record<string, unknown>) {
    super(message, "VALIDATION_ERROR", 400, meta);
  }
}

export class NotFoundError extends AppError {
  constructor(entity: string, id: string) {
    super(`${entity} with id ${id} not found`, "NOT_FOUND", 404, { entity, id });
  }
}

export class UnauthorizedError extends AppError {
  constructor(message = "Unauthorized") {
    super(message, "UNAUTHORIZED", 401);
  }
}
```

### Never swallow errors

```typescript
// GOOD: re-throw or return, never swallow
try {
  await riskyOperation();
} catch (error) {
  logger.error("riskyOperation failed", { error });
  throw error; // or: return err(toAppError(error))
}

// BAD: silent catch hides bugs
try {
  await riskyOperation();
} catch {
  // nothing — errors vanish here
}
```

### Exhaustive switch with never

```typescript
function assertNever(x: never): never {
  throw new Error(`Unhandled case: ${JSON.stringify(x)}`);
}

function handleStatus(status: Status): string {
  switch (status) {
    case Status.Active:    return "active";
    case Status.Inactive:  return "inactive";
    case Status.Suspended: return "suspended";
    default: return assertNever(status); // compile error if a Status is added
  }
}
```

---

## 9. Concurrency

### async/await fundamentals

```typescript
// GOOD: parallel independent fetches
const [user, settings] = await Promise.all([
  fetchUser(userId),
  fetchSettings(userId),
]);

// BAD: sequential when not dependent — doubles latency
const user = await fetchUser(userId);
const settings = await fetchSettings(userId);
```

### AbortSignal for cancellation

```typescript
// Pass AbortSignal through the call chain — do not create signals inside library code
async function fetchWithTimeout(
  url: string,
  signal?: AbortSignal,
  timeoutMs = 5000
): Promise<Response> {
  const timeoutSignal = AbortSignal.timeout(timeoutMs);
  const combined = signal
    ? AbortSignal.any([signal, timeoutSignal])
    : timeoutSignal;

  return fetch(url, { signal: combined });
}
```

```typescript
// Caller controls the lifecycle
const controller = new AbortController();
const { signal } = controller;

// Cancel on route change / component unmount / request completion
setTimeout(() => controller.abort(), 10_000);

const response = await fetchWithTimeout(url, signal);
```

### Promise.allSettled for partial failures

```typescript
// When all results are needed, even if some fail
const results = await Promise.allSettled([
  sendEmail(user),
  sendPushNotification(user),
  logActivity(user),
]);

for (const result of results) {
  if (result.status === "rejected") {
    logger.error("Notification delivery failed", { reason: result.reason });
  }
}
```

### Limit concurrency

```typescript
// Run at most N promises at a time — avoid overwhelming downstream services
async function processInBatches<T, R>(
  items: T[],
  batchSize: number,
  process: (item: T) => Promise<R>
): Promise<R[]> {
  const results: R[] = [];
  for (let i = 0; i < items.length; i += batchSize) {
    const batch = items.slice(i, i + batchSize);
    results.push(...(await Promise.all(batch.map(process))));
  }
  return results;
}
```

### Async error propagation

```typescript
// GOOD: errors from async functions propagate as rejected promises
async function main(): Promise<void> {
  const result = await riskyOperation(); // rejection surfaces to caller
}

// BAD: fire-and-forget loses errors
function main(): void {
  riskyOperation(); // promise rejection is unhandled — Node.js will warn or crash
}

// Pattern for top-level fire-and-forget with error capture
riskyOperation().catch((error) => {
  logger.error("Background task failed", { error });
  Sentry.captureException(error);
});
```

---

## 10. Interfaces

### Prefer type aliases for unions and primitives, interfaces for object shapes

```typescript
// Interface: object shape — can be extended via declaration merging
interface Repository<T, ID = string> {
  findById(id: ID): Promise<T | null>;
  save(entity: T): Promise<T>;
  delete(id: ID): Promise<void>;
}

// Type alias: unions, primitives, mapped types
type Status = "active" | "inactive" | "suspended";
type UserId = string & { readonly _brand: "UserId" };
type Nullable<T> = T | null;
```

### Composition over inheritance

```typescript
// GOOD: compose small interfaces
interface Timestamps {
  readonly createdAt: Date;
  readonly updatedAt: Date;
}

interface SoftDelete {
  readonly deletedAt: Date | null;
}

interface User extends Timestamps, SoftDelete {
  readonly id: UserId;
  readonly email: string;
  readonly name: string;
}

// BAD: deep inheritance chains
class BaseEntity { ... }
class AuditableEntity extends BaseEntity { ... }
class User extends AuditableEntity { ... }  // rigid, hard to test
```

### Structural typing for test doubles

```typescript
// Depend on structural shape, not class identity
interface UserRepository {
  findById(id: UserId): Promise<User | null>;
}

// Any object with findById matches — no need to extend or import the real class
const fakeRepo: UserRepository = {
  findById: async (id) => mockUser,
};
```

### readonly by default

```typescript
// Mark all interface properties readonly unless mutation is explicitly required
interface Config {
  readonly dbUrl: string;
  readonly port: number;
  readonly maxConnections: number;
}
```

---

## 11. Tests

### Jest configuration

```typescript
// jest.config.ts
import type { Config } from "jest";

const config: Config = {
  preset: "ts-jest",
  testEnvironment: "node",
  roots: ["<rootDir>/src"],
  testMatch: ["**/*.test.ts"],
  collectCoverageFrom: ["src/**/*.ts", "!src/**/*.test.ts", "!src/index.ts"],
  coverageThreshold: {
    global: { lines: 80, branches: 70 },
  },
  clearMocks: true,
  restoreMocks: true,
};

export default config;
```

```bash
# Install Jest + ts-jest
npm install --save-dev jest ts-jest @types/jest

# Run all tests
npx jest

# Run a specific test file
npx jest src/users/users.test.ts

# Run tests matching a pattern
npx jest --testNamePattern="findById"

# Generate coverage report
npx jest --coverage

# Run in CI mode (no watch, fail on first error)
npx jest --ci --forceExit
```

### AAA pattern

```typescript
// src/users/users.test.ts
import { UsersService } from "./users.service";
import { createMockRepository } from "../shared/test-helpers";

describe("UsersService", () => {
  describe("findById", () => {
    it("returns the user when found", async () => {
      // Arrange
      const mockUser: User = { id: toUserId("u1"), name: "Alice", email: "alice@example.com" };
      const repo = createMockRepository({ findById: async () => mockUser });
      const service = new UsersService(repo);

      // Act
      const result = await service.findById(toUserId("u1"));

      // Assert
      expect(result.ok).toBe(true);
      if (result.ok) {
        expect(result.value).toEqual(mockUser);
      }
    });

    it("returns NOT_FOUND when user does not exist", async () => {
      // Arrange
      const repo = createMockRepository({ findById: async () => null });
      const service = new UsersService(repo);

      // Act
      const result = await service.findById(toUserId("missing"));

      // Assert
      expect(result.ok).toBe(false);
      if (!result.ok) {
        expect(result.error).toBe("NOT_FOUND");
      }
    });
  });
});
```

### TDD cycle

```bash
# 1. Write a failing test
npx jest --watch --testNamePattern="should create user"

# 2. Implement the minimum code to pass
# 3. Refactor — tests stay green
```

---

## 12. Mocks

### jest.mock for modules

```typescript
// Mock an entire module — declaration is hoisted by Jest
jest.mock("../shared/db", () => ({
  query: jest.fn(),
}));

import { query } from "../shared/db";

const mockQuery = jest.mocked(query);

beforeEach(() => {
  mockQuery.mockResolvedValue({ rows: [], rowCount: 0 });
});

it("calls the database with the correct query", async () => {
  mockQuery.mockResolvedValueOnce({ rows: [{ id: "u1", name: "Alice" }], rowCount: 1 });
  const result = await findUser("u1");
  expect(mockQuery).toHaveBeenCalledWith(
    "SELECT * FROM users WHERE id = $1",
    ["u1"]
  );
});
```

### Manual test doubles

```typescript
// Prefer hand-written fakes for repositories — they're simpler and more honest than mock chains

// src/shared/test-helpers.ts
import type { UserRepository } from "../users/users.types";

export function createFakeUserRepository(
  overrides: Partial<UserRepository> = {}
): UserRepository {
  return {
    findById: async () => null,
    save: async (user) => user,
    delete: async () => void 0,
    ...overrides,
  };
}
```

### Spy on methods

```typescript
it("calls logger.error on failure", async () => {
  const logSpy = jest.spyOn(logger, "error").mockImplementation(() => void 0);
  const repo = createFakeUserRepository({
    findById: async () => { throw new Error("DB down"); },
  });

  await service.findById("u1");

  expect(logSpy).toHaveBeenCalledWith(
    expect.stringContaining("findById failed"),
    expect.objectContaining({ error: expect.any(Error) })
  );
});
```

### Timer mocks

```typescript
beforeEach(() => jest.useFakeTimers());
afterEach(() => jest.useRealTimers());

it("retries after delay", async () => {
  const attempt = jest.fn().mockRejectedValueOnce(new Error()).mockResolvedValue("ok");
  const promise = retryWithDelay(attempt, { delay: 1000, attempts: 2 });

  jest.advanceTimersByTime(1000);
  await expect(promise).resolves.toBe("ok");
  expect(attempt).toHaveBeenCalledTimes(2);
});
```

---

## 13. Integration Tests

Integration tests hit real infrastructure. Use a test database, never mock the DB layer.

### Configuration

```typescript
// jest.integration.config.ts
import type { Config } from "jest";

const config: Config = {
  preset: "ts-jest",
  testEnvironment: "node",
  roots: ["<rootDir>/tests/integration"],
  testMatch: ["**/*.integration.test.ts"],
  globalSetup: "./tests/integration/setup.ts",
  globalTeardown: "./tests/integration/teardown.ts",
  testTimeout: 30_000,
};

export default config;
```

```typescript
// tests/integration/setup.ts
import { execSync } from "node:child_process";

export default async function setup(): Promise<void> {
  // Apply migrations to test DB
  execSync("npx supabase db push --local", { stdio: "inherit" });
}
```

```bash
# Run integration tests (requires local DB)
npx jest --config jest.integration.config.ts

# Run with verbose output
npx jest --config jest.integration.config.ts --verbose

# Run a single integration test file
npx jest --config jest.integration.config.ts tests/integration/users.integration.test.ts
```

### Integration test pattern

```typescript
// tests/integration/users.integration.test.ts
import { createTestDb, cleanDatabase } from "./helpers";
import { UsersRepository } from "../../src/users/users.repository";

describe("UsersRepository (integration)", () => {
  const db = createTestDb();

  afterEach(async () => {
    await cleanDatabase(db, ["users"]);
  });

  it("persists and retrieves a user", async () => {
    const repo = new UsersRepository(db);
    const created = await repo.save({
      id: toUserId(crypto.randomUUID()),
      name: "Alice",
      email: "alice@example.com",
    });

    const found = await repo.findById(created.id);
    expect(found).toMatchObject({ name: "Alice", email: "alice@example.com" });
  });
});
```

---

## 14. Load Testing

Use k6 with TypeScript (native support since k6 v0.57). Scripts live in `tests/load/`.

```typescript
// tests/load/users.load.ts
import http from "k6/http";
import { check, sleep } from "k6";
import type { Options } from "k6/options";

export const options: Options = {
  stages: [
    { duration: "30s", target: 10 },   // ramp up
    { duration: "1m",  target: 10 },   // sustain
    { duration: "10s", target: 0 },    // ramp down
  ],
  thresholds: {
    http_req_duration: ["p(95)<500"],  // 95th percentile under 500ms
    http_req_failed:   ["rate<0.01"],  // less than 1% error rate
  },
};

export default function run(): void {
  const res = http.get(`${__ENV.BASE_URL}/api/users`);
  check(res, {
    "status is 200": (r) => r.status === 200,
    "response has users": (r) => Array.isArray(r.json<{ users: unknown[] }>()?.users),
  });
  sleep(1);
}
```

```bash
# Install k6
brew install k6

# Run load test locally
k6 run tests/load/users.load.ts --env BASE_URL=http://localhost:3000

# Run with custom VUs and duration
k6 run --vus 20 --duration 60s tests/load/users.load.ts --env BASE_URL=http://localhost:3000

# Run with output to InfluxDB for Grafana visualization
k6 run --out influxdb=http://localhost:8086/k6 tests/load/users.load.ts

# Run a specific scenario
k6 run --scenario ramp_up tests/load/users.load.ts
```

---

## 15. Profiling

Profile production-equivalent code, not dev mode.

### Node.js built-in profiler

```bash
# CPU profile — generates isolate-*.log
node --prof dist/index.js

# Convert to readable text
node --prof-process isolate-*.log > profile.txt

# View in Chrome DevTools
node --inspect dist/index.js
# Open chrome://inspect
```

### clinic.js

```bash
# Install clinic
npm install --save-dev clinic

# Doctor: identifies bottlenecks (CPU, async, memory)
npx clinic doctor -- node dist/index.js

# Flame graph: per-function CPU time
npx clinic flame -- node dist/index.js

# Bubbleprof: async operations visualization
npx clinic bubbleprof -- node dist/index.js
```

### Performance Hooks (Node.js built-in)

```typescript
import { performance, PerformanceObserver } from "node:perf_hooks";

// Observe all measures
const obs = new PerformanceObserver((list) => {
  for (const entry of list.getEntries()) {
    logger.info("performance measure", {
      name: entry.name,
      durationMs: entry.duration,
    });
  }
});
obs.observe({ type: "measure" });

// Mark start and end
performance.mark("db-query:start");
const rows = await db.query(sql, params);
performance.mark("db-query:end");
performance.measure("db-query", "db-query:start", "db-query:end");
```

---

## 16. Benchmarks

Use `performance.now()` for micro-benchmarks. Use k6 for HTTP benchmarks.

```typescript
// src/shared/bench.ts — minimal benchmark harness, no deps
type BenchFn = () => void | Promise<void>;

async function bench(name: string, fn: BenchFn, iterations = 1000): Promise<void> {
  // Warmup
  for (let i = 0; i < Math.min(iterations / 10, 100); i++) await fn();

  const start = performance.now();
  for (let i = 0; i < iterations; i++) await fn();
  const end = performance.now();

  const totalMs = end - start;
  console.log(
    `[bench] ${name}: ${(totalMs / iterations).toFixed(3)}ms/op ` +
    `(${iterations} iterations, ${totalMs.toFixed(1)}ms total)`
  );
}

// Usage
await bench("JSON.parse large payload", () => {
  JSON.parse(largeJsonString);
});

await bench("Zod schema parse", () => {
  userSchema.parse(rawUserObject);
});
```

```bash
# Run benchmark directly with ts-node
npx ts-node src/shared/bench.ts

# Run with Node.js flags for better measurement
node --expose-gc dist/bench.js
```

---

## 17. Optimization

### Tree-shaking: named exports only from library files

```typescript
// GOOD: named exports — bundlers can tree-shake
export function formatDate(date: Date): string { ... }
export function parseDate(str: string): Date { ... }

// BAD: default-exported object — bundler must include everything
export default {
  formatDate,
  parseDate,
  // + 20 other functions the consumer never uses
};
```

### Lazy imports for large modules

```typescript
// Static import at module level blocks startup
// import { PDFDocument } from "pdf-lib"; // <-- always loaded

// Dynamic import defers loading until needed
async function generatePdf(data: ReportData): Promise<Buffer> {
  const { PDFDocument } = await import("pdf-lib"); // loaded on first call
  // ...
}
```

### Avoid memory leaks in long-lived services

```typescript
// WeakMap for object-keyed caches — entries are GC'd when keys are
const cache = new WeakMap<Request, ProcessedData>();

// EventEmitter: always remove listeners
class Service extends EventEmitter {
  private readonly handler = () => this.onEvent();

  start(): void {
    process.on("SIGTERM", this.handler);
  }

  stop(): void {
    process.off("SIGTERM", this.handler); // prevents leak
  }
}
```

### Bundle analysis

```bash
# Analyze Next.js bundle size
npx @next/bundle-analyzer

# Check package sizes before adding a dependency
npx bundlephobia <package-name>

# Find duplicate dependencies
npx npm-dedupe

# Check why a dependency is included
npx why <package-name>
```

---

## 18. Documentation

### TSDoc on all exported functions

```typescript
/**
 * Creates a new user account and sends a welcome email.
 *
 * @param input - Validated user creation payload.
 * @returns `Ok<User>` on success, `Err<ValidationError>` if email is taken,
 *          `Err<AppError>` on infrastructure failure.
 *
 * @example
 * ```typescript
 * const result = await createUser({ name: "Alice", email: "alice@example.com" });
 * if (!result.ok) {
 *   console.error(result.error.message);
 *   return;
 * }
 * console.log(result.value.id);
 * ```
 */
export async function createUser(
  input: CreateUserInput
): Promise<Result<User, ValidationError | AppError>> {
  // ...
}
```

### @deprecated tag

```typescript
/**
 * @deprecated Use `findById` instead. Will be removed in v3.
 */
export function getUserById(id: string): User { ... }
```

### @internal for non-public symbols

```typescript
/**
 * @internal
 * Not part of the public API. May change without notice.
 */
export function _buildQuery(filters: QueryFilters): string { ... }
```

Do not document what the code already says. Document *why* a non-obvious decision was made.

---

## 19. Security

### Env var validation at startup with Zod

Never read `process.env` directly in application code. Validate once at startup and export a typed config object.

```typescript
// src/env.ts — imported first in src/index.ts
import { z } from "zod";

const envSchema = z.object({
  NODE_ENV: z.enum(["development", "test", "production"]),
  DATABASE_URL: z.string().url(),
  SUPABASE_URL: z.string().url(),
  SUPABASE_ANON_KEY: z.string().min(1),
  SUPABASE_SERVICE_ROLE_KEY: z.string().min(1),
  SENTRY_DSN: z.string().url().optional(),
  PORT: z.coerce.number().int().min(1).max(65535).default(3000),
  LOG_LEVEL: z.enum(["debug", "info", "warn", "error"]).default("info"),
});

const parsed = envSchema.safeParse(process.env);

if (!parsed.success) {
  console.error("Invalid environment variables:");
  console.error(parsed.error.flatten().fieldErrors);
  process.exit(1); // hard fail at startup — never run with bad config
}

export const env = parsed.data;
// downstream: import { env } from "./env"; — always typed, never undefined
```

```typescript
// src/index.ts — env must be the very first import
import "./env";        // validates and exits on failure
import { startApp } from "./app";

startApp().catch((error) => {
  console.error("Fatal startup error", error);
  process.exit(1);
});
```

### Input validation at trust boundaries

```typescript
// Validate all external input with Zod before it enters the domain layer
const createUserSchema = z.object({
  name: z.string().min(1).max(100).trim(),
  email: z.string().email().toLowerCase(),
  password: z.string().min(12).max(128),
});

// In the route/action handler — reject before any business logic
const parsed = createUserSchema.safeParse(await request.json());
if (!parsed.success) {
  return new Response(
    JSON.stringify({ error: "Validation failed", details: parsed.error.flatten() }),
    { status: 400 }
  );
}
// parsed.data is fully typed from here
```

### Parameterized queries — never string-concatenate SQL

```typescript
// GOOD: parameterized — input is data, never SQL
const rows = await db.query(
  "SELECT * FROM users WHERE email = $1 AND deleted_at IS NULL",
  [email]
);

// BAD: SQL injection
const rows = await db.query(
  `SELECT * FROM users WHERE email = '${email}'` // attacker controls email
);
```

### Secrets management

```typescript
// Never log secret values
logger.info("Config loaded", {
  dbUrl: env.DATABASE_URL.replace(/:[^:@]+@/, ":***@"), // mask password
  port: env.PORT,
  // never include: SUPABASE_SERVICE_ROLE_KEY, JWT secrets, API keys
});

// Never serialize secrets in error objects
class AppError extends Error {
  toJSON(): Record<string, unknown> {
    return {
      name: this.name,
      message: this.message,
      code: this.code,
      // no stack trace, no internal meta in public error responses
    };
  }
}
```

### Content Security Policy headers

```typescript
// HTTP response headers — set at the edge or middleware layer
const securityHeaders = {
  "Content-Security-Policy":
    "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'",
  "X-Content-Type-Options": "nosniff",
  "X-Frame-Options": "DENY",
  "Referrer-Policy": "strict-origin-when-cross-origin",
  "Permissions-Policy": "camera=(), microphone=(), geolocation=()",
} as const satisfies Record<string, string>;
```

---

## 20. Performance

### Memoization for pure functions

```typescript
// Memoize expensive deterministic computations
function memoize<TArgs extends readonly unknown[], TReturn>(
  fn: (...args: TArgs) => TReturn
): (...args: TArgs) => TReturn {
  const cache = new Map<string, TReturn>();
  return (...args: TArgs): TReturn => {
    const key = JSON.stringify(args);
    if (cache.has(key)) return cache.get(key) as TReturn;
    const result = fn(...args);
    cache.set(key, result);
    return result;
  };
}

const getPermissions = memoize((role: Role): Permission[] => computePermissions(role));
```

### Lazy evaluation

```typescript
// Compute expensive values only when first accessed
class LazyConfig {
  #parsedRoutes: RouteMap | undefined;

  get routes(): RouteMap {
    this.#parsedRoutes ??= parseRoutes(this.rawConfig);
    return this.#parsedRoutes;
  }
}
```

### Caching with TTL

```typescript
// Simple in-process TTL cache — no dep needed for most use cases
class TtlCache<K, V> {
  readonly #store = new Map<K, { value: V; expiresAt: number }>();

  set(key: K, value: V, ttlMs: number): void {
    this.#store.set(key, { value, expiresAt: Date.now() + ttlMs });
  }

  get(key: K): V | undefined {
    const entry = this.#store.get(key);
    if (!entry || Date.now() > entry.expiresAt) {
      this.#store.delete(key);
      return undefined;
    }
    return entry.value;
  }
}

// ponytail: no external cache library unless Redis is already in the stack
const userCache = new TtlCache<string, User>();
```

### Avoid unnecessary re-serialization

```typescript
// Serialize once, reuse the string
const serialized = JSON.stringify(largePayload);
await Promise.all([
  cache.set(key, serialized),
  queue.publish(serialized),
]);
```

---

## 21. Comments

**Comment the why, not the what.** TypeScript types document the what.

```typescript
// GOOD: explains a non-obvious business rule
// Supabase RLS policies require the service role key for admin writes.
// Using the anon key here would silently return 0 rows.
const adminClient = createClient(env.SUPABASE_URL, env.SUPABASE_SERVICE_ROLE_KEY);

// GOOD: explains a workaround
// Safari 15 returns a different MIME type for FormData uploads.
// See: https://bugs.webkit.org/show_bug.cgi?id=229696
const contentType = request.headers.get("content-type")?.split(";")[0];

// BAD: restates the code
// Get the user by id
const user = await getUserById(id);
```

### TODO format

When a deferral is intentional, make it traceable:

```typescript
// TODO(gh-123): replace with streaming once the edge runtime supports ReadableStream pipeTo
const body = await response.text();
```

No bare `TODO` without a ticket reference in production code.

---

## 22. Database

### Typed query helper (Supabase)

```typescript
// src/shared/db.ts — single client instance per process
import { createClient } from "@supabase/supabase-js";
import type { Database } from "./database.types"; // generated by supabase gen types
import { env } from "./env";

// ponytail: one client per process — do not create per-request
export const db = createClient<Database>(env.SUPABASE_URL, env.SUPABASE_SERVICE_ROLE_KEY, {
  auth: { persistSession: false },
});
```

```bash
# Generate TypeScript types from your Supabase schema
npx supabase gen types typescript --local > src/shared/database.types.ts

# Regenerate after each migration
npx supabase db push --local && npx supabase gen types typescript --local > src/shared/database.types.ts
```

### Repository pattern with typed queries

```typescript
// src/users/users.repository.ts
import type { Database } from "../shared/database.types";
import { db } from "../shared/db";
import { err, ok, type Result } from "../shared/result";
import type { UserId } from "./users.types";

type UserRow = Database["public"]["Tables"]["users"]["Row"];

export async function findUserById(
  id: UserId
): Promise<Result<UserRow, "NOT_FOUND" | "DB_ERROR">> {
  const { data, error } = await db
    .from("users")
    .select("*")
    .eq("id", id)
    .maybeSingle();

  if (error) return err("DB_ERROR");
  if (!data) return err("NOT_FOUND");
  return ok(data);
}
```

### Transactions

```typescript
// Supabase does not expose raw transactions via the client SDK.
// Use a Postgres function (RPC) for multi-table atomic operations.

const { error } = await db.rpc("create_family_and_owner", {
  family_name: input.name,
  owner_id: input.ownerId,
});
```

### Pagination

```typescript
// Cursor-based pagination for large tables (stable under concurrent writes)
async function listUsers(
  cursor?: string,
  limit = 20
): Promise<{ users: UserRow[]; nextCursor: string | null }> {
  let query = db.from("users").select("*").order("id").limit(limit + 1);
  if (cursor) query = query.gt("id", cursor);

  const { data, error } = await query;
  if (error) throw new AppError("Failed to list users", "DB_ERROR");

  const users = (data ?? []).slice(0, limit);
  const nextCursor = data && data.length > limit ? (data[limit]?.id ?? null) : null;
  return { users, nextCursor };
}
```

---

## 23. Logs

### Structured logger

Never use `console.log` in application code. Emit JSON in production.

```typescript
// src/shared/logger.ts
import * as Sentry from "@sentry/node";
import { env } from "./env";

type LogLevel = "debug" | "info" | "warn" | "error";

interface LogFields {
  [key: string]: unknown;
  error?: Error | unknown;
  correlationId?: string;
  userId?: string;
  durationMs?: number;
}

function log(level: LogLevel, message: string, fields: LogFields = {}): void {
  const entry = {
    timestamp: new Date().toISOString(),
    level,
    message,
    ...fields,
    ...(fields.error instanceof Error && {
      error: {
        name: fields.error.name,
        message: fields.error.message,
        stack: fields.error.stack,
      },
    }),
  };

  // Emit JSON in production, readable in dev
  if (env.NODE_ENV === "production") {
    process.stdout.write(JSON.stringify(entry) + "\n");
  } else {
    const color = { debug: "\x1b[36m", info: "\x1b[32m", warn: "\x1b[33m", error: "\x1b[31m" }[level];
    console[level === "debug" ? "debug" : level](`${color}[${level}]\x1b[0m ${message}`, fields);
  }
}

export const logger = {
  debug: (msg: string, fields?: LogFields) => log("debug", msg, fields),
  info:  (msg: string, fields?: LogFields) => log("info",  msg, fields),
  warn:  (msg: string, fields?: LogFields) => log("warn",  msg, fields),
  error: (msg: string, fields?: LogFields) => {
    log("error", msg, fields);
    if (fields?.error instanceof Error) {
      Sentry.captureException(fields.error, { extra: fields as Record<string, unknown> });
    }
  },
};
```

### Correlation IDs with AsyncLocalStorage

```typescript
// src/shared/context.ts — propagate request context through async call chains
import { AsyncLocalStorage } from "node:async_hooks";
import { randomUUID } from "node:crypto";

interface RequestContext {
  correlationId: string;
  userId?: string;
}

const storage = new AsyncLocalStorage<RequestContext>();

export function withContext<T>(ctx: Partial<RequestContext>, fn: () => T): T {
  const context: RequestContext = {
    correlationId: ctx.correlationId ?? randomUUID(),
    ...ctx,
  };
  return storage.run(context, fn);
}

export function getContext(): RequestContext | undefined {
  return storage.getStore();
}

// Middleware — sets context for every request
export function contextMiddleware(req: Request, next: () => Promise<Response>): Promise<Response> {
  const correlationId = req.headers.get("x-correlation-id") ?? randomUUID();
  return withContext({ correlationId }, next);
}
```

```typescript
// Updated logger — auto-attaches context fields
function log(level: LogLevel, message: string, fields: LogFields = {}): void {
  const ctx = getContext();
  const entry = {
    timestamp: new Date().toISOString(),
    level,
    message,
    correlationId: ctx?.correlationId,
    userId: ctx?.userId,
    ...fields,
  };
  // ...
}
```

### Sentry initialization

```typescript
// src/index.ts — initialize Sentry before any other imports that might throw
import * as Sentry from "@sentry/node";
import { env } from "./env";

if (env.SENTRY_DSN) {
  Sentry.init({
    dsn: env.SENTRY_DSN,
    environment: env.NODE_ENV,
    tracesSampleRate: env.NODE_ENV === "production" ? 0.1 : 1.0,
    beforeSend(event) {
      // Strip PII from breadcrumbs before sending
      if (event.breadcrumbs) {
        event.breadcrumbs.values = event.breadcrumbs.values?.map((b) => ({
          ...b,
          message: b.message?.replace(/([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})/g, "[email]"),
        }));
      }
      return event;
    },
  });
}
```

### Log levels

| Level | When to use |
|---|---|
| `debug` | Detailed flow for local debugging. Never enabled in production by default. |
| `info` | Normal operational events: request received, job completed, cache hit. |
| `warn` | Unexpected but recoverable: retry triggered, fallback used, deprecated path hit. |
| `error` | Operation failed and the failure is surfaced to the user or a system boundary. Always include the `error` field. |

---

## 24. Golden Rules

These are non-negotiable. A PR that violates them does not merge.

1. **`strict: true` plus `noUncheckedIndexedAccess` and `exactOptionalPropertyTypes` in every tsconfig.** No suppressions without a comment explaining why and a ticket to remove it.

2. **No `any`.** Use `unknown` and narrow explicitly. If a third-party type forces `any`, contain it in one adapter file.

3. **Errors are return values for recoverable failures.** Use `Result<T, E>`. Throw only for programming errors and truly unrecoverable situations.

4. **Validate all external input with Zod at the trust boundary.** API request bodies, env vars, webhook payloads, queue messages — all validated before entering domain code.

5. **Process.env is never read directly in application code.** Only `src/env.ts` reads `process.env`. Everything else imports `env` from that module.

6. **No `!` non-null assertions on data that came from outside the process** (DB rows, API responses, user input). Assert on compile-time constants only.

7. **Tests use real types, not `as SomeType` casts.** Build objects that satisfy the type structurally. If building a fixture is painful, the type is too wide.

8. **Every `catch` block either re-throws, returns `err(...)`, or calls `logger.error`.** Silent catch blocks are banned. Capturing in Sentry is not a substitute for propagating the error.

9. **No unhandled promise rejections.** Every `async` function call is either `await`ed or `.catch()`-chained. Background tasks attach a `.catch()` that logs and captures to Sentry.

10. **Dead code is deleted, not commented out.** Version control is the history. Commented-out code confuses future readers and never gets uncommented.

---

## 25. Checklist

### Pre-commit

```bash
# Run all checks in sequence — abort on first failure
npx tsc --noEmit \
  && npx eslint 'src/**/*.ts' --max-warnings 0 \
  && npx prettier --check 'src/**/*.ts' \
  && npx jest --passWithNoTests --ci
```

- [ ] `tsc --noEmit` passes with zero errors
- [ ] ESLint passes with zero warnings
- [ ] All new exported functions have TSDoc comments
- [ ] New env vars added to `src/env.ts` schema and `.env.local.example`
- [ ] No `console.log` left in application code (only in scripts and benchmarks)
- [ ] No `any` introduced without an explanation comment
- [ ] Test coverage for new logic (unit or integration)
- [ ] Error paths return `Result` or throw a typed `AppError`, not a plain `Error`

### Pre-deploy

```bash
# Build clean from source
npm run clean && npm run build

# Run integration tests against staging DB
DATABASE_URL=$STAGING_DB_URL npx jest --config jest.integration.config.ts --ci

# Verify bundle size has not regressed
npx tsc --noEmit && du -sh dist/
```

- [ ] Integration tests pass against staging
- [ ] Sentry DSN is set in production env vars
- [ ] `supabase gen types` was run after the latest migration and types are committed
- [ ] No secrets in committed files (grep: `grep -rn "sk_live\|service_role" src/`)
- [ ] Load test run for new endpoints (k6, at minimum a smoke test)
- [ ] Database migrations are backward-compatible or a rollback plan exists

---

## 26. References

- TypeScript Handbook: https://www.typescriptlang.org/docs/handbook/
- TSConfig Reference: https://www.typescriptlang.org/tsconfig
- TypeScript Strict Mode (typescriptlang.org): https://www.typescriptlang.org/tsconfig/strict.html
- TypeScript Utility Types: https://www.typescriptlang.org/docs/handbook/utility-types.html
- TSDoc standard: https://tsdoc.org/
- Microsoft TypeScript Coding Guidelines: https://github.com/microsoft/TypeScript/wiki/Coding-guidelines
- Google TypeScript Style Guide: https://google.github.io/styleguide/tsguide.html
- Zod documentation: https://zod.dev/
- Jest documentation: https://jestjs.io/docs/getting-started
- ts-jest: https://kulshekhar.github.io/ts-jest/
- k6 TypeScript compatibility: https://grafana.com/docs/k6/latest/using-k6/javascript-typescript-compatibility-mode/
- Node.js Performance Hooks: https://nodejs.org/api/perf_hooks.html
- Node.js AbortController: https://nodejs.org/api/globals.html#class-abortcontroller
- AbortSignal.timeout() (MDN): https://developer.mozilla.org/en-US/docs/Web/API/AbortSignal/timeout_static
- Sentry Node.js SDK: https://docs.sentry.io/platforms/javascript/guides/node/
- Sentry Structured Logging: https://docs.sentry.io/platforms/javascript/guides/node/logs/
- Node.js AsyncLocalStorage: https://nodejs.org/api/async_context.html#class-asynclocalstorage
- clinic.js: https://clinicjs.org/
- Supabase TypeScript types generation: https://supabase.com/docs/reference/cli/supabase-gen-types
