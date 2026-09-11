//! Toolchain check for the RTIC tier: builds without a board
//! (`cargo build --release --bin smoke-rtic` from `rust/rtic/`); with the NUCLEO
//! attached, `cargo run --release --bin smoke-rtic` flashes it and logs once over RTT.
#![no_std]
#![no_main]

use defmt_rtt as _;
use panic_probe as _;

#[rtic::app(device = stm32l4::stm32l4x6, peripherals = true)]
mod app {
    #[shared]
    struct Shared {}

    #[local]
    struct Local {}

    #[init]
    fn init(_cx: init::Context) -> (Shared, Local) {
        defmt::info!("course2/rust/rtic OK — RTIC 2 on the STM32L476RG");
        (Shared {}, Local {})
    }

    #[idle]
    fn idle(_cx: idle::Context) -> ! {
        loop {
            cortex_m::asm::wfi();
        }
    }
}
