# Dump machine specs for Clang and extract target triple
execute_process(
    COMMAND ${CMAKE_C_COMPILER} ${CMAKE_C_FLAGS} -dumpmachine
    OUTPUT_VARIABLE CMAKE_C_COMPILER_TARGET_TRIPLE
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

# Check if the triple contains "darwin": this shall indicate that
# an Apple compiler or cross-compiler is used.
string(FIND "${CMAKE_C_COMPLILER_TARGET_TRIPLE}" "darwin" found_index)

if(NOT found_index EQUAL -1)
    set(CMAKE_C_COMPILER_TARGET_DARWIN TRUE)
else()
    set(CMAKE_C_COMPILER_TARGET_DARWIN FALSE)
endif()
