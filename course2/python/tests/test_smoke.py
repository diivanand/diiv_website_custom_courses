"""Toolchain check: the core scientific stack imports and reports a version."""


def test_core_stack_imports():
    import matplotlib
    import numpy
    import scipy

    for mod in (numpy, scipy, matplotlib):
        assert isinstance(mod.__version__, str) and mod.__version__
