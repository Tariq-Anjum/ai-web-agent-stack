'use strict';
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { spawnSync } = require('node:child_process');
const root = path.resolve(__dirname, '..');
const fixtures = JSON.parse(fs.readFileSync(path.join(__dirname, 'fixtures/read-content.json'), 'utf8'));
fixtures.push({ name: 'malformed-json', pass: false, raw: '{"success":' });
for (const fixture of fixtures) {
  const result = spawnSync(process.execPath, [path.join(root, 'scripts/read-content.cjs')], {
    input: fixture.raw || JSON.stringify(fixture.response), encoding: 'utf8'
  });
  assert.equal(result.status, fixture.pass ? 0 : 1, fixture.name + ': ' + result.stderr);
  if (fixture.pass) {
    assert.equal(result.stdout, fixture.response.markdown.trim() + '\n', fixture.name);
    assert.equal(result.stderr, '');
  } else {
    assert.equal(result.stdout, '', fixture.name + ': rejected content leaked to stdout');
    assert.match(result.stderr, /^web-read: /);
  }
  console.log('PASS validator: ' + fixture.name);
}
