import { writeFileSync } from 'node:fs'
import { fileURLToPath } from 'node:url'

const root = fileURLToPath(new URL('../../', import.meta.url))
const tasks = []

for (let level = 1; level <= 5; level += 1) {
  const module = await import(`../../legacy-web/src/chemistry/tasks/level${level}.ts`)
  const group = module[`level${level}Tasks`]
  if (!Array.isArray(group) || group.length !== 40) {
    throw new Error(`Level ${level} should contain 40 curated tasks`)
  }
  tasks.push(...group)
}

writeFileSync(`${root}data/chemistry/curated_tasks.json`, `${JSON.stringify(tasks, null, 2)}\n`)
console.log(`Exported ${tasks.length} curated tasks from the preserved TypeScript bank`)
