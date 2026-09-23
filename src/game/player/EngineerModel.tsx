import { RoundedBox } from '@react-three/drei'
import { useFrame } from '@react-three/fiber'
import { useMemo, useRef } from 'react'
import { Group, MathUtils, Vector2 } from 'three'
import { useGameStore } from '../../state/useGameStore'
import { inputManager } from '../input/inputManager'

type Activity = 'player' | 'hammer' | 'carry' | 'inspect'

function Glove() {
  return <group>
    <mesh castShadow scale={[1, 1.15, 0.85]}><sphereGeometry args={[0.12, 24, 16]} /><meshStandardMaterial color="#244c59" roughness={0.68} /></mesh>
    <mesh position={[-0.08, 0.02, 0.065]} scale={[0.6, 0.9, 0.75]} castShadow><sphereGeometry args={[0.09, 20, 12]} /><meshStandardMaterial color="#346474" roughness={0.68} /></mesh>
  </group>
}

function Leg({ side }: { side: number }) {
  return <group>
    <mesh position={[0, -0.1, 0]} castShadow><capsuleGeometry args={[0.135, 0.21, 8, 24]} /><meshStandardMaterial color="#284b64" roughness={0.88} /></mesh>
    <RoundedBox args={[0.28, 0.2, 0.44]} radius={0.085} smoothness={5} position={[0, -0.29, 0.09]} castShadow><meshStandardMaterial color="#5b4030" roughness={0.58} /></RoundedBox>
    <RoundedBox args={[0.29, 0.065, 0.46]} radius={0.025} smoothness={4} position={[0, -0.37, 0.09]} castShadow><meshStandardMaterial color="#202e36" roughness={0.88} /></RoundedBox>
    <mesh position={[0, -0.25, 0.26]} scale={[1, 0.4, 0.45]} castShadow><sphereGeometry args={[0.135, 24, 16]} /><meshStandardMaterial color="#856044" roughness={0.65} /></mesh>
    {[0, 1].map((i) => <mesh key={i} position={[0, -0.205, 0.09 + i * 0.07]} rotation={[0, 0, side * 0.1]}><boxGeometry args={[0.16, 0.016, 0.018]} /><meshStandardMaterial color="#ccb791" /></mesh>)}
  </group>
}

export function EngineerModel({ activity = 'player', phase = 0, vest = '#e98332' }: { activity?: Activity; phase?: number; vest?: string }) {
  const rig = useRef<Group>(null)
  const leftLeg = useRef<Group>(null)
  const rightLeg = useRef<Group>(null)
  const leftArm = useRef<Group>(null)
  const rightArm = useRef<Group>(null)
  const head = useRef<Group>(null)
  const eyes = useRef<Group>(null)
  const elapsed = useRef(phase)
  const torso = useMemo(() => [new Vector2(0.22, -0.42), new Vector2(0.34, -0.32), new Vector2(0.39, -0.06), new Vector2(0.35, 0.23), new Vector2(0.25, 0.32)], [])

  useFrame((_, delta) => {
    const state = useGameStore.getState()
    if (state.mode === 'paused') return
    const reduced = state.learningProgress.settings.reducedMotion
    elapsed.current += Math.min(delta, 0.05)
    const t = elapsed.current
    const walking = activity === 'carry' || activity === 'player' && state.mode === 'playing' && inputManager.movement().moving
    const stride = walking ? Math.sin(t * 10) * (reduced ? 0.22 : 0.5) : 0
    if (leftLeg.current) leftLeg.current.rotation.x = MathUtils.damp(leftLeg.current.rotation.x, stride, 14, delta)
    if (rightLeg.current) rightLeg.current.rotation.x = MathUtils.damp(rightLeg.current.rotation.x, -stride, 14, delta)
    if (leftArm.current) leftArm.current.rotation.x = activity === 'carry' || activity === 'inspect' ? -0.8 : -stride * 0.7
    if (rightArm.current) rightArm.current.rotation.x = activity === 'hammer' ? -0.98 - (reduced ? 0 : Math.pow((1 + Math.sin(t * 3.4)) / 2, 2) * 0.37) : activity === 'carry' || activity === 'inspect' ? -0.8 : stride * 0.7
    if (rig.current) {
      rig.current.position.y = reduced ? 0 : walking ? Math.abs(Math.sin(t * 10)) * 0.045 : Math.sin(t * 2) * 0.013
      rig.current.rotation.z = walking && !reduced ? Math.sin(t * 10) * 0.025 : 0
      if (activity === 'player' && state.answerFeedback && !reduced) {
        rig.current.position.y += state.answerFeedback.correct ? Math.abs(Math.sin(t * 7)) * 0.06 : 0
        rig.current.rotation.z += state.answerFeedback.correct ? Math.sin(t * 8) * 0.035 : -0.05
      }
    }
    if (head.current) head.current.rotation.y = reduced ? 0 : Math.sin(t * 0.8) * (walking ? 0.025 : 0.07)
    if (eyes.current) eyes.current.scale.y = !reduced && t % 4.3 > 4.12 ? 0.12 : 1
  })

  return <group ref={rig} name="engineer-model">
    <group ref={leftLeg} position={[-0.17, -0.39, 0]}><Leg side={-1} /></group>
    <group ref={rightLeg} position={[0.17, -0.39, 0]}><Leg side={1} /></group>
    <mesh castShadow><latheGeometry args={[torso, 48]} /><meshStandardMaterial color={vest} roughness={0.72} /></mesh>
    <mesh position={[0, 0.32, 0]} castShadow><cylinderGeometry args={[0.15, 0.19, 0.16, 32]} /><meshStandardMaterial color="#31566b" roughness={0.85} /></mesh>
    {/* Reflective tape wraps the vest, keeping strips flush with the curved body. */}
    {[-0.14, -0.22].map((y) => <mesh key={y} position={[0, y, 0]} rotation={[Math.PI / 2, 0, 0]} scale={[1, 1, 0.75]}><torusGeometry args={[0.377, 0.022, 8, 64]} /><meshStandardMaterial color="#f4f1cf" roughness={0.38} metalness={0.15} /></mesh>)}
    {[-0.2, 0.2].map((x) => <RoundedBox key={x} args={[0.065, 0.42, 0.025]} radius={0.01} position={[x, 0.075, 0.312]} rotation={[-0.08, x > 0 ? 0.3 : -0.3, x > 0 ? -0.12 : 0.12]}><meshStandardMaterial color="#f4f1cf" roughness={0.42} /></RoundedBox>)}
    <mesh position={[0, 0.07, 0.379]}><boxGeometry args={[0.018, 0.4, 0.012]} /><meshStandardMaterial color="#b55325" roughness={0.6} /></mesh>
    <RoundedBox args={[0.13, 0.15, 0.035]} radius={0.012} position={[0.15, 0.13, 0.35]}><meshStandardMaterial color="#2d6b78" /></RoundedBox>
    <mesh position={[0.15, 0.145, 0.371]}><boxGeometry args={[0.075, 0.025, 0.008]} /><meshStandardMaterial color="#f5efe0" /></mesh>
    <mesh position={[0, -0.34, 0]}><cylinderGeometry args={[0.33, 0.3, 0.085, 48]} /><meshStandardMaterial color="#5b4637" roughness={0.72} /></mesh>
    <RoundedBox args={[0.13, 0.085, 0.035]} radius={0.018} position={[0, -0.34, 0.328]}><meshStandardMaterial color="#b8c3c8" metalness={0.8} roughness={0.3} /></RoundedBox>
    <RoundedBox args={[0.18, 0.23, 0.14]} radius={0.035} position={[-0.34, -0.28, 0.02]} castShadow><meshStandardMaterial color="#805b3a" roughness={0.85} /></RoundedBox>
    <RoundedBox args={[0.44, 0.49, 0.22]} radius={0.08} position={[0, 0.01, -0.35]} castShadow><meshStandardMaterial color="#247789" roughness={0.5} /></RoundedBox>
    {[-1, 1].map((side) => <group key={side} ref={side < 0 ? leftArm : rightArm} position={[side * 0.37, 0.19, 0]} rotation={[0, 0, side * 0.12]}>
      <mesh position={[0, -0.13, 0]} castShadow><capsuleGeometry args={[0.12, 0.23, 8, 24]} /><meshStandardMaterial color="#31566b" roughness={0.82} /></mesh>
      <mesh position={[0, -0.28, 0.012]} castShadow><capsuleGeometry args={[0.09, 0.13, 8, 24]} /><meshStandardMaterial color="#c68c66" roughness={0.7} /></mesh>
      <group name={activity === 'hammer' && side > 0 ? 'hammer-hand' : undefined} position={[0, -0.42, 0.035]}><Glove /></group>
      {activity === 'hammer' && side > 0 && <group name="hammer-grip" position={[0, -0.42, 0.035]}>
        <mesh position={[0, 0, 0.19]} rotation={[Math.PI / 2, 0, 0]} castShadow><cylinderGeometry args={[0.027, 0.034, 0.44, 24]} /><meshStandardMaterial color="#a7764d" roughness={0.65} /></mesh>
        <mesh rotation={[Math.PI / 2, 0, 0]}><cylinderGeometry args={[0.039, 0.039, 0.14, 24]} /><meshStandardMaterial color="#293d46" roughness={0.85} /></mesh>
        <RoundedBox args={[0.1, 0.25, 0.1]} radius={0.025} smoothness={5} position={[0, 0, 0.41]} castShadow><meshStandardMaterial color="#93a5ad" metalness={0.85} roughness={0.25} /></RoundedBox>
        <mesh name="hammer-face" position={[0, -0.13, 0.41]} castShadow><cylinderGeometry args={[0.048, 0.058, 0.045, 24]} /><meshStandardMaterial color="#c1cbd0" metalness={0.8} roughness={0.22} /></mesh>
      </group>}
    </group>)}
    <group ref={head} position={[0, 0.73, 0.015]}>
      <mesh scale={[1.06, 1.02, 0.98]} castShadow><sphereGeometry args={[0.36, 48, 32]} /><meshStandardMaterial color="#cf956e" roughness={0.64} /></mesh>
      <mesh position={[0, -0.16, 0.115]} scale={[1, 0.7, 0.82]} castShadow><sphereGeometry args={[0.27, 32, 24]} /><meshStandardMaterial color="#cf956e" roughness={0.64} /></mesh>
      {[-1, 1].map((side) => <group key={side} position={[side * 0.365, -0.015, 0]}><mesh scale={[0.6, 1, 0.8]} castShadow><sphereGeometry args={[0.105, 24, 16]} /><meshStandardMaterial color="#c68c66" roughness={0.7} /></mesh><mesh position={[side * 0.037, 0, 0.05]} scale={[0.35, 0.55, 0.25]}><sphereGeometry args={[0.085, 20, 16]} /><meshStandardMaterial color="#b87a59" /></mesh></group>)}
      <mesh position={[0, 0.065, -0.125]} scale={[1.03, 0.85, 0.83]} castShadow><sphereGeometry args={[0.33, 32, 24]} /><meshStandardMaterial color="#47352c" roughness={0.9} /></mesh>
      <group ref={eyes} position={[0, 0.025, 0.325]}>
        {[-1, 1].map((side) => <group key={side} position={[side * 0.14, 0, 0]} rotation={[0, side * 0.17, 0]}>
          <mesh scale={[0.86, 1.15, 0.4]}><sphereGeometry args={[0.068, 24, 20]} /><meshStandardMaterial color="#fff3df" roughness={0.35} /></mesh>
          <mesh position={[0.008, 0, 0.026]} scale={[0.7, 1, 0.32]}><sphereGeometry args={[0.047, 24, 20]} /><meshStandardMaterial color="#243b3f" roughness={0.22} /></mesh>
          <mesh position={[-0.006, 0.018, 0.042]}><sphereGeometry args={[0.014, 12, 8]} /><meshBasicMaterial color="#ffffff" /></mesh>
        </group>)}
      </group>
      {[-1, 1].map((side) => <mesh key={side} position={[side * 0.145, 0.13, 0.305]} rotation={[0, 0, Math.PI / 2 + side * 0.1]} castShadow><capsuleGeometry args={[0.027, 0.092, 6, 20]} /><meshStandardMaterial color="#513a2e" roughness={0.8} /></mesh>)}
      <mesh position={[0, -0.045, 0.37]} scale={[1.05, 0.8, 0.9]} castShadow><sphereGeometry args={[0.098, 32, 24]} /><meshStandardMaterial color="#d79a70" roughness={0.6} /></mesh>
      <mesh position={[0, -0.175, 0.321]} rotation={[0, 0, Math.PI]}><torusGeometry args={[0.075, 0.012, 8, 24, Math.PI]} /><meshStandardMaterial color="#90573f" roughness={0.75} /></mesh>
      <group position={[0, 0.24, 0]}>
        <mesh scale={[1.12, 0.72, 1.05]} castShadow><sphereGeometry args={[0.42, 48, 32, 0, Math.PI * 2, 0, Math.PI / 2]} /><meshPhysicalMaterial color="#f2bd32" roughness={0.3} clearcoat={0.42} clearcoatRoughness={0.25} /></mesh>
        <mesh rotation={[Math.PI / 2, 0, 0]} scale={[1.12, 1.08, 0.65]} castShadow><torusGeometry args={[0.418, 0.042, 16, 64]} /><meshPhysicalMaterial color="#eeb426" roughness={0.34} clearcoat={0.3} /></mesh>
        <RoundedBox args={[0.62, 0.075, 0.27]} radius={0.035} smoothness={6} position={[0, 0, 0.34]} castShadow><meshPhysicalMaterial color="#f2bd32" roughness={0.3} clearcoat={0.3} /></RoundedBox>
        <mesh position={[0, 0.23, 0]} scale={[0.11, 0.75, 0.94]} castShadow><sphereGeometry args={[0.3, 32, 20]} /><meshStandardMaterial color="#edb12e" roughness={0.4} /></mesh>
        <RoundedBox args={[0.16, 0.12, 0.025]} radius={0.012} position={[0, 0.095, 0.424]}><meshStandardMaterial color="#258593" roughness={0.4} /></RoundedBox>
      </group>
    </group>
    {activity === 'carry' && <RoundedBox args={[0.62, 0.4, 0.45]} radius={0.035} position={[0, -0.02, 0.6]} castShadow><meshStandardMaterial color="#b48960" roughness={0.8} /></RoundedBox>}
    {activity === 'inspect' && <RoundedBox args={[0.42, 0.035, 0.32]} radius={0.015} position={[0, -0.16, 0.43]} rotation={[0.35, 0, 0]} castShadow><meshStandardMaterial color="#e7ddbd" roughness={0.85} /></RoundedBox>}
  </group>
}
