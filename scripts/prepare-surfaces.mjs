import { mkdir, readFile } from 'node:fs/promises'
import { fileURLToPath } from 'node:url'
import sharp from 'sharp'
import { FloatType } from 'three'
import { EXRLoader } from 'three/addons/loaders/EXRLoader.js'

// Re-encode the supplied CC0 material maps for the browser. Data maps remain linear.
const output = new URL('../public/assets/textures/', import.meta.url)
await mkdir(output, { recursive: true })
for (const name of ['concrete_wall_009', 'metal_plate']) {
  const root = new URL(`../assets-source/Poly Haven/${name}_1k.blend/textures/`, import.meta.url)
  await sharp(await readFile(new URL(`${name}_diff_1k.jpg`, root)))
    .resize(1024, 1024).webp({ quality: 88 }).toFile(fileURLToPath(new URL(`${name}-color.webp`, output)))
  for (const [source, target] of [['nor_gl', 'normal'], ['rough', 'roughness']]) {
    const input = await readFile(new URL(`${name}_${source}_1k.exr`, root))
    const image = new EXRLoader().setDataType(FloatType).parse(input.buffer.slice(input.byteOffset, input.byteOffset + input.byteLength))
    const data = new Uint8Array(image.width * image.height * 4)
    for (let i = 0; i < data.length; i++) data[i] = Math.round(Math.min(1, Math.max(0, image.data[i])) * 255)
    await sharp(data, { raw: { width: image.width, height: image.height, channels: 4 } })
      .flip().resize(512, 512).png().toFile(fileURLToPath(new URL(`${name}-${target}.png`, output)))
  }
}
