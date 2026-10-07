#!/usr/bin/env python3
"""Sanitizes an IPA by stripping existing tweak injection from the Mach-O binaries and bundle.

Usage:
  scripts/clean-ipa.py <input.ipa> [output.ipa]

If output.ipa is omitted, a temporary file is created and atomically replaces input.ipa.
"""
import os
import re
import struct
import sys
import tempfile
import zipfile

DYLIBS_TO_STRIP = {
    b"@rpath/spotifyglass.dylib",
    b"@rpath/SpotifyGlassAppGroups.dylib",
    b"@rpath/FLEX.dylib",
    b"@rpath/autoflex.dylib",
}

BUNDLE_FILES_TO_STRIP = (
    "frameworks/spotifyglass.dylib",
    "frameworks/spotifyglassappgroups.dylib",
    "frameworks/flex.dylib",
    "frameworks/autoflex.dylib",
    "plugins/spotifyglassliveactivity.appex",
)


def strip_macho_dylibs(data: bytearray, dylib_names: set[bytes]) -> tuple[bytearray, int]:
    if len(data) < 32:
        return data, 0
    magic, cputype, cpusubtype, filetype, ncmds, sizeofcmds, flags, reserved = struct.unpack_from("<IiiIIIII", data, 0)
    if magic != 0xFEEDFACF:
        # Not a 64-bit Mach-O binary
        return data, 0

    off = 32
    i = 0
    removed = 0
    while i < ncmds:
        cmd, cmdsize = struct.unpack_from("<II", data, off)
        if cmd in (0xC, 0x18, 0x1F, 0x80000018, 0x8000001F):
            name = bytes(data[off + 24:off + cmdsize].split(b"\0")[0])
            if name in dylib_names:
                end = 32 + sizeofcmds
                data[off : end - cmdsize] = data[off + cmdsize : end]
                data[end - cmdsize : end] = b"\0" * cmdsize
                ncmds -= 1
                sizeofcmds -= cmdsize
                removed += 1
                continue
        off += cmdsize
        i += 1

    if removed > 0:
        struct.pack_into("<II", data, 16, ncmds, sizeofcmds)
    return data, removed


def should_skip_file(name: str) -> bool:
    name_lower = name.lower()
    for pattern in BUNDLE_FILES_TO_STRIP:
        if pattern in name_lower:
            return True
    return False


def clean_ipa(in_path: str, out_path: str) -> None:
    print(f"[*] Sanitizing IPA: {in_path} -> {out_path}")
    total_stripped = 0

    with zipfile.ZipFile(in_path, "r") as zin:
        with zipfile.ZipFile(out_path, "w", compression=zipfile.ZIP_DEFLATED) as zout:
            for item in zin.infolist():
                if should_skip_file(item.filename):
                    print(f"    - removed bundle item: {item.filename}")
                    continue

                content = zin.read(item.filename)

                # Check if this item is a Mach-O binary in the bundle
                is_main_bin = bool(re.search(r"Payload/[^/]+\.app/Spotify$", item.filename))
                is_widget_bin = bool(re.search(r"Payload/[^/]+\.app/PlugIns/WidgetExtension\.appex/WidgetExtension$", item.filename))

                if is_main_bin or is_widget_bin:
                    clean_data, count = strip_macho_dylibs(bytearray(content), DYLIBS_TO_STRIP)
                    if count > 0:
                        print(f"    - stripped {count} dylib load command(s) from {item.filename}")
                        total_stripped += count
                    content = clean_data

                zout.writestr(item, content)

    print(f"[*] Sanitization complete (removed {total_stripped} injection load commands)")


def main():
    if len(sys.argv) < 2:
        sys.exit(f"Usage: {sys.argv[0]} <input.ipa> [output.ipa]")

    in_path = sys.argv[1]
    if not os.path.isfile(in_path):
        sys.exit(f"Error: file not found: {in_path}")

    if len(sys.argv) >= 3:
        out_path = sys.argv[2]
        clean_ipa(in_path, out_path)
    else:
        tmp_fd, tmp_path = tempfile.mkstemp(suffix=".ipa")
        os.close(tmp_fd)
        try:
            clean_ipa(in_path, tmp_path)
            os.replace(tmp_path, in_path)
        finally:
            if os.path.exists(tmp_path):
                os.remove(tmp_path)


if __name__ == "__main__":
    main()
