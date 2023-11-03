include(CheckCSourceCompiles)
include(CheckFunctionExists)
include(CheckIncludeFile)
include(CheckSymbolExists)
include(CheckTypeSize)

# Check for Large-File Support (LFS)
set(CMAKE_REQUIRED_DEFINITIONS -D_LARGEFILE64_SOURCE=1)
check_type_size(off64_t OFF64_T)
set(ZLIB_HAVE_OFF64_T ${HAVE_OFF64_T})
unset(CMAKE_REQUIRED_DEFINITIONS)

if(ZLIB_HAVE_OFF64_T)
    set(ZLIB_HAVE_FSEEKO ON)
else()
    # Check for fseeko()
    check_symbol_exists(fseeko stdio.h ZLIB_HAVE_FSEEKO)
endif()

# Check for strerror()
check_symbol_exists(strerror string.h ZLIB_HAVE_STRERROR)

# Check for unistd.h
check_include_file(unistd.h ZLIB_HAVE_UNISTD_H)

# Check for stdarg.h
check_include_file(stdarg.h ZLIB_HAVE_STDARG_H)

# Check for visibility
check_c_source_compiles(
    "#define ZLIB_INTERNAL __attribute__((visibility (\"hidden\")))
    int ZLIB_INTERNAL foo;
    int main() { return 0; }"
    ZLIB_HAVE_HIDDEN
)
