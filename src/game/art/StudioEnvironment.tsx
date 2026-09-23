import { useThree } from '@react-three/fiber'
import { useEffect } from 'react'
import { PMREMGenerator } from 'three'
import { RoomEnvironment } from 'three/addons/environments/RoomEnvironment.js'

export function StudioEnvironment() {
  const { gl, scene } = useThree()
  useEffect(() => {
    const generator = new PMREMGenerator(gl)
    const room = new RoomEnvironment()
    const environment = generator.fromScene(room, 0.04)
    const previous = scene.environment
    scene.environment = environment.texture
    scene.environmentIntensity = 0.45
    room.dispose()
    generator.dispose()
    return () => { scene.environment = previous; environment.dispose() }
  }, [gl, scene])
  return null
}
