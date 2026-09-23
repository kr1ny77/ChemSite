import { expect, test, type Page } from '@playwright/test'

// Exercise the browser's default GPU path as well as the software gameplay suite.
test.use({ launchOptions: { args: [] }, viewport: { width: 1280, height: 800 } })

async function expectVisibleFrame(page: Page, name: string) {
  const screenshot = await page.screenshot({ path: `artifacts/playtest/${name}.png` })
  const colorCount = await page.evaluate(async (base64) => {
    const image = new Image()
    image.src = `data:image/png;base64,${base64}`
    await image.decode()
    const canvas = document.createElement('canvas')
    canvas.width = 64
    canvas.height = 40
    const context = canvas.getContext('2d')!
    context.drawImage(image, 0, 0, 64, 40)
    const pixels = context.getImageData(0, 0, 64, 40).data
    const colors = new Set<string>()
    for (let i = 0; i < pixels.length; i += 4) {
      colors.add(`${pixels[i] >> 4},${pixels[i + 1] >> 4},${pixels[i + 2] >> 4}`)
    }
    return colors.size
  }, screenshot.toString('base64'))
  expect(colorCount, 'The composed browser frame must contain the visible game and UI').toBeGreaterThan(30)
  for (const label of await page.locator('.world-label').all()) {
    const bounds = await label.boundingBox()
    expect(bounds?.width).toBeLessThan(220)
    expect(bounds?.height).toBeLessThan(80)
  }
}

test('keeps the full screen visible through loading, play, pause, and resize', async ({ page }) => {
  const errors: string[] = []
  page.on('pageerror', (error) => errors.push(error.message))
  page.on('console', (message) => {
    if (message.type() === 'error') errors.push(message.text())
  })
  await page.goto('/')
  await expect.poll(() => page.evaluate(() => window.__CHEMSITE_DEBUG__?.getSnapshot().sceneReady)).toBe(true)
  await expectVisibleFrame(page, 'stable-01-menu')
  await page.getByRole('button', { name: /Карьерный режим/ }).click()
  await page.getByRole('button', { name: 'Начать уровень' }).click()
  for (let i = 0; i < 3; i++) {
    await page.waitForTimeout(700)
    await expectVisibleFrame(page, `stable-02-play-${i}`)
  }
  await page.keyboard.press('Escape')
  await expect(page.getByRole('dialog', { name: 'Пауза' })).toBeVisible()
  await expectVisibleFrame(page, 'stable-03-pause')
  await page.keyboard.press('Escape')
  await page.setViewportSize({ width: 1440, height: 900 })
  await expectVisibleFrame(page, 'stable-04-resize')
  expect(errors).toEqual([])
})
