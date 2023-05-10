#!/usr/bin/env node
const puppeteer = require('puppeteer');

(async () => {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();

  await page.setViewport({
    width: 800,
    height: 200,
    deviceScaleFactor: 4
  });

  await page.goto(`file://${__dirname}/../test/fixtures/footnote.html`);
  await page.screenshot({path: "./before.png"});

  await page.goto(`file://${__dirname}/../test/fixtures/footnote-2.html`);
  await page.screenshot({path: "./after.png"});

  await page.close();
  await browser.close();
})()
