import { useGLTF } from '@react-three/drei'
import { useEffect, useMemo, useRef } from 'react'
import { useFrame } from '@react-three/fiber'
import { Mesh, MeshStandardMaterial } from 'three'
import { useGameStore } from '../../state/useGameStore'
import { WindFlag } from './WindFlag'
import { useSurfaceMaps } from '../art/useSurfaceMaps'

export function Neighborhood() {
  const { scene } = useGLTF('/assets/models/neighborhood.glb')
  const { normalMap, roughnessMap } = useSurfaceMaps('concrete_wall_009')
  const wind = useMemo(() => ({ value: 0 }), [])
  const model = useMemo(() => {
    const clone = scene.clone(true)
    clone.traverse((child) => {
      if (!(child instanceof Mesh) || !(child.material instanceof MeshStandardMaterial)) return
      child.castShadow = true
      child.receiveShadow = true
      child.material = child.material.clone()
      if (['plaster', 'cream'].includes(child.material.name)) {
        child.material.normalMap = normalMap
        child.material.roughnessMap = roughnessMap
        child.material.normalScale.set(0.28, 0.28)
      }
      if (child.material.name.startsWith('leaf')) {
        child.material.color.multiplyScalar(0.78)
        child.material.onBeforeCompile = (shader: Parameters<MeshStandardMaterial['onBeforeCompile']>[0]) => {
          shader.uniforms.ambientWind = wind
          shader.vertexShader = `uniform float ambientWind;\n${shader.vertexShader}`.replace('#include <begin_vertex>', `#include <begin_vertex>
            vec3 windWorld = (modelMatrix * vec4(transformed, 1.0)).xyz;
            float windScale = max(length(modelMatrix[0].xyz), 0.0001);
            transformed.x += sin(ambientWind * 1.2 + windWorld.z * 1.7) * (0.035 / windScale) * smoothstep(0.5, 2.0, windWorld.y);`)
        }
        child.material.customProgramCacheKey = () => 'chemsite-foliage-wind-v1'
      }
    })
    return clone
  }, [scene, normalMap, roughnessMap, wind])
  useEffect(() => () => model.traverse((child) => {
    if (child instanceof Mesh && child.material instanceof MeshStandardMaterial) child.material.dispose()
  }), [model])
  const time = useRef(0)
  useFrame((_, delta) => {
    const state = useGameStore.getState()
    if (state.mode === 'paused' || state.learningProgress.settings.reducedMotion) return
    time.current += Math.min(delta, 0.05)
    wind.value = time.current
  })
  return <group>
    <primitive object={model} />
    {[-16.2, 16.4].map((x) => <group key={x} position={[x, -0.36, -6.4]}>
      <mesh position={[0, 1.7, 0]} castShadow><cylinderGeometry args={[0.045, 0.08, 3.4, 24]} /><meshStandardMaterial color="#6c8991" metalness={0.6} roughness={0.35} /></mesh>
      <mesh position={[0.22, 3.35, 0]} rotation={[0, 0, Math.PI / 2]}><capsuleGeometry args={[0.07, 0.45, 6, 16]} /><meshStandardMaterial color="#526b74" /></mesh>
      <mesh position={[0.44, 3.3, 0]} scale={[1.4, 0.35, 1]}><sphereGeometry args={[0.16, 24, 16]} /><meshStandardMaterial color="#fff1c7" emissive="#ffe3a2" emissiveIntensity={0.4} /></mesh>
    </group>)}
    <group>
      {[-13.8, 14.2].map((x, i) => <group key={x} position={[x, i ? 5.2 : 3.8, -13.5]}>
        <WindFlag color={i ? '#e8b64b' : '#408e9c'} phase={i} />
      </group>)}
    </group>
  </group>
}
useGLTF.preload('/assets/models/neighborhood.glb')
