## --------------------------------------------------------------------
## find android sdk

# List of possible Android SDK paths
set(possible_sdk_paths
    ~/Library/Developer/Xamarin/android-sdk-macosx  # Mac / Visual Studio for Mac
    ~/Library/Android/sdk                           # Mac / Android Studio
    ~/Android/Sdk                                   # Ubuntu / Android Studio (Software Center)
    /usr/lib/android-sdk                            # Ubuntu / apt install android-sdk
    $ENV{ProgramFiles\(x86\)}/Android/android-sdk     # Windows / Visual Studio 2022
    $ENV{LOCALAPPDATA}/Android/sdk                  # Windows / Android Studio
)

# Find the Android SDK path
foreach(path IN LISTS possible_sdk_paths)
    # convert to absolute path
    get_filename_component(absolute_path "${path}" ABSOLUTE)
    if(EXISTS "${absolute_path}")
        set(android_sdk_path "${absolute_path}")
        break()
    endif()
endforeach()

if(NOT android_sdk_path)
    message(FATAL_ERROR "Could not find Android SDK in any of the specified paths")
else()
    message("Android SDK  : ${android_sdk_path}")
endif()

## --------------------------------------------------------------------
## find android ndk

# Get a list of all NDK versions
if(EXISTS "${android_sdk_path}/ndk-bundle")
    set(android_ndk_path "${android_sdk_path}/ndk-bundle")
else()
    file(GLOB ndk_versions LIST_DIRECTORIES true "${android_sdk_path}/ndk/*")

    list(LENGTH ndk_versions ndk_versions_length)
    if(ndk_versions_length EQUAL 0)
        message(FATAL_ERROR "Could not find Android NDK in any of the specified paths")
    endif()

    # Sort the list in descending order
    list(SORT ndk_versions ORDER DESCENDING)

    # Get the latest NDK version
    list(GET ndk_versions 0 android_ndk_path)
endif()

if(NOT android_ndk_path)
    message(FATAL_ERROR "Could not find Android NDK in any of the specified paths")
else()
    message("Android NDK  : ${android_ndk_path}")
endif()

## --------------------------------------------------------------------
## find llvm prebuilt

if(WIN32)
    set(android_ndk_prebuilt "${android_ndk_path}/toolchains/llvm/prebuilt/windows")
elseif(APPLE)
    set(android_ndk_prebuilt "${android_ndk_path}/toolchains/llvm/prebuilt/darwin-x86_64")
elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    set(android_ndk_prebuilt "${android_ndk_path}/toolchains/llvm/prebuilt/linux-x86_64")
endif()

if(NOT android_ndk_prebuilt)
    message(FATAL_ERROR "Could not find Android NDK LLVM Prebuilt in any of the specified paths")
else()
    message("LLVM Prebuilt: ${android_ndk_prebuilt}")
endif()

## --------------------------------------------------------------------
## find clang

# clang
if(WIN32)
    file(GLOB clang_versions LIST_FILES true "${android_ndk_prebuilt}/bin/aarch64-linux-android*-clang.cmd")
else()
    file(GLOB clang_versions LIST_FILES true "${android_ndk_prebuilt}/bin/aarch64-linux-android*-clang")
endif()
list(SORT clang_versions ORDER DESCENDING)
list(GET clang_versions 0 android_clang_path)
message("LLVM clang   : ${android_clang_path}")

# clang++
if(WIN32)
    file(GLOB clangpp_versions LIST_FILES true "${android_ndk_prebuilt}/bin/aarch64-linux-android*-clang++.cmd")
else()
    file(GLOB clangpp_versions LIST_FILES true "${android_ndk_prebuilt}/bin/aarch64-linux-android*-clang++")
endif()
list(SORT clangpp_versions ORDER DESCENDING)
list(GET clangpp_versions 0 android_clangpp_path)
message("LLVM clang++ : ${android_clangpp_path}")

## --------------------------------------------------------------------
## toolchains

# set the target operating system to Android
set(CMAKE_SYSTEM_NAME Android)

# specify the cross compiler
set(CMAKE_ANDROID_NDK  "${android_ndk_path}")
set(CMAKE_C_COMPILER   "${android_clang_path}")
set(CMAKE_CXX_COMPILER "${android_clangpp_path}")

# where is the target environment
set(CMAKE_FIND_ROOT_PATH ${CMAKE_ANDROID_NDK})

# search for programs in the build host directories
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)

# for libraries and headers in the target directories
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

