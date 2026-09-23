import { RoundedBox } from '@react-three/drei'
import { useSurfaceMaps } from '../art/useSurfaceMaps'

// Small authored details communicate scale and separate the material zones.
export function SiteDetails() {
  const concreteSurface = useSurfaceMaps('concrete_wall_009')
  return (
    <group>
      {[-1, 1].map((side) => (
        <group key={side}>
          {Array.from({ length: 13 }, (_, i) => (
            <RoundedBox key={i} args={[1.75, 0.14, 0.25]} radius={0.045} smoothness={2} position={[(i - 6) * 1.85, 0.03, side * 8.95]} receiveShadow>
              <meshStandardMaterial color={i % 2 ? '#e9c350' : '#51636b'} {...concreteSurface} roughness={0.88} />
            </RoundedBox>
          ))}
          <mesh position={[side * 1.7, 0.115, 0]} rotation={[-Math.PI / 2, 0, 0]}>
            <planeGeometry args={[0.045, 15.2]} /><meshStandardMaterial color="#f1cd60" roughness={0.7} />
          </mesh>
          <mesh position={[0, 0.12, side * 1.58]} rotation={[-Math.PI / 2, 0, 0]}>
            <planeGeometry args={[19.5, 0.045]} /><meshStandardMaterial color="#f1cd60" roughness={0.7} />
          </mesh>
        </group>
      ))}
      {[-4.8, 4.8].map((x) => (
        <group key={x} position={[x, 0.11, 0]}>
          <mesh rotation={[-Math.PI / 2, 0, 0]}><planeGeometry args={[0.38, 2.6]} /><meshStandardMaterial color="#233741" metalness={0.5} roughness={0.5} /></mesh>
          {Array.from({ length: 14 }, (_, i) => <mesh key={i} position={[0, 0.012, -1.22 + i * 0.185]} castShadow><boxGeometry args={[0.36, 0.018, 0.07]} /><meshStandardMaterial color="#8da3ad" roughness={0.36} metalness={0.8} /></mesh>)}
        </group>
      ))}
      {[-9.7, -6.3, 5.5, 9].map((x) => (
        <group key={x} position={[x, 0.125, -2]}>
          {Array.from({ length: 5 }, (_, i) => <mesh key={i} position={[i * 0.18, 0, 0]} rotation={[-Math.PI / 2, 0, -0.45]}><planeGeometry args={[0.09, 0.4]} /><meshStandardMaterial color="#f7cd59" roughness={0.8} /></mesh>)}
        </group>
      ))}
      {/* Shallow slab expansion joints remain visual so they never snag the player. */}
      {[-9, -6, -3, 3, 6, 9].map((x) => <mesh key={x} position={[x, 0.053, 0]} rotation={[-Math.PI / 2, 0, 0]}><planeGeometry args={[0.018, 17]} /><meshStandardMaterial color="#697e89" roughness={1} /></mesh>)}
    </group>
  )
}
