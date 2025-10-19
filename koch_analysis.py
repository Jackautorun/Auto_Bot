"""Utilities for analyzing geometric properties of the Koch snowflake."""
from __future__ import annotations

import argparse
import dataclasses
import math
from typing import Iterable


@dataclasses.dataclass(frozen=True)
class KochMetrics:
    """Summary metrics describing a particular Koch snowflake iteration."""

    iteration: int
    segment_length: float
    segments: int
    perimeter: float
    area: float
    added_area: float


def koch_metrics(iteration: int, *, initial_length: float = 1.0) -> KochMetrics:
    """Compute length, perimeter, and area metrics for a Koch snowflake iteration.

    Args:
        iteration: The iteration depth (``0`` for the initial equilateral triangle).
        initial_length: The side length of the initial equilateral triangle.

    Returns:
        A :class:`KochMetrics` instance describing the requested iteration.

    Raises:
        ValueError: If ``iteration`` is negative or ``initial_length`` is not positive.
    """

    if iteration < 0:
        raise ValueError("iteration must be non-negative")
    if initial_length <= 0:
        raise ValueError("initial_length must be positive")

    segment_length = initial_length / (3**iteration)
    segments = 3 * (4**iteration)
    perimeter = segments * segment_length
    area = _koch_area(iteration, initial_length)
    previous_area = _koch_area(iteration - 1, initial_length) if iteration > 0 else area
    added_area = area - previous_area

    return KochMetrics(
        iteration=iteration,
        segment_length=segment_length,
        segments=segments,
        perimeter=perimeter,
        area=area,
        added_area=added_area,
    )


def _koch_area(iteration: int, initial_length: float) -> float:
    if iteration < 0:
        return 0.0
    factor = math.sqrt(3) * (initial_length**2) / 20
    return factor * (8 - 3 * ((4 / 9) ** iteration))


def format_metrics(metrics: KochMetrics) -> Iterable[str]:
    """Create human-readable lines describing :class:`KochMetrics`."""

    yield f"Iteration: {metrics.iteration}"
    yield f"Segments: {metrics.segments}"
    yield f"Segment length: {metrics.segment_length:.6f}"
    yield f"Perimeter: {metrics.perimeter:.6f}"
    yield f"Area: {metrics.area:.6f}"
    yield f"Added area: {metrics.added_area:.6f}"


def main(argv: Iterable[str] | None = None) -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("iteration", type=int, help="Iteration depth to analyse")
    parser.add_argument(
        "--initial-length",
        type=float,
        default=1.0,
        help="Side length of the initial equilateral triangle (default: 1.0)",
    )
    args = parser.parse_args(list(argv) if argv is not None else None)

    metrics = koch_metrics(args.iteration, initial_length=args.initial_length)
    for line in format_metrics(metrics):
        print(line)


if __name__ == "__main__":
    main()
