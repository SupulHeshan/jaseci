/**
 * @file First-core test for the runner initialization.
 * Validates: single Worker creation, init message with SAB, resolution on 'ready'.
 */

import { initPyodideWorker } from "../../js/run-code.js";

describe("initPyodideWorker()", () => {
  test("initializes one Worker, posts SAB init, and resolves on 'ready'", async () => {
    // --- Arrange ------------------------------------------------------------
    // (Nothing else to arrange; Worker is mocked in setup-jest)

    // --- Act ----------------------------------------------------------------
    const initPromise = initPyodideWorker();

    // Access the most recently created mock worker (from setup’s global)
    const worker = global.__lastWorker;
    expect(worker).toBeDefined();

    // --- Assert: first message is the init payload with a SAB ----------------
    expect(worker.messages.length).toBeGreaterThan(0);
    const initMsg = worker.messages[0];
    expect(initMsg).toMatchObject({ type: "init" });
    // SharedArrayBuffer existence is enough for this level (we’re not sizing it yet)
    expect(initMsg.sab).toBeInstanceOf(SharedArrayBuffer);

    // --- Act: simulate worker becoming ready --------------------------------
    worker._emit({ type: "ready" });

    // --- Assert: promise resolves, and subsequent calls reuse same promise ---
    await expect(initPromise).resolves.toBeUndefined();

    const again = initPyodideWorker();
    expect(again).toBe(initPromise); // idempotent/singleton behavior
  });
});
