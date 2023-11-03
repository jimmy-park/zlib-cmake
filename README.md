# zlib-cmake

[![CI](https://github.com/jimmy-park/zlib-cmake/actions/workflows/ci.yaml/badge.svg)](https://github.com/jimmy-park/zlib-cmake/actions/workflows/ci.yaml)
[![CodeQL](https://github.com/jimmy-park/zlib-cmake/actions/workflows/codeql.yaml/badge.svg)](https://github.com/jimmy-park/zlib-cmake/actions/workflows/codeql.yaml)

Build [zlib](https://github.com/madler/zlib) using modern CMake and override the [`FindZLIB`](https://cmake.org/cmake/help/latest/module/FindZLIB.html) module

## CMake Options

| Option         | Default | Description                    |
| -------------- | ------- | ------------------------------ |
| `ZLIB_INSTALL` | `OFF`   | Install zlib and CMake targets |
| `ZLIB_TEST`    | `OFF`   | Enable testing and build tests |

- `CPM_SOURCE_CACHE`
  - Set to `/path/to/cache` to reuse downloaded source code

## Usage

### Build

```sh
cmake --list-presets all                    # List all CMake presets
cmake --preset windows                      # Configure
cmake --build --preset windows              # Build
ctest --preset windows                      # Test
cmake --build --preset windows -t install   # Install
```

### Integration

```CMake
include(FetchContent)

# Set options before FetchContent_MakeAvailable()
set(ZLIB_TEST ON)

FetchContent_Declare(
    zlib-cmake
    URL https://github.com/jimmy-park/zlib-cmake/archive/main.zip
)

# This line must be preceded before find_package(ZLIB)
FetchContent_MakeAvailable(zlib-cmake)

# If you're using CPM.cmake
# CPMAddPackage(
#     NAME zlib-cmake
#     URL https://github.com/jimmy-park/zlib-cmake/archive/main.tar.gz
#     OPTIONS "ZLIB_TEST ON"
# )

# Use same target as FindZLIB module
add_executable(main main.cpp)
target_link_libraries(main PRIVATE ZLIB::ZLIB)
```
