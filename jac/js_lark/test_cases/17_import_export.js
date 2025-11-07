// Test 17: Import/export statements
import defaultExport from "module";
import { named1, named2 } from "module";
import { original as alias } from "module";
import * as namespace from "module";
import defaultExport, { named } from "module";
import "module";

// Export declarations
export const variable = 42;
export let mutableVar = 10;
export function func() {}
export class MyClass {}

// Export list
export { var1, var2 };
export { original as renamed };

// Re-export
export { name } from "module";
export * from "module";

// Default export
export default function() {}
export default class {}
export default 42;
