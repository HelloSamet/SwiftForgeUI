"""Replicates SwiftForgeContrastAudit.checks(for:) for the design source, plus stricter HC goals."""
import sys
from colorlib import hx, contrast, mix
from themes import THEMES, palette

APPEARANCES = ['light', 'dark', 'lightHC', 'darkHC']
TONES = ['accent', 'neutral', 'info', 'success', 'warning', 'danger']

def resolve(p, ref4, i):
    return hx(p[ref4[i]])

def checks(t):
    c = t['colors']
    surfaces = [('canvas', c['canvas']), ('surface', c['surface']), ('surfaceRaised', c['surfaceRaised'])]
    for level, ref in t.get('fills', {}).items():
        surfaces.append((f'fills[.{level}][0]', ref))
    out = []
    def add(name, fg, bgs, req):
        for bn, bg in bgs:
            out.append((name, fg, bn, bg, req, None))
    subtles = [(f'{n}.subtle', t['tones'][n]['subtle']) for n in TONES]
    add('textPrimary', c['textPrimary'], surfaces + subtles, 4.5)
    add('textSecondary', c['textSecondary'], surfaces + subtles, 4.5)
    add('borderStrong', c['borderStrong'], surfaces, 3)
    focus = t['tones']['accent']['text']
    add('focusRing', focus, surfaces, 3)
    for n in TONES:
        tone = t['tones'][n]
        solids = [(f'{n}.solid', tone['solid'])]
        out.append((f'{n}.onSolid', tone['onSolid'], f'{n}.solid', tone['solid'], 4.5, None))
        if tone.get('solidFill'):
            stops = tone['solidFill']
            for k, s in enumerate(stops):
                out.append((f'{n}.onSolid', tone['onSolid'], f'{n}.solidFill.stop{k}', s, 4.5, None))
            for k in range(len(stops) - 1):
                for tt in (0.25, 0.5, 0.75):
                    out.append((f'{n}.onSolid', tone['onSolid'], f'{n}.solidFill.mix{k}@{tt}', (stops[k], stops[k + 1], tt), 4.5, 'mix'))
        add(f'{n}.text', tone['text'], surfaces + [(f'{n}.subtle', tone['subtle'])], 4.5)
    if t.get('button_border'):
        add('components.button.borderColor', t['button_border'], surfaces, 3)
    if t.get('field_filled'):
        bg = [('field.background', c['fillMuted'])]
        add('textPrimary', c['textPrimary'], bg, 4.5)
        add('textSecondary', c['textSecondary'], bg, 4.5)
        add('borderStrong', c['borderStrong'], bg, 3)
    add('neutral.solid', t['tones']['neutral']['solid'], [('fillMuted', c['fillMuted'])], 3)
    for n in TONES:
        add(f'{n}.text', t['tones'][n]['text'], [('fillMuted', c['fillMuted'])], 3)
    if t.get('toggle_border'):
        add('components.toggle.borderColor', t['toggle_border'], surfaces, 3)
    return out

def run(key, verbose=False):
    t = THEMES[key]
    p = palette(t)
    bad, hcweak = [], []
    for name, fg, bn, bg, req, kind in checks(t):
        for i, ap in enumerate(APPEARANCES):
            f = resolve(p, fg, i)
            if kind == 'mix':
                a, b, tt = bg
                b_ = mix(resolve(p, a, i), resolve(p, b, i), tt)
            else:
                b_ = resolve(p, bg, i)
            r = contrast(f, b_)
            if r < req:
                bad.append(f'{name} on {bn} [{ap}]: {r:.2f} < {req}')
            elif ap.endswith('HC') and name in ('textPrimary', 'textSecondary') and r < 7 and not bn.endswith('subtle'):
                hcweak.append(f'{name} on {bn} [{ap}]: {r:.2f} (HC goal 7)')
    print(f'== {key}: {len(bad)} violations')
    for b in bad: print('  ', b)
    if verbose:
        for w in hcweak: print('   ~', w)
    return bad

if __name__ == '__main__':
    keys = sys.argv[1:] or list(THEMES)
    total = sum(len(run(k, verbose=True)) for k in keys)
    print('TOTAL', total)
