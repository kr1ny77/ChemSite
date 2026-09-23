import { useRef } from 'react'
import { useFrame } from '@react-three/fiber'
import { Group } from 'three'
import { RoundedBox } from '@react-three/drei'
import { EngineerModel } from '../player/EngineerModel'
import { useGameStore } from '../../state/useGameStore'

/** Ambient workers stay outside the player perimeter and have no gameplay authority. */
export function ConstructionCrew() {
  const carrier = useRef<Group>(null)
  const time = useRef(0)
  useFrame((_, delta) => {
    const state = useGameStore.getState()
    if (!carrier.current || state.mode === 'paused' || state.learningProgress.settings.reducedMotion) return
    time.current += Math.min(delta, 0.05)
    carrier.current.position.x = 1 + Math.sin(time.current * 0.22) * 3
    carrier.current.rotation.y = Math.cos(time.current * 0.22) >= 0 ? Math.PI / 2 : -Math.PI / 2
  })
  return <group>
    <group position={[-12.15, -0.36, -3.5]}>
      <RoundedBox args={[0.65, 0.65, 1.4]} radius={0.06} position={[0, 0.325, 0]} castShadow><meshStandardMaterial color="#4e6b74" roughness={0.65} /></RoundedBox>
      <RoundedBox args={[0.72, 0.1, 1.5]} radius={0.035} position={[0, 0.7, 0]} castShadow><meshStandardMaterial color="#ab9064" roughness={0.8} /></RoundedBox>
      {[0, 1, 2].map((i) => <mesh key={i} position={[0, 0.8, (i - 1) * 0.35]} castShadow><boxGeometry args={[0.4, 0.12, 0.28]} /><meshStandardMaterial color="#b99378" roughness={0.9} /></mesh>)}
    </group>
    <group ref={carrier} position={[1, 0.3, -10.2]} scale={0.8}><EngineerModel activity="carry" vest="#efb13f" phase={1} /></group>
    <group position={[-12.9, 0.3, -3.5]} rotation={[0, Math.PI / 2, 0]} scale={0.8}><EngineerModel activity="hammer" phase={2} /></group>
    <group position={[12.8, 0.3, -4.6]} rotation={[0, -Math.PI / 2, 0]} scale={0.8}><EngineerModel activity="inspect" vest="#57a1ac" phase={3} /></group>
  </group>
}
