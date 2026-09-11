//! Toolchain check for the QEMU tier: `cargo run --bin smoke-qemu` (from `rust/qemu/`).
#![no_std]
#![no_main]

use cortex_m_rt::entry;
use lm3s6965 as _; // the PAC supplies the vector table: every bin in this crate needs this line
use cortex_m_semihosting::{debug, hprintln};
use panic_halt as _;

#[entry]
fn main() -> ! {
    hprintln!("course2/rust/qemu OK — hello from thumbv7m-none-eabi in QEMU");
    debug::exit(debug::EXIT_SUCCESS);
    loop {
        cortex_m::asm::wfi(); // not reached under QEMU; on hardware, sleep instead of spinning
    }
}
