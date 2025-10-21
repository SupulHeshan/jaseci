// --- Worker mock ------------------------------------------------------------
import { jest } from '@jest/globals';

class MockWorker {
  constructor(url) {
    this.url = url;
    this._messageListeners = new Set();
    this.messages = [];
    // For legacy code paths that use onmessage/onerror directly:
    this.onmessage = null;
    this.onerror = null;
    // Keep a reference for assertions in tests
    global.__lastWorker = this;
  }
  addEventListener(type, cb) {
    if (type === "message") this._messageListeners.add(cb);
  }
  removeEventListener(type, cb) {
    if (type === "message") this._messageListeners.delete(cb);
  }
  postMessage(msg) {
    this.messages.push(msg);
  }
  // helper used by tests to simulate worker → main thread messages
  _emit(data) {
    // EventTarget style
    this._messageListeners.forEach((cb) => cb({ data }));
    // onmessage style
    if (this.onmessage) this.onmessage({ data });
  }
}
global.Worker = MockWorker;

// --- CustomEvent mock (jsdom lacks it in older versions) --------------------
if (typeof global.CustomEvent === "undefined") {
  global.CustomEvent = class CustomEvent extends Event {
    constructor(name, opts = {}) {
      super(name, opts);
      this.detail = opts.detail;
    }
  };
}

// --- SAB/Atomics soft stubs for Node ---------------------------------------
if (typeof global.SharedArrayBuffer === "undefined") {
  global.SharedArrayBuffer = class {};
}
// we don’t assert the *behavior* of Atomics in this first test
global.Atomics = global.Atomics || { store: () => {}, notify: () => {}, wait: () => {} };

// --- fetch default mock (not used in first test but useful later) -----------
global.fetch = jest.fn(async () => ({
  arrayBuffer: async () => new ArrayBuffer(4),
}));

// --- IntersectionObserver mock ------------------------------------------------
global.IntersectionObserver = class IntersectionObserver {
  constructor(callback, options) {
    this.callback = callback;
    this.options = options;
  }
  observe() {}
  unobserve() {}
  disconnect() {}
};
