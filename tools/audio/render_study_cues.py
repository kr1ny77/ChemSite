"""Original deterministic study cues; preserves all existing accepted audio files."""
import math,random,struct,wave
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]/'assets/audio'
RATE=44100

def save(name,duration,signal):
    values=[]
    for i in range(round(duration*RATE)):
        t=i/RATE
        attack=math.sin(min(1,t/.014)*math.pi/2)**2
        release=math.sin(min(1,(duration-t)/.045)*math.pi/2)**2
        values.append(signal(t)*attack*release)
    values[0]=values[-1]=0.0
    assert max(map(abs,values))<.22
    with wave.open(str(ROOT/name),'wb') as output:
        output.setnchannels(1);output.setsampwidth(2);output.setframerate(RATE)
        output.writeframes(b''.join(struct.pack('<h',round(v*32767)) for v in values))

def ui_signal(t):
    return (.11*math.sin(2*math.pi*380*t)+.035*math.sin(2*math.pi*610*t))*math.exp(-45*t)
save('ui_action.wav',.090,ui_signal)

rng=random.Random(814)
filtered=[0.0,0.0]
def liquid_signal(t):
    alpha=1-math.exp(-2*math.pi*900/RATE)
    filtered[0]+=alpha*(rng.uniform(-1,1)-filtered[0])
    filtered[1]+=alpha*(filtered[0]-filtered[1])
    flow=filtered[1]*.18*math.sin(math.pi*min(t/.26,1))**2
    droplet=.032*math.sin(2*math.pi*(620*t-260*t*t))*math.exp(-9*t)
    return flow+droplet
save('liquid_mix.wav',.32,liquid_signal)

def notes(t,items):
    value=0
    for frequency,start,gain in items:
        x=t-start
        if x>=0:
            envelope=min(1,x/.025)*math.exp(-10*x)
            value+=gain*math.sin(2*math.pi*frequency*x)*envelope
    return value
save('combo.wav',.48,lambda t:notes(t,[(261.63,0,.08),(329.63,.055,.07),(392,.11,.07)]))
save('timer_warning.wav',.40,lambda t:notes(t,[(392,0,.08),(329.63,.13,.075)]))
print('STUDY_CUES_RENDERED: UI, liquid, combo, timer; finite mono PCM 44.1 kHz')
