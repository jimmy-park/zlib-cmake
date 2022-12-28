cmake_minimum_required(VERSION 3.24)

project(
    zlib-cmake
    VERSION 0.1.0
    DESCRIPTION "Override CMake's FindZLIB module"
    HOMEPAGE_URL "https://github.com/jimmy-park/zlib-cmake"
    LANGUAGES C
)

include(FetchContent)
include(GNUInstallDirs)
include(cmake/GetCPM.cmake)

CPMAddPackage(
    NAME zlib-source
    DOWNLOAD_ONLY ON
    URL https://github.com/madler/zlib/archive/v1.2.13.tar.gz
    URL_HASH SHA256=1525952a0a567581792613a9723333d7f8cc20b87a81f920fb8bc7e3f2251428
)
file(REMOVE ${zlib-source_SOURCE_DIR}/CMakeLists.txt)
configure_file(${zlib-source_SOURCE_DIR}/zconf.h.cmakein ${zlib-source_BINARY_DIR}/zconf.h @ONLY)

FetchContent_Declare(
    ZLIB
    SOURCE_DIR ${zlib-source_SOURCE_DIR}
    BINARY_DIR ${zlib-source_BINARY_DIR}
    OVERRIDE_FIND_PACKAGE
)
FetchContent_MakeAvailable(ZLIB)

set(CMAKE_CURRENT_BINARY_DIR ${zlib_BINARY_DIR})

set(ZLIB_HEADERS
    ${zlib_BINARY_DIR}/zconf.h
    ${zlib_SOURCE_DIR}/zlib.h
)
set(ZLIB_SOURCES
    ${zlib_SOURCE_DIR}/adler32.c
    ${zlib_SOURCE_DIR}/compress.c
    ${zlib_SOURCE_DIR}/crc32.c
    ${zlib_SOURCE_DIR}/crc32.h
    ${zlib_SOURCE_DIR}/deflate.c
    ${zlib_SOURCE_DIR}/deflate.h
    ${zlib_SOURCE_DIR}/gzclose.c
    ${zlib_SOURCE_DIR}/gzguts.h
    ${zlib_SOURCE_DIR}/gzlib.c
    ${zlib_SOURCE_DIR}/gzread.c
    ${zlib_SOURCE_DIR}/gzwrite.c
    ${zlib_SOURCE_DIR}/infback.c
    ${zlib_SOURCE_DIR}/inffast.c
    ${zlib_SOURCE_DIR}/inffast.h
    ${zlib_SOURCE_DIR}/inffixed.h
    ${zlib_SOURCE_DIR}/inflate.c
    ${zlib_SOURCE_DIR}/inflate.h
    ${zlib_SOURCE_DIR}/inftrees.c
    ${zlib_SOURCE_DIR}/inftrees.h
    ${zlib_SOURCE_DIR}/trees.c
    ${zlib_SOURCE_DIR}/trees.h
    ${zlib_SOURCE_DIR}/uncompr.c
    ${zlib_SOURCE_DIR}/zutil.c
    ${zlib_SOURCE_DIR}/zutil.h
)

if(ZLIB_USE_STATIC_LIBS)
    set(ZLIB_LIBRARY_TYPE STATIC)
else()
    set(ZLIB_LIBRARY_TYPE "")
endif()

add_library(zlib ${ZLIB_LIBRARY_TYPE} ${ZLIB_SOURCES})
add_library(ZLIB::ZLIB ALIAS zlib)
target_sources(zlib PUBLIC
    FILE_SET HEADERS
    BASE_DIRS ${zlib_SOURCE_DIR} ${zlib_BINARY_DIR}
    FILES ${ZLIB_HEADERS}
)
set_target_properties(zlib PROPERTIES
    OUTPUT_NAME $<IF:$<BOOL:${UNIX}>,z,zlib>
    WINDOWS_EXPORT_ALL_SYMBOLS ON
    ARCHIVE_OUTPUT_DIRECTORY ${zlib_BINARY_DIR}
    COMPILE_PDB_OUTPUT_DIRECTORY ${zlib_BINARY_DIR}
    LIBRARY_OUTPUT_DIRECTORY ${zlib_BINARY_DIR}
    PDB_OUTPUT_DIRECTORY ${zlib_BINARY_DIR}
    RUNTIME_OUTPUT_DIRECTORY ${zlib_BINARY_DIR}
)
install(
    TARGETS zlib
    FILE_SET HEADERS
)

file(GENERATE OUTPUT output.log CONTENT "$<TARGET_FILE_NAME:zlib>")

# Provide result variables of FindZLIB module
set(ZLIB_INCLUDE_DIRS ${zlib_SOURCE_DIR} ${zlib_BINARY_DIR} CACHE STRING "Override FindZLIB variables" FORCE)
set(ZLIB_LIBRARIES "" CACHE STRING "Override FindZLIB variables" FORCE)
set(ZLIB_FOUND ON CACHE BOOL "Override FindZLIB variables" FORCE)

if(PROJECT_IS_TOP_LEVEL)
    add_subdirectory(apps)
endif()