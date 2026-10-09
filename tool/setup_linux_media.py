#!/usr/bin/env python3
"""Prepare a project-local libmpv on Fedora, without changing system packages."""

import os
from pathlib import Path
import platform
import subprocess


def main():
    if platform.freedesktop_os_release().get("ID") != "fedora":
        raise SystemExit("Este helper é para Fedora. Instale libmpv-dev na sua distribuição.")
    if platform.machine() != "x86_64":
        raise SystemExit("Este helper requer Fedora x86_64.")
    project = Path(__file__).resolve().parent.parent
    cache = project / ".dart_tool/luminthor-linux-media"
    rpms = cache / "rpms"
    root = cache / "root"
    rpms.mkdir(parents=True, exist_ok=True)
    root.mkdir(parents=True, exist_ok=True)
    packages = ["mpv-devel", "mpv-libs", "mujs", "compat-lua-libs",
                "vapoursynth-libs", "libXpresent"]
    subprocess.run([
        "dnf", "--disable-repo=*", "--enable-repo=fedora", "--enable-repo=updates",
        "download", f"--destdir={rpms}", *[f"{p}.x86_64" for p in packages],
    ], check=True)
    for rpm in sorted(rpms.glob("*.rpm")):
        unpack = subprocess.Popen(["rpm2cpio", str(rpm)], stdout=subprocess.PIPE)
        result = subprocess.run(
            ["cpio", "-idmu", "--quiet", "--no-absolute-filenames"],
            stdin=unpack.stdout, cwd=root,
        )
        unpack.stdout.close()
        if unpack.wait() or result.returncode:
            raise SystemExit(f"Não foi possível extrair {rpm.name}.")
    prefix = root / "usr"
    pc = prefix / "lib64/pkgconfig/mpv.pc"
    # Dynamic linking requires only libmpv; private build dependencies are unused.
    lines = pc.read_text().splitlines()
    pc.write_text("\n".join(
        f"prefix={prefix}" if line.startswith("prefix=") else line
        for line in lines
        if not line.startswith(("Requires.private:", "Libs.private:"))
    ) + "\n")
    environment = dict(os.environ, LD_LIBRARY_PATH=str(prefix / "lib64"))
    linked = subprocess.run(["ldd", str(prefix / "lib64/libmpv.so.2")],
                            env=environment, capture_output=True, text=True, check=True)
    missing = [line.strip() for line in linked.stdout.splitlines() if "not found" in line]
    if missing:
        raise SystemExit("Dependências de runtime ausentes:\n" + "\n".join(missing))
    print("libmpv preparado. Execute flutter build linux ou flutter run -d linux.")


if __name__ == "__main__":
    main()
