#!/bin/sh
# run-qemu.sh <qemu-system-arm> <machine> <elf>
# Boots a Course 2 bare-metal ELF in QEMU with semihosting enabled and exits
# with the program's own exit status (main's return value).  A program that
# never calls exit is killed after $COURSE2_QEMU_TIMEOUT seconds (default 60)
# and reported as a failure — an infinite `for (;;)` in a HardFault handler
# then shows up as a timeout rather than a hung terminal.
set -u
qemu="$1"; machine="$2"; elf="$3"
timeout_s="${COURSE2_QEMU_TIMEOUT:-60}"

# macOS has no `timeout`; use perl's alarm, which every Mac has.
perl -e '
  my ($t, @cmd) = @ARGV;
  my $pid = fork();
  if ($pid == 0) { exec @cmd or die "exec: $!"; }
  local $SIG{ALRM} = sub { kill "TERM", $pid; waitpid($pid, 0); print STDERR "run-qemu: timed out after ${t}s\n"; exit 124; };
  alarm $t;
  waitpid($pid, 0);
  exit($? >> 8);
' "$timeout_s" "$qemu" -machine "$machine" -cpu cortex-m4 -nographic \
    -semihosting-config enable=on,target=native -kernel "$elf"
