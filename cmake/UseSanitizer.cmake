
if(MSVC)
    if("${ZLIB_SANITIZE}" STREQUAL "address")
        string(REPLACE "/RTC1" "" CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG}")
        string(REPLACE "/RTC1" "" CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG}")
        add_compile_options(/fsanitize=address /Zi)
        add_link_options(
            /INCREMENTAL:NO
            $<$<CONFIG:Release>:/DEBUG>
        )
    endif()
else()
    if(NOT "${ZLIB_SANITIZE}" STREQUAL "")
        add_compile_options(-fno-omit-frame-pointer)
        add_compile_options(-fsanitize=${ZLIB_SANITIZE})
        add_link_options(-fsanitize=${ZLIB_SANITIZE})
    endif()
endif()
