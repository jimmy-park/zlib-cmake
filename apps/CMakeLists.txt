project(apps LANGUAGES CXX)

find_package(ZLIB REQUIRED)

add_executable(main main.cpp)
target_link_libraries(main PRIVATE ZLIB::ZLIB)

if(BUILD_SHARED_LIBS AND CMAKE_GENERATOR MATCHES "Visual Studio")
    set_target_properties(main PROPERTIES
        VS_DEBUGGER_ENVIRONMENT "PATH=%PATH%;${zlib_BINARY_DIR}/$<CONFIG>"
    )
endif()
