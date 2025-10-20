#!/usr/bin/env python3
"""Generate a standardized experiment run log template.

This helper script creates a structured summary for experiment runs so that
every execution captures the fields required by the team's operational
guidelines (feature scope, code snapshot, dataset details, configuration,
hardware, protocol, metrics, segment deltas, final decision, and handy links).

Example
-------
Generate a template with a few populated fields and store it next to an
experiment notebook:

```
python scripts/run_log_template.py \
    --feature "Ranker: Thai locale boost" \
    --repo "https://github.com/example/repo" \
    --commit d34db33 \
    --branch feature/thai-ranker \
    --pr 42 \
    --oec-name "Primary Conversion" \
    --oec-value 0.423 \
    --oec-delta "+3.4%" \
    --oec-ci "[+1.2%, +5.1%]" \
    --oec-decision pass \
    --output docs/runs/2025-01-09_thai_ranker.md
```

If ``--output`` is omitted, the template is printed to stdout so that it can be
piped or captured by other tooling.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any, Dict, Iterable


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description=(
            "Generate a run log template that satisfies the required reporting "
            "fields for experiments and launches."
        )
    )

    parser.add_argument("--feature", default="{feature}", help="Name of the feature or experiment focus.")

    # Code snapshot metadata
    parser.add_argument("--repo", default="<repo_url>", help="Repository URL that hosted the change.")
    parser.add_argument("--commit", default="<commit_hash>", help="Git commit hash used for the run.")
    parser.add_argument("--branch", default="<branch>", help="Git branch name for traceability.")
    parser.add_argument("--pr", default="<pr_id>", help="Pull request number or identifier.")

    # Dataset info
    parser.add_argument("--snapshot-id", default="<snapshot_id>", help="Identifier for the dataset snapshot.")
    parser.add_argument(
        "--split",
        default="train/val/test(pct)",
        help="Dataset split percentages (e.g. 70/20/10).",
    )
    parser.add_argument(
        "--preprocessing",
        default="<preprocessing_steps>",
        help="Key preprocessing steps applied to the data.",
    )

    # Training/inference configuration
    parser.add_argument("--lr", default="<lr>", help="Learning rate or analogous tuning parameter.")
    parser.add_argument("--bs", default="<batch_size>", help="Batch size used during the run.")
    parser.add_argument("--epochs", default="<epochs>", help="Number of epochs or training passes.")
    parser.add_argument("--seed", default="<seed>", help="Random seed (or 'none' if not fixed).")
    parser.add_argument(
        "--deterministic",
        choices=("on", "off"),
        default="<deterministic:on/off>",
        help="Whether determinism flags were enforced.",
    )

    # Hardware
    parser.add_argument("--gpu", default="<gpu_model>", help="GPU hardware description.")
    parser.add_argument("--cpu", default="<cpu_model>", help="CPU hardware description.")
    parser.add_argument("--ram", default="<ram>", help="RAM allocation (e.g. 64GB).")
    parser.add_argument("--runtime", default="<runtime>", help="Total runtime, e.g. '2h15m'.")
    parser.add_argument("--cost", default="<cost>", help="Approximate monetary cost (e.g. '$23.50').")

    # Experiment protocol
    parser.add_argument("--sample-size", default="<n>", help="Predetermined sample size.")
    parser.add_argument("--horizon", default="<days>", help="Experiment duration or horizon in days.")
    parser.add_argument(
        "--test-type",
        default="<fixed|sequential>",
        help="Type of statistical testing protocol employed.",
    )

    # OEC metrics
    parser.add_argument("--oec-name", default="<OEC_name>", help="Name of the objective evaluation criterion.")
    parser.add_argument("--oec-value", default="<value>", help="Measured OEC value.")
    parser.add_argument("--oec-delta", default="<Δ_pct>", help="Percent delta vs. baseline.")
    parser.add_argument("--oec-ci", default="[l,u]", help="95%% confidence interval for the OEC.")
    parser.add_argument(
        "--oec-decision",
        default="<pass|fail>",
        help="Decision derived from the OEC (pass/fail).",
    )

    # Structured JSON blobs
    parser.add_argument(
        "--guardrails",
        help=(
            "JSON object describing guardrail metrics, e.g. "
            "'{\"latency_p95\": {\"value\": 120, \"threshold\": 150}}'."
        ),
    )
    parser.add_argument(
        "--segments",
        help=(
            "JSON object describing segment deltas and confidence intervals, "
            "e.g. '{\"device\": {\"delta\": \"+1.2%%\", \"ci\": "
            "\"[+0.2%%, +2.0%%]\"}}'."
        ),
    )

    # Outcome + ownership
    parser.add_argument(
        "--outcome",
        default="<deploy|hold|rollback>",
        help="Final launch decision for the run.",
    )
    parser.add_argument("--owner", default="@owner", help="Accountable owner or on-call.")
    parser.add_argument(
        "--rationale",
        default="<1-2 line rationale>",
        help="Short reasoning for the outcome.",
    )

    # Useful links
    parser.add_argument("--dashboard", default="<dashboard_url>", help="Monitoring dashboard link.")
    parser.add_argument("--notebook", default="<notebook_url>", help="Analysis notebook link.")
    parser.add_argument("--model-card", default="<model_card_url>", help="Model card link.")
    parser.add_argument("--datasheet", default="<datasheet_url>", help="Data sheet link.")

    parser.add_argument(
        "--output",
        type=Path,
        help="Optional output file path. If omitted, the template is printed to stdout.",
    )

    return parser


def _load_json_arg(parser: argparse.ArgumentParser, value: str | None, field_name: str) -> Dict[str, Any] | None:
    if value is None:
        return None
    try:
        parsed = json.loads(value)
    except json.JSONDecodeError as exc:  # pragma: no cover - defensive guard
        parser.error(f"{field_name} must be valid JSON: {exc}")
    if not isinstance(parsed, dict):
        parser.error(f"{field_name} must decode to an object/dict.")
    return parsed


def _format_guardrails(data: Dict[str, Any] | None) -> str:
    if not data:
        return "{latency_p95: {value: <value>, threshold: <threshold>}, error_rate: {value: <value>, threshold: <threshold>}, fairness_segment: {delta: <Δ%>, threshold: <threshold>}}"

    entries: Iterable[str] = []
    formatted_entries = []
    for metric, payload in data.items():
        if isinstance(payload, dict):
            parts = []
            value = payload.get("value", "<value>")
            parts.append(f"value={value}")
            threshold = payload.get("threshold", "<threshold>")
            parts.append(f"threshold={threshold}")
            for key, val in payload.items():
                if key in {"value", "threshold"}:
                    continue
                parts.append(f"{key}={val}")
        else:
            parts = [f"value={payload}", "threshold=<threshold>"]
        formatted_entries.append(f"{metric}: {{{', '.join(parts)}}}")
    return "{" + ", ".join(formatted_entries) + "}"


def _format_segments(data: Dict[str, Any] | None) -> str:
    if not data:
        return "{device: {delta: <Δ%>, CI95: [l,u]}, country: {delta: <Δ%>, CI95: [l,u]}, cohort: {delta: <Δ%>, CI95: [l,u]}}"

    entries = []
    for segment, payload in data.items():
        if isinstance(payload, dict):
            delta = payload.get("delta", "<Δ%>")
            ci = payload.get("ci", "[l,u]")
            notes = payload.get("notes")
            entry = f"{segment}: delta={delta} CI95={ci}"
            if notes:
                entry += f" notes={notes}"
        else:
            entry = f"{segment}: {payload}"
        entries.append(entry)
    return "{" + "; ".join(entries) + "}"


def _render_template(args: argparse.Namespace, guardrails: Dict[str, Any] | None, segments: Dict[str, Any] | None) -> str:
    guardrail_str = _format_guardrails(guardrails)
    segment_str = _format_segments(segments)

    lines = [
        f"feature: {args.feature}",
        "code: repo={repo} commit={commit} branch={branch} PR={pr}".format(
            repo=args.repo,
            commit=args.commit,
            branch=args.branch,
            pr=args.pr,
        ),
        "data: snapshot_id={snapshot} split={split} preprocessing={preproc}".format(
            snapshot=args.snapshot_id,
            split=args.split,
            preproc=args.preprocessing,
        ),
        "config: lr={lr} bs={bs} epochs={epochs} seed={seed} flags={{deterministic:{det}}}".format(
            lr=args.lr,
            bs=args.bs,
            epochs=args.epochs,
            seed=args.seed,
            det=args.deterministic,
        ),
        "hardware: GPU={gpu} CPU={cpu} RAM={ram} runtime={runtime} cost≈{cost}".format(
            gpu=args.gpu,
            cpu=args.cpu,
            ram=args.ram,
            runtime=args.runtime,
            cost=args.cost,
        ),
        "protocol: sample_size={sample_size} horizon={horizon} test_type={test_type}".format(
            sample_size=args.sample_size,
            horizon=args.horizon,
            test_type=args.test_type,
        ),
        "metrics:",
        "  - OEC={name} value={value} delta={delta} CI95={ci} decision={decision}".format(
            name=args.oec_name,
            value=args.oec_value,
            delta=args.oec_delta,
            ci=args.oec_ci,
            decision=args.oec_decision,
        ),
        f"  - guardrails: {guardrail_str}",
        f"segments: {segment_str}",
        "outcome: {outcome} owner={owner} rationale={rationale}".format(
            outcome=args.outcome,
            owner=args.owner,
            rationale=args.rationale,
        ),
        "links: dashboard={dashboard} notebook={notebook} model_card={model_card} datasheet={datasheet}".format(
            dashboard=args.dashboard,
            notebook=args.notebook,
            model_card=args.model_card,
            datasheet=args.datasheet,
        ),
    ]
    return "\n".join(lines)


def main() -> None:
    parser = _build_parser()
    args = parser.parse_args()

    guardrails = _load_json_arg(parser, args.guardrails, "--guardrails")
    segments = _load_json_arg(parser, args.segments, "--segments")

    template = _render_template(args, guardrails, segments)

    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(template, encoding="utf-8")
    else:
        print(template)


if __name__ == "__main__":  # pragma: no cover - CLI entry point
    main()

