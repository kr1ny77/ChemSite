import { readFileSync, writeFileSync } from 'node:fs'
import { fileURLToPath } from 'node:url'

const root = fileURLToPath(new URL('../../', import.meta.url))
const tasks = []
// Native-only observation illustrations supplement the preserved source bank.
const nativeRecords = new Map(JSON.parse(readFileSync(`${root}data/chemistry/curated_tasks.json`, 'utf8')).map(task => [task.id, task]))
const reviewOverrides = JSON.parse(readFileSync(`${root}data/chemistry/review_overrides.json`, 'utf8'))

for (let level = 1; level <= 5; level += 1) {
  const module = await import(`../../legacy-web/src/chemistry/tasks/level${level}.ts`)
  const group = module[`level${level}Tasks`]
  if (!Array.isArray(group) || group.length !== 40) {
    throw new Error(`Level ${level} should contain 40 curated tasks`)
  }
  tasks.push(...group.map((task) => {
    const result = { ...task, ...(reviewOverrides[task.id] ?? {}) }
    const visuals = nativeRecords.get(task.id)?.parameters?.comparisonVisuals
    if (visuals) result.parameters = { ...result.parameters, comparisonVisuals: visuals }
    return result
  }))
}

for (const id of Object.keys(reviewOverrides)) {
  if (!tasks.some((task) => task.id === id)) {
    throw new Error(`Unknown review override: ${id}`)
  }
}

// Course content is authored separately from the preserved 200-task source.
for (let level = 1; level <= 5; level += 1) {
  tasks.push(...JSON.parse(readFileSync(`${root}data/chemistry/course/level${level}.json`, 'utf8')))
}
if (tasks.length !== 1000 || new Set(tasks.map(task => task.id)).size !== 1000) {
  throw new Error('Expected 1000 unique chemistry tasks')
}
writeFileSync(`${root}data/chemistry/curated_tasks.json`, `${JSON.stringify(tasks, null, 2)}\n`)
console.log(`Exported ${tasks.length} tasks from the preserved bank and course extension`)
