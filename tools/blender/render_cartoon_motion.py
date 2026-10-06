"""Render complete fresh-export cartoon cycles from front and three-quarter views."""
import bpy, math, json
from pathlib import Path
from mathutils import Vector
ROOT=Path(__file__).resolve().parents[2];OUT=ROOT/'artifacts/cartoon-character'
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
bpy.ops.import_scene.gltf(filepath=str(OUT/'cartoon_chemist.glb'))
rig=next(o for o in bpy.data.objects if o.type=='ARMATURE')
scene=bpy.context.scene;scene.render.engine='BLENDER_EEVEE'
scene.render.resolution_x=448;scene.render.resolution_y=448;scene.render.resolution_percentage=100
scene.render.image_settings.file_format='PNG';scene.render.fps=24
scene.world.color=(.16,.16,.16)
bpy.ops.mesh.primitive_plane_add(size=200,location=(0,0,-.001))
floor=bpy.context.object;m=bpy.data.materials.new('Preview floor');m.diffuse_color=(.09,.11,.14,1);floor.data.materials.append(m)
for loc,power,size in [((-3,-4,5),450,4),((3,-2,3),220,3),((1,3,4),350,3)]:
    bpy.ops.object.light_add(type='AREA',location=loc)
    light=bpy.context.object;light.data.energy=power;light.data.shape='DISK';light.data.size=size
    light.rotation_euler=(Vector((0,0,.8))-light.location).to_track_quat('-Z','Y').to_euler()
bpy.ops.object.camera_add();cam=bpy.context.object;scene.camera=cam;cam.data.type='ORTHO';cam.data.ortho_scale=2.0
manifest=[]
for name in ('Walk','Run','Interact'):
    clip=next(a for a in bpy.data.actions if a.name==name);rig.animation_data.action=clip
    first,last=clip.frame_range
    for view,loc in [('front',(0,-4,1.2)),('three-quarter',(3,-4,2.1))]:
        cam.location=loc;cam.rotation_euler=(Vector((0,0,.8))-cam.location).to_track_quat('-Z','Y').to_euler()
        folder=OUT/'motion'/name/view;folder.mkdir(parents=True,exist_ok=True)
        count=48 if name in ('Walk','Run') else 24
        for sample in range(count):
            phase=((sample/24)/(float(last-first)/24))%1 if name in ('Walk','Run') else sample/(count-1)
            f=first+(last-first)*phase
            scene.frame_set(int(f),subframe=f%1)
            scene.render.filepath=str(folder/f'frame-{sample:03d}.png')
            bpy.ops.render.render(write_still=True)
        manifest.append({'action':name,'view':view,'frames':count,'fps':24,'source':'fresh GLB'})
(OUT/'motion/manifest.json').write_text(json.dumps(manifest,indent=2))
print('CHEMSITE_CARTOON_MOTION_RENDER_OK')
