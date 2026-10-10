"""Package an already verified native build with notices and checksums.

Example: python3 tools/release/package_release.py --platform macOS
  --build builds/macos/ChemSite.app --verification-log /tmp/career.log
  --verification-log /tmp/practice.log
"""
import argparse
import hashlib
import json
import os
import re
from pathlib import Path
import stat
import subprocess
import tempfile
import zipfile

ROOT = Path(__file__).resolve().parents[2]


def sha(path):
    digest = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(block)
    return digest.hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--version', default='0.1.0', help='Release version written into package metadata and instructions')
    parser.add_argument('--source-revision', default='HEAD', help='Verified build source commit; defaults to current HEAD')
    parser.add_argument('--platform', choices=['macOS', 'Windows'], required=True)
    parser.add_argument('--build', type=Path, required=True)
    parser.add_argument('--verification-log', type=Path, action='append', required=True)
    parser.add_argument('--output', type=Path, default=ROOT / 'builds/release')
    args = parser.parse_args()
    if not re.fullmatch(r'\d+\.\d+\.\d+(?:-[A-Za-z0-9.-]+)?', args.version):
        parser.error('--version must be a semantic version')
    logs = '\n'.join(path.read_text() for path in args.verification_log)
    levels = [1] if args.platform == 'macOS' else range(1, 6)
    required = [f'KEYBOARD_ROUND_SMOKE_OK level={level}' for level in levels]
    required.append('PRACTICE_LEVELS_SMOKE_OK topics=44 levels=5')
    for marker in required:
        if marker not in logs:
            raise SystemExit('Missing packaged verification marker: ' + marker)
    if any(line.startswith(('ERROR:', 'SCRIPT ERROR:')) for line in logs.splitlines()):
        raise SystemExit('Verification log contains engine errors')
    revision = subprocess.check_output(['git', 'rev-parse', '--verify', args.source_revision + '^{commit}'], cwd=ROOT, text=True).strip()
    notices = ROOT / 'docs/release/notices'
    manifest = json.loads((notices / 'manifest.json').read_text())
    for entry in manifest:
        if sha(notices / entry['file']) != entry['sha256']:
            raise SystemExit('Notice checksum mismatch: ' + entry['file'])
    build = args.build.resolve()
    if args.platform == 'macOS':
        executable = build / 'Contents/MacOS/ChemSite'
        if not executable.is_file() or not os.access(executable, os.X_OK):
            raise SystemExit('Missing executable macOS app')
        files = [(path, Path('ChemSite') / build.name / path.relative_to(build))
                 for path in sorted(build.rglob('*')) if path.is_file() or path.is_symlink()]
    else:
        files = [(build / name, Path('ChemSite') / name) for name in ['ChemSite.exe', 'ChemSite.pck']]
        if any(not source.is_file() for source, _ in files):
            raise SystemExit('Windows build requires paired EXE and PCK')
        if (build / 'ChemSite.exe').read_bytes()[:2] != b'MZ':
            raise SystemExit('Windows executable lacks PE header')
    files += [(path, Path('ChemSite/ThirdPartyNotices') / path.name)
              for path in sorted(notices.iterdir()) if path.is_file()]
    files += [(ROOT / 'docs/ASSET_LICENSES.md', Path('ChemSite/ASSET_LICENSES.md')),
              (ROOT / 'docs/RELEASE_READINESS.md', Path('ChemSite/KNOWN_ISSUES.md'))]
    args.output.mkdir(parents=True, exist_ok=True)
    archive = args.output / f'ChemSite-{args.platform}.zip'
    binary_hashes = {str(target): sha(source) for source, target in files if not source.is_symlink()}
    info = {'version': args.version, 'source_revision': revision, 'platform': args.platform,
            'verification_markers': required, 'files_sha256': binary_hashes,
            'scope': 'Automated packaged QA; human and hardware acceptance listed in KNOWN_ISSUES.md'}
    instructions = (f'ChemSite v{args.version} prerelease\n\n'
                    + ('Extract the entire ZIP and open ChemSite.app.\n'
                       'This build is unsigned and unnotarized. macOS may require explicit approval in Privacy & Security.\n'
                       if args.platform == 'macOS' else
                       'Extract the entire ZIP and run ChemSite.exe. Keep ChemSite.pck beside it.\n')
                    + '\nMove: WASD/arrows. Interact: E. Run: Shift. Pause/back: Escape.\n'
                    'Menu/answers: Tab, arrows, Space/Enter. Audio and reduced motion: Settings.\n'
                    'Practice covers all five levels without changing career progress.\n'
                    'See KNOWN_ISSUES.md and ThirdPartyNotices.\n')
    # Atomic replacement avoids publishing a partially written archive.
    with tempfile.NamedTemporaryFile(dir=args.output, suffix='.zip', delete=False) as temporary:
        temp_path = Path(temporary.name)
    try:
        with zipfile.ZipFile(temp_path, 'w', zipfile.ZIP_DEFLATED, compresslevel=6) as output:
            for source, target in files:
                if source.name == '.DS_Store':
                    continue
                if source.is_symlink():
                    link = zipfile.ZipInfo(str(target))
                    link.create_system = 3
                    link.external_attr = (stat.S_IFLNK | 0o777) << 16
                    output.writestr(link, os.readlink(source))
                else:
                    output.write(source, target)
            output.writestr('ChemSite/BUILD_INFO.json', json.dumps(info, indent=2) + '\n')
            output.writestr('ChemSite/README.txt', instructions)
        with zipfile.ZipFile(temp_path) as check:
            if check.testzip() is not None:
                raise SystemExit('Archive CRC verification failed')
        temp_path.replace(archive)
    finally:
        temp_path.unlink(missing_ok=True)
    checksum = archive.with_suffix('.zip.sha256')
    checksum.write_text(f'{sha(archive)}  {archive.name}\n')
    print(f'PACKAGED_RELEASE_OK {archive.name} bytes={archive.stat().st_size} revision={revision}')


if __name__ == '__main__':
    main()
