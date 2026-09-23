"""Deterministic, original short UI cues for the native chemistry loop."""
import math, wave, struct
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]/'assets/audio'
ROOT.mkdir(parents=True,exist_ok=True)
RATE=44100

def render(name,notes,duration=.32):
 out=[]
 for i in range(int(RATE*duration)):
  t=i/RATE
  env=min(1,t/.018)*max(0,1-t/duration)**2
  signal=0
  for freq,offset,weight in notes:
   phase=t-offset
   if phase>=0:
    signal+=math.sin(2*math.pi*freq*phase)*weight*math.exp(-6*phase)
  sample=max(-1,min(1,signal*env*.32))
  out.append(struct.pack('<h',int(sample*32767)))
 with wave.open(str(ROOT/name),'wb') as f:
  f.setnchannels(1);f.setsampwidth(2);f.setframerate(RATE);f.writeframes(b''.join(out))
render('correct.wav',[(523.25,0,.55),(659.25,.08,.4),(783.99,.16,.35)],.42)
render('incorrect.wav',[(392,0,.5),(311.13,.1,.45)],.36)
render('interact.wav',[(587.33,0,.4),(880,.065,.3)],.22)
