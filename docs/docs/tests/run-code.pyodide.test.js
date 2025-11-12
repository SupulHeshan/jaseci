import { describe, it, beforeEach, expect, vi } from 'vitest';

describe('initPyodideWorker', () => {
    let workerInstance;
    let initPyodideWorker;

    async function setupWorkerCapture() {
        const OriginalWorker = global.Worker;
        global.Worker = class extends OriginalWorker {
            constructor(...args) {
                super(...args);
                workerInstance = this;
            }
        };
        
        const module = await import('../js/run-code.js');
        initPyodideWorker = module.initPyodideWorker;
    }

    beforeEach(async () => {
        vi.resetModules();
        workerInstance = null;
        await setupWorkerCapture();
    });

    it('creates worker only once on multiple calls', () => {
        initPyodideWorker();
        const firstWorker = workerInstance;
        
        initPyodideWorker();
        
        expect(workerInstance).toBe(firstWorker);
        expect(workerInstance.postMessage).toHaveBeenCalledTimes(1);
    });

    it('creates a new worker after resetModules', async () => {
        initPyodideWorker();
        const firstWorker = workerInstance;
        
        // Reset and reinitialize
        vi.resetModules();
        workerInstance = null;
        await setupWorkerCapture();
        
        initPyodideWorker();
        const secondWorker = workerInstance;
        
        expect(secondWorker).not.toBe(firstWorker);
        expect(secondWorker.postMessage).toHaveBeenCalledTimes(1);
    });

    it('rejects promise when worker encounters error', async () => {
        const promise = initPyodideWorker();
        const error = new Error('Worker initialization failed');
        
        workerInstance.onerror(error);
        await expect(promise).rejects.toThrow('Worker initialization failed');
    });

    it('resolves promise when worker sends ready message', async () => {
        const promise1 = initPyodideWorker();
        const promise2 = initPyodideWorker();

        workerInstance.emit({ type: 'ready' });
        expect(promise1).toBe(promise2);
        await expect(promise1).resolves.toBeUndefined();
        await expect(promise2).resolves.toBeUndefined();
    });

    it('sends correct initialization message to worker', () => {
        initPyodideWorker();
        
        expect(workerInstance.postMessage).toHaveBeenCalledWith({
            type: 'init',
            sab: expect.any(SharedArrayBuffer)
        });
    });
});

