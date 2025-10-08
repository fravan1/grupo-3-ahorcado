import { describe, expect, it } from 'vitest';
import dedent from "dedent";

describe('test01', () => {
    it('works', async () => {
        const src = dedent`
            pragma circom 2.2.2;

            template EntryPoint() {
                10 === 10;
            }

            component main = EntryPoint();
        `
        await expect(src).toCircomExecOk();
    });


})