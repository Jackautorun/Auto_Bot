# Experiment Run Log Template

> ใช้บันทึกผลการรันทุกครั้งตามข้อกำหนด Guardrails และ OEC ของโปรเจกต์

## Run Overview
- **feature**: 
- **code**: `repo=<url> commit=<hash> branch=<name> PR=<id>`
- **data**: `snapshot_id=<id> split=train/val/test(%) preprocessing=<desc>`
- **config**: `lr=… bs=… epochs=… seed=… flags={deterministic:on/off}`
- **hardware**: `GPU=… CPU=… RAM=… runtime=… cost≈…`
- **protocol**: `sample_size=<n> horizon=<days> test_type=<fixed|sequential>`

## Metrics Summary
### OEC
- **name**: 
- **value**: 
- **delta** (%): 
- **CI95**: `[lower, upper]`
- **decision** (`pass` | `fail`): 

### Guardrails
| Metric | Value | Δ% | CI95 | Threshold | Decision |
| ------ | ----- | --- | ---- | --------- | -------- |
| latency_p95 |  |  |  |  |  |
| error_rate |  |  |  |  |  |
| fairness_segment… |  |  |  |  |  |

> หากมี guardrail เพิ่มเติมให้ขยายตารางหรือเพิ่มตารางใหม่

## Segment Analysis
- **Segments**: `{device, country, cohort, ...}`
- สรุป delta + CI สำหรับแต่ละเซกเมนต์:
  - Segment: 
    - Metric: 
    - Δ%: 
    - CI95: `[lower, upper]`
    - Observation: 

## Statistical Controls
- **Multiple testing control**: (เช่น Holm-Bonferroni, Benjamini-Hochberg สำหรับ FDR)
- **Notes**: วิธีการคำนวณ, adjustments, assumptions

## Outcome & Ownership
- **Outcome**: `{deploy | hold | rollback}`
- **Owner**: `@user`
- **Rationale**: 

## Links & Artifacts
- **dashboard**: 
- **notebook**: 
- **model_card**: 
- **datasheet**: 

## Additional Notes
- 
- 

