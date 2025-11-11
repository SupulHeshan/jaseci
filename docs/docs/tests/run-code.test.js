import { describe, it, expect } from "vitest";
import "../js/run-code.js";

describe("Basic Environment Test", () => {
  it("should have document and window objects", () => {
    expect(typeof document).toBe("object");
    expect(typeof window).toBe("object");
  });
});

describe("run code loaded", () => {
  it("should not throw errors when imported", () => {
    expect(true).toBe(true);
  })
})