import { useGLTF } from '@react-three/drei'
import { useEffect, useMemo, useRef } from 'react'
import { useFrame } from '@react-three/fiber'
import { useGameStore } from '../../state/useGameStore'
import type { ThreeElements } from '@react-three/fiber'
import { Box3, Mesh, MeshStandardMaterial, Vector3, type Object3D } from 'three'
import { CuboidCollider, RigidBody } from '@react-three/rapier'

const PACK_URLS = {
  industrial: '/assets/models/industrial-kit.glb',
  materials: '/assets/models/site-materials.glb',
} as const

type SiteAssetProps = Omit<ThreeElements['group'], 'children'> & {
  pack?: keyof typeof PACK_URLS
  name: string
  castShadow?: boolean
  receiveShadow?: boolean
  collidable?: boolean
}

function findAssetScene(scenes: Object3D[], name: string) {
  return scenes.find((scene) => scene.name === name || scene.children[0]?.name === name)
}

export function SiteAsset({
  pack = 'industrial',
  name,
  castShadow = true,
  receiveShadow = true,
  collidable = true,
  ...groupProps
}: SiteAssetProps) {
  const elapsed = useRef(0)
  const gltf = useGLTF(PACK_URLS[pack])
  const object = useMemo(() => {
    const source = findAssetScene(gltf.scenes, name)
    if (!source) throw new Error(`Missing ${pack} site asset: ${name}`)
    const clone = source.clone(true)
    const materials = new Map<MeshStandardMaterial, MeshStandardMaterial>()
    const upgrade = (source: MeshStandardMaterial) => {
      const cached = materials.get(source)
      if (cached) return cached
      const material = source.clone()
      const metal = /pipe|machine|hopper|Iron|scanner|screen|conveyor|catwalk|crane/.test(name)
      const wood = /Wood|Textiles/.test(name)
      material.roughness = metal ? 0.34 : wood ? 0.78 : 0.65
      material.metalness = metal ? 0.48 : 0.04
      material.envMapIntensity = metal ? 0.8 : 0.35
      materials.set(source, material)
      return material
    }
    clone.traverse((child) => {
      if (child instanceof Mesh) {
        child.castShadow = castShadow
        child.receiveShadow = receiveShadow
        child.material = Array.isArray(child.material)
          ? child.material.map(upgrade)
          : upgrade(child.material)
      }
    })
    return clone
  }, [castShadow, gltf.scenes, name, pack, receiveShadow])
  const craneArm = useMemo(() => name === 'crane' ? object.getObjectByName('arm') : undefined, [name, object])
  useFrame((_, delta) => {
    if (!craneArm) return
    const state = useGameStore.getState()
    if (state.mode === 'paused' || state.learningProgress.settings.reducedMotion) return
    elapsed.current += Math.min(delta, 0.05)
    craneArm.rotation.y = Math.sin(elapsed.current * 0.16) * 0.32
  })
  useEffect(() => () => {
    const materials = new Set<MeshStandardMaterial>()
    object.traverse((child) => {
      if (child instanceof Mesh) {
        for (const material of [child.material].flat()) materials.add(material)
      }
    })
    materials.forEach((material) => material.dispose())
  }, [object])
  const bounds = useMemo(() => {
    const box = new Box3().setFromObject(object)
    const center = box.getCenter(new Vector3())
    const halfSize = box.getSize(new Vector3()).multiplyScalar(0.5)
    return { center: center.toArray() as [number, number, number], halfSize: halfSize.toArray() as [number, number, number] }
  }, [object])

  return (
    <group {...groupProps}>
      {collidable ? (
        <RigidBody type="fixed" colliders={false}>
          <CuboidCollider args={bounds.halfSize} position={bounds.center} />
          <primitive object={object} />
        </RigidBody>
      ) : <primitive object={object} />}
    </group>
  )
}

useGLTF.preload(PACK_URLS.industrial)
useGLTF.preload(PACK_URLS.materials)
