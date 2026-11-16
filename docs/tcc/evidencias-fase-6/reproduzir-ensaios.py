"""Reexecute os 33 programas usados na documentação, sem alterar o aplicativo.

Na raiz do projeto, após cargo build --offline --manifest-path rust_core/Cargo.toml:
python3 docs/tcc/evidencias-fase-6/reproduzir-ensaios.py
"""
import argparse
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--cli', type=Path, default=Path('rust_core/target/debug/ide-cli'))
args = parser.parse_args()
reference = json.loads(gzip.decompress(
    Path(__file__).with_name('ensaios-cli.json.gz').read_bytes()))
exe = args.cli.resolve()
checked = []
for name, case in reference['casos'].items():
    process = subprocess.run([str(exe), '--json', case['source']],
                             text=True, capture_output=True, timeout=10, check=True)
    actual = json.loads(process.stdout)
    expected = case['result']
    # Dictionaries compare by content, independent of HashMap serialization order.
    assert actual == expected, f'Resultado mudou para {name}; revise a documentação.'
    checked.append(name)
print(json.dumps({'casos_reproduzidos': len(checked),
                  'bin_sha256': hashlib.sha256(exe.read_bytes()).hexdigest(),
                  'todos_compativeis': True}, ensure_ascii=False))
