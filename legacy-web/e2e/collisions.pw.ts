import { expect, test } from '@playwright/test'

test.use({ launchOptions: { args: [] } })

test('solid props stop the player at their visible boundaries', async ({ page }) => {
  await page.goto('/')
  await expect.poll(() => page.evaluate(() => !!window.__CHEMSITE_DEBUG__?.teleportPlayer)).toBe(true)
  await page.getByRole('button', { name: /Карьерный режим/ }).click()
  await page.getByRole('button', { name: 'Начать уровень' }).click()

  const obstacles: Array<{ name: string; start: [number, number, number]; key: string; axis: 0 | 2; min: number; max: number }> = [
    { name: 'laboratory cabin', start: [9.8, 1, -4.3], key: 'w', axis: 2, min: -6.1, max: -4.5 },
    { name: 'concrete column', start: [-9, 1, -7.1], key: 'a', axis: 0, min: -10, max: -9 },
    { name: 'material stockpile', start: [-7, 1, 6.3], key: 'a', axis: 0, min: -10.3, max: -7.3 },
  ]
  await test.step('slides along the rotated station without entering its volume', async () => {
    await page.evaluate(() => window.__CHEMSITE_DEBUG__?.teleportPlayer?.([0, 1, -4.4]))
    await page.waitForTimeout(200)
    await page.keyboard.down('d')
    const angle = Math.atan2(-3.1, 4.4)
    for (let i = 0; i < 6; i++) {
      await page.waitForTimeout(200)
      const [x, , z] = await page.evaluate(() => window.__CHEMSITE_DEBUG__!.getSnapshot().playerPosition)
      const localX = Math.cos(angle) * (x - 3.1) - Math.sin(angle) * (z + 4.4)
      const localZ = Math.sin(angle) * (x - 3.1) + Math.cos(angle) * (z + 4.4)
      expect(Math.abs(localX) > 1.25 || Math.abs(localZ) > 0.71).toBe(true)
    }
    await page.keyboard.up('d')
  })
  for (const obstacle of obstacles) {
    await test.step(obstacle.name, async () => {
      await page.evaluate((position) => window.__CHEMSITE_DEBUG__?.teleportPlayer?.(position), obstacle.start)
      await page.waitForTimeout(200)
      await page.keyboard.down(obstacle.key)
      await page.waitForTimeout(1_200)
      const first = await page.evaluate(() => window.__CHEMSITE_DEBUG__!.getSnapshot().playerPosition)
      await page.waitForTimeout(650)
      await page.keyboard.up(obstacle.key)
      const last = await page.evaluate(() => window.__CHEMSITE_DEBUG__!.getSnapshot().playerPosition)
      expect(last[obstacle.axis]).toBeGreaterThan(obstacle.min)
      expect(last[obstacle.axis]).toBeLessThan(obstacle.max)
      expect(Math.abs(last[obstacle.axis] - first[obstacle.axis])).toBeLessThan(0.1)
      expect(last[1]).toBeGreaterThan(0.6)
    })
  }
  await page.screenshot({ path: 'artifacts/playtest/solid-stockpile.png' })
})
