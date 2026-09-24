"""Deterministic, original short UI cues for the native chemistry loop."""
import math, wave, struct, random
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

def render_step(name, seed, weight):
 rng=random.Random(seed)
 samples=[]
 for i in range(int(RATE*.18)):
  t=i/RATE
  body=math.exp(-38*t)*math.sin(2*math.pi*(82+weight*12)*t)
  grit=(rng.random()*2-1)*math.exp(-27*t)
  click=(rng.random()*2-1)*math.exp(-140*t)
  value=max(-1,min(1,(body*.38+grit*.2+click*.13)*.55))
  samples.append(struct.pack('<h',int(value*32767)))
 with wave.open(str(ROOT/name),'wb') as file:
  file.setnchannels(1);file.setsampwidth(2);file.setframerate(RATE);file.writeframes(b''.join(samples))

render_step('step_a.wav',11,0)
render_step('step_b.wav',29,1)

def render_machinery():
 rng=random.Random(51)
 duration=4.0
 samples=[]
 for i in range(int(RATE*duration)):
  t=i/RATE
  phase=2*math.pi*t
  hum=math.sin(phase*55)*.18+math.sin(phase*110)*.07
  rotation=math.sin(phase*1.5)*.045
  texture=(rng.random()*2-1)*.027
  ramp=min(1,t/.18,(duration-t)/.18)
  value=max(-1,min(1,(hum+rotation+texture)*ramp*.42))
  samples.append(struct.pack('<h',int(value*32767)))
 with wave.open(str(ROOT/'machinery_loop.wav'),'wb') as file:
  file.setnchannels(1);file.setsampwidth(2);file.setframerate(RATE);file.writeframes(b''.join(samples))

render_machinery()
