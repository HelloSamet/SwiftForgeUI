"""Design source for the Midnight, Aurora, Paper, Neo-Brutal, Mono, Ocean, and Sunset themes (Forge is hand-tuned in Swift). Each color role is (light, dark, lightHC, darkHC);
None in the HC slots means "same as the base appearance". References are 'Ramp.step', a named extra,
'white' or 'black'."""
from colorlib import ramp

def R(light, dark, lhc=None, dhc=None):
    return (light, dark, lhc or light, dhc or dark)

THEMES = {}

# ---------------------------------------------------------------- Midnight
THEMES['midnight'] = dict(
    character='Dark-first, high contrast, neon accents, medium-sharp corners; accent glow instead of shadows in dark mode; in light mode, ink-navy controls with neon-cyan labels.',
    name='Midnight',
    ramps={'Night': '#3B4A7A', 'Cyan': '#06B6D4', 'Jade': '#10B981', 'Amber': '#F59E0B', 'Rose': '#F43F5E',
           'Azure': '#3B82F6'},
    extras={'neonCyan': '#22E4FF', 'neonJade': '#3DFFA2', 'neonAmber': '#FFC23D', 'neonRose': '#FF5C7A',
            'neonAzure': '#6FA8FF', 'void': '#05070F', 'deep': '#0A0F1E', 'panel': '#111830', 'lift': '#18213D',
            'frost': '#F2F6FF'},
    colors=dict(
        canvas=R('Night.50', 'void'),
        surface=R('white', 'deep'),
        surfaceRaised=R('white', 'panel'),
        fillMuted=R('Night.100', 'lift'),
        textPrimary=R('Night.950', 'frost', 'black', 'white'),
        textSecondary=R('Night.700', 'Night.300', 'Night.800', 'Night.200'),
        borderSubtle=R('Night.200', 'Night.800', 'Night.400', 'Night.600'),
        borderStrong=R('Night.500', 'Night.500', 'Night.700', 'Night.300'),
        pressedOverlay=None,
    ),
    tones=dict(
        accent=dict(solid=R('Night.900', 'neonCyan', 'Night.950', 'Cyan.200'), onSolid=R('neonCyan', 'void', 'white', 'black'),
                    text=R('Cyan.700', 'neonCyan', 'Cyan.800', 'Cyan.200'), subtle=R('Cyan.50', 'Cyan.950', 'Cyan.100', 'Cyan.900')),
        neutral=dict(solid=R('Night.800', 'Night.300', 'Night.900', 'Night.200'), onSolid=R('white', 'void', 'white', 'black'),
                     text=R('Night.700', 'Night.300', 'Night.800', 'Night.200'), subtle=R('Night.100', 'lift', 'Night.200', 'Night.900')),
        info=dict(solid=R('Azure.700', 'neonAzure', 'Azure.800', 'Azure.200'), onSolid=R('white', 'void', 'white', 'black'),
                  text=R('Azure.700', 'neonAzure', 'Azure.800', 'Azure.200'), subtle=R('Azure.50', 'Azure.950', 'Azure.100', 'Azure.900')),
        success=dict(solid=R('Jade.700', 'neonJade', 'Jade.800', 'Jade.200'), onSolid=R('white', 'void', 'white', 'black'),
                     text=R('Jade.700', 'neonJade', 'Jade.800', 'Jade.200'), subtle=R('Jade.50', 'Jade.950', 'Jade.100', 'Jade.900')),
        warning=dict(solid=R('neonAmber', 'neonAmber', 'Amber.300', 'Amber.200'), onSolid=R('black', 'void', 'black', 'black'),
                     text=R('Amber.700', 'neonAmber', 'Amber.800', 'Amber.200'), subtle=R('Amber.50', 'Amber.950', 'Amber.100', 'Amber.900')),
        danger=dict(solid=R('Rose.700', 'neonRose', 'Rose.800', 'Rose.200'), onSolid=R('white', 'void', 'white', 'black'),
                    text=R('Rose.700', 'neonRose', 'Rose.800', 'Rose.200'), subtle=R('Rose.50', 'Rose.950', 'Rose.100', 'Rose.900')),
    ),
)

# ---------------------------------------------------------------- Aurora
THEMES['aurora'] = dict(
    character='Violet-to-teal gradient buttons, pill controls, 24-pt cards, tinted soft shadows, glass overlays, SF Rounded, airy spacing, bouncy motion.',
    name='Aurora',
    ramps={'Haze': '#7C6FA6', 'Violet': '#7C3AED', 'Teal': '#0D9488', 'Mint': '#10B981', 'Honey': '#F59E0B',
           'Coral': '#F43F5E', 'Sky': '#0EA5E9'},
    extras={'dusk': '#0E0B1E', 'nightPanel': '#18142E', 'nightLift': '#221D3E', 'mist': '#F6F4FD',
            'lavender': '#C4B5FD', 'aqua': '#67E8F9', 'ink': '#120A2A'},
    colors=dict(
        canvas=R('mist', 'dusk'),
        surface=R('white', 'nightPanel'),
        surfaceRaised=R('white', 'nightLift'),
        fillMuted=R('Haze.100', 'Haze.900', 'Haze.200', 'Haze.800'),
        textPrimary=R('Haze.950', 'Haze.50', 'black', 'white'),
        textSecondary=R('Haze.700', 'Haze.300', 'Haze.800', 'Haze.200'),
        borderSubtle=R('Haze.200', 'Haze.800', 'Haze.400', 'Haze.600'),
        borderStrong=R('Haze.500', 'Haze.500', 'Haze.700', 'Haze.300'),
        pressedOverlay=None,
    ),
    tones=dict(
        accent=dict(solid=R('Violet.600', 'lavender', 'Violet.800', 'Violet.200'), onSolid=R('white', 'ink', 'white', 'black'),
                    text=R('Violet.600', 'Violet.300', 'Violet.800', 'Violet.200'), subtle=R('Violet.100', 'Violet.950', 'Violet.200', 'Violet.900'),
                    solidFill=[R('Violet.600', 'lavender', 'Violet.800', 'Violet.200'), R('Teal.700', 'aqua', 'Teal.800', 'Teal.200')]),
        neutral=dict(solid=R('Haze.800', 'Haze.300', 'Haze.900', 'Haze.200'), onSolid=R('white', 'ink', 'white', 'black'),
                     text=R('Haze.700', 'Haze.300', 'Haze.800', 'Haze.200'), subtle=R('Haze.100', 'Haze.900', 'Haze.200', 'Haze.800')),
        info=dict(solid=R('Sky.700', 'Sky.300', 'Sky.800', 'Sky.200'), onSolid=R('white', 'ink', 'white', 'black'),
                  text=R('Sky.700', 'Sky.300', 'Sky.800', 'Sky.200'), subtle=R('Sky.100', 'Sky.950', 'Sky.200', 'Sky.900')),
        success=dict(solid=R('Mint.700', 'Mint.300', 'Mint.800', 'Mint.200'), onSolid=R('white', 'ink', 'white', 'black'),
                     text=R('Mint.700', 'Mint.300', 'Mint.800', 'Mint.200'), subtle=R('Mint.100', 'Mint.950', 'Mint.200', 'Mint.900')),
        warning=dict(solid=R('Honey.300', 'Honey.300', 'Honey.400', 'Honey.200'), onSolid=R('black', 'ink', 'black', 'black'),
                     text=R('Honey.700', 'Honey.300', 'Honey.800', 'Honey.200'), subtle=R('Honey.100', 'Honey.950', 'Honey.200', 'Honey.900')),
        danger=dict(solid=R('Coral.700', 'Coral.300', 'Coral.800', 'Coral.200'), onSolid=R('white', 'ink', 'white', 'black'),
                    text=R('Coral.700', 'Coral.300', 'Coral.800', 'Coral.200'), subtle=R('Coral.100', 'Coral.950', 'Coral.200', 'Coral.900')),
    ),
    fills={'overlay': R('white', 'nightLift')},
    field_filled=True,
)

# ---------------------------------------------------------------- Paper
THEMES['paper'] = dict(
    character='Ink on warm paper, New York serif headings, hairlines everywhere, no shadows, barely rounded corners, underlined fields. Evolved from Graphite.',
    name='Paper',
    ramps={'Stone': '#8A8377', 'Forest': '#2F6B3A', 'Ochre': '#B7791F', 'Oxblood': '#9B2C2C', 'Indigo': '#2C5282'},
    extras={'paper': '#FAF8F3', 'sheet': '#FFFEFB', 'ink': '#1C1A17', 'night': '#151412', 'nightSheet': '#1E1C19',
            'nightLift': '#282622', 'chalk': '#F3EFE6'},
    colors=dict(
        canvas=R('paper', 'night'),
        surface=R('sheet', 'nightSheet'),
        surfaceRaised=R('white', 'nightLift'),
        fillMuted=R('Stone.100', 'Stone.900', 'Stone.200', 'Stone.800'),
        textPrimary=R('ink', 'chalk', 'black', 'white'),
        textSecondary=R('Stone.700', 'Stone.300', 'Stone.800', 'Stone.200'),
        borderSubtle=R('Stone.200', 'Stone.800', 'Stone.400', 'Stone.600'),
        borderStrong=R('Stone.500', 'Stone.500', 'Stone.700', 'Stone.300'),
        pressedOverlay=None,
    ),
    tones=dict(
        accent=dict(solid=R('ink', 'chalk', 'black', 'white'), onSolid=R('paper', 'night', 'white', 'black'),
                    text=R('ink', 'chalk', 'black', 'white'), subtle=R('Stone.100', 'Stone.900', 'Stone.200', 'Stone.800')),
        neutral=dict(solid=R('Stone.700', 'Stone.300', 'Stone.800', 'Stone.200'), onSolid=R('white', 'night', 'white', 'black'),
                     text=R('Stone.700', 'Stone.300', 'Stone.800', 'Stone.200'), subtle=R('Stone.100', 'Stone.900', 'Stone.200', 'Stone.800')),
        info=dict(solid=R('Indigo.700', 'Indigo.300', 'Indigo.800', 'Indigo.200'), onSolid=R('white', 'night', 'white', 'black'),
                  text=R('Indigo.700', 'Indigo.300', 'Indigo.800', 'Indigo.200'), subtle=R('Indigo.50', 'Indigo.950', 'Indigo.100', 'Indigo.900')),
        success=dict(solid=R('Forest.700', 'Forest.300', 'Forest.800', 'Forest.200'), onSolid=R('white', 'night', 'white', 'black'),
                     text=R('Forest.700', 'Forest.300', 'Forest.800', 'Forest.200'), subtle=R('Forest.50', 'Forest.950', 'Forest.100', 'Forest.900')),
        warning=dict(solid=R('Ochre.300', 'Ochre.300', 'Ochre.400', 'Ochre.200'), onSolid=R('ink', 'night', 'black', 'black'),
                     text=R('Ochre.700', 'Ochre.300', 'Ochre.800', 'Ochre.200'), subtle=R('Ochre.50', 'Ochre.950', 'Ochre.100', 'Ochre.900')),
        danger=dict(solid=R('Oxblood.700', 'Oxblood.300', 'Oxblood.800', 'Oxblood.200'), onSolid=R('white', 'night', 'white', 'black'),
                    text=R('Oxblood.700', 'Oxblood.300', 'Oxblood.800', 'Oxblood.200'), subtle=R('Oxblood.50', 'Oxblood.950', 'Oxblood.100', 'Oxblood.900')),
    ),
)

# ---------------------------------------------------------------- Neo-Brutal
THEMES['neoBrutal'] = dict(
    character='Square corners, thick ink outlines, hard offset shadows (sunflower in dark mode), flat saturated colors on cream, black-weight titles.',
    name='Neo-Brutal',
    ramps={'Sand': '#8A7F66', 'Sun': '#E5B800', 'Pink': '#EC4899', 'Mint': '#10B981', 'Tangerine': '#F97316',
           'Cherry': '#EF4444', 'Cobalt': '#3B5BFD'},
    extras={'cream': '#FFF8E7', 'ink': '#0A0A0A', 'sun': '#FFD23F', 'pink': '#FF5CA8', 'mint': '#3DDC97',
            'tangerine': '#FF9F1C', 'cherry': '#FF4D4D', 'cobalt': '#5B7CFF', 'coal': '#141414', 'coalPanel': '#1E1E1E',
            'coalLift': '#282828', 'bone': '#F5F0E6'},
    colors=dict(
        canvas=R('cream', 'coal'),
        surface=R('white', 'coalPanel'),
        surfaceRaised=R('white', 'coalLift'),
        fillMuted=R('Sand.100', 'Sand.900', 'Sand.200', 'Sand.800'),
        textPrimary=R('ink', 'bone', 'black', 'white'),
        textSecondary=R('Sand.800', 'Sand.200', 'Sand.900', 'Sand.100'),
        borderSubtle=R('ink', 'bone', 'black', 'white'),
        borderStrong=R('ink', 'bone', 'black', 'white'),
        pressedOverlay=None,
    ),
    tones=dict(
        accent=dict(solid=R('sun', 'sun', 'sun', 'sun'), onSolid=R('ink', 'ink', 'black', 'black'),
                    text=R('ink', 'sun', 'black', 'sun'), subtle=R('Sun.100', 'Sun.950', 'Sun.200', 'Sun.900')),
        neutral=dict(solid=R('ink', 'bone', 'black', 'white'), onSolid=R('white', 'ink', 'white', 'black'),
                     text=R('Sand.800', 'Sand.200', 'Sand.900', 'Sand.100'), subtle=R('Sand.100', 'Sand.900', 'Sand.200', 'Sand.800')),
        info=dict(solid=R('cobalt', 'cobalt', 'Cobalt.600', 'Cobalt.300'), onSolid=R('ink', 'ink', 'white', 'black'),
                  text=R('Cobalt.700', 'Cobalt.300', 'Cobalt.800', 'Cobalt.200'), subtle=R('Cobalt.100', 'Cobalt.950', 'Cobalt.200', 'Cobalt.900')),
        success=dict(solid=R('mint', 'mint', 'mint', 'mint'), onSolid=R('ink', 'ink', 'black', 'black'),
                     text=R('Mint.700', 'Mint.300', 'Mint.800', 'Mint.200'), subtle=R('Mint.100', 'Mint.950', 'Mint.200', 'Mint.900')),
        warning=dict(solid=R('tangerine', 'tangerine', 'tangerine', 'tangerine'), onSolid=R('ink', 'ink', 'black', 'black'),
                     text=R('Tangerine.700', 'Tangerine.300', 'Tangerine.800', 'Tangerine.200'), subtle=R('Tangerine.100', 'Tangerine.950', 'Tangerine.200', 'Tangerine.900')),
        danger=dict(solid=R('cherry', 'cherry', 'cherry', 'cherry'), onSolid=R('ink', 'ink', 'black', 'black'),
                    text=R('Cherry.700', 'Cherry.300', 'Cherry.800', 'Cherry.200'), subtle=R('Cherry.100', 'Cherry.950', 'Cherry.200', 'Cherry.900')),
    ),
    button_border=R('ink', 'bone', 'black', 'white'),
    toggle_border=R('ink', 'bone', 'black', 'white'),
)

# ---------------------------------------------------------------- Mono
THEMES['mono'] = dict(
    character='SF Mono everywhere, one phosphor-green accent, hairline boxes, no shadows, 0.75x spacing, short controls with 44-pt hit areas.',
    name='Mono',
    ramps={'Moss': '#5F7A66', 'Phosphor': '#16A34A', 'Amber': '#D97706', 'Red': '#DC2626', 'Cyan': '#0891B2'},
    extras={'term': '#0A0F0B', 'termPanel': '#101712', 'termLift': '#16201A', 'glow': '#39FF7A', 'paper': '#F5F7F4',
            'ink': '#0B1A10', 'phosphorText': '#D5F5DC', 'amber': '#FFB000', 'red': '#FF5F56', 'cyan': '#5FD7FF'},
    colors=dict(
        canvas=R('paper', 'term'),
        surface=R('white', 'termPanel'),
        surfaceRaised=R('white', 'termLift'),
        fillMuted=R('Moss.100', 'Moss.900', 'Moss.200', 'Moss.800'),
        textPrimary=R('ink', 'phosphorText', 'black', 'white'),
        textSecondary=R('Moss.700', 'Moss.300', 'Moss.800', 'Moss.200'),
        borderSubtle=R('Moss.200', 'Moss.800', 'Moss.400', 'Moss.600'),
        borderStrong=R('Moss.500', 'Moss.500', 'Moss.700', 'Moss.300'),
        pressedOverlay=None,
    ),
    tones=dict(
        accent=dict(solid=R('Phosphor.700', 'glow', 'Phosphor.800', 'Phosphor.200'), onSolid=R('white', 'term', 'white', 'black'),
                    text=R('Phosphor.700', 'glow', 'Phosphor.800', 'Phosphor.200'), subtle=R('Phosphor.50', 'Phosphor.950', 'Phosphor.100', 'Phosphor.900')),
        neutral=dict(solid=R('Moss.800', 'Moss.300', 'Moss.900', 'Moss.200'), onSolid=R('white', 'term', 'white', 'black'),
                     text=R('Moss.700', 'Moss.300', 'Moss.800', 'Moss.200'), subtle=R('Moss.100', 'Moss.900', 'Moss.200', 'Moss.800')),
        info=dict(solid=R('Cyan.700', 'cyan', 'Cyan.800', 'Cyan.200'), onSolid=R('white', 'term', 'white', 'black'),
                  text=R('Cyan.700', 'cyan', 'Cyan.800', 'Cyan.200'), subtle=R('Cyan.50', 'Cyan.950', 'Cyan.100', 'Cyan.900')),
        success=dict(solid=R('Phosphor.700', 'glow', 'Phosphor.800', 'Phosphor.200'), onSolid=R('white', 'term', 'white', 'black'),
                     text=R('Phosphor.700', 'glow', 'Phosphor.800', 'Phosphor.200'), subtle=R('Phosphor.50', 'Phosphor.950', 'Phosphor.100', 'Phosphor.900')),
        warning=dict(solid=R('amber', 'amber', 'Amber.300', 'Amber.200'), onSolid=R('black', 'term', 'black', 'black'),
                     text=R('Amber.700', 'amber', 'Amber.800', 'Amber.200'), subtle=R('Amber.50', 'Amber.950', 'Amber.100', 'Amber.900')),
        danger=dict(solid=R('Red.700', 'red', 'Red.800', 'Red.200'), onSolid=R('white', 'term', 'white', 'black'),
                    text=R('Red.700', 'red', 'Red.800', 'Red.200'), subtle=R('Red.50', 'Red.950', 'Red.100', 'Red.900')),
    ),
)

# ---------------------------------------------------------------- Ocean
THEMES['ocean'] = dict(
    character='Calm and deep: lagoon-teal accents on sea-foam surfaces, pebble-rounded corners (14-pt controls, 22-pt cards), soft diffuse sea-tinted shadows, tall controls, lighter headings, and slow tidal motion without bounce.',
    name='Ocean',
    ramps={'Tide': '#56788A', 'Lagoon': '#0A8FA8', 'Reef': '#2F6FE0', 'Kelp': '#13A07A', 'Sand': '#E3A21A',
           'Coral': '#F2545B'},
    extras={'foam': '#F0F7F9', 'abyss': '#03131B', 'deep': '#0A1F29', 'trench': '#122C38', 'pearl': '#E6F3F7',
            'ink': '#06222C'},
    colors=dict(
        canvas=R('foam', 'abyss'),
        surface=R('white', 'deep'),
        surfaceRaised=R('white', 'trench'),
        fillMuted=R('Tide.100', 'Tide.900', 'Tide.200', 'Tide.800'),
        textPrimary=R('ink', 'pearl', 'black', 'white'),
        textSecondary=R('Tide.700', 'Tide.300', 'Tide.800', 'Tide.200'),
        borderSubtle=R('Tide.200', 'Tide.800', 'Tide.400', 'Tide.600'),
        borderStrong=R('Tide.500', 'Tide.500', 'Tide.700', 'Tide.300'),
        pressedOverlay=None,
    ),
    tones=dict(
        accent=dict(solid=R('Lagoon.600', 'Lagoon.300', 'Lagoon.800', 'Lagoon.200'), onSolid=R('white', 'abyss', 'white', 'black'),
                    text=R('Lagoon.700', 'Lagoon.300', 'Lagoon.800', 'Lagoon.200'), subtle=R('Lagoon.50', 'Lagoon.950', 'Lagoon.100', 'Lagoon.900')),
        neutral=dict(solid=R('Tide.800', 'Tide.300', 'Tide.900', 'Tide.200'), onSolid=R('white', 'abyss', 'white', 'black'),
                     text=R('Tide.700', 'Tide.300', 'Tide.800', 'Tide.200'), subtle=R('Tide.100', 'Tide.900', 'Tide.200', 'Tide.800')),
        info=dict(solid=R('Reef.700', 'Reef.300', 'Reef.800', 'Reef.200'), onSolid=R('white', 'abyss', 'white', 'black'),
                  text=R('Reef.700', 'Reef.300', 'Reef.800', 'Reef.200'), subtle=R('Reef.50', 'Reef.950', 'Reef.100', 'Reef.900')),
        success=dict(solid=R('Kelp.700', 'Kelp.300', 'Kelp.800', 'Kelp.200'), onSolid=R('white', 'abyss', 'white', 'black'),
                     text=R('Kelp.700', 'Kelp.300', 'Kelp.800', 'Kelp.200'), subtle=R('Kelp.50', 'Kelp.950', 'Kelp.100', 'Kelp.900')),
        warning=dict(solid=R('Sand.300', 'Sand.300', 'Sand.400', 'Sand.200'), onSolid=R('ink', 'abyss', 'black', 'black'),
                     text=R('Sand.700', 'Sand.300', 'Sand.800', 'Sand.200'), subtle=R('Sand.50', 'Sand.950', 'Sand.100', 'Sand.900')),
        danger=dict(solid=R('Coral.700', 'Coral.300', 'Coral.800', 'Coral.200'), onSolid=R('white', 'abyss', 'white', 'black'),
                    text=R('Coral.700', 'Coral.300', 'Coral.800', 'Coral.200'), subtle=R('Coral.50', 'Coral.950', 'Coral.100', 'Coral.900')),
    ),
)

# ---------------------------------------------------------------- Sunset
THEMES['sunset'] = dict(
    character='Warm and expressive: golden-hour magenta-to-orange gradient buttons, apricot cream and dusk-plum surfaces, warm glowing shadows, heavy rounded headings over a plain body, and lively springy motion.',
    name='Sunset',
    ramps={'Dune': '#8E7470', 'Ember': '#F2661B', 'Magenta': '#D4267C', 'Dusk': '#5B5BD6', 'Palm': '#2F9A4C',
           'Gold': '#EDB00C', 'Crimson': '#E0262F'},
    extras={'cream': '#FFF6EF', 'plum': '#1A0E1B', 'plumPanel': '#251527', 'plumLift': '#311D33', 'glow': '#FFEDE4',
            'ink': '#2B1316'},
    colors=dict(
        canvas=R('cream', 'plum'),
        surface=R('white', 'plumPanel'),
        surfaceRaised=R('white', 'plumLift'),
        fillMuted=R('Dune.100', 'Dune.900', 'Dune.200', 'Dune.800'),
        textPrimary=R('ink', 'glow', 'black', 'white'),
        textSecondary=R('Dune.700', 'Dune.300', 'Dune.800', 'Dune.200'),
        borderSubtle=R('Dune.200', 'Dune.800', 'Dune.400', 'Dune.600'),
        borderStrong=R('Dune.500', 'Dune.500', 'Dune.700', 'Dune.300'),
        pressedOverlay=None,
    ),
    tones=dict(
        accent=dict(solid=R('Magenta.600', 'Magenta.300', 'Magenta.800', 'Magenta.200'), onSolid=R('white', 'plum', 'white', 'black'),
                    text=R('Magenta.700', 'Magenta.300', 'Magenta.800', 'Magenta.200'), subtle=R('Magenta.50', 'Magenta.950', 'Magenta.100', 'Magenta.900'),
                    solidFill=[R('Magenta.600', 'Magenta.300', 'Magenta.800', 'Magenta.200'), R('Ember.600', 'Ember.300', 'Ember.800', 'Ember.200')]),
        neutral=dict(solid=R('Dune.800', 'Dune.300', 'Dune.900', 'Dune.200'), onSolid=R('white', 'plum', 'white', 'black'),
                     text=R('Dune.700', 'Dune.300', 'Dune.800', 'Dune.200'), subtle=R('Dune.100', 'Dune.900', 'Dune.200', 'Dune.800')),
        info=dict(solid=R('Dusk.700', 'Dusk.300', 'Dusk.800', 'Dusk.200'), onSolid=R('white', 'plum', 'white', 'black'),
                  text=R('Dusk.700', 'Dusk.300', 'Dusk.800', 'Dusk.200'), subtle=R('Dusk.50', 'Dusk.950', 'Dusk.100', 'Dusk.900')),
        success=dict(solid=R('Palm.700', 'Palm.300', 'Palm.800', 'Palm.200'), onSolid=R('white', 'plum', 'white', 'black'),
                     text=R('Palm.700', 'Palm.300', 'Palm.800', 'Palm.200'), subtle=R('Palm.50', 'Palm.950', 'Palm.100', 'Palm.900')),
        warning=dict(solid=R('Gold.300', 'Gold.300', 'Gold.400', 'Gold.200'), onSolid=R('ink', 'plum', 'black', 'black'),
                     text=R('Gold.700', 'Gold.300', 'Gold.800', 'Gold.200'), subtle=R('Gold.50', 'Gold.950', 'Gold.100', 'Gold.900')),
        danger=dict(solid=R('Crimson.700', 'Crimson.400', 'Crimson.800', 'Crimson.200'), onSolid=R('white', 'plum', 'white', 'black'),
                    text=R('Crimson.700', 'Crimson.400', 'Crimson.800', 'Crimson.200'), subtle=R('Crimson.50', 'Crimson.950', 'Crimson.100', 'Crimson.900')),
    ),
)


def palette(theme):
    p = {'white': 'FFFFFF', 'black': '000000'}
    for name, anchor in theme['ramps'].items():
        for step, value in ramp(anchor).items():
            p[f'{name}.{step}'] = value
    for name, value in theme.get('extras', {}).items():
        p[name] = value.lstrip('#')
    return p
