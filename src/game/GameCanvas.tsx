import { Canvas, useThree } from '@react-three/fiber'
import { Bloom, EffectComposer, N8AO, SMAA, ToneMapping } from '@react-three/postprocessing'
import { ToneMappingMode } from 'postprocessing'
import { Physics } from '@react-three/rapier'
import { Suspense, useEffect } from 'react'
import { ACESFilmicToneMapping, SRGBColorSpace, Vector3 } from 'three'
import { IsometricCamera } from './camera/IsometricCamera'
import { Player } from './player/Player'
import { ConstructionSite } from './world/ConstructionSite'
import { useGameStore } from '../state/useGameStore'
import { SITE_COLORS } from './art/palette'
import { StudioEnvironment } from './art/StudioEnvironment'

function GameScene() {
  const scene = useThree((state) => state.scene)
  useEffect(() => {
    const debug = window.__CHEMSITE_DEBUG__
    if (!import.meta.env.DEV || !debug) return
    debug.scenePoint = (name) => scene.getObjectByName(name)?.getWorldPosition(new Vector3()).toArray() ?? null
    return () => { delete debug.scenePoint }
  }, [scene])
  const physicsPaused = useGameStore((state) => state.mode !== 'playing')
  const cameraEffects = useGameStore((state) => state.learningProgress.settings.cameraEffects)
  const highQuality = useGameStore((state) => state.learningProgress.settings.highQualityGraphics)

  return (
    <>
      <color attach="background" args={[SITE_COLORS.sky]} />
      <fog attach="fog" args={[SITE_COLORS.haze, 52, 100]} />
      <StudioEnvironment />
      <hemisphereLight args={['#ddecff', '#55545b', 0.9]} />
      <directionalLight
        key={highQuality ? 'sun-high' : 'sun-light'}
        position={[10, 21, 8]}
        intensity={3.3}
        color="#fff0dc"
        castShadow
        shadow-mapSize-width={highQuality ? 4096 : 2048}
        shadow-mapSize-height={highQuality ? 4096 : 2048}
        shadow-camera-near={1}
        shadow-camera-far={45}
        shadow-camera-left={-19}
        shadow-camera-right={19}
        shadow-camera-top={19}
        shadow-camera-bottom={-19}
        shadow-bias={-0.00018}
        shadow-normalBias={0.025}
      />
      <directionalLight position={[-12, 9, -11]} intensity={0.72} color="#78b9cf" />
      <IsometricCamera />
      <Physics gravity={[0, -18, 0]} paused={physicsPaused} timeStep={1 / 60}>
        <ConstructionSite />
        <Player />
      </Physics>
      {cameraEffects && (
        <EffectComposer multisampling={0}>
          <N8AO halfRes aoRadius={2.2} distanceFalloff={0.75} intensity={0.72} quality="performance" />
          <Bloom luminanceThreshold={1.1} luminanceSmoothing={0.45} intensity={0.2} mipmapBlur />
          <ToneMapping mode={ToneMappingMode.ACES_FILMIC} />
          <SMAA />
        </EffectComposer>
      )}
    </>
  )
}

export function GameCanvas() {
  const highQuality = useGameStore((state) => state.learningProgress.settings.highQualityGraphics)
  return (
    <Canvas
      className="game-canvas"
      shadows
      dpr={highQuality ? [1.5, 2] : [1, 1.35]}
      gl={{
        antialias: true,
        alpha: false,
        powerPreference: 'high-performance',
        preserveDrawingBuffer: import.meta.env.DEV,
      }}
      fallback={<div className="webgl-fallback">Для ChemSite требуется поддержка WebGL.</div>}
      onCreated={({ gl }) => {
        gl.outputColorSpace = SRGBColorSpace
        gl.toneMapping = ACESFilmicToneMapping
        gl.toneMappingExposure = 1.08
      }}
    >
      <Suspense fallback={null}>
        <GameScene />
      </Suspense>
    </Canvas>
  )
}
