import { DataTexture, LinearFilter, LinearMipmapLinearFilter, RepeatWrapping, RGBAFormat, SRGBColorSpace } from 'three'

// Original seamless, deterministic material maps. Shared across the scene.
const size = 256
function texture(data: Uint8Array, color = false) {
  const result = new DataTexture(data, size, size, RGBAFormat)
  result.wrapS = result.wrapT = RepeatWrapping
  result.magFilter = LinearFilter
  result.minFilter = LinearMipmapLinearFilter
  result.generateMipmaps = true
  result.anisotropy = 4
  if (color) result.colorSpace = SRGBColorSpace
  result.needsUpdate = true
  return result
}

function makePavingSurface() {
  const heights = new Float32Array(size * size)
  const diffuse = new Uint8Array(size * size * 4)
  const roughness = new Uint8Array(size * size * 4)
  const normal = new Uint8Array(size * size * 4)
  let seed = 7281
  const random = () => { seed = (Math.imul(seed, 1664525) + 1013904223) >>> 0; return seed / 4294967296 }
  for (let y = 0; y < size; y++) for (let x = 0; x < size; x++) {
    const index = y * size + x
    const grain = random()
    const seam = x % 128 < 2 || y % 128 < 2
    const cloud = Math.sin(x * Math.PI / 64) * Math.cos(y * Math.PI / 128) * 0.025
    heights[index] = seam ? 0.1 : 0.55 + grain * 0.08 + cloud
    const shade = seam ? 142 : 222 + grain * 16 + cloud * 120
    for (let c = 0; c < 3; c++) {
      diffuse[index * 4 + c] = shade
      roughness[index * 4 + c] = 205 + grain * 40
    }
    diffuse[index * 4 + 3] = roughness[index * 4 + 3] = 255
  }
  const height = (x: number, y: number) => heights[((y + size) % size) * size + ((x + size) % size)]
  for (let y = 0; y < size; y++) for (let x = 0; x < size; x++) {
    const i = (y * size + x) * 4
    const dx = (height(x - 1, y) - height(x + 1, y)) * 1.8
    const dy = (height(x, y - 1) - height(x, y + 1)) * 1.8
    const length = Math.hypot(dx, dy, 1)
    normal[i] = (dx / length * 0.5 + 0.5) * 255
    normal[i + 1] = (dy / length * 0.5 + 0.5) * 255
    normal[i + 2] = (1 / length * 0.5 + 0.5) * 255
    normal[i + 3] = 255
  }
  return { map: texture(diffuse, true), normalMap: texture(normal), roughnessMap: texture(roughness) }
}

export const pavingSurface = makePavingSurface()
for (const map of Object.values(pavingSurface)) map.repeat.set(8, 6)
