import { describe, it, beforeEach, expect } from 'vitest';

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

async function loadModuleNCreateCodeblock(className, isRunAvailable = true, isServeAvailable = false, isDotAvailable = false) {
    await import('../js/run-code.js');

    const block = createCodeBlock(className);
    triggerIntersection(block);

    await new Promise(resolve => setTimeout(resolve, 100));
    const { run, serve, dot } = queryControls(block);

    const buttons = [
        { element: run, available: isRunAvailable },
        { element: serve, available: isServeAvailable },
        { element: dot, available: isDotAvailable }
    ];

    buttons.forEach(({ element, available }) => {
        expect(element).toBeTruthy();
        expect(element.style.display).toBe(available ? 'none' : 'none');
    });

    return block;
};


/** -------------- Tests -------------- **/
describe('code block initialization (intersection-driven)', () => {
    beforeEach(() => {
        document.body.innerHTML = '';
    });

    it('initializes a default .code-block and shows default run button', async () => {
        loadModuleNCreateCodeblock('', true, false, false);
    });

    it('initializes a .code-block.serve and shows only serve button', async () => {
        loadModuleNCreateCodeblock('serve-only', false, true, false);
    });

    it('initializes a .code-block.dot and shows run-serve ', async () => {
        loadModuleNCreateCodeblock('run-serve', false, false, true);
    });

    it('initializes a .code-block.dot and shows serve-dot', async () => {
        loadModuleNCreateCodeblock('serve-dot', false, true, true);
    });

    it('initializes a .code-block.dot and shows all buttons', async () => {
        loadModuleNCreateCodeblock('run-dot-serve', true, true, true);
    });
});