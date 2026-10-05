"""Clip fitted cloth details from a skinned garment, retaining interpolated weights.

The bounds are linear planes in garment space. The thin overlay follows the
garment's smooth normals and original bone weights through exported animation.
"""

import bpy


def garment_detail(garment, name, bounds, material, offset=0.002, facing=None):
    vertices, faces, weights = [], [], []
    cached = {}

    def interpolate(a, b, amount):
        co = a[0].lerp(b[0], amount)
        normal = a[1].lerp(b[1], amount).normalized()
        groups = set(a[2]) | set(b[2])
        skin = {g: a[2].get(g, 0) * (1 - amount) + b[2].get(g, 0) * amount for g in groups}
        return co, normal, skin

    for polygon in garment.data.polygons:
        if facing and polygon.normal.y * facing < 0.25:
            continue
        points = []
        for index in polygon.vertices:
            v = garment.data.vertices[index]
            points.append((v.co.copy(), v.normal.copy(), {g.group: g.weight for g in v.groups}))
        for axis, low, high in bounds:
            for limit, sign in ((low, 1), (high, -1)):
                clipped = []
                for i, current in enumerate(points):
                    previous = points[i - 1]
                    a = (previous[0][axis] - limit) * sign
                    b = (current[0][axis] - limit) * sign
                    if (a >= 0) != (b >= 0):
                        clipped.append(interpolate(previous, current, a / (a - b)))
                    if b >= 0:
                        clipped.append(current)
                points = clipped
                if len(points) < 3:
                    break
            if len(points) < 3:
                break
        if len(points) < 3:
            continue
        face = []
        for co, normal, skin in points:
            point = co + normal * offset
            key = tuple(round(value, 7) for value in point)
            if key not in cached:
                cached[key] = len(vertices)
                vertices.append(point)
                weights.append(skin)
            index = cached[key]
            if not face or face[-1] != index:
                face.append(index)
        if len(face) > 1 and face[0] == face[-1]:
            face.pop()
        if len(set(face)) >= 3:
            faces.append(face)
    if not faces:
        raise ValueError(f"Empty garment detail: {name}")
    mesh = bpy.data.meshes.new(name)
    mesh.from_pydata(vertices, [], faces)
    mesh.update()
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    obj.matrix_world = garment.matrix_world.copy()
    obj.parent = garment.parent
    obj.data.materials.append(material)
    for group in garment.vertex_groups:
        obj.vertex_groups.new(name=group.name)
    for index, skin in enumerate(weights):
        influences = sorted(skin.items(), key=lambda item: item[1], reverse=True)[:4]
        total = sum(weight for _, weight in influences)
        for group, weight in influences:
            if weight > 1e-7:
                obj.vertex_groups[group].add([index], weight / total, "REPLACE")
    for polygon in obj.data.polygons:
        polygon.use_smooth = True
    deform = obj.modifiers.new("Cloth skinning", "ARMATURE")
    deform.object = garment.parent
    return obj
