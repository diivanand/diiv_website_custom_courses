# The course warning set — applied identically in host/, mcu/, linux/.
# New diagnostics are triaged like failing tests: fix, or justify in a comment.
set(COURSE2_WARNINGS
    -Wall -Wextra -Wpedantic -Wconversion -Wshadow
    -Wstrict-prototypes -Wundef -Wdouble-promotion -Wformat=2)
