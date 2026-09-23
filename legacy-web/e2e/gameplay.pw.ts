import { expect, test, type Page } from '@playwright/test'
import { Buffer } from 'node:buffer'
import { mkdir, writeFile } from 'node:fs/promises'

type DebugSnapshot = {
  mode: 'menu' | 'career-select' | 'practice-select' | 'playing' | 'paused' | 'station' | 'results'
  playerPosition: readonly [number, number, number]
  nearbyStationId: string | null
  activeStationId: string | null
  sceneReady: boolean
  currentLevel: 1 | 2 | 3 | 4 | 5
  practiceTimed: boolean
  roundTasks: Array<{
    id: string
    interactionType: string
    correctAnswer: string | { value: number }
    acceptedAnswers?: string[]
    options?: string[]
    parameters?: { missionSteps?: Array<{ title: string; readout: string }> }
  }>
  learningProgress: {
    xp: number
    unlockedLevel: number
    reviewQueue: unknown[]
  }
}

const snapshot = (page: Page) =>
  page.evaluate(() => window.__CHEMSITE_DEBUG__?.getSnapshot() as DebugSnapshot)

async function captureCanvas(page: Page, filename: string) {
  const dataUrl = await page.locator('canvas').evaluate((canvas) =>
    (canvas as HTMLCanvasElement).toDataURL('image/png'),
  )
  await mkdir('artifacts/playtest', { recursive: true })
  await writeFile(`artifacts/playtest/${filename}`, Buffer.from(dataUrl.split(',')[1], 'base64'))
}

async function captureOverlay(page: Page, selector: string, filename: string) {
  const style = await page.addStyleTag({
    content: 'canvas { visibility: hidden !important; } .modal-layer { backdrop-filter: none !important; background: #48656b !important; }',
  })
  await page.locator(selector).screenshot({ path: `artifacts/playtest/${filename}` })
  await style.evaluate((node) => node.remove())
}

test('boots, moves, collides, interacts, and pauses', async ({ page }) => {
  const consoleErrors: string[] = []
  page.on('console', (message) => {
    if (message.type() === 'error') consoleErrors.push(message.text())
  })
  page.on('pageerror', (error) => consoleErrors.push(error.message))

  await page.goto('/')
  await expect(page.getByRole('button', { name: /Карьерный режим/ })).toBeVisible()
  await page.getByRole('button', { name: /Карьерный режим/ }).click()
  await expect(page.getByText('Выбери рабочий участок')).toBeVisible()
  await page.getByRole('button', { name: 'Начать уровень' }).click()
  await expect(page.getByText('УРОВЕНЬ 1 · ЗАДАНИЕ 1/5')).toBeVisible()
  await expect(page.locator('canvas')).toBeVisible()
  await expect(page.locator('.webgl-fallback')).toBeHidden()
  await expect.poll(async () => (await snapshot(page)).sceneReady, { timeout: 30_000 }).toBe(true)
  const cadence = await page.evaluate(() => new Promise<{ average: number; p95: number; samples: number }>((resolve) => {
    const samples: number[] = []
    let previous = performance.now()
    let finished = false
    const finish = () => {
      if (finished) return
      finished = true
      const steady = samples.slice(Math.min(5, Math.floor(samples.length / 3))).sort((left, right) => left - right)
      resolve({
        average: steady.reduce((sum, value) => sum + value, 0) / steady.length,
        p95: steady[Math.floor((steady.length - 1) * 0.95)],
        samples: steady.length,
      })
    }
    const timeout = window.setTimeout(finish, 15_000)
    const frame = (now: number) => {
      if (finished) return
      samples.push(now - previous)
      previous = now
      if (samples.length < 40) requestAnimationFrame(frame)
      else {
        window.clearTimeout(timeout)
        finish()
      }
    }
    requestAnimationFrame(frame)
  }))
  expect(cadence.samples).toBeGreaterThanOrEqual(8)
  const softwareRendering = process.env.CHEMSITE_SOFTWARE_WEBGL === '1'
  expect(cadence.average).toBeLessThan(softwareRendering ? 750 : 50)
  expect(cadence.p95).toBeLessThan(softwareRendering ? 1_500 : 100)
  await page.waitForTimeout(500)
  await captureCanvas(page, '01-world.png')
  await page.locator('.objective-chip').screenshot({ path: 'artifacts/playtest/01-hud.png' })

  const start = await snapshot(page)
  await page.keyboard.down('w')
  await page.keyboard.down('d')
  await expect(page.locator('.interaction-prompt')).toBeVisible({ timeout: 30_000 })
  await page.keyboard.up('d')
  await page.keyboard.up('w')

  const moved = await snapshot(page)
  expect(Math.hypot(moved.playerPosition[0] - start.playerPosition[0], moved.playerPosition[2] - start.playerPosition[2])).toBeGreaterThan(2.5)
  expect((await snapshot(page)).nearbyStationId).toBe('formula-board')
  await captureCanvas(page, '02-station-nearby.png')

  await page.keyboard.press('e')
  await expect(page.getByRole('dialog')).toBeVisible()
  await page.locator('.station-panel').screenshot({ path: 'artifacts/playtest/03-station-panel.png' })
  expect((await snapshot(page)).mode).toBe('station')
  await page.getByLabel('Формула').fill('Fe(NO3)3')
  await page.getByRole('button', { name: /Проверить ответ/ }).click()
  await expect(page.getByText('ВЕРНО')).toBeVisible()

  await page.keyboard.press('Enter')
  await expect(page.getByRole('dialog')).toHaveCount(0)
  await page.keyboard.press('Escape')
  await expect(page.getByRole('dialog', { name: 'Пауза' })).toBeVisible()
  expect((await snapshot(page)).mode).toBe('paused')
  await page.keyboard.press('Escape')
  expect((await snapshot(page)).mode).toBe('playing')

  // The station route now has correctly rotated solid props. Test the perimeter
  // from the clear central aisle rather than driving through the reaction bench.
  await page.evaluate(() => window.__CHEMSITE_DEBUG__?.teleportPlayer?.([0, 1, 0]))
  await page.keyboard.down('d')
  await expect.poll(async () => (await snapshot(page)).playerPosition[0], { timeout: 30_000 }).toBeGreaterThan(10)
  await page.waitForTimeout(1_500)
  await page.keyboard.up('d')
  const atBoundary = await snapshot(page)
  expect(atBoundary.playerPosition[0]).toBeGreaterThan(10)
  expect(atBoundary.playerPosition[0]).toBeLessThan(11.25)
  expect(consoleErrors).toEqual([])
})

test('keeps the HUD inside a narrow viewport', async ({ page }) => {
  await page.setViewportSize({ width: 390, height: 844 })
  await page.goto('/')
  await page.getByRole('button', { name: /Карьерный режим/ }).click()
  await page.getByRole('button', { name: 'Начать уровень' }).click()
  await expect(page.getByText('УРОВЕНЬ 1 · ЗАДАНИЕ 1/5')).toBeVisible()
  const sizes = await page.evaluate(() => ({
    width: document.documentElement.clientWidth,
    scrollWidth: document.documentElement.scrollWidth,
  }))
  expect(sizes.scrollWidth).toBeLessThanOrEqual(sizes.width)
  await page.screenshot({ path: 'artifacts/playtest/04-mobile-sanity.png' })
})

test('plays Engineering Chemistry and staged Construction Chemist tasks', async ({ page }) => {
  const consoleErrors: string[] = []
  page.on('console', (message) => {
    if (message.type() === 'error') consoleErrors.push(message.text())
  })
  page.on('pageerror', (error) => consoleErrors.push(error.message))

  await page.goto('/')
  await expect.poll(async () => (await snapshot(page)).sceneReady, { timeout: 30_000 }).toBe(true)

  await page.evaluate(() => window.__CHEMSITE_DEBUG__?.startRound(4, 121))
  const engineering = await snapshot(page)
  const engineeringIndex = engineering.roundTasks.findIndex((task) =>
    ['hess-puzzle', 'kinetics-experiment', 'equilibrium-control', 'electrochemistry', 'corrosion-inspection'].includes(task.interactionType),
  )
  expect(engineeringIndex).toBeGreaterThanOrEqual(0)
  await page.evaluate((index) => window.__CHEMSITE_DEBUG__?.openTask(index), engineeringIndex)
  await expect(page.locator('.engineering-instrument')).toBeVisible()
  await captureOverlay(page, '.station-panel', '05-level4-engineering.png')

  const engineeringTask = (await snapshot(page)).roundTasks[engineeringIndex]
  const engineeringAnswer = typeof engineeringTask.correctAnswer === 'string'
    ? engineeringTask.correctAnswer
    : String(engineeringTask.correctAnswer.value)
  const engineeringOption = page.getByRole('button', { name: new RegExp(engineeringAnswer.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')) }).first()
  if (await engineeringOption.isVisible().catch(() => false)) {
    await engineeringOption.click()
  } else {
    await page.locator('.answer-input input').fill(engineeringAnswer)
  }
  await page.getByRole('button', { name: /Проверить ответ/ }).click()
  await expect(page.getByText('ВЕРНО')).toBeVisible()
  const persistedXp = (await snapshot(page)).learningProgress.xp
  expect(persistedXp).toBeGreaterThan(0)
  await page.reload()
  await expect.poll(async () => (await snapshot(page)).learningProgress.xp).toBe(persistedXp)

  let construction = await snapshot(page)
  let missionIndex = -1
  for (let seed = 161; seed < 181 && missionIndex < 0; seed += 1) {
    await page.evaluate((roundSeed) => window.__CHEMSITE_DEBUG__?.startRound(5, roundSeed), seed)
    construction = await snapshot(page)
    missionIndex = construction.roundTasks.findIndex((task) => (task.parameters?.missionSteps?.length ?? 0) >= 3)
  }
  expect(missionIndex).toBeGreaterThanOrEqual(0)
  await page.evaluate((index) => window.__CHEMSITE_DEBUG__?.openTask(index), missionIndex)
  await expect(page.locator('.mission-sequence')).toBeVisible()
  while (await page.getByRole('button', { name: /Выполнить этап/ }).isVisible().catch(() => false)) {
    await page.getByRole('button', { name: /Выполнить этап/ }).click()
  }
  await expect(page.getByText(/Данные собраны/)).toBeVisible()
  await captureOverlay(page, '.station-panel', '06-level5-mission.png')
  expect(consoleErrors).toEqual([])
})

test('starts topic practice and persists accessibility settings', async ({ page }) => {
  const consoleErrors: string[] = []
  page.on('console', (message) => {
    if (message.type() === 'error') consoleErrors.push(message.text())
  })
  page.on('pageerror', (error) => consoleErrors.push(error.message))

  await page.goto('/')
  await page.getByRole('button', { name: /Практика/ }).click()
  await expect(page.getByText('Настрой тренировку')).toBeVisible()
  await page.getByRole('button', { name: /Коррозия/ }).click()
  await page.getByRole('button', { name: /Начать тренировку/ }).click()
  await expect(page.getByText(/ПРАКТИКА · ЗАДАНИЕ 1\/5/)).toBeVisible()
  expect((await snapshot(page)).practiceTimed).toBe(false)

  await page.keyboard.press('Escape')
  await expect(page.getByRole('dialog', { name: 'Пауза' })).toBeVisible()
  await page.getByRole('button', { name: /Сниженная анимация/ }).click()
  await expect.poll(async () => page.evaluate(() => document.documentElement.dataset.reducedMotion)).toBe('true')
  await page.reload()
  await expect(page.getByRole('button', { name: /Карьерный режим/ })).toBeVisible()
  await page.getByRole('button', { name: /Карьерный режим/ }).click()
  expect(await page.getByRole('button', { name: /Требуется предыдущий уровень/ }).count()).toBe(4)
  expect(consoleErrors).toEqual([])
})

test('validates a playable station task in every chemistry level', async ({ page }) => {
  const consoleErrors: string[] = []
  page.on('console', (message) => {
    if (message.type() === 'error') consoleErrors.push(message.text())
  })
  page.on('pageerror', (error) => consoleErrors.push(error.message))

  await page.goto('/')
  await expect.poll(async () => (await snapshot(page)).sceneReady, { timeout: 30_000 }).toBe(true)

  for (const level of [1, 2, 3, 4, 5] as const) {
    await page.evaluate((careerLevel) => window.__CHEMSITE_DEBUG__?.startRound(careerLevel, careerLevel * 101), level)
    await page.evaluate(() => window.__CHEMSITE_DEBUG__?.openTask(0))
    const task = (await snapshot(page)).roundTasks[0]

    while (await page.getByRole('button', { name: /Выполнить этап/ }).isVisible().catch(() => false)) {
      await page.getByRole('button', { name: /Выполнить этап/ }).click()
    }

    if (task.options) {
      const accepted = new Set([typeof task.correctAnswer === 'string' ? task.correctAnswer : '', ...(task.acceptedAnswers ?? [])])
      const option = task.options.find((candidate) => accepted.has(candidate)) ?? task.options[0]
      await page.locator('.answer-option').filter({ hasText: option }).click()
    } else {
      const answer = typeof task.correctAnswer === 'string' ? task.correctAnswer : String(task.correctAnswer.value)
      await page.locator('.answer-input input').fill(answer)
    }
    await page.getByRole('button', { name: /Проверить ответ/ }).click()
    await expect(page.getByText('ВЕРНО')).toBeVisible()
  }

  expect(consoleErrors).toEqual([])
})
