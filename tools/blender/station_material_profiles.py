"""Shared stylized station PBR profiles, used by source builders and refinement.
Dielectric coatings/minerals preserve approved colors. Bare metals use metallic 1.
Opaque vessels preserve the readable virtual-sample style and avoid sorting cost.
"""
import re
PROFILES = {
 'blue powder-coated steel': (0.0, .62), 'deep teal powder coat': (0.0, .62),
 'dark slate': (0.0, .82), 'charcoal display': (0.0, .70),
 'charcoal rubber': (0.0, .88), 'charcoal elastomer': (0.0, .88),
 'concrete': (0.0, .91), 'cast concrete': (0.0, .91),
 'aggregate charcoal': (0.0, .93), 'gypsum white': (0.0, .88),
 'limestone cream': (0.0, .84), 'sealed plywood': (0.0, .78),
 'warm white': (0.0, .61), 'warm ceramic': (0.0, .48),
 'inspection ceramic': (0.0, .48), 'safety amber': (0.0, .53),
 'chemistry cyan': (0.0, .35), 'cyan instrument': (0.0, .35),
 'cyan display': (0.0, .35), 'cyan indicator': (0.0, .35),
 'laboratory glass': (0.0, .22), 'frosted glass': (0.0, .30),
 'frosted vessel glass': (0.0, .30), 'frosted water vessel': (0.0, .30),
 'blue virtual electrolyte': (0.0, .24), 'dilute blue sample': (0.0, .24),
 'virtual water sample': (0.0, .24), 'reaction coral': (0.0, .61),
 'inspection green': (0.0, .61), 'sample red': (0.0, .61),
 'sample green': (0.0, .61), 'protective coating': (0.0, .65),
 'surface corrosion': (0.0, .94), 'uncoated steel': (1.0, .54),
 'zinc electrode': (1.0, .40), 'copper electrode': (1.0, .38),
 'machined platen': (1.0, .32),
}
def profile_values(name, metallic, roughness):
 return PROFILES.get(re.sub(r'\.\d{3}$', '', name), (metallic, roughness))
