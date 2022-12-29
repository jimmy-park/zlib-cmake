cmake_minimum_required(VERSION 3.24)

project(
    zlib-cmake
    VERSION 0.1.0
    DESCRIPTION "Build zlib using modern CMake"
    HOMEPAGE_URL "https://github.com/jimmy-park/zlib-cmake"
    LANGUAGES C
)

include(FetchContent)
include(GNUInstallDirs)
include(cmake/GetCPM.cmake)

# Information of latest zlib release
set(ZLIB_LATEST_VERSION 1.2.13 CACHE INTERNAL "zlib version of latest release")
set(ZLIB_LATEST_SHA256 1525952a0a567581792613a9723333d7f8cc20b87a81f920fb8bc7e3f2251428 CACHE INTERNAL "Hash of archived zlib release")

# Override hint variable to select the type of library
option(ZLIB_USE_STATIC_LIBS "Build zlib a static library" OFF)

# Download zlib source
CPMAddPackage(
    NAME zlib-source
    DOWNLOAD_ONLY ON
    URL https://github.com/madler/zlib/archive/v${ZLIB_LATEST_VERSION}.tar.gz
    URL_HASH SHA256=${ZLIB_LATEST_SHA256}
)

# Modify zlib source
file(REMOVE
    ${zlib-source_SOURCE_DIR}/CMakeLists.txt
    ${zlib-source_SOURCE_DIR}/zconf.h
)
configure_file(
    ${zlib-source_SOURCE_DIR}/zconf.h.cmakein
    ${zlib-source_BINARY_DIR}/zconf.h
    @ONLY
)

# Override find_package(ZLIB)
FetchContent_Declare(
    ZLIB
    SOURCE_DIR ${zlib-source_SOURCE_DIR}
    BINARY_DIR ${zlib-source_BINARY_DIR}
    OVERRIDE_FIND_PACKAGE
)
FetchContent_MakeAvailable(ZLIB)

set(ZLIB_INCLUDE_DIRS ${zlib_SOURCE_DIR} ${zlib_BINARY_DIR} CACHE STRING "Override FindZLIB variables" FORCE)
set(ZLIB_LIBRARIES "" CACHE STRING "Override FindZLIB variables" FORCE)
set(ZLIB_FOUND ON CACHE BOOL "Override FindZLIB variables" FORCE)

string(REPLACE "." ";" ZLIB_LATEST_VERSION_LIST ${ZLIB_LATEST_VERSION})
list(GET ZLIB_LATEST_VERSION_LIST 0 ZLIB_LATEST_VERSION_MAJOR)
list(GET ZLIB_LATEST_VERSION_LIST 1 ZLIB_LATEST_VERSION_MINOR)
list(GET ZLIB_LATEST_VERSION_LIST 2 ZLIB_LATEST_VERSION_PATCH)

set(ZLIB_VERSION_STRING ${ZLIB_LATEST_VERSION} CACHE STRING "Override FindZLIB variables" FORCE)
set(ZLIB_VERSION_MAJOR ${ZLIB_LATEST_VERSION_MAJOR} CACHE STRING "Override FindZLIB variables" FORCE)
set(ZLIB_VERSION_MINOR ${ZLIB_LATEST_VERSION_MINOR} CACHE STRING "Override FindZLIB variables" FORCE)
set(ZLIB_VERSION_PATCH ${ZLIB_LATEST_VERSION_PATCH} CACHE STRING "Override FindZLIB variables" FORCE)
set(ZLIB_VERSION_TWEAK "" CACHE STRING "Override FindZLIB variables" FORCE)

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
    BASE_DIRS ${ZLIB_INCLUDE_DIRS}
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

# Install zlib
install(
    TARGETS zlib
    FILE_SET HEADERS
)
configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/zlib.pc.in
    ${zlib_BINARY_DIR}/zlib.pc
    @ONLY
)
install(
    FILES ${zlib_BINARY_DIR}/zlib.pc
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig
)

if(PROJECT_IS_TOP_LEVEL)
    add_subdirectory(apps)
endif()