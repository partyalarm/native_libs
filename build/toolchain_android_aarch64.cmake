## --------------------------------------------------------------------
## find android sdk

# List of possible Android SDK paths
set(possible_sdk_paths
    ~/Library/Developer/Xamarin/android-sdk-macosx # Visual Studio for Mac
    ~/Library/Android/sdk   # Android Studio (Mac)
    ~/Android/Sdk           # Android Studio (Ubuntu Software Center)
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
    message("Android SDK path: ${android_sdk_path}")
endif()

## --------------------------------------------------------------------
## find android ndk

# Get a list of all NDK versions
file(GLOB ndk_versions LIST_DIRECTORIES true "${android_sdk_path}/ndk/*")

# Sort the list in descending order
list(SORT ndk_versions ORDER DESCENDING)

# Get the latest NDK version
list(GET ndk_versions 0 android_ndk_path)

if(NOT android_ndk_path)
    message(FATAL_ERROR "Could not find Android NDK in any of the specified paths")
else()
    message("Android NDK path: ${android_ndk_path}")
endif()

## --------------------------------------------------------------------
## toolchains

# set the target operating system to Android
set(CMAKE_SYSTEM_NAME Android)

# specify the cross compiler
set(CMAKE_ANDROID_NDK  ${android_ndk_path})
set(CMAKE_C_COMPILER   ${CMAKE_ANDROID_NDK}/toolchains/llvm/prebuilt/darwin-x86_64/bin/aarch64-linux-android34-clang)
set(CMAKE_CXX_COMPILER ${CMAKE_ANDROID_NDK}/toolchains/llvm/prebuilt/darwin-x86_64/bin/aarch64-linux-android34-clang++)

# where is the target environment
set(CMAKE_FIND_ROOT_PATH ${CMAKE_ANDROID_NDK})

# search for programs in the build host directories
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)

# for libraries and headers in the target directories
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

