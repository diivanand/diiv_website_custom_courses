"""Toolchain check for the Python workspace: `uv run python course2/python/src/smoke.py`."""
import importlib
import sys


def main() -> None:
    print(f"python {sys.version.split()[0]}")
    for name in ("numpy", "scipy", "matplotlib", "pandas", "sklearn"):
        try:
            print(f"{name:12s} {importlib.import_module(name).__version__}")
        except ImportError:
            print(f"{name:12s} not installed")
    try:
        import torch
    except ImportError:
        print("torch        not installed (uv sync --group ml)")
        return
    if torch.cuda.is_available():
        device = f"cuda ({torch.cuda.get_device_name(0)})"
    elif getattr(torch.backends, "mps", None) is not None and torch.backends.mps.is_available():
        device = "mps"
    else:
        device = "cpu"
    print(f"torch        {torch.__version__} — device: {device}")


if __name__ == "__main__":
    main()
