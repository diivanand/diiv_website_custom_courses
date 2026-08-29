"""Make `python/src/` importable from the tests, so `import ex_1_3`-style helpers work."""
import sys
from pathlib import Path

SRC = Path(__file__).resolve().parents[1] / "src"
if str(SRC) not in sys.path:
    sys.path.insert(0, str(SRC))
