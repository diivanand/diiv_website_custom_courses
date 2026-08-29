//! Toolchain check for the host tier: `cargo run --bin smoke-host`.
fn main() {
    println!(
        "course2/rust/host OK — {} {}",
        std::env::consts::ARCH,
        std::env::consts::OS
    );
}
