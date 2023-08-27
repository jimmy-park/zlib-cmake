cmake_minimum_required(VERSION 3.24)

project(
    zlib-cmake
    VERSION 1.3
    DESCRIPTION "Build zlib using modern CMake"
    HOMEPAGE_URL "https://github.com/jimmy-park/zlib-cmake"
    LANGUAGES C
)

include(CheckIncludeFile)
include(FetchContent)
include(cmake/GetCPM.cmake)

# Custom options
option(ZLIB_ENABLE_LFS "Enable Large-File Support (LFS) on 32-bit system" OFF)
option(ZLIB_INSTALL "Install zlib and CMake targets" OFF)
option(ZLIB_TEST "Enable testing and build tests" OFF)

if(DEFINED ZLIB_USE_STATIC_LIBS)
    if(ZLIB_USE_STATIC_LIBS AND BUILD_SHARED_LIBS)
        message(WARNING "ZLIB_USE_STATIC_LIBS is ON, but zlib will be built as a shared library")
    elseif(NOT ZLIB_USE_STATIC_LIBS AND NOT BUILD_SHARED_LIBS)
        message(WARNING "ZLIB_USE_STATIC_LIBS is OFF, but zlib will be built as a static library")
    endif()
endif()

# Download zlib source
CPMAddPackage(
    NAME zlib-source
    DOWNLOAD_ONLY ON
    URL https://github.com/madler/zlib/archive/v${PROJECT_VERSION}.tar.gz
    URL_HASH SHA256=b5b06d60ce49c8ba700e0ba517fa07de80b5d4628a037f4be8ad16955be7a7c0
)

# Modify zlib source
check_include_file(unistd.h Z_HAVE_UNISTD_H)
file(REMOVE
    ${zlib-source_SOURCE_DIR}/CMakeLists.txt
    ${zlib-source_SOURCE_DIR}/zconf.h
)
configure_file(
    ${zlib-source_SOURCE_DIR}/zconf.h.cmakein
    ${zlib-source_BINARY_DIR}/zconf.h
    @ONLY
)
file(READ ${zlib-source_SOURCE_DIR}/zutil.c ZUTIL)
string(REPLACE "malloc(items * size)" "malloc((size_t) items * size)" ZUTIL "${ZUTIL}")
file(WRITE ${zlib-source_SOURCE_DIR}/zutil.c "${ZUTIL}")
file(READ ${zlib-source_SOURCE_DIR}/test/infcover.c INFCOVER)
string(REPLACE "%lu" "%zu" INFCOVER "${INFCOVER}")
file(WRITE ${zlib-source_SOURCE_DIR}/test/infcover.c "${INFCOVER}")

# Override find_package(ZLIB)
FetchContent_Declare(
    ZLIB
    SOURCE_DIR ${zlib-source_SOURCE_DIR}
    BINARY_DIR ${zlib-source_BINARY_DIR}
    OVERRIDE_FIND_PACKAGE
)
FetchContent_MakeAvailable(ZLIB)

# Result variables of FindZLIB module
set(ZLIB_INCLUDE_DIRS ${zlib_SOURCE_DIR} ${zlib_BINARY_DIR} CACHE STRING "Override FindZLIB variables" FORCE)
set(ZLIB_LIBRARIES "" CACHE STRING "Override FindZLIB variables" FORCE)
set(ZLIB_FOUND ON CACHE BOOL "Override FindZLIB variables" FORCE)
set(ZLIB_VERSION ${PROJECT_VERSION} CACHE STRING "Override FindZLIB variables" FORCE)

# Legacy variables of FindZLIB module
set(ZLIB_VERSION_STRING ${ZLIB_VERSION} CACHE STRING "Override FindZLIB variables" FORCE)
set(VERSION_LEVEL MAJOR MINOR PATCH TWEAK)

foreach(level IN LISTS VERSION_LEVEL)
    set(ZLIB_VERSION_${level} ${PROJECT_VERSION_${level}} CACHE STRING "Override FindZLIB variables" FORCE)
    set(ZLIB_${level}_VERSION ${PROJECT_VERSION_${level}} CACHE STRING "Override FindZLIB variables" FORCE)
endforeach()

# Create ZLIB target
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

add_library(ZLIB ${ZLIB_SOURCES})
add_library(ZLIB::ZLIB ALIAS ZLIB)
target_sources(ZLIB PUBLIC
    FILE_SET HEADERS
    BASE_DIRS ${ZLIB_INCLUDE_DIRS}
    FILES ${ZLIB_HEADERS}
)
set_target_properties(ZLIB PROPERTIES
    OUTPUT_NAME $<IF:$<BOOL:${UNIX}>,z,zlib>
    WINDOWS_EXPORT_ALL_SYMBOLS ON
    ARCHIVE_OUTPUT_DIRECTORY ${zlib_BINARY_DIR}
    COMPILE_PDB_OUTPUT_DIRECTORY ${zlib_BINARY_DIR}
    LIBRARY_OUTPUT_DIRECTORY ${zlib_BINARY_DIR}
    PDB_OUTPUT_DIRECTORY ${zlib_BINARY_DIR}
    RUNTIME_OUTPUT_DIRECTORY ${zlib_BINARY_DIR}
    DEBUG_POSTFIX d
    DEFINE_SYMBOL ZLIB_INTERNAL
    VERSION ${ZLIB_VERSION}
    SOVERSION ${ZLIB_VERSION_MAJOR}
)

if(WIN32 AND BUILD_SHARED_LIBS)
    target_compile_definitions(ZLIB PUBLIC ZLIB_DLL)
endif()

if(ZLIB_ENABLE_LFS)
    target_compile_definitions(ZLIB PUBLIC
        _LARGEFILE64_SOURCE
        _FILE_OFFSET_BITS=64
    )
endif()

# Install zlib
if(ZLIB_INSTALL)
    include(CMakePackageConfigHelpers)
    include(GNUInstallDirs)

    write_basic_package_version_file(
        ${CMAKE_CURRENT_BINARY_DIR}/zlib-config-version.cmake
        COMPATIBILITY SameMajorVersion
    )
    install(
        TARGETS ZLIB
        EXPORT zlibTargets
        FILE_SET HEADERS
    )
    export(
        TARGETS ZLIB
        NAMESPACE ZLIB::
        FILE ${CMAKE_CURRENT_BINARY_DIR}/zlib-target.cmake
    )
    install(
        EXPORT zlibTargets
        NAMESPACE ZLIB::
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/zlib
    )
    install(
        FILES
        ${CMAKE_CURRENT_SOURCE_DIR}/cmake/zlib-config.cmake
        ${CMAKE_CURRENT_BINARY_DIR}/zlib-config-version.cmake
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/zlib
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
endif()

if(ZLIB_TEST AND NOT CMAKE_CROSSCOMPILING)
    include(CTest)

    add_executable(example ${zlib_SOURCE_DIR}/test/example.c)
    target_link_libraries(example PRIVATE ZLIB::ZLIB)
    add_test(test_example example)

    add_executable(infcover ${zlib_SOURCE_DIR}/test/infcover.c)
    target_link_libraries(infcover PRIVATE ZLIB::ZLIB)
    add_test(test_infcover infcover)

    add_executable(minigzip ${zlib_SOURCE_DIR}/test/minigzip.c)
    target_link_libraries(minigzip PRIVATE ZLIB::ZLIB)
    file(
        GENERATE OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/$<CONFIG>/test_minigzip.cmake
        CONTENT
        "execute_process(
            COMMAND cmake -E echo hello world
            COMMAND $<TARGET_FILE:minigzip>
            COMMAND $<TARGET_FILE:minigzip> -d
            COMMAND_ERROR_IS_FATAL ANY
        )"
    )
    add_test(
        NAME test_minigzip
        COMMAND cmake -P ${CMAKE_CURRENT_BINARY_DIR}/$<CONFIG>/test_minigzip.cmake
        COMMAND_EXPAND_LISTS
    )

    if(WIN32 AND BUILD_SHARED_LIBS)
        add_custom_command(
            TARGET minigzip POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy_if_different $<TARGET_RUNTIME_DLLS:minigzip> $<TARGET_FILE_DIR:minigzip>
            COMMAND_EXPAND_LISTS
        )
    endif()
endif()
