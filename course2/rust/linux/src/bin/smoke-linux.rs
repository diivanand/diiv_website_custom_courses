//! Toolchain check for the Linux tier: prints a CLOCK_MONOTONIC timestamp.
//! Builds on the Mac (POSIX-common) and on the board.
use std::time::Instant;

fn main() {
    let t0 = Instant::now();
    #[cfg(target_os = "linux")]
    {
        use nix::time::{ClockId, clock_gettime};
        match clock_gettime(ClockId::CLOCK_MONOTONIC) {
            Ok(ts) => println!("CLOCK_MONOTONIC = {}.{:09} s", ts.tv_sec(), ts.tv_nsec()),
            Err(e) => eprintln!("clock_gettime failed: {e}"),
        }
    }
    println!(
        "course2/rust/linux OK — {} {} (Instant elapsed {:?})",
        std::env::consts::ARCH,
        std::env::consts::OS,
        t0.elapsed()
    );
}
