'use strict';
const assert = require('node:assert/strict');
const fs = require('node:fs');
const http = require('node:http');
const os = require('node:os');
const path = require('node:path');
const { spawn } = require('node:child_process');
const root = path.resolve(__dirname, '..');
const temp = fs.mkdtempSync(path.join(os.tmpdir(), 'web-read-test-'));
const content = 'This domain is for use in documentation examples without needing permission. This page contains meaningful substantive text suitable for a compact deterministic content extraction test.';
let response = { success: true, markdown: content };
let status = 200;
let truncated = false;
let received;
const server = http.createServer((req, res) => {
  let body = '';
  req.on('data', chunk => { body += chunk; });
  req.on('end', () => {
    received = { payload: JSON.parse(body), auth: req.headers.authorization, path: req.url };
    const encoded = JSON.stringify(response);
    const headers = { 'Content-Type': 'application/json' };
    if (truncated) {
      headers['Content-Length'] = Buffer.byteLength(encoded) + 100;
      headers.Connection = 'close';
    }
    res.writeHead(status, headers);
    res.end(encoded);
  });
});
function run(args) {
  return new Promise((resolve, reject) => {
    const child = spawn(path.join(root, 'bin/web-read'), args, {
      env: { ...process.env, WEB_STACK_HOME: temp, WEB_READ_TIMEOUT: '5' }
    });
    let stdout = '', stderr = '';
    child.stdout.on('data', data => { stdout += data; });
    child.stderr.on('data', data => { stderr += data; });
    child.on('error', reject);
    child.on('close', code => resolve({ code, stdout, stderr }));
  });
}
(async () => {
  try {
    await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
    fs.mkdirSync(path.join(temp, 'scripts'));
    fs.symlinkSync(path.join(root, 'scripts/read-content.cjs'), path.join(temp, 'scripts/read-content.cjs'));
    fs.writeFileSync(path.join(temp, '.env'),
      'CRAWL4AI_API_TOKEN=fixture-token\nCRAWL4AI_PORT=' + server.address().port + '\n', { mode: 0o600 });
    const url = 'https://example.com/path?x=1&y=%22quoted%22';
    const query = 'research "focus"; $(echo NOT_EXECUTED) & newline\ntext';
    for (const args of [[url], ['--query', query, url], ['-q', query, url]]) {
      const result = await run(args);
      assert.equal(result.code, 0, result.stderr);
      assert.equal(result.stdout, content + '\n');
      assert.equal(result.stderr, '');
      assert.deepEqual(received, {
        payload: { url, f: args.length === 1 ? 'fit' : 'bm25', q: args.length === 1 ? '' : query, c: '0' },
        auth: 'Bearer fixture-token', path: '/md'
      });
    }
    console.log('PASS web-read: fit/BM25 contract, literal URL/query, Markdown-only stdout');
    for (const args of [[], ['-q'], ['--query', ' ', url], ['--bad', url], [url, url],
      ['file:///etc/passwd'], ['https://user:password@example.com'], ['javascript:alert(1)']]) {
      const result = await run(args);
      assert.equal(result.code, 2);
      assert.equal(result.stdout, '');
    }
    assert.equal((await run(['--help'])).code, 0);
    console.log('PASS web-read: help and invalid input');
    for (const bad of [{ success: false, markdown: content }, { success: true, markdown: 'Verify you are human' }]) {
      response = bad;
      const result = await run([url]);
      assert.equal(result.code, 1);
      assert.equal(result.stdout, '');
    }
    status = 500;
    const failure = await run([url]);
    assert.equal(failure.code, 1);
    assert.equal(failure.stdout, '');
    assert.ok(!failure.stderr.includes('fixture-token'));
    status = 200;
    response = { success: true, markdown: content };
    truncated = true;
    const incomplete = await run([url]);
    assert.equal(incomplete.code, 1);
    assert.equal(incomplete.stdout, '', 'late transport failure must not emit content');
    console.log('PASS web-read: HTTP/crawl/challenge/late-transfer failure and no token diagnostics');
  } finally {
    await new Promise(resolve => server.close(resolve));
    fs.rmSync(temp, { recursive: true, force: true });
  }
})().catch(error => { console.error(error); process.exitCode = 1; });
