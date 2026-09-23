import { Float, RoundedBox } from '@react-three/drei'
import { useFrame } from '@react-three/fiber'
import { CuboidCollider, RigidBody } from '@react-three/rapier'
import { useMemo, useRef } from 'react'
import { Group } from 'three'
import { SITE_COLORS } from '../art/palette'
import { SiteAsset } from '../assets/SiteAsset'
import { STATIONS } from '../config/stations'
import { Station } from '../stations/Station'
import { pavingSurface } from '../art/surfaceTextures'
import { useSurfaceMaps } from '../art/useSurfaceMaps'
import { SiteDetails } from './SiteDetails'
import { ConstructionCrew } from './ConstructionCrew'
import { useGameStore } from '../../state/useGameStore'
import { Neighborhood } from './Neighborhood'

function SiteGround() {
  const concreteSurface = useSurfaceMaps('concrete_wall_009')
  return (
    <>
      <mesh position={[0, -0.92, 0]} receiveShadow>
        <boxGeometry args={[36, 1.1, 29]} />
        <meshStandardMaterial color="#344751" {...concreteSurface} roughness={1} />
      </mesh>

      <RigidBody type="fixed" colliders={false}>
        <CuboidCollider args={[12, 0.25, 9]} position={[0, -0.2, 0]} />
        <RoundedBox args={[24.5, 0.62, 18.5]} radius={0.18} smoothness={5} position={[0, -0.26, 0]} receiveShadow>
          <meshStandardMaterial color="#b7c3c9" {...concreteSurface} roughness={0.95} />
        </RoundedBox>
      </RigidBody>

      <RoundedBox args={[7.4, 0.08, 5.8]} radius={0.025} smoothness={4} position={[-7.4, 0.055, 4.9]} receiveShadow>
        <meshStandardMaterial color="#d9c5ac" {...concreteSurface} roughness={0.9} />
      </RoundedBox>
      <RoundedBox args={[8.1, 0.08, 5.6]} radius={0.025} smoothness={4} position={[7.45, 0.055, 4.6]} receiveShadow>
        <meshStandardMaterial color="#789eac" {...concreteSurface} roughness={0.8} />
      </RoundedBox>
      <RoundedBox args={[7.5, 0.08, 5]} radius={0.025} smoothness={4} position={[-7.2, 0.055, -5.15]} receiveShadow>
        <meshStandardMaterial color="#a5b8c1" {...concreteSurface} roughness={0.9} />
      </RoundedBox>
      <RoundedBox args={[8, 0.08, 5]} radius={0.025} smoothness={4} position={[7.2, 0.055, -4.9]} receiveShadow>
        <meshStandardMaterial color="#739ba6" {...concreteSurface} roughness={0.8} />
      </RoundedBox>

      <mesh position={[0, 0.102, 0]} rotation={[-Math.PI / 2, 0, 0]} receiveShadow>
        <planeGeometry args={[3.3, 15.5]} />
        <meshStandardMaterial color="#d5dce0" {...pavingSurface} roughness={0.82} />
      </mesh>
      <mesh position={[0, 0.105, -0.2]} rotation={[-Math.PI / 2, 0, Math.PI / 2]} receiveShadow>
        <planeGeometry args={[3, 19.6]} />
        <meshStandardMaterial color="#d5dce0" {...pavingSurface} roughness={0.82} />
      </mesh>

      {[-5.55, 5.55].map((x) => (
        <group key={x} position={[x, 0.115, 0]}>
          {[-1, 0, 1].map((z) => (
            <mesh key={z} position={[0, 0, z * 1.35]} rotation={[-Math.PI / 2, 0, 0]}>
              <planeGeometry args={[0.16, 0.75]} />
              <meshBasicMaterial color={SITE_COLORS.safety} transparent opacity={0.46} />
            </mesh>
          ))}
        </group>
      ))}
    </>
  )
}

function CenterMarking() {
  const nodes: Array<[number, number]> = [[-0.82, -0.18], [0.7, -0.52], [0.2, 0.82]]
  return (
    <group position={[0, 0.116, 0]}>
      <mesh rotation={[-Math.PI / 2, 0, 0]}><ringGeometry args={[1.08, 1.14, 48]} /><meshBasicMaterial color="#d7cfb8" transparent opacity={0.72} /></mesh>
      {nodes.map(([x, z], index) => (
        <group key={index}>
          <mesh position={[x / 2, 0, z / 2]} rotation={[-Math.PI / 2, 0, Math.atan2(z, x)]}><planeGeometry args={[1.05, 0.07]} /><meshBasicMaterial color="#d7cfb8" transparent opacity={0.6} /></mesh>
          <mesh position={[x, 0.003, z]} rotation={[-Math.PI / 2, 0, 0]}><ringGeometry args={[0.16, 0.24, 24]} /><meshBasicMaterial color={index === 1 ? SITE_COLORS.safety : SITE_COLORS.chemistry} transparent opacity={0.62} /></mesh>
        </group>
      ))}
    </group>
  )
}

function Perimeter() {
  const colliders: Array<[number, number, number, number, number]> = [
    [0, 0.55, -8.7, 11.7, 0.22],
    [0, 0.55, 8.7, 11.7, 0.22],
    [-11.7, 0.55, 0, 0.22, 8.5],
    [11.7, 0.55, 0, 0.22, 8.5],
  ]
  const railRuns: Array<[number, number, number, number]> = [
    [-5.7, -8.55, 8, 0], [6.5, -8.55, 7, 0],
    [-6.8, 8.55, 7, 0], [6.6, 8.55, 7, 0],
    [-11.65, -4.2, 5, Math.PI / 2], [-11.65, 5.4, 4, Math.PI / 2],
    [11.65, -4.7, 5, Math.PI / 2], [11.65, 5.1, 4, Math.PI / 2],
  ]
  return (
    <>
      {colliders.map(([x, y, z, hx, hz], index) => (
        <RigidBody key={index} type="fixed" colliders={false}>
          <CuboidCollider args={[hx, 0.55, hz]} position={[x, y, z]} />
        </RigidBody>
      ))}
      {railRuns.map(([x, z, length, rotation], index) => (
        <group key={index} position={[x, 0, z]} rotation={[0, rotation, 0]}>
          {Array.from({ length }, (_, post) => (
            <group key={post} position={[(post - (length - 1) / 2) * 1.35, 0, 0]}>
              <mesh position={[0, 0.55, 0]} castShadow><boxGeometry args={[0.11, 1.1, 0.11]} /><meshStandardMaterial color={SITE_COLORS.steel} metalness={0.5} roughness={0.48} /></mesh>
              {post < length - 1 && <mesh position={[0.68, 0.72, 0]} castShadow><boxGeometry args={[1.38, 0.13, 0.12]} /><meshStandardMaterial color={post % 2 ? SITE_COLORS.safetyOrange : SITE_COLORS.safety} roughness={0.46} metalness={0.2} /></mesh>}
            </group>
          ))}
        </group>
      ))}
    </>
  )
}

function StructuralZone() {
  const columns: Array<[number, number, number]> = [[-10.2, -7.1, 0], [-8.15, -7.1, 0], [-10.2, -4.8, 0], [-8.15, -4.8, 0]]
  return (
    <group>
      {columns.map(([x, z], index) => <SiteAsset key={index} name="column-wide" position={[x, 0, z]} scale={[0.8, 2.35, 0.8]} />)}
      <mesh position={[-9.18, 4.45, -7.1]} castShadow><boxGeometry args={[2.75, 0.46, 0.58]} /><meshStandardMaterial color={SITE_COLORS.concreteLight} roughness={0.88} /></mesh>
      <mesh position={[-10.2, 4.45, -5.95]} castShadow><boxGeometry args={[0.58, 0.46, 2.75]} /><meshStandardMaterial color={SITE_COLORS.concreteLight} roughness={0.88} /></mesh>
      {columns.map(([x, z], index) => (
        <group key={`rebar-${index}`} position={[x, 4.65, z]}>
          {[-0.18, 0.18].flatMap((dx) => [-0.18, 0.18].map((dz) => <mesh key={`${dx}-${dz}`} position={[dx, 0.48, dz]} castShadow><cylinderGeometry args={[0.035, 0.035, 1.3, 8]} /><meshStandardMaterial color="#765046" metalness={0.62} roughness={0.6} /></mesh>))}
        </group>
      ))}
      <SiteAsset name="wall-half" position={[-7.2, 0, -7.6]} rotation={[0, Math.PI / 2, 0]} scale={[1.5, 1.25, 1.5]} />
      <SiteAsset name="stairs-open-short" position={[-10.1, 0, -2.8]} rotation={[0, Math.PI, 0]} scale={1.3} />
      <SiteAsset name="barricade-window-b" position={[-6.5, 0, -8.15]} scale={1.15} />
    </group>
  )
}

function MaterialStorage() {
  return (
    <group position={[-10.3, 0, 5.8]}>
      <SiteAsset pack="materials" name="Pallet_Wood" position={[0.4, 0, 0.5]} scale={0.82} rotation={[0, 0.2, 0]} />
      <SiteAsset pack="materials" name="Wood_Planks_Stack_Large" position={[-0.45, 0.2, 0.15]} scale={0.7} rotation={[0, -0.22, 0]} />
      <SiteAsset pack="materials" name="Stone_Bricks_Stack_Large" position={[1.35, 0.15, -0.05]} scale={0.65} rotation={[0, 0.12, 0]} />
      <SiteAsset pack="materials" name="Textiles_Stack_Large" position={[0.25, 0.15, -1.25]} scale={0.72} rotation={[0, 0.08, 0]} />
      <SiteAsset pack="materials" name="Iron_Bars_Stack_Large" position={[-1.05, 0, -1.1]} scale={0.55} rotation={[0, -0.12, 0]} />
      <SiteAsset pack="materials" name="Fuel_A_Barrels" position={[1.35, 0, 1.35]} scale={0.62} />
      <mesh position={[0.1, 0.05, -0.25]} rotation={[-Math.PI / 2, 0, 0]}><ringGeometry args={[2.35, 2.44, 4]} /><meshBasicMaterial color={SITE_COLORS.safety} transparent opacity={0.42} /></mesh>
    </group>
  )
}

function AnimatedCrane() {
  const hook = useRef<Group>(null)
  const elapsed = useRef(0)
  useFrame((_, delta) => {
    if (!hook.current) return
    const state = useGameStore.getState()
    if (state.mode === 'paused' || state.learningProgress.settings.reducedMotion) return
    elapsed.current += Math.min(delta, 0.05)
    const angle = Math.sin(elapsed.current * 0.16) * 0.32
    hook.current.position.x = -Math.sin(angle) * 4.3
    hook.current.position.z = -Math.cos(angle) * 4.3
    hook.current.scale.y = 1 + Math.sin(elapsed.current * 0.38) * 0.25
  })
  return (
    <group position={[-7.6, 0, -11.15]} rotation={[0, Math.PI + 0.2, 0]}>
      <SiteAsset name="crane" scale={1.65} collidable={false} />
      <group ref={hook} position={[0, 4.95, -4.3]}>
        <SiteAsset name="crane-lift" scale={0.68} collidable={false} />
      </group>
    </group>
  )
}

function MachineryYard() {
  const rotor = useRef<Group>(null)
  useFrame((_, delta) => {
    const state = useGameStore.getState()
    if (state.mode === 'paused' || state.learningProgress.settings.reducedMotion) return
    if (rotor.current) rotor.current.rotation.z += delta * 0.48
  })
  return (
    <group position={[10.8, 0, 7.6]} rotation={[0, -0.62, 0]} scale={0.78}>
      <SiteAsset name="machine" position={[-1.2, 0, 0]} scale={1.45} />
      <SiteAsset name="hopper-high-round" position={[0.65, 0, -0.2]} scale={1.25} />
      <SiteAsset name="pipe-large-long" position={[1.7, 0.45, -0.15]} rotation={[0, Math.PI / 2, 0]} scale={0.72} />
      <SiteAsset name="pipe-large-bend" position={[2.7, 0.45, -0.15]} rotation={[0, Math.PI / 2, 0]} scale={0.72} />
      <group ref={rotor} position={[-1.2, 1.1, 0.82]}>
        {[0, Math.PI / 2].map((rotation) => <mesh key={rotation} rotation={[0, 0, rotation]} castShadow><boxGeometry args={[1.15, 0.12, 0.1]} /><meshStandardMaterial color={SITE_COLORS.safety} roughness={0.45} metalness={0.25} /></mesh>)}
      </group>
      <SiteAsset name="cone" position={[-2.2, 0, 1.15]} scale={1.4} />
      <SiteAsset name="warning-traffic" position={[0.3, 0, 1.5]} scale={0.92} />
    </group>
  )
}

function LaboratoryCabin() {
  return (
    <group position={[9.8, 0, -7.35]} rotation={[0, -0.08, 0]}>
      <RigidBody type="fixed" colliders={false}><CuboidCollider args={[2.6, 1.45, 1.05]} position={[0, 1.45, 0]} /></RigidBody>
      <RoundedBox args={[5.2, 2.9, 2.1]} radius={0.1} smoothness={4} position={[0, 1.45, 0]} castShadow receiveShadow><meshStandardMaterial color="#e0e8e8" roughness={0.48} metalness={0.2} /></RoundedBox>
      <RoundedBox args={[5.5, 0.18, 2.4]} radius={0.07} smoothness={4} position={[0, 2.97, 0]} castShadow><meshStandardMaterial color="#287184" roughness={0.32} metalness={0.5} /></RoundedBox>
      {Array.from({ length: 16 }, (_, i) => <mesh key={i} position={[-2.42 + i * 0.32, 1.4, 1.055]}><boxGeometry args={[0.025, 2.65, 0.03]} /><meshStandardMaterial color="#acbdc4" roughness={0.48} metalness={0.45} /></mesh>)}
      <SiteAsset name="wall-window-wide-square-detailed" position={[-0.45, 0.25, 1.08]} scale={[1.15, 1.15, 0.8]} />
      <SiteAsset name="screen-wide" position={[1.72, 0.95, 1.1]} scale={0.72} />
      <SiteAsset name="scanner-high" position={[-2.05, 0.1, 1.12]} scale={0.72} />
      <mesh position={[0, 3.25, -0.15]} castShadow><cylinderGeometry args={[0.42, 0.5, 0.54, 16]} /><meshStandardMaterial color={SITE_COLORS.galvanized} roughness={0.42} metalness={0.55} /></mesh>
    </group>
  )
}

function PipeRun() {
  return (
    <group position={[12.5, 0, -1.2]} rotation={[0, -Math.PI / 2, 0]}>
      <SiteAsset name="pipe-large-long" position={[0, 0, 0]} scale={0.82} />
      <SiteAsset name="pipe-large-valve" position={[1.52, 0, 0]} scale={0.82} />
      <SiteAsset name="pipe-glass-large-long" position={[3.05, 0, 0]} scale={0.82} />
      <SiteAsset name="pipe-glass-large-bend" position={[4.55, 0, 0]} scale={0.82} />
    </group>
  )
}

function SiteApron() {
  return (
    <group>
      <mesh position={[0, -0.35, -11.4]} receiveShadow><boxGeometry args={[35, 0.28, 3.2]} /><meshStandardMaterial color={SITE_COLORS.asphalt} roughness={0.92} /></mesh>
      {[-12, -6, 0, 6, 12].map((x) => <mesh key={x} position={[x, -0.19, -11.35]} rotation={[-Math.PI / 2, 0, 0]}><planeGeometry args={[2.6, 0.12]} /><meshBasicMaterial color="#ddc76b" transparent opacity={0.72} /></mesh>)}
      <Neighborhood />
      <SiteAsset name="catwalk-straight" position={[14.1, 0.7, 2.2]} rotation={[0, Math.PI / 2, 0]} scale={1.8} />
      <SiteAsset name="catwalk-stairs" position={[13.2, 0, 3.25]} rotation={[0, Math.PI / 2, 0]} scale={1.4} />
      <SiteAsset name="structure-yellow-tall" position={[-14.4, 0, 3.5]} scale={[1.3, 2.1, 1.3]} />
      <SiteAsset name="structure-yellow-medium" position={[-14.4, 0, 5.7]} scale={[1.3, 2.1, 1.3]} />
      <SiteAsset name="conveyor-long" position={[7.5, -0.1, 10.3]} rotation={[0, 0.24, 0]} scale={1.5} />
      <SiteAsset name="box-large" position={[10.8, -0.1, 11.5]} rotation={[0, -0.15, 0]} scale={1.2} />
      <SiteAsset name="box-small" position={[12.3, -0.1, 11.5]} rotation={[0, 0.2, 0]} scale={1.2} />
    </group>
  )
}

function SiteAtmosphere() {
  const motes = useMemo(() => Array.from({ length: 14 }, (_, index) => ({
    x: -10 + (index * 3.7) % 20,
    y: 1.4 + (index % 5) * 0.58,
    z: -8 + (index * 5.3) % 16,
    size: 0.025 + (index % 3) * 0.012,
  })), [])
  return (
    <group>
      {motes.map((mote, index) => (
        <Float key={index} speed={0.35 + (index % 4) * 0.08} floatIntensity={0.65} rotationIntensity={0}>
          <mesh position={[mote.x, mote.y, mote.z]}><sphereGeometry args={[mote.size, 6, 4]} /><meshBasicMaterial color="#fff1b0" transparent opacity={0.36} depthWrite={false} /></mesh>
        </Float>
      ))}
    </group>
  )
}

export function ConstructionSite() {
  return (
    <group>
      <SiteGround />
      <CenterMarking />
      <SiteApron />
      <Perimeter />
      <StructuralZone />
      <MaterialStorage />
      <AnimatedCrane />
      <ConstructionCrew />
      <MachineryYard />
      <LaboratoryCabin />
      <PipeRun />
      <SiteAtmosphere />
      <SiteDetails />
      {STATIONS.map((station) => <Station key={station.id} station={station} />)}
    </group>
  )
}
