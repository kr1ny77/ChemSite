import type { TaskDefinition } from '../types'

function seededRandom(seed: number) {
  let state = seed >>> 0 || 1
  return () => {
    state ^= state << 13
    state ^= state >>> 17
    state ^= state << 5
    return (state >>> 0) / 4_294_967_296
  }
}

function shuffled<T>(items: readonly T[], random: () => number) {
  const result = [...items]
  for (let index = result.length - 1; index > 0; index -= 1) {
    const target = Math.floor(random() * (index + 1))
    ;[result[index], result[target]] = [result[target], result[index]]
  }
  return result
}

export function selectRoundTasks(
  bank: readonly TaskDefinition[],
  count = 5,
  seed = 1,
  preferences: {
    preferredTopics?: readonly string[]
    preferredTaskIds?: ReadonlySet<string>
  } = {},
) {
  const candidates = bank.filter((task) => task.reviewStatus === 'verified')
  const random = seededRandom(seed)
  const pool = shuffled(candidates, random)
  const selected: TaskDefinition[] = []

  while (selected.length < count && pool.length > 0) {
    const previous = selected.at(-1)
    const previousTwo = selected.slice(-2)
    let bestIndex = 0
    let bestScore = Number.NEGATIVE_INFINITY

    pool.forEach((candidate, index) => {
      const interactionFresh = selected.some((task) => task.interactionType === candidate.interactionType) ? 0 : 5
      const stationFresh = previous?.station === candidate.station ? 0 : 2
      const topicPenalty = previousTwo.every((task) => task.topic === candidate.topic) ? -10 : 0
      const sharedCompoundPenalty = selected.some((task) =>
        candidate.parameters?.compound && task.parameters?.compound === candidate.parameters.compound,
      ) ? -8 : 0
      const topicRank = preferences.preferredTopics?.indexOf(candidate.topic) ?? -1
      const adaptiveBonus = topicRank >= 0 ? Math.max(1, 7 - topicRank) : 0
      const scheduledBonus = preferences.preferredTaskIds?.has(candidate.id) ? 12 : 0
      const score = interactionFresh + stationFresh + topicPenalty + sharedCompoundPenalty + adaptiveBonus + scheduledBonus + random()
      if (score > bestScore) {
        bestScore = score
        bestIndex = index
      }
    })

    selected.push(pool.splice(bestIndex, 1)[0])
  }

  return selected
}

export function findRemediationTask(
  bank: readonly TaskDefinition[],
  source: TaskDefinition,
  excludedIds: ReadonlySet<string>,
) {
  const sourceCompound = source.parameters?.compound
  return bank
    .filter((candidate) =>
      candidate.reviewStatus === 'verified' &&
      candidate.id !== source.id &&
      !excludedIds.has(candidate.id) &&
      (!sourceCompound || candidate.parameters?.compound !== sourceCompound),
    )
    .map((candidate) => ({
      candidate,
      score:
        (candidate.subtopic === source.subtopic ? 8 : 0) +
        (candidate.topic === source.topic ? 5 : 0) +
        candidate.tags.filter((tag) => source.tags.includes(tag)).length,
    }))
    .filter(({ score }) => score > 0)
    .sort((left, right) => right.score - left.score || left.candidate.id.localeCompare(right.candidate.id))[0]?.candidate ?? null
}
