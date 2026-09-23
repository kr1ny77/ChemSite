import { useFrame } from '@react-three/fiber'
import { CapsuleCollider, RigidBody, type RapierRigidBody } from '@react-three/rapier'
import { useEffect, useRef } from 'react'
import { Group, MathUtils } from 'three'
import { STATIONS } from '../config/stations'
import { inputManager } from '../input/inputManager'
import { useGameStore } from '../../state/useGameStore'
import { EngineerModel } from './EngineerModel'

export function Player() {
  const body = useRef<RapierRigidBody>(null)
  const character = useRef<Group>(null)
  const lastStation = useRef<string | null>(null)
  useEffect(() => {
    const debug = window.__CHEMSITE_DEBUG__
    if (!import.meta.env.DEV || !debug) return
    debug.teleportPlayer = ([x, y, z]) => {
      body.current?.setTranslation({ x, y, z }, true)
      body.current?.setLinvel({ x: 0, y: 0, z: 0 }, true)
    }
    return () => { delete debug.teleportPlayer }
  }, [])
  useFrame((_, delta) => {
    if (!body.current) return
    const state = useGameStore.getState()
    state.setSceneReady()
    const movement = inputManager.movement()
    const moving = state.mode === 'playing'
    body.current.setLinvel({ x: moving ? movement.x * 5.4 : 0, y: body.current.linvel().y, z: moving ? movement.z * 5.4 : 0 }, true)
    if (moving && movement.moving && character.current) {
      state.setHasMoved()
      const angle = character.current.rotation.y
      const difference = Math.atan2(Math.sin(Math.atan2(movement.x, movement.z) - angle), Math.cos(Math.atan2(movement.x, movement.z) - angle))
      character.current.rotation.y = MathUtils.damp(angle, angle + difference, 15, delta)
    }
    const p = body.current.translation()
    state.setPlayerPosition([p.x, p.y, p.z])
    let nearest: string | null = null
    let distance = Infinity
    for (const station of STATIONS) {
      const d = Math.hypot(p.x - station.position[0], p.z - station.position[2])
      if (d < station.interactionRadius && d < distance) { nearest = station.id; distance = d }
    }
    if (nearest !== lastStation.current) { lastStation.current = nearest; state.setNearbyStation(nearest) }
  })
  return <RigidBody ref={body} name="player" position={[0, 1, 0]} colliders={false} enabledRotations={[false, false, false]} friction={0.2} restitution={0} ccd canSleep={false}>
    <CapsuleCollider args={[0.44, 0.32]} position={[0, -0.03, 0]} />
    <group ref={character}><EngineerModel /></group>
  </RigidBody>
}
