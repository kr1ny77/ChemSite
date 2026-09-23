import { useTexture } from '@react-three/drei'
import { RepeatWrapping, SRGBColorSpace } from 'three'

export function useSurfaceMaps(name: 'concrete_wall_009' | 'metal_plate') {
  const textures = useTexture({
    map: `/assets/textures/${name}-color.webp`,
    normalMap: `/assets/textures/${name}-normal.png`,
    roughnessMap: `/assets/textures/${name}-roughness.png`,
  }, (loaded) => {
    for (const texture of Array.isArray(loaded) ? loaded : [loaded]) {
      texture.wrapS = texture.wrapT = RepeatWrapping
      texture.repeat.set(2, 2)
      texture.anisotropy = 4
    }
  })
  textures.map.colorSpace = SRGBColorSpace
  return textures
}
