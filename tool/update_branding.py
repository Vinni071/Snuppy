#!/usr/bin/env python3
"""Regenerate the supplied-logo icons while preserving other Xcode settings."""

from pathlib import Path
import re
import subprocess

project = Path(__file__).resolve().parent.parent
subprocess.run(["flutter", "test", "tool/render_branding_test.dart"],
               cwd=project, check=True)
ios = project / "ios/Runner.xcodeproj/project.pbxproj"
# flutter_launcher_icons 0.14.4 also rewrites this unrelated asset setting.
setting = r"ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = [^;]+;"
original = iter(re.findall(setting, ios.read_text()))
try:
    subprocess.run(["dart", "run", "flutter_launcher_icons"], cwd=project, check=True)
finally:
    ios.write_text(re.sub(setting, lambda match: next(original, match.group()),
                          ios.read_text()))
