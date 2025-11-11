import { vi } from 'vitest'

// Observers (jsdom doesn't have these)
class IO {
  constructor(cb) { 
    this.cb = cb;
    IO._instances = IO._instances || [];
    IO._instances.push(this);
  }
  observe() {}
  unobserve() {}
  disconnect() {}
}
global.IntersectionObserver = IO

class MO {
  constructor(cb) { this.cb = cb }
  observe() {}
  disconnect() {}
}
global.MutationObserver = MO

// AMD require used by loadMonacoEditor()
global.require = function(deps, cb) {
  if (cb) setTimeout(cb, 0)
}
global.require.config = vi.fn()
global.require[Symbol.toStringTag] = 'require'

// Minimal monaco stub so your code can create an editor without crashing
global.monaco = {
  languages: {
    register: vi.fn(),
    setMonarchTokensProvider: vi.fn(),
    setLanguageConfiguration: vi.fn(),
  },
  editor: {
    defineTheme: vi.fn(),
    setTheme: vi.fn(),
    EditorOption: { lineHeight: 0 },
    create: vi.fn((container, opts) => {
      let value = String(opts?.value ?? '')
      const handlers = []
      const model = { getLineCount: () => value.split('\n').length }
      return {
        getModel: () => model,
        getValue: () => value,
        setValue: (v) => { value = v; handlers.forEach(fn => fn({})) },
        layout: vi.fn(),
        onDidChangeModelContent: (fn) => handlers.push(fn),
        getOption: () => 20,
      }
    })
  }
}

// Graphviz Viz mock used by renderDotToGraph()
global.Viz = class {
  renderSVGElement() {
    const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg')
    svg.setAttribute('viewBox', '0 0 800 400')
    return Promise.resolve(svg)
  }
}

// Worker + Atomics stubs (enough for unit tests)
class FakeWorker {
  onmessage = null
  onerror = null
  #listeners = new Set()
  postMessage(_msg) {}
  addEventListener(type, fn) { if (type === 'message') this.#listeners.add(fn) }
  removeEventListener(type, fn) { this.#listeners.delete(fn) }
  emit(data) {
    this.onmessage?.({ data })
    this.#listeners.forEach(fn => fn({ data }))
  }
}
global.Worker = FakeWorker
global.Atomics = { store: vi.fn(), notify: vi.fn(), wait: vi.fn() }
