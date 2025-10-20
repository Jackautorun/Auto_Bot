# Experiment Run Log Template

Use this template to document every evaluation or deployment decision so that the team can enforce a single Overall Evaluation Criterion (OEC) together with its guardrails.

## feature
- `feature`: <name or short description>

## code
- `repo`: <repository URL>
- `commit`: <commit hash>
- `branch`: <branch name>
- `PR`: <pull request id or link>

## data
- `snapshot_id`: <unique dataset snapshot identifier>
- `split`: <train/val/test percentages>
- `preprocessing`: <brief description of preprocessing and filters>

## config
- `lr`: <learning rate>
- `bs`: <batch size>
- `epochs`: <number of training epochs>
- `seed`: <random seed>
- `flags`: { deterministic: <on|off>, ... }

## hardware
- `GPU`: <model or N/A>
- `CPU`: <model>
- `RAM`: <total memory>
- `runtime`: <wall-clock runtime>
- `cost`: <approximate cost>

## protocol
- `sample_size`: <n>
- `horizon`: <days>
- `test_type`: <fixed | sequential>
- Notes: Describe any pre-registered protocol requirements. Sample sizes and test duration must be declared in advance and respected during the run.

## metrics
- OEC:
  - `name`: <metric name>
  - `value`: <measured value>
  - `delta`: <percentage change relative to baseline>
  - `CI95`: [<lower>, <upper>]
  - `decision`: <pass | fail>
- Guardrails (include thresholds and observed values for each guardrail):
  - `latency_p95`: <value> (threshold: <value>)
  - `error_rate`: <value> (threshold: <value>)
  - `fairness_segment...`: <value> (threshold: <value>)
- Multiple Comparisons: Document any corrections (e.g., FDR control) applied when monitoring multiple metrics or segments.

## segments
Provide deltas and 95% confidence intervals for each relevant segment grouping (e.g., `device`, `country`, `cohort`).

## outcome
- `outcome`: <deploy | hold | rollback>
- `owner`: <@owner>
- `rationale`: <one or two sentences>

## links
- `dashboard`: <URL>
- `notebook`: <URL>
- `model_card`: <URL>
- `datasheet`: <URL>

## checklist
- [ ] Sample size and horizon declared before the run.
- [ ] Guardrail thresholds documented and checked.
- [ ] Confidence intervals reported for all key metrics.
- [ ] FDR control applied when evaluating multiple metrics or segments.
