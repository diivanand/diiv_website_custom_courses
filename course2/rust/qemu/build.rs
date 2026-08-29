// Build scripts run on the host; the crate-wide expect_used lint is for board code.
#![allow(clippy::expect_used)]
//! Put `memory.x` where cortex-m-rt's `link.x` can find it, and re-link when it changes.
use std::{env, fs, path::PathBuf};

fn main() {
    let out = PathBuf::from(env::var("OUT_DIR").expect("OUT_DIR is set by cargo"));
    fs::copy("memory.x", out.join("memory.x")).expect("copy memory.x");
    println!("cargo:rustc-link-search={}", out.display());
    println!("cargo:rerun-if-changed=memory.x");
}
