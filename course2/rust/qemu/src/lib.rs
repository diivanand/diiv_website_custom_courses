//! Course 2 — bare-metal tier, simulated (QEMU lm3s6965evb).
//!
//! Exercises are `#![no_std] #![no_main]` binaries in `src/bin/ex-M-N.rs`,
//! booted with `cargo run --bin ex-M-N` from this directory.  This library
//! ships empty on purpose.
#![no_std]
//!
//! The `lm3s6965` PAC is a dependency (for RTIC's `device = lm3s6965`), which switches
//! `cortex-m-rt` to device mode: **every binary must contain `use lm3s6965 as _;`** so the
//! interrupt vector table is linked, or the link fails with "The interrupt vectors are missing".
