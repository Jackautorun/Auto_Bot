import math

import pytest

from koch_analysis import KochMetrics, format_metrics, koch_metrics


def test_koch_metrics_iteration_zero():
    metrics = koch_metrics(0, initial_length=2.0)
    assert isinstance(metrics, KochMetrics)
    assert metrics.iteration == 0
    assert metrics.segments == 3
    assert math.isclose(metrics.segment_length, 2.0)
    assert math.isclose(metrics.perimeter, 6.0)
    expected_area = math.sqrt(3) * (2.0**2) / 4
    assert math.isclose(metrics.area, expected_area)
    assert math.isclose(metrics.added_area, 0.0)


def test_koch_metrics_iteration_one():
    metrics = koch_metrics(1, initial_length=3.0)
    assert metrics.segments == 12
    assert math.isclose(metrics.segment_length, 1.0)
    assert math.isclose(metrics.perimeter, 12.0)
    expected_area = math.sqrt(3) * (3.0**2) / 20 * (8 - 3 * (4 / 9))
    assert math.isclose(metrics.area, expected_area)
    previous_area = math.sqrt(3) * (3.0**2) / 4
    assert math.isclose(metrics.added_area, expected_area - previous_area)


def test_format_metrics_contains_all_fields():
    metrics = koch_metrics(2)
    output_lines = list(format_metrics(metrics))
    assert len(output_lines) == 6
    assert any("Iteration:" in line for line in output_lines)
    assert any("Segments:" in line for line in output_lines)
    assert any("Segment length:" in line for line in output_lines)
    assert any("Perimeter:" in line for line in output_lines)
    assert any("Area:" in line for line in output_lines)
    assert any("Added area:" in line for line in output_lines)


def test_invalid_inputs_raise_value_error():
    with pytest.raises(ValueError):
        koch_metrics(-1)
    with pytest.raises(ValueError):
        koch_metrics(0, initial_length=0)
