"""Reproduza os cenários de T3 em duas revisões, sem alterar o aplicativo.

Uso na raiz: python3 docs/tcc/evidencias-fase-7/reproduzir-t3.py --output /tmp/tcc-t3
Requer Python 3.12+, Git, Cargo e as dependências do motor disponíveis no cache.
"""
import argparse
import hashlib
import io
import json
from pathlib import Path
import shutil
import subprocess
import tarfile
import tempfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--root', type=Path, default=Path(__file__).resolve().parents[3])
parser.add_argument('--output', type=Path, required=True)
args = parser.parse_args()
root = args.root.resolve()
args.output.mkdir(parents=True, exist_ok=True)
probe = Path(__file__).with_name('t3-probe.rs').read_text()
revisions = [('atual', root / 'rust_core', None),
             ('historico', None, '6cb452290f51183247f6eb1a5a82eb31994684ff')]
records = []
with tempfile.TemporaryDirectory(prefix='tcc-t3-') as tmp:
    base = Path(tmp)
    for name, engine, rev in revisions:
        if rev:
            archive = subprocess.check_output(['git', 'archive', rev, 'rust_core'], cwd=root)
            target = base / 'historico'
            target.mkdir()
            with tarfile.open(fileobj=io.BytesIO(archive)) as tar:
                tar.extractall(target, filter='data')
            engine = target / 'rust_core'
        project = base / ('probe-' + name)
        (project / 'src').mkdir(parents=True)
        (project / 'src/main.rs').write_text(probe)
        # JSON string quoting also quotes a Cargo TOML basic string path here.
        manifest = ('[package]\nname = "tcc_t3_' + name + '"\nversion = "0.1.0"\n'
                    'edition = "2021"\n\n[dependencies]\nide_engine = { path = '
                    + json.dumps(str(engine)) + ' }\nserde_json = "1"\n')
        (project / 'Cargo.toml').write_text(manifest)
        shutil.copy2(engine / 'Cargo.lock', project / 'Cargo.lock')
        command = ['cargo', 'run', '--offline', '--manifest-path', str(project / 'Cargo.toml'),
                   '--target-dir', str(base / 'target')]
        result = subprocess.run(command, capture_output=True, text=True, check=True)
        data = json.loads(result.stdout)
        assert len(data) == 5
        for case, kind in zip(data, ['ParserError', 'RuntimeError', 'ParserError', None, 'RuntimeError']):
            response = case['resultado']
            observed = next(iter(response['errors'][0])) if response['errors'] else None
            assert observed == kind, case['cenario']
            if kind == 'ParserError':
                assert response['ast'] is None and not response['execution_trace']
                assert response['errors'][0][kind]['message'] == "Esperado ')', mas foi encontrado ';'"
            if kind == 'RuntimeError':
                assert response['errors'][0][kind]['message'] == 'Divisão por zero'
                assert len(response['execution_trace']) == 2
            if kind is None:
                assert response['success'] and response['output'] == '15\n'
        (args.output / ('t3-' + name + '.json')).write_text(result.stdout)
        (args.output / ('t3-compilacao-' + name + '.txt')).write_text(result.stderr)
        records.append({'revisao': rev or subprocess.check_output(
            ['git', 'rev-parse', 'HEAD'], cwd=root, text=True).strip(),
            'cenario_count': len(data), 'api_sha256': hashlib.sha256(
                (engine / 'src/api.rs').read_bytes()).hexdigest()})
(args.output / 'reproducao.json').write_text(json.dumps(records, ensure_ascii=False, indent=2) + '\n')
print(json.dumps({'revisoes': len(records), 'cenarios_por_revisao': 5, 'todos_compativeis': True}))
