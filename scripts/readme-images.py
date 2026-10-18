#!/usr/bin/env python3
"""Regenerates the README images in docs/images. Requires Pillow (`pip3 install --user Pillow`).

    scripts/readme-images.py themes
        docs/images/themes.png from the snapshot references (run `scripts/snapshots.sh fetch` first): per built-in
        theme, buttons and switches in light mode, cards and banners in dark mode.

    scripts/readme-images.py screens --app <SwiftForgeShowcase.app> --device <simulator UDID>
        docs/images/gallery.png and docs/images/example-screens.png from the Showcase app, captured on a booted iPhone
        simulator (an iPhone 16 Pro gives the published proportions). Build the app first, e.g.:
        xcodebuild build -project Examples/SwiftForgeShowcase/SwiftForgeShowcase.xcodeproj -scheme SwiftForgeShowcase \\
          -destination 'platform=iOS Simulator,id=<UDID>' -derivedDataPath .build/showcase
"""
import argparse
import pathlib
import subprocess
import tempfile
import time

from PIL import Image, ImageDraw

ROOT = pathlib.Path(__file__).resolve().parent.parent
IMAGES = ROOT / "docs/images"
SNAPSHOTS = ROOT / "Examples/SwiftForgeShowcase/__Snapshots__"
THEMES = ["forge", "midnight", "aurora", "paper", "neo-brutal", "mono", "ocean", "sunset"]
BUNDLE_ID = "dev.swiftforge.Showcase"


def themes():
    """A grid: one row per theme; buttons and switches light, cards and banners dark."""
    columns = [("ComponentSnapshotTests/buttons", "light"), ("ComponentSnapshotTests/toggles", "light"),
               ("ComponentSnapshotTests/cards", "dark"), ("ComponentSnapshotTests/banners", "dark")]
    cell_width, gap = 390, 5
    rows = []
    for theme in THEMES:
        cells = []
        for name, appearance in columns:
            path = SNAPSHOTS / f"{name}.{theme}-{appearance}.png"
            if not path.exists():
                raise SystemExit(f"{path} is missing; run scripts/snapshots.sh fetch")
            image = Image.open(path).convert("RGB")
            cells.append(image.resize((cell_width, round(image.height * cell_width / image.width)), Image.LANCZOS))
        rows.append(cells)
    width = len(columns) * cell_width + (len(columns) - 1) * gap
    height = sum(max(c.height for c in row) for row in rows) + (len(rows) - 1) * gap
    grid = Image.new("RGB", (width, height), (158, 158, 158))
    y = 0
    for row in rows:
        row_height = max(c.height for c in row)
        for index, cell in enumerate(row):
            x = index * (cell_width + gap)
            # Extend each cell's own background to the row's height.
            background = cell.getpixel((cell.width - 1, cell.height - 1))
            grid.paste(Image.new("RGB", (cell_width, row_height), background), (x, y))
            grid.paste(cell, (x, y))
        y += row_height + gap
    grid.save(IMAGES / "themes.png", optimize=True)
    print("Wrote docs/images/themes.png")


def capture(device, fixture, theme, appearance, directory):
    subprocess.run(["xcrun", "simctl", "terminate", device, BUNDLE_ID], capture_output=True)
    subprocess.run(["xcrun", "simctl", "launch", device, BUNDLE_ID, "-uiTestFixture", fixture,
                    "-uiTestTheme", theme, "-uiTestAppearance", appearance], check=True, capture_output=True)
    time.sleep(3)
    path = pathlib.Path(directory) / f"{fixture}-{theme}-{appearance}.png"
    subprocess.run(["xcrun", "simctl", "io", device, "screenshot", str(path)], check=True, capture_output=True)
    return Image.open(path).convert("RGB")


def rounded(image, radius):
    mask = Image.new("L", image.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, image.width - 1, image.height - 1), radius, fill=255)
    out = Image.new("RGBA", image.size, (0, 0, 0, 0))
    out.paste(image, (0, 0), mask)
    return out


def sheet(images, columns, cell_width, gap, radius):
    scaled = [i.resize((cell_width, round(i.height * cell_width / i.width)), Image.LANCZOS) for i in images]
    cell_height = scaled[0].height
    rows = (len(scaled) + columns - 1) // columns
    canvas = Image.new("RGBA", (columns * cell_width + (columns - 1) * gap, rows * cell_height + (rows - 1) * gap),
                       (255, 255, 255, 0))
    for index, image in enumerate(scaled):
        x, y = (index % columns) * (cell_width + gap), (index // columns) * (cell_height + gap)
        piece = rounded(image, radius) if radius else image.convert("RGBA")
        canvas.paste(piece, (x, y), piece)
    return canvas


def screens(app, device):
    subprocess.run(["xcrun", "simctl", "install", device, app], check=True)
    subprocess.run(["xcrun", "simctl", "status_bar", device, "override", "--time", "9:41", "--batteryState",
                    "charged", "--batteryLevel", "100", "--wifiBars", "3", "--cellularMode", "notSupported"],
                   check=True)
    try:
        with tempfile.TemporaryDirectory() as directory:
            looks = [("forge", "light"), ("midnight", "dark"), ("ocean", "light"), ("sunset", "dark")]
            gallery = [capture(device, fixture, theme, appearance, directory)
                       for fixture in ["authScreen", "auditFeedback"] for theme, appearance in looks]
            sheet(gallery, columns=4, cell_width=300, gap=24, radius=40).save(IMAGES / "gallery.png", optimize=True)
            examples = [capture(device, fixture, "midnight", "dark", directory)
                        for fixture in ["authScreen", "settingsScreen", "inboxScreen"]]
            sheet(examples, columns=3, cell_width=440, gap=24, radius=0).save(IMAGES / "example-screens.png",
                                                                               optimize=True)
    finally:
        subprocess.run(["xcrun", "simctl", "status_bar", device, "clear"], check=False)
    print("Wrote docs/images/gallery.png and docs/images/example-screens.png")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    commands = parser.add_subparsers(dest="command", required=True)
    commands.add_parser("themes")
    screens_parser = commands.add_parser("screens")
    screens_parser.add_argument("--app", required=True)
    screens_parser.add_argument("--device", required=True)
    arguments = parser.parse_args()
    if arguments.command == "themes":
        themes()
    else:
        screens(arguments.app, arguments.device)
