import { Float, Html, RoundedBox } from '@react-three/drei'
import { useFrame } from '@react-three/fiber'
import { CuboidCollider, RigidBody } from '@react-three/rapier'
import { useRef } from 'react'
import { Group, MathUtils } from 'three'
import type { StationDefinition } from '../types'
import { useGameStore } from '../../state/useGameStore'
import { useSurfaceMaps } from '../art/useSurfaceMaps'
import { SITE_COLORS } from '../art/palette'

type StationProps = { station: StationDefinition }

function GlassVessel({ position, color, tall = false }: { position: [number, number, number]; color: string; tall?: boolean }) {
  return (
    <group position={position}>
      <mesh castShadow>
        <cylinderGeometry args={[tall ? 0.13 : 0.2, tall ? 0.17 : 0.24, tall ? 0.72 : 0.48, 16]} />
        <meshPhysicalMaterial color={SITE_COLORS.glass} transparent opacity={0.38} roughness={0.12} transmission={0.25} thickness={0.15} />
      </mesh>
      <mesh position={[0, tall ? -0.15 : -0.1, 0]}>
        <cylinderGeometry args={[tall ? 0.115 : 0.18, tall ? 0.15 : 0.21, tall ? 0.36 : 0.22, 16]} />
        <meshStandardMaterial color={color} emissive={color} emissiveIntensity={0.14} transparent opacity={0.82} />
      </mesh>
    </group>
  )
}

function PeriodicTerminal({ accent }: { accent: string }) {
  return (
    <group>
      <mesh position={[0, 1.5, 0.2]} rotation={[-0.12, 0, 0]} castShadow>
        <boxGeometry args={[1.72, 1.05, 0.16]} />
        <meshStandardMaterial color={SITE_COLORS.steelDark} roughness={0.42} metalness={0.35} />
      </mesh>
      {Array.from({ length: 18 }, (_, index) => {
        const column = index % 6
        const row = Math.floor(index / 6)
        const color = column < 2 ? accent : column < 4 ? '#64dba7' : '#f2bd2d'
        return (
          <mesh key={index} position={[-0.62 + column * 0.25, 1.78 - row * 0.24, 0.3]} rotation={[-0.12, 0, 0]}>
            <boxGeometry args={[0.18, 0.15, 0.035]} />
            <meshStandardMaterial color={color} emissive={color} emissiveIntensity={0.42} />
          </mesh>
        )
      })}
      <mesh position={[0, 0.98, 0.43]}><boxGeometry args={[0.52, 0.09, 0.32]} /><meshStandardMaterial color={SITE_COLORS.galvanized} metalness={0.45} roughness={0.4} /></mesh>
    </group>
  )
}

function SubstanceStorage({ accent }: { accent: string }) {
  return (
    <group>
      <mesh position={[0, 1.1, 0.1]} castShadow><boxGeometry args={[1.82, 0.12, 0.78]} /><meshStandardMaterial color={SITE_COLORS.galvanized} metalness={0.48} roughness={0.48} /></mesh>
      {[-0.58, 0, 0.58].map((x, index) => (
        <group key={x} position={[x, 1.38, 0.12]}>
          <mesh castShadow><cylinderGeometry args={[0.2, 0.22, 0.52, 14]} /><meshStandardMaterial color={index === 1 ? '#dfebe7' : accent} roughness={0.34} metalness={0.08} /></mesh>
          <mesh position={[0, 0.03, 0.205]}><boxGeometry args={[0.22, 0.14, 0.025]} /><meshBasicMaterial color={index === 1 ? accent : '#f7f0d5'} /></mesh>
          <mesh position={[0, 0.3, 0]}><cylinderGeometry args={[0.12, 0.12, 0.08, 12]} /><meshStandardMaterial color={SITE_COLORS.steelDark} roughness={0.65} /></mesh>
        </group>
      ))}
    </group>
  )
}

function FormulaBoard({ accent }: { accent: string }) {
  return (
    <group>
      <mesh position={[0, 1.5, 0.16]} rotation={[-0.08, 0, 0]} castShadow><boxGeometry args={[1.88, 1.02, 0.17]} /><meshStandardMaterial color="#172f35" roughness={0.38} metalness={0.28} /></mesh>
      <mesh position={[0, 1.57, 0.27]} rotation={[-0.08, 0, 0]}><boxGeometry args={[1.58, 0.55, 0.025]} /><meshStandardMaterial color="#123f49" emissive={accent} emissiveIntensity={0.22} roughness={0.3} /></mesh>
      {[-0.55, 0, 0.55].map((x, index) => (
        <RoundedBox key={x} args={[0.4, 0.3, 0.12]} radius={0.05} smoothness={3} position={[x, 1.55, 0.34]}>
          <meshStandardMaterial color={index === 1 ? '#f5efe0' : accent} roughness={0.42} />
        </RoundedBox>
      ))}
      <mesh position={[0, 1.02, 0.42]}><boxGeometry args={[0.86, 0.08, 0.26]} /><meshStandardMaterial color={SITE_COLORS.safety} roughness={0.48} /></mesh>
    </group>
  )
}

function ReactionBench({ accent }: { accent: string }) {
  return (
    <group>
      <mesh position={[0, 1.07, 0.08]} castShadow><boxGeometry args={[1.92, 0.14, 0.86]} /><meshStandardMaterial color={SITE_COLORS.galvanized} roughness={0.38} metalness={0.52} /></mesh>
      <GlassVessel position={[-0.57, 1.42, 0.08]} color={accent} />
      <GlassVessel position={[0, 1.5, 0.08]} color="#f2bd2d" tall />
      <GlassVessel position={[0.57, 1.42, 0.08]} color="#4ed9a1" />
      <mesh position={[0, 1.2, -0.22]} castShadow><boxGeometry args={[1.65, 0.08, 0.18]} /><meshStandardMaterial color={SITE_COLORS.steelDark} roughness={0.45} metalness={0.52} /></mesh>
    </group>
  )
}

function MixingStation({ accent }: { accent: string }) {
  return (
    <group>
      <mesh position={[0, 1.22, 0.06]} castShadow><cylinderGeometry args={[0.66, 0.56, 0.72, 24]} /><meshStandardMaterial color={SITE_COLORS.galvanized} metalness={0.45} roughness={0.36} /></mesh>
      <mesh position={[0, 1.61, 0.06]}><cylinderGeometry args={[0.55, 0.55, 0.08, 24]} /><meshStandardMaterial color={accent} emissive={accent} emissiveIntensity={0.24} roughness={0.2} /></mesh>
      {[0, 0.9, 1.8].map((phase, index) => (
        <Float key={phase} speed={2 + index * 0.3} floatIntensity={0.24} rotationIntensity={0}>
          <mesh position={[-0.28 + index * 0.28, 1.82 + Math.sin(phase) * 0.06, 0.1]}><sphereGeometry args={[0.075 + index * 0.01, 10, 8]} /><meshStandardMaterial color="#d8fff5" transparent opacity={0.72} emissive={accent} emissiveIntensity={0.35} /></mesh>
        </Float>
      ))}
      <mesh position={[-0.72, 1.55, -0.05]} rotation={[0, 0, -0.35]}><cylinderGeometry args={[0.08, 0.08, 0.95, 10]} /><meshStandardMaterial color={SITE_COLORS.steel} metalness={0.62} roughness={0.34} /></mesh>
    </group>
  )
}

function SolutionLaboratory({ accent }: { accent: string }) {
  return (
    <group>
      <mesh position={[-0.48, 1.22, 0.02]} castShadow><cylinderGeometry args={[0.38, 0.38, 0.09, 22]} /><meshStandardMaterial color="#e2e6df" metalness={0.28} roughness={0.32} /></mesh>
      <mesh position={[-0.48, 1.02, 0.02]} castShadow><boxGeometry args={[0.8, 0.34, 0.72]} /><meshStandardMaterial color={SITE_COLORS.steel} roughness={0.44} metalness={0.36} /></mesh>
      <mesh position={[-0.48, 1.04, 0.39]}><boxGeometry args={[0.38, 0.12, 0.03]} /><meshStandardMaterial color={accent} emissive={accent} emissiveIntensity={0.55} /></mesh>
      <GlassVessel position={[0.45, 1.42, 0.05]} color={accent} tall />
      <GlassVessel position={[0.8, 1.34, 0.1]} color="#7ae7b5" />
    </group>
  )
}

function IonicReactor({ accent }: { accent: string }) {
  return (
    <group>
      <mesh position={[0, 1.38, 0.04]} castShadow><cylinderGeometry args={[0.5, 0.5, 1.05, 22]} /><meshPhysicalMaterial color={SITE_COLORS.glass} transparent opacity={0.34} transmission={0.3} roughness={0.08} thickness={0.2} /></mesh>
      <mesh position={[0, 1.12, 0.04]}><cylinderGeometry args={[0.45, 0.45, 0.42, 22]} /><meshStandardMaterial color={accent} transparent opacity={0.55} emissive={accent} emissiveIntensity={0.18} /></mesh>
      {[-0.24, -0.08, 0.1, 0.25].map((x, index) => (
        <Float key={x} speed={1.4 + index * 0.2} rotationIntensity={0.2} floatIntensity={0.18}><mesh position={[x, 1.16 + index * 0.09, 0.14]}><octahedronGeometry args={[0.07, 0]} /><meshStandardMaterial color={index % 2 ? '#f4f0d7' : accent} emissive={accent} emissiveIntensity={0.22} /></mesh></Float>
      ))}
      {[-0.62, 0.62].map((x) => <mesh key={x} position={[x, 1.35, 0.02]} castShadow><boxGeometry args={[0.18, 0.84, 0.18]} /><meshStandardMaterial color={SITE_COLORS.steel} metalness={0.58} roughness={0.38} /></mesh>)}
    </group>
  )
}

function InspectionRig({ accent }: { accent: string }) {
  return (
    <group>
      <RoundedBox args={[0.88, 0.74, 0.72]} radius={0.08} smoothness={3} position={[-0.35, 1.36, 0.02]} castShadow><meshStandardMaterial color={SITE_COLORS.concreteLight} roughness={0.88} /></RoundedBox>
      {[[-0.52, 1.78, -0.12], [-0.18, 1.78, 0.16]].map((position, index) => <mesh key={index} position={position as [number, number, number]}><cylinderGeometry args={[0.035, 0.035, 0.62, 8]} /><meshStandardMaterial color="#805347" metalness={0.5} roughness={0.66} /></mesh>)}
      <mesh position={[0.57, 1.5, 0.04]} rotation={[0, -0.16, 0]} castShadow><boxGeometry args={[0.55, 0.72, 0.18]} /><meshStandardMaterial color={SITE_COLORS.steelDark} metalness={0.4} roughness={0.36} /></mesh>
      <mesh position={[0.57, 1.56, 0.145]} rotation={[0, -0.16, 0]}><boxGeometry args={[0.4, 0.35, 0.025]} /><meshStandardMaterial color={accent} emissive={accent} emissiveIntensity={0.48} /></mesh>
    </group>
  )
}

function ElectrochemistryRig({ accent }: { accent: string }) {
  return (
    <group>
      <GlassVessel position={[-0.45, 1.4, 0.08]} color="#7dd9e8" tall />
      <GlassVessel position={[0.45, 1.4, 0.08]} color="#d79b58" tall />
      {[-0.45, 0.45].map((x, index) => <mesh key={x} position={[x, 1.62, 0.06]} castShadow><boxGeometry args={[0.11, 0.86, 0.18]} /><meshStandardMaterial color={index ? '#bc7149' : '#8ba4a6'} metalness={0.72} roughness={0.34} /></mesh>)}
      <mesh position={[0, 1.08, 0.42]}><boxGeometry args={[0.7, 0.27, 0.12]} /><meshStandardMaterial color={SITE_COLORS.steelDark} metalness={0.42} roughness={0.35} /></mesh>
      <mesh position={[0, 1.08, 0.49]}><boxGeometry args={[0.38, 0.1, 0.025]} /><meshStandardMaterial color={accent} emissive={accent} emissiveIntensity={0.62} /></mesh>
      <mesh position={[0, 1.94, 0]} rotation={[Math.PI / 2, 0, 0]}><torusGeometry args={[0.62, 0.025, 6, 30, Math.PI]} /><meshStandardMaterial color={SITE_COLORS.safety} emissive={SITE_COLORS.safety} emissiveIntensity={0.16} /></mesh>
    </group>
  )
}

function CorrosionRig({ accent }: { accent: string }) {
  return (
    <group>
      <mesh position={[-0.3, 1.33, 0.04]} rotation={[0, 0, Math.PI / 2]} castShadow><boxGeometry args={[0.28, 1.34, 0.5]} /><meshStandardMaterial color="#6f7772" metalness={0.66} roughness={0.56} /></mesh>
      {[-0.52, -0.12, 0.22].map((x, index) => <mesh key={x} position={[x, 1.34, 0.3]} rotation={[Math.PI / 2, 0, 0]}><circleGeometry args={[0.09 + index * 0.025, 12]} /><meshStandardMaterial color={accent} roughness={0.94} /></mesh>)}
      <mesh position={[0.62, 1.5, 0.03]} rotation={[0, -0.14, 0]} castShadow><boxGeometry args={[0.56, 0.76, 0.2]} /><meshStandardMaterial color={SITE_COLORS.steelDark} metalness={0.42} roughness={0.38} /></mesh>
      <mesh position={[0.62, 1.55, 0.15]} rotation={[0, -0.14, 0]}><boxGeometry args={[0.4, 0.36, 0.025]} /><meshStandardMaterial color={accent} emissive={accent} emissiveIntensity={0.48} /></mesh>
      <mesh position={[0.25, 1.7, 0.08]} rotation={[0, 0, 0.55]}><cylinderGeometry args={[0.055, 0.055, 0.9, 10]} /><meshStandardMaterial color={SITE_COLORS.safety} metalness={0.35} roughness={0.38} /></mesh>
    </group>
  )
}

function MaterialsLab({ accent }: { accent: string }) {
  return (
    <group>
      {[-0.64, 0, 0.64].map((x, index) => <RoundedBox key={x} args={[0.46, 0.46, 0.46]} radius={0.05} smoothness={3} position={[x, 1.28, 0.16]} castShadow><meshStandardMaterial color={index === 1 ? '#d7d2c5' : SITE_COLORS.concreteLight} roughness={0.88} /></RoundedBox>)}
      <mesh position={[0, 1.05, -0.26]} castShadow><boxGeometry args={[1.72, 0.16, 0.24]} /><meshStandardMaterial color={SITE_COLORS.galvanized} metalness={0.52} roughness={0.38} /></mesh>
      <mesh position={[0, 1.72, -0.25]} castShadow><boxGeometry args={[0.18, 1.2, 0.18]} /><meshStandardMaterial color={SITE_COLORS.steel} metalness={0.6} roughness={0.36} /></mesh>
      <mesh position={[0, 1.93, 0.02]} castShadow><boxGeometry args={[0.8, 0.18, 0.58]} /><meshStandardMaterial color={SITE_COLORS.steelDark} metalness={0.48} roughness={0.34} /></mesh>
      <mesh position={[0, 1.93, 0.32]}><boxGeometry args={[0.42, 0.09, 0.025]} /><meshStandardMaterial color={accent} emissive={accent} emissiveIntensity={0.44} /></mesh>
    </group>
  )
}

function StationEquipment({ station }: StationProps) {
  switch (station.stationType) {
    case 'periodic-table-terminal': return <PeriodicTerminal accent={station.accent} />
    case 'substance-storage': return <SubstanceStorage accent={station.accent} />
    case 'formula-board': return <FormulaBoard accent={station.accent} />
    case 'reaction-bench': return <ReactionBench accent={station.accent} />
    case 'mixing-station': return <MixingStation accent={station.accent} />
    case 'solution-laboratory': return <SolutionLaboratory accent={station.accent} />
    case 'ionic-reaction-station': return <IonicReactor accent={station.accent} />
    case 'electrochemistry-station': return <ElectrochemistryRig accent={station.accent} />
    case 'corrosion-test-rig': return <CorrosionRig accent={station.accent} />
    case 'construction-materials-station': return <MaterialsLab accent={station.accent} />
    default: return <InspectionRig accent={station.accent} />
  }
}

export function Station({ station }: StationProps) {
  const steelSurface = useSurfaceMaps('metal_plate')
  const isNearby = useGameStore((state) => state.nearbyStationId === station.id)
  const isActive = useGameStore((state) => state.activeStationId === station.id)
  const feedback = useGameStore((state) => state.answerFeedback)
  const beacon = useRef<Group>(null)
  const [x, , z] = station.position
  const rotation = Math.atan2(-x, -z)

  useFrame(({ clock }, delta) => {
    if (!beacon.current) return
    const pulse = isNearby ? 1 + Math.sin(clock.elapsedTime * 5) * 0.08 : 1
    beacon.current.scale.setScalar(MathUtils.damp(beacon.current.scale.x, pulse, 9, delta))
    beacon.current.rotation.y += delta * 0.55
  })

  const feedbackColor = isActive && feedback ? (feedback.correct ? SITE_COLORS.success : SITE_COLORS.danger) : station.accent

  return (
    <group position={[x, 0, z]}>
      <RigidBody type="fixed" colliders={false}>
        <CuboidCollider args={[1.25, 0.55, 0.71]} position={[0, 0.55, 0]} rotation={[0, rotation, 0]} />
      </RigidBody>
      <group rotation={[0, rotation, 0]}>
        <RoundedBox args={[2.5, 0.88, 1.42]} radius={0.14} smoothness={4} position={[0, 0.5, 0]} castShadow receiveShadow><meshStandardMaterial color={SITE_COLORS.steelDark} roughness={0.58} metalness={0.3} /></RoundedBox>
        <RoundedBox args={[2.48, 0.16, 1.42]} radius={0.06} smoothness={4} position={[0, 0.98, 0]} castShadow receiveShadow><meshStandardMaterial color="#c6d4da" normalMap={steelSurface.normalMap} roughnessMap={steelSurface.roughnessMap} roughness={0.72} metalness={0.72} /></RoundedBox>
        {[-0.82, 0.82].map((x) => <mesh key={x} position={[x, 0.42, 0.716]}><boxGeometry args={[0.5, 0.035, 0.035]} /><meshStandardMaterial color="#d2dfe2" metalness={0.8} roughness={0.3} /></mesh>)}
        <mesh position={[0, 0.91, 0.63]}><boxGeometry args={[2.12, 0.12, 0.06]} /><meshStandardMaterial color={feedbackColor} emissive={feedbackColor} emissiveIntensity={isNearby ? 0.56 : 0.18} /></mesh>
        <StationEquipment station={station} />
        <group ref={beacon} position={[0.96, 1.78, -0.42]}>
          <mesh castShadow><cylinderGeometry args={[0.13, 0.16, 0.24, 12]} /><meshStandardMaterial color={feedbackColor} emissive={feedbackColor} emissiveIntensity={isNearby ? 1.25 : 0.42} roughness={0.24} /></mesh>
          <pointLight color={feedbackColor} intensity={isNearby ? 0.8 : 0} distance={2.5} decay={2} />
        </group>
      </group>
      <mesh position={[0, 0.025, 0]} rotation={[-Math.PI / 2, 0, 0]}><ringGeometry args={[1.38, 1.48, 48]} /><meshBasicMaterial color={station.accent} transparent opacity={isNearby ? 0.72 : 0.1} depthWrite={false} /></mesh>
      {/* Screen-space labels keep their pixel size with the orthographic camera. */}
      <Html position={[0, 2.42, 0]} center zIndexRange={[2, 1]} style={{ pointerEvents: 'none' }}><div className={isNearby ? 'world-label world-label--active' : 'world-label'}><span>{station.icon}</span><b>{station.shortName}</b></div></Html>
    </group>
  )
}
