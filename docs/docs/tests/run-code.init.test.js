import { describe, it, beforeEach, expect } from 'vitest';

// Create a code block with optional extra classes
function createCodeBlock(extra = '') {
  const el = document.createElement('div')
  el.className = `code-block ${extra}`.trim()
  el.textContent = 'print("hello")'
  document.body.appendChild(el)
  return el
}

// Accessor for elements inside a block
function queryControls(root) {
  return {
    run: root.querySelector('.run-code-btn'),
    serve: root.querySelector('.serve-code-btn'),
    dot: root.querySelector('.dot-code-btn'),
    output: root.querySelector('.code-output'),
  }
}

// Trigger the mocked IntersectionObserver for a target
function triggerIntersection(target) {
    const instances = globalThis.IntersectionObserver._instances || [];

    instances.forEach(observer => {
        observer.cb([{ isIntersecting: true, target }]);
    });
}

/** -------------- Tests -------------- **/
describe('code block initialization (intersection-driven)', () => {
  beforeEach(() => {
    document.body.innerHTML = '';
  });

  it('initializes a default .code-block and shows all three buttons', async () => {
    await import('../js/run-code.js');

    const block = createCodeBlock();
    triggerIntersection(block);

    await new Promise(resolve => setTimeout(resolve, 100));
    const { run, serve, dot } = queryControls(block);

    expect(run).toBeTruthy()
    expect(run.style.display).not.toBe('none')
    expect(serve).toBeTruthy()
    expect(serve.style.display).toBe('none')
    expect(dot).toBeTruthy()
    expect(dot.style.display).toBe('none')
  })
})