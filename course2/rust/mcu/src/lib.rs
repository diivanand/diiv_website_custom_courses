//! Course 2 — bare-metal and RTOS tiers on the STM32L476RG.
//!
//! Exercises are `#![no_std] #![no_main]` binaries in `src/bin/ex-M-N.rs`,
//! built with `cargo build --release --bin ex-M-N` from this directory and
//! flashed with `cargo run --release --bin ex-M-N` (probe-rs).  Building never
//! needs the board; running does.  This library ships empty on purpose.
#![no_std]
