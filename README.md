# zlib-cmake

[![CI](https://github.com/jimmy-park/zlib-cmake/actions/workflows/ci.yaml/badge.svg)](https://github.com/jimmy-park/zlib-cmake/actions/workflows/ci.yaml)
[![CodeQL](https://github.com/jimmy-park/zlib-cmake/actions/workflows/codeql.yaml/badge.svg)](https://github.com/jimmy-park/zlib-cmake/actions/workflows/codeql.yaml)

Build zlib using modern CMake and override the `FindZLIB` module

## Requirements

- CMake 3.24+ (due to `FetchContent_Declare(OVERRIDE_FIND_PACKAGE)`)

## Configure Options

| Option                        | Type      | Default       | Description                                       |
| ---                           | ---       | ---           | ---                                               |
| `ZLIB_ENABLE_LFS`             | bool      | `OFF`         | Enable Large-File Support (LFS) on 32-bit system  |
| `ZLIB_INSTALL`                | bool      | `OFF`         | Install zlib and CMake targets                    |
| `ZLIB_TEST`                   | bool      | `OFF`         | Enable testing and build tests                    |
| `ZLIB_USE_STATIC_LIBS`        | bool      | `OFF`         | Build zlib as a static library                    |

### Notes

- `ZLIB_USE_STATIC_LIBS`
  - Use the same name as the hint variable of `FindZLIB` module
  - If it is `OFF`, `BUILD_SHARED_LIBS` will determine the type of library
- `CPM_SOURCE_CACHE`
  - Set to `/path/to/cache` to reuse downloaded source code

## Usage

### Build

```sh
git clone https://github.com/jimmy-park/zlib-cmake
cd zlib-cmake

# List all presets
cmake --list-presets all

# Use a configure preset
cmake --preset windows

# Use a build preset
# <configure-preset>-<debug|release>[-clean|install]
cmake --build --preset windows-release
```

### Integration

```CMake
include(FetchContent)

# Set options before FetchContent_MakeAvailable()
set(ZLIB_USE_STATIC_LIBS ON)

FetchContent_Declare(
    zlib-cmake
    URL https://github.com/jimmy-park/zlib-cmake/archive/main.zip
)

# This line must be preceded before find_package(ZLIB)
FetchContent_MakeAvailable(zlib-cmake)

# Use same target as FindZLIB module
add_executable(main main.cpp)
target_link_libraries(main PRIVATE ZLIB::ZLIB)
```

#### Using [CPM.cmake](https://github.com/cpm-cmake/CPM.cmake)

```CMake
set(CPM_SOURCE_CACHE /path/to/cache)

CPMAddPackage(
    NAME    zlib-cmake
    URL     https://github.com/jimmy-park/zlib-cmake/archive/main.zip
    OPTIONS "ZLIB_USE_STATIC_LIBS ON"
)
```
