#!/usr/bin/env node
'use strict';

// Crawl4AI 0.9.4 /md response parser and deterministic content acceptance gate.
// No raw-Markdown fallback: empty fit/BM25 output is a failed read.
const fs = require('node:fs');

function reject(reason) {
  throw new Error(reason);
}

function readContent(response) {
  if (!response || typeof response !== 'object' || Array.isArray(response))
    reject('malformed Crawl4AI response');
  if (response.success !== true)
    reject('Crawl4AI reported failure or missing success status');
  if (typeof response.markdown !== 'string' || !response.markdown.trim())
    reject('no extracted Markdown');

  const markdown = response.markdown.trim();
  // Leading page instructions/headings, not an indiscriminate keyword blacklist.
  // Articles mentioning CAPTCHA/access denial in ordinary prose remain readable.
  const leadingLines = markdown.slice(0, 2000).split(/\r?\n/).slice(0, 12)
    .map(line => line.replace(/^[\s#>*_-]+/, '').trim());
  const interstitial = /^(?:just a moment\b|attention required\b|access denied\b|verify (?:that )?you are (?:a )?human\b|enable javascript and cookies\b|checking (?:your )?browser\b|(?:please )?(?:complete|solve) (?:the |this |a )?captcha\b|captcha(?:\s+(?:required|verification|challenge)\b|$))/i;
  if (leadingLines.some(line => interstitial.test(line)) ||
      /cf-browser-verification/i.test(markdown.slice(0, 2000)))
    reject('challenge, bot verification, or access-denied content');

  // Count visible substance, not Markdown syntax, image placeholders or link URLs.
  const text = markdown.replace(/!\[[^\]]*\]\([^)]*\)/g, '')
    .replace(/\[([^\]]*)\]\([^)]*\)/g, '$1')
    .replace(/https?:\/\/\S+/g, '');
  const characters = (text.match(/[\p{L}\p{N}]/gu) || []).length;
  const words = (text.match(/[\p{L}\p{N}]+/gu) || []).length;
  // Compact real pages can pass; long punctuation/link-only pages cannot.
  // CJK text need not have whitespace-delimited words.
  const cjk = (text.match(/[\p{Script=Han}\p{Script=Hiragana}\p{Script=Katakana}]/gu) || []).length;
  if (characters < 80 || (words < 12 && cjk < 80))
    reject('trivial content (insufficient substantive text)');
  return markdown + '\n';
}

module.exports = { readContent };

if (require.main === module) {
  try {
    let response;
    try {
      response = JSON.parse(fs.readFileSync(0, 'utf8'));
    } catch {
      reject('malformed Crawl4AI JSON');
    }
    process.stdout.write(readContent(response));
  } catch (error) {
    // Never echo server/page content, which may contain sensitive material.
    process.stderr.write(`web-read: ${error.message}\n`);
    process.exitCode = 1;
  }
}
