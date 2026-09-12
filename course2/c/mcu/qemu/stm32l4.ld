/* Linker script for the Course 2 bare-metal tier — STM32L4 memory map.
 *
 * The same map serves QEMU's b-l475e-iot01a machine (STM32L475VG) and the
 * NUCLEO-L476RG (STM32L476RG): 1 MB of flash at 0x08000000 and 96 KB of SRAM1
 * at 0x20000000.  (Both parts also have 32 KB of SRAM2 at 0x10000000; it is left
 * out on purpose so that every exercise's .data/.bss/heap/stack live in one
 * region and the map file stays easy to read.)
 *
 * Symbols consumed by qemu/startup.c: _estack, _sidata, _sdata, _edata, _sbss,
 * _ebss.  Symbols consumed by newlib-nano's _sbrk (via --specs=nosys.specs):
 * end / __heap_start, __heap_end.  Compare with CubeMX's
 * STM32L476RGTX_FLASH.ld in course3/firmware/ — same idea, more sections.
 */

MEMORY
{
  FLASH (rx)  : ORIGIN = 0x08000000, LENGTH = 1024K
  RAM   (rwx) : ORIGIN = 0x20000000, LENGTH = 96K
}

_estack = ORIGIN(RAM) + LENGTH(RAM);   /* initial MSP: top of SRAM1, full-descending */
_Min_Heap_Size  = 0x1000;              /* 4 KB reserved for newlib's heap */
_Min_Stack_Size = 0x1000;              /* 4 KB reserved for the main stack */

ENTRY(Reset_Handler)

SECTIONS
{
  /* The vector table must be the very first thing in flash: the core reads the
   * initial SP from offset 0 and the reset vector from offset 4.  KEEP() stops
   * --gc-sections from discarding it — nothing references it by name. */
  .isr_vector :
  {
    . = ALIGN(4);
    KEEP(*(.isr_vector))
    . = ALIGN(4);
  } > FLASH

  .text :
  {
    . = ALIGN(4);
    *(.text .text.*)
    *(.glue_7 .glue_7t)          /* ARM/Thumb interworking veneers */
    *(.eh_frame)
    KEEP(*(.init))
    KEEP(*(.fini))
    . = ALIGN(4);
    _etext = .;
  } > FLASH

  .rodata :
  {
    . = ALIGN(4);
    *(.rodata .rodata.*)
    . = ALIGN(4);
  } > FLASH

  .ARM.extab : { *(.ARM.extab* .gnu.linkonce.armextab.*) } > FLASH
  .ARM       : { __exidx_start = .; *(.ARM.exidx*) __exidx_end = .; } > FLASH

  /* C runtime init/fini arrays — empty in plain C, harmless to keep. */
  .preinit_array :
  {
    PROVIDE_HIDDEN(__preinit_array_start = .);
    KEEP(*(.preinit_array*))
    PROVIDE_HIDDEN(__preinit_array_end = .);
  } > FLASH
  .init_array :
  {
    PROVIDE_HIDDEN(__init_array_start = .);
    KEEP(*(SORT(.init_array.*)))
    KEEP(*(.init_array*))
    PROVIDE_HIDDEN(__init_array_end = .);
  } > FLASH
  .fini_array :
  {
    PROVIDE_HIDDEN(__fini_array_start = .);
    KEEP(*(SORT(.fini_array.*)))
    KEEP(*(.fini_array*))
    PROVIDE_HIDDEN(__fini_array_end = .);
  } > FLASH

  /* Initialized data: lives in RAM at run time, but its initial values are
   * stored in flash right after .rodata.  _sidata is the flash copy; startup.c
   * copies [_sidata, _sidata + (_edata - _sdata)) to [_sdata, _edata). */
  _sidata = LOADADDR(.data);
  .data :
  {
    . = ALIGN(4);
    _sdata = .;
    *(.data .data.*)
    . = ALIGN(4);
    _edata = .;
  } > RAM AT > FLASH

  /* Zero-initialized data: occupies RAM only; startup.c zeroes it. */
  .bss :
  {
    . = ALIGN(4);
    _sbss = .;
    __bss_start__ = _sbss;
    *(.bss .bss.*)
    *(COMMON)
    . = ALIGN(4);
    _ebss = .;
    __bss_end__ = _ebss;
  } > RAM

  /* Uninitialized data that survives a reset — startup.c does NOT touch it. */
  .noinit (NOLOAD) :
  {
    . = ALIGN(4);
    *(.noinit .noinit.*)
    . = ALIGN(4);
  } > RAM

  /* Heap (grows up from `end`) and stack (grows down from _estack) share the
   * rest of RAM.  The section is only a link-time check that both minimums fit;
   * the map file shows exactly how much is left between them. */
  ._user_heap_stack :
  {
    . = ALIGN(8);
    PROVIDE(end = .);
    PROVIDE(_end = .);
    PROVIDE(__heap_start = .);
    . = . + _Min_Heap_Size;
    PROVIDE(__heap_end = .);
    . = . + _Min_Stack_Size;
    . = ALIGN(8);
  } > RAM

  /DISCARD/ : { *(.ARM.attributes) *(.comment) }
}
