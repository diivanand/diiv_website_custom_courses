# The course warning set — applied identically in host/, mcu/, rtos/, linux/.
# New diagnostics are triaged like failing tests: fix, or justify in a comment.
# -fno-common rides along: tentative definitions must not silently merge across
# translation units on any tier (Module 1).
set(COURSE2_WARNINGS
    -Wall -Wextra -Wpedantic -Wconversion -Wshadow
    -Wstrict-prototypes -Wundef -Wdouble-promotion -Wformat=2
    -fno-common)
