"""Summarize the applied survey without exporting names, emails or raw comments.

Usage: python3 analisar_respostas.py INPUT.xlsx --output SUMMARY.json
The input workbook is read only. Qualitative coding refers to Excel row numbers
in the 12-response export reviewed on 2026-11-14, not participant identities.
"""

import argparse
from collections import Counter
from datetime import datetime, timedelta
import hashlib
import json
from pathlib import Path
import re
from statistics import median
import xml.etree.ElementTree as ET
from zipfile import ZipFile


NS = {"s": "http://schemas.openxmlformats.org/spreadsheetml/2006/main"}
ACCEPTED = {
    "Tenho 18 anos ou mais, li as informações e aceito participar.",
    "Li as informações e aceito participar.",
}
DECLINED = {
    "Tenho 18 anos ou mais e não aceito participar.",
    "Não aceito participar.",
}
OPENED = "Sim, instalei e o aplicativo abriu."
CODED_EXPORT_SHA256 = "a445e1595e352b67a2240a0ae5715ec7cbc77fa68ad37188311f16c7ad396917"


def read_export(path):
    with ZipFile(path) as archive:
        workbook = ET.fromstring(archive.read("xl/workbook.xml"))
        prop = workbook.find("s:workbookPr", NS)
        epoch = datetime(1904, 1, 1) if prop is not None and prop.get(
            "date1904"
        ) in {"1", "true"} else datetime(1899, 12, 30)
        shared = []
        if "xl/sharedStrings.xml" in archive.namelist():
            shared = [
                "".join(t.text or "" for t in cell.findall(".//s:t", NS))
                for cell in ET.fromstring(archive.read(
                    "xl/sharedStrings.xml"
                )).findall("s:si", NS)
            ]
        sheet = ET.fromstring(archive.read("xl/worksheets/sheet1.xml"))
        rows = []
        for row in sheet.findall("s:sheetData/s:row", NS):
            cells = {}
            for cell in row.findall("s:c", NS):
                value = cell.find("s:v", NS)
                text = value.text if value is not None else None
                if cell.get("t") == "s" and text is not None:
                    text = shared[int(text)]
                elif cell.get("t") == "inlineStr":
                    text = "".join(t.text or "" for t in cell.findall(
                        ".//s:t", NS
                    ))
                cells[re.sub(r"\d+", "", cell.get("r"))] = text
            if any(value is not None for value in cells.values()):
                rows.append((int(row.get("r")), cells))
    return rows[0][1], rows[1:], epoch


def summarize(path):
    headers, records, epoch = read_export(path)
    if len(headers) != 26 or not headers["G"].startswith("C01"):
        raise ValueError("Unexpected form layout; review column mapping.")
    unknown = [r for _, r in records if (r.get("G") or "").strip()
               not in ACCEPTED | DECLINED]
    if unknown:
        raise ValueError("Unrecognized consent response; review before inclusion.")
    accepted = [(i, r) for i, r in records
                if (r.get("G") or "").strip() in ACCEPTED]
    users = [(i, r) for i, r in accepted
             if (r.get("M") or "").strip() == OPENED]

    def counts(column, group):
        return dict(Counter((r.get(column) or "").strip() or "Ausente"
                            for _, r in group))

    likert = {}
    for column in "QRSTUVWX":
        values = []
        unavailable = missing = 0
        for _, record in users:
            text = (record.get(column) or "").strip()
            if not text:
                missing += 1
            elif text == "Não consegui avaliar.":
                unavailable += 1
            else:
                match = re.match(r"^([1-5])\s*[—-]", text)
                if not match:
                    raise ValueError(f"Unrecognized rating in column {column}.")
                values.append(int(match.group(1)))
        frequencies = {str(v): values.count(v) for v in range(1, 6)}
        agree = sum(value >= 4 for value in values)
        likert[headers[column].split(" — ", 1)[0]] = {
            "column": column,
            "statement": headers[column].split(" — ", 1)[1],
            "valid": len(values),
            "missing": missing,
            "unavailable": unavailable,
            "frequencies": frequencies,
            "median": median(values) if values else None,
            "agreement_count": agree,
            "agreement_percent": agree * 100 / len(values) if values else None,
        }
        assert sum(frequencies.values()) == len(values)
        assert len(values) + missing + unavailable == len(users)

    dates = [epoch + timedelta(days=float(r["C"]))
             for _, r in accepted if r.get("C")]
    result = {
        "source": {
            "file": path.name,
            "sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
            "sheet": "Sheet1",
            "research_range": "G1:Z13",
            "analysis_date": "2026-11-14",
            "completion_dates": [min(dates).date().isoformat(),
                                 max(dates).date().isoformat()],
        },
        "total_records": len(records),
        "declined_excluded": len(records) - len(accepted),
        "accepted": len(accepted),
        "reported_opening": len(users),
        "unique_submission_ids": len({r.get("A") for _, r in records}) == len(records),
        "profile_accepted": counts("H", accepted),
        "profile_users": counts("H", users),
        "experience_accepted": counts("I", accepted),
        "experience_users": counts("I", users),
        "installation": counts("M", accepted),
        "form_consultation_users": counts("L", users),
        "tasks": {
            f"T{i}": {
                "column": column,
                "users": len(users),
                "responses": sum(bool((r.get(column) or "").strip()) for _, r in users),
                "missing": sum(not bool((r.get(column) or "").strip()) for _, r in users),
            } for i, column in enumerate("NOP", 1)
        },
        "likert": likert,
        "comments": {
            "A01": sum(bool((r.get("Y") or "").strip()) for _, r in users),
            "A02": sum(bool((r.get("Z") or "").strip()) for _, r in users),
            "respondents": sum(any((r.get(c) or "").strip() for c in "YZ")
                               for _, r in users),
        },
        "interpretation": {
            "missing_tasks_are_not_failures": True,
            "task_replies_do_not_establish_observed_success": True,
            "no_SUS_or_learning_gain_calculated": True,
            "application_version_not_identified_in_export": True,
        },
    }
    # Human coding after comparison with the full task wording supplied by the researcher.
    # Refuse to silently reuse annotations on an enlarged/reordered/different export.
    expected_users = [4, 5, 6, 8, 9, 10, 11, 13]
    if (result["source"]["sha256"] != CODED_EXPORT_SHA256
            or [i for i, _ in users] != expected_users):
        raise ValueError("Review qualitative coding for this export.")
    result["qualitative_coding"] = {
        "task_evidence": {
            "T1": {"pair_5_and_10_without_both_requested_records": 5,
                   "isolated_10": 1},
            "T2": {"explicit_parenthesis_diagnostic": 3,
                   "valid_corrected_code_with_output_15": 1,
                   "isolated_output_15": 1},
            "T3": {"division_by_zero_named": 3,
                   "valid_single_initial_value_change_with_code_and_output": 1,
                   "different_diagnostic_reported": 1,
                   "isolated_output_4": 1,
                   "pre_failure_variable_state_explicitly_recorded": 0},
        },
        "comment_themes_nonexclusive": {
            "navigation_and_control_discovery": 2,
            "didactic_explanations": 1,
            "division_by_zero_diagnostic": 1,
            "typing_on_a_small_screen": 1,
        },
        "coding_note": "Themes and evidence categories are descriptive, not correctness scores.",
    }
    assert result["accepted"] + result["declined_excluded"] == len(records)
    assert len(users) <= len(accepted)
    assert all(t["responses"] + t["missing"] == len(users)
               for t in result["tasks"].values())
    return result


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("input", type=Path)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    summary = summarize(args.input)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(summary, ensure_ascii=False, indent=2) + "\n")
    print(json.dumps({key: summary[key] for key in (
        "total_records", "declined_excluded", "accepted", "reported_opening"
    )}, ensure_ascii=False))
