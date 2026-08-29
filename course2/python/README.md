# Course 2 — Python workspace (Modules 1–3)

Scientific-Python track of [Course 2](https://www.diiv.io/course2/): NumPy/SciPy/Matplotlib (M1),
processing / statistics / classical-ML libraries and the Python↔C/Rust bridge (M2), PyTorch and
deployment to the edge (M3). Everything uses the **repo-root uv project** (Python 3.13) — there is
no separate environment here.

```
python/
  README.md
  src/ex-M-N.py            # scripts
  notebooks/ex-M-N.ipynb   # notebooks
  tests/test_ex_M_N.py     # pytest; conftest.py puts src/ on sys.path
  artifacts/ex-M-N.npz     # saved reference artifacts (np.savez) the C/Rust versions are checked against
```

## Run (from the repo root)

```sh
uv sync                                           # core: numpy/scipy/matplotlib/pandas/scikit-learn/pytest/…
uv sync --group ml                                # + torch/torchaudio/torchvision/onnx/onnxruntime (heavy)
uv run python course2/python/src/smoke.py         # prints library versions + the torch device if installed
uv run python course2/python/src/ex-1-3.py        # a script exercise
uv run jupyter lab                                # notebooks (open python/notebooks/)
uv run pytest course2/python/tests                # every test_ex_M_N.py
```

Device-side Python (CuPy, TensorRT, `tflite-runtime` on the Jetson; `onnxruntime` on the Pi) is
platform-specific — see `../../course3/docs/edge-setup.md`.

## Conventions

- One script or notebook per exercise, named `ex-M-N`; the module's write-up is `../mM/notes.md`.
- Every exercise ends by saving the **reference artifact** the C/Rust modules are later checked
  against — `np.save`/`np.savez` into `artifacts/ex-M-N.npz`, plus the tolerance you chose for
  `np.testing.assert_allclose` (recorded in `mM/notes.md`).
- `src/`, `notebooks/`, and `artifacts/` ship empty (only `smoke.py`); that is the coursework.
