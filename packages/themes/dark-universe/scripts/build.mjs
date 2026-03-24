import { copyFile, mkdir, rm } from 'node:fs/promises';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const currentDir = dirname(fileURLToPath(import.meta.url));
const packageDir = resolve(currentDir, '..');
const srcDir = resolve(packageDir, 'src');
const distDir = resolve(packageDir, 'dist');

await rm(distDir, { force: true, recursive: true });
await mkdir(distDir, { recursive: true });

for (const fileName of ['tokens.css', 'background.css', 'index.css']) {
  await copyFile(resolve(srcDir, fileName), resolve(distDir, fileName));
}
