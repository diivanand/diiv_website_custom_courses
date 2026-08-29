//! Toolchain check for the MCU tier: builds without a board
//! (`cargo build --release --bin smoke-mcu` from `rust/mcu/`); with the NUCLEO
//! attached, `cargo run --release --bin smoke-mcu` flashes it and blinks LD2 (PA5).
#![no_std]
#![no_main]

use defmt::info;
use defmt_rtt as _;
use embassy_executor::Spawner;
use embassy_stm32::gpio::{Level, Output, Speed};
use embassy_time::Timer;
use panic_probe as _;

#[embassy_executor::main]
async fn main(_spawner: Spawner) {
    let p = embassy_stm32::init(Default::default());
    info!("course2/rust/mcu OK — STM32L476RG up");

    let mut led = Output::new(p.PA5, Level::Low, Speed::Low); // LD2 on the NUCLEO-L476RG
    loop {
        led.set_high();
        Timer::after_millis(500).await;
        led.set_low();
        Timer::after_millis(500).await;
    }
}
