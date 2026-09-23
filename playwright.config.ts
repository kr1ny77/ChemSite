import { defineConfig } from '@playwright/test'

export default defineConfig({
  workers: 1,
  testDir: './e2e',
  testMatch: '**/*.pw.ts',
  timeout: 90_000,
  use: {
    baseURL: 'http://127.0.0.1:4173',
    browserName: 'chromium',
    channel: 'chrome',
    headless: true,
    viewport: { width: 1024, height: 640 },
    launchOptions: {
      args: [
        ...(process.env.CHEMSITE_SOFTWARE_WEBGL === '1' ? [
          '--enable-webgl',
          '--enable-unsafe-swiftshader',
          '--use-gl=angle',
          '--use-angle=swiftshader',
        ] : []),
        '--disable-background-timer-throttling',
        '--disable-backgrounding-occluded-windows',
        '--disable-renderer-backgrounding',
      ],
    },
  },
  webServer: {
    command: 'npm run dev -- --port 4173',
    url: 'http://127.0.0.1:4173',
    reuseExistingServer: true,
  },
  reporter: 'line',
})
