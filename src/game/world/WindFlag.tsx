import { useEffect, useMemo, useRef } from 'react'
import { useFrame } from '@react-three/fiber'
import { DoubleSide, PlaneGeometry } from 'three'
import { useGameStore } from '../../state/useGameStore'

export function WindFlag({ color, phase = 0 }: { color: string; phase?: number }) {
  const cloth = useMemo(() => new PlaneGeometry(0.55, 0.3, 12, 4).translate(0.275, 0, 0), [])
  const time = useRef(phase)
  useEffect(() => () => cloth.dispose(), [cloth])
  useFrame((_, delta) => {
    const state = useGameStore.getState()
    if (state.mode === 'paused' || state.learningProgress.settings.reducedMotion) return
    time.current += Math.min(delta, 0.05)
    const positions = cloth.attributes.position
    for (let i = 0; i < positions.count; i++) {
      const x = positions.getX(i)
      positions.setZ(i, Math.sin(time.current * 2.2 - x * 7) * x * 0.2)
    }
    positions.needsUpdate = true
    cloth.computeVertexNormals()
  })
  return <group>
    <mesh position={[0, 0.5, 0]}><cylinderGeometry args={[0.025, 0.025, 1.1, 16]} /><meshStandardMaterial color="#718890" metalness={0.5} /></mesh>
    <mesh position={[0, 0.76, 0]} geometry={cloth}><meshStandardMaterial color={color} roughness={0.9} side={DoubleSide} /></mesh>
  </group>
}
