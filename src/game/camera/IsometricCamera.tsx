import { OrthographicCamera } from '@react-three/drei'
import { useFrame, useThree } from '@react-three/fiber'
import { useEffect, useMemo, useRef } from 'react'
import { MathUtils, Vector3, OrthographicCamera as ThreeCamera } from 'three'
import { useGameStore } from '../../state/useGameStore'

export function IsometricCamera() {
  const camera = useThree((state) => state.camera)
  const gl = useThree((state) => state.gl)
  const target = useMemo(() => new Vector3(), [])
  const desired = useMemo(() => new Vector3(), [])
  const inspection = useRef<{ position: [number, number, number]; zoom: number } | null>(null)
  useEffect(() => {
    const debug = window.__CHEMSITE_DEBUG__
    if (!import.meta.env.DEV || !debug) return
    debug.focusCamera = (position, zoom = 120) => { inspection.current = position ? { position, zoom } : null }
    return () => { delete debug.focusCamera }
  }, [])
  useEffect(() => {
    const wheel = (event: WheelEvent) => {
      if (useGameStore.getState().mode !== 'playing' || event.ctrlKey) return
      event.preventDefault()
      const state = useGameStore.getState()
      state.updateSettings({ cameraZoom: MathUtils.clamp(state.learningProgress.settings.cameraZoom * Math.exp(-event.deltaY * 0.0015), 0.8, 2.8) })
    }
    gl.domElement.addEventListener('wheel', wheel, { passive: false })
    return () => gl.domElement.removeEventListener('wheel', wheel)
  }, [gl])

  useFrame((_, delta) => {
    const state = useGameStore.getState()
    const [x, , z] = state.playerPosition
    const zoom = state.learningProgress.settings.cameraZoom
    const follow = MathUtils.smoothstep(zoom, 1, 1.8)
    const ortho = camera as ThreeCamera
    ortho.zoom = MathUtils.damp(ortho.zoom, inspection.current?.zoom ?? 34 * zoom, 9, Math.min(delta, 0.1))
    ortho.updateProjectionMatrix()
    desired.set(x * (0.11 + 0.89 * follow), 0.6, z * (0.1 + 0.9 * follow) - 0.55 * (1 - follow))
    if (inspection.current) desired.set(...inspection.current.position)
    target.lerp(desired, 1 - Math.exp(-5 * Math.min(delta, 0.1)))
    camera.position.set(target.x + 18.5, target.y + 19.15, target.z + 18.5)
    camera.lookAt(target)
  })

  return <OrthographicCamera makeDefault position={[18.5, 19.5, 18.5]} zoom={34} near={0.1} far={120} />
}
