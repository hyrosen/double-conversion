include(bde_package)
include(bde_utils)
include(bde_struct)
include(bde_uor)
include(bde_ufid)

bde_prefixed_override(fpconvert process_standalone_package)
function(fpconvert_process_standalone_package retUOR listFile installOpts)
    bde_assert_no_extra_args()

    get_filename_component(listDir ${listFile} DIRECTORY)
    get_filename_component(rootDir ${listDir} DIRECTORY)

    set(TARGET fpconvert)

    set(headers
        ${rootDir}/double-conversion/bignum-dtoa.h
        ${rootDir}/double-conversion/bignum.h
        ${rootDir}/double-conversion/cached-powers.h
        ${rootDir}/double-conversion/diy-fp.h
        ${rootDir}/double-conversion/double-conversion.h
        ${rootDir}/double-conversion/fast-dtoa.h
        ${rootDir}/double-conversion/fixed-dtoa.h
        ${rootDir}/double-conversion/ieee.h
        ${rootDir}/double-conversion/strtod.h
        ${rootDir}/double-conversion/utils.h
    )

    set(sources
        ${rootDir}/double-conversion/bignum-dtoa.cc
        ${rootDir}/double-conversion/bignum.cc
        ${rootDir}/double-conversion/cached-powers.cc
        ${rootDir}/double-conversion/diy-fp.cc
        ${rootDir}/double-conversion/double-conversion.cc
        ${rootDir}/double-conversion/fast-dtoa.cc
        ${rootDir}/double-conversion/fixed-dtoa.cc
        ${rootDir}/double-conversion/strtod.cc
    )

    bde_ufid_add_library(${TARGET} ${sources} ${headers})

    # Set up PIC
    # This code does not work in 3.8, but will be fixed in later versions.
    # The -fPIC flag is set explicitely in the compile options for now.
    if(${bde_ufid_is_shr} OR ${bde_ufid_is_pic})
        set_target_properties(${TARGET} PROPERTIES POSITION_INDEPENDENT_CODE 1)
    endif()

    # Common compile definitions.
    target_compile_definitions(
        ${TARGET}
        PRIVATE
    )

    target_compile_options(
        ${TARGET}
        PRIVATE
            $<$<C_COMPILER_ID:AppleClang>:
                $<$<OR:${bde_ufid_is_shr},${bde_ufid_is_pic}>: -fPIC>
            >
            $<$<C_COMPILER_ID:Clang>:
                $<$<OR:${bde_ufid_is_shr},${bde_ufid_is_pic}>: -fPIC>
            >
            $<$<C_COMPILER_ID:GNU>:
                -std=gnu99
                $<$<OR:${bde_ufid_is_shr},${bde_ufid_is_pic}>: -fPIC>
            >
            $<$<C_COMPILER_ID:SunPro>:
                -temp=/bb/data/tmp
                $<$<OR:${bde_ufid_is_shr},${bde_ufid_is_pic}>: -xcode=pic32>
            >
            $<$<C_COMPILER_ID:XL>:
                $<$<OR:${bde_ufid_is_shr},${bde_ufid_is_pic}>: -qpic>
                $<${bde_ufid_is_mt}: -qthreaded>
            >
    )

    target_compile_definitions(
        ${TARGET}
        PRIVATE
    )

    target_compile_definitions(
        ${TARGET}
        PRIVATE
            $<${bde_ufid_is_mt}: _REENTRANT>
            $<$<C_COMPILER_ID:AppleClang>:
                "LINUX"
                "efi2"
            >
            $<$<C_COMPILER_ID:Clang>:
                "USE_REAL_MALLOC"
                "LINUX"
                "efi2"
            >
            $<$<C_COMPILER_ID:GNU>:
                "USE_REAL_MALLOC"
                "LINUX"
                "efi2"
            >
            $<$<C_COMPILER_ID:MSVC>:
                "WINNT"
                "WINDOWS"
                "WNT"
                $<${CMAKE_CL_64}:
                    "ia32"
                >
            >
            $<$<C_COMPILER_ID:SunPro>:
                "SUNOS"
                "efi2"
                "__linux"
                "__float80=double"
                "BID_THREAD="
            >
            $<$<C_COMPILER_ID:XL>:
                "LINUX"
                "efi2"
                "__linux"
                "__QNX__"
                "__thread="
            >
    )

    bde_struct_get_field(component ${installOpts} COMPONENT)
    bde_struct_get_field(includeInstallDir ${installOpts} INCLUDE_DIR)
    install(
        FILES ${headers}
        COMPONENT "${component}-headers"
        DESTINATION "${includeInstallDir}/${TARGET}"
    )

    target_include_directories(
        ${TARGET}
        PUBLIC
            $<BUILD_INTERFACE:${rootDir}>
    )

    # Don't create interfaces to only use our own build/usage reqiurements
    bde_struct_create(
        uor
        BDE_UOR_TYPE
        NAME "${TARGET}"
        TARGET "${TARGET}"
    )
    standalone_package_install(${uor} ${listFile} ${installOpts})

    # Meta data install
    install(
        DIRECTORY ${listDir}
        COMPONENT "${component}-meta"
        DESTINATION "share/bdemeta/thirdparty/${component}"
        EXCLUDE_FROM_ALL
    )

    bde_return(${uor})
endfunction()
