// Original beveled architectural set, baked by material into a compact GLB.
import { writeFileSync } from 'node:fs'
import { Scene, Mesh, MeshStandardMaterial, CylinderGeometry, SphereGeometry } from 'three'
import { NodeIO } from '@gltf-transform/core'
import { ALL_EXTENSIONS } from '@gltf-transform/extensions'
import { dedup, weld, prune, meshopt } from '@gltf-transform/functions'
import { MeshoptEncoder } from 'meshoptimizer'
import { RoundedBoxGeometry } from 'three/addons/geometries/RoundedBoxGeometry.js'
import { mergeGeometries } from 'three/addons/utils/BufferGeometryUtils.js'
import { GLTFExporter } from 'three/addons/exporters/GLTFExporter.js'
globalThis.FileReader = class {
  readAsArrayBuffer(blob) { blob.arrayBuffer().then((buffer) => { this.result = buffer; this.onloadend?.() }) }
}
const scene = new Scene()
scene.name = 'ChemSite-neighborhood'
const materials = Object.fromEntries(Object.entries({ plaster: '#b4bdba', cream: '#d8c9af', slate: '#526a74', trim: '#e0ddd0', metal: '#718890', glass: '#80a9b5', warmGlass: '#d4b977', bark: '#6f5642', leaf: '#608775', leafLight: '#87a182', soil: '#4e594a', brick: '#ac8267' }).map(([name, color]) => [name, new MeshStandardMaterial({ name, color, roughness: name.includes('Glass') || name === 'glass' ? 0.22 : 0.78, metalness: name === 'metal' || name === 'glass' ? 0.4 : 0 })]))
const batches = new Map()
function add(geometry, material, position, rotation = [0, 0, 0], scale = [1, 1, 1]) {
  const mesh = new Mesh(geometry)
  mesh.position.set(...position); mesh.rotation.set(...rotation); mesh.scale.set(...scale); mesh.updateMatrix()
  const baked = (geometry.index ? geometry.toNonIndexed() : geometry).clone().applyMatrix4(mesh.matrix)
  if (!batches.has(material)) batches.set(material, [])
  batches.get(material).push(baked)
}
const box = (size, material, p, radius = 0.025) => add(new RoundedBoxGeometry(...size, 3, Math.min(radius, Math.min(...size) * 0.4)), material, p)
const buildings = [[-13.8, -13.6, 4.2, 3.7], [-8.8, -13.8, 3.8, 4.6], [-3.8, -13.8, 4.6, 3.2], [2.8, -13.8, 5.4, 4.4], [8.7, -13.6, 4.2, 3.5], [14.2, -13.5, 5, 5.1]]
for (const [index, [x, z, w, h]] of buildings.entries()) {
  box([w, h, 2.5], index % 2 ? 'cream' : 'plaster', [x, h / 2 - 0.2, z], 0.12)
  box([w + 0.2, 0.3, 2.7], 'slate', [x, -0.17, z], 0.05)
  box([w + 0.22, 0.16, 2.72], 'trim', [x, h - 0.18, z], 0.04)
  box([w - 0.15, 0.08, 2.35], 'slate', [x, h - 0.06, z], 0.025)
  for (const dz of [-1.22, 1.22]) box([w, 0.27, 0.11], 'trim', [x, h + 0.02, z + dz])
  for (const dx of [-w / 2 + 0.05, w / 2 - 0.05]) box([0.12, 0.27, 2.44], 'trim', [x + dx, h + 0.02, z])
  for (const y of [h * 0.4, h * 0.78]) {
    for (let col = 0; col < 3; col++) {
      const wx = x + (col - 1) * w * 0.29
      box([0.88, 0.99, 0.13], 'trim', [wx, y, z + 1.29], 0.035)
      box([0.72, 0.82, 0.045], col === index % 3 ? 'warmGlass' : 'glass', [wx, y, z + 1.37], 0.012)
      box([0.035, 0.83, 0.06], 'slate', [wx, y, z + 1.407], 0.006)
      box([0.74, 0.035, 0.06], 'slate', [wx, y + 0.09, z + 1.407], 0.006)
      box([1.02, 0.1, 0.3], 'trim', [wx, y - 0.48, z + 1.38], 0.025)
    }
  }
  for (const dx of [-w / 2 + 0.12, w / 2 - 0.12]) box([0.19, h - 0.18, 0.14], 'trim', [x + dx, h / 2 - 0.2, z + 1.28])
  box([0.75, 0.5, 0.85], 'metal', [x - w * 0.2, h + 0.16, z], 0.08)
  for (let i = 0; i < 5; i++) box([0.65, 0.025, 0.035], 'slate', [x - w * 0.2, h + 0.03 + i * 0.07, z + 0.44], 0.006)
  add(new CylinderGeometry(0.18, 0.2, 0.6, 24), 'metal', [x + w * 0.25, h + 0.18, z - 0.3])
  add(new CylinderGeometry(0.27, 0.24, 0.07, 24), 'slate', [x + w * 0.25, h + 0.5, z - 0.3])
  box([w + 0.3, 0.18, 0.65], 'trim', [x, -0.2, z + 1.62], 0.04)
}
// Planters soften the industrial silhouette while staying outside all player routes.
for (const [index, [x, z]] of [[-16, -9], [-15.4, -4], [-15.4, 0.6], [15.8, -8], [16, -3], [16, 6]].entries()) {
  box([1.55, 0.46, 1.45], 'slate', [x, -0.12, z], 0.1)
  box([1.35, 0.06, 1.25], 'soil', [x, 0.13, z], 0.06)
  add(new CylinderGeometry(0.09, 0.16, 1.75, 20), 'bark', [x, 0.94, z])
  for (let i = 0; i < 5; i++) {
    const a = i * 2.4 + index
    add(new SphereGeometry(0.63, 24, 16), i % 2 ? 'leafLight' : 'leaf', [x + Math.cos(a) * 0.42, 1.75 + (i % 3) * 0.35, z + Math.sin(a) * 0.4], [0, a, 0], [1, 1.1, 0.85])
  }
  for (let i = 0; i < 3; i++) add(new SphereGeometry(0.25, 16, 12), 'leaf', [x - 0.45 + i * 0.45, 0.27, z + 0.4], [0, 0, 0], [1, 0.7, 1])
}
for (const [name, geometries] of batches) {
  const geometry = mergeGeometries(geometries)
  const mesh = new Mesh(geometry, materials[name]); mesh.name = `neighborhood-${name}`
  scene.add(mesh)
}
const binary = await new GLTFExporter().parseAsync(scene, { binary: true })
writeFileSync('public/assets/models/neighborhood.glb', Buffer.from(binary))
await MeshoptEncoder.ready
const io = new NodeIO().registerExtensions(ALL_EXTENSIONS).registerDependencies({ 'meshopt.encoder': MeshoptEncoder })
const document = await io.read('public/assets/models/neighborhood.glb')
await document.transform(weld(), dedup(), prune(), meshopt({ encoder: MeshoptEncoder, level: 'medium' }))
await io.write('public/assets/models/neighborhood.glb', document)
console.log(`Authored ${scene.children.length} material batches; optimized with weld, dedup and Meshopt`)
