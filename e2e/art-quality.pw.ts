import { expect, test } from '@playwright/test'

test('hammer stays in the glove throughout a swing and high quality renders above CSS resolution', async ({ page }) => {
  const errors: string[] = []
  page.on('pageerror', (error) => errors.push(error.message))
  await page.setViewportSize({ width: 1440, height: 900 })
  await page.goto('/')
  await expect.poll(() => page.evaluate(() => window.__CHEMSITE_DEBUG__?.getSnapshot().sceneReady)).toBe(true)
  await page.getByRole('button', { name: /Карьерный режим/ }).click()
  await page.getByRole('button', { name: 'Начать уровень' }).click()
  const pixelRatio = await page.locator('canvas').evaluate((canvas) => canvas.width / canvas.clientWidth)
  expect(pixelRatio).toBeGreaterThanOrEqual(1.5)
  await page.screenshot({ path: 'artifacts/playtest/neighborhood-wide.png' })
  await page.evaluate(() => window.__CHEMSITE_DEBUG__?.focusCamera?.([-12.5, 0.6, -3.5], 210))
  await page.waitForTimeout(1200)
  const heights: number[] = []
  for (let frame = 0; frame < 8; frame++) {
    const pose = await page.evaluate(() => ({
      grip: window.__CHEMSITE_DEBUG__?.scenePoint?.('hammer-grip'),
      hand: window.__CHEMSITE_DEBUG__?.scenePoint?.('hammer-hand'),
    }))
    expect(pose.grip).toBeTruthy()
    expect(pose.hand).toEqual(pose.grip)
    heights.push(pose.grip![1])
    if (frame % 2 === 0) await page.screenshot({ path: `artifacts/playtest/hammer-swing-${frame}.png` })
    await page.waitForTimeout(200)
  }
  expect(Math.max(...heights) - Math.min(...heights)).toBeGreaterThan(0.05)
  await page.evaluate(() => window.__CHEMSITE_DEBUG__?.focusCamera?.(null))
  await page.keyboard.press('Escape')
  await page.getByRole('button', { name: /Качество графики/ }).click()
  await expect(page.getByRole('button', { name: /Качество графики ЛЁГКОЕ/ })).toBeVisible()
  await expect.poll(() => page.locator('canvas').evaluate((canvas) => canvas.width / canvas.clientWidth)).toBeLessThanOrEqual(1.35)
  await page.keyboard.press('Escape')
  expect(errors).toEqual([])
})
