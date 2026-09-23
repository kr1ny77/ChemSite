import { GameCanvas } from '../game/GameCanvas'
import { Hud } from '../ui/Hud'
import { PauseMenu } from '../ui/PauseMenu'
import { ResultsScreen } from '../ui/ResultsScreen'
import { StationPanel } from '../ui/StationPanel'
import { InputController } from './InputController'
import { RoundController } from './RoundController'
import { AudioController } from '../audio/AudioController'
import { MainMenu } from '../ui/MainMenu'
import { CameraControls } from '../ui/CameraControls'

export function App() {
  return (
    <main className="app-shell">
      <GameCanvas />
      <InputController />
      <RoundController />
      <AudioController />
      <MainMenu />
      <Hud />
      <CameraControls />
      <PauseMenu />
      <StationPanel />
      <ResultsScreen />
      <div className="brand-mark" aria-label="ChemSite">
        <span className="brand-mark__molecule">CS</span>
        <span>CHEM<strong>SITE</strong></span>
      </div>
    </main>
  )
}
