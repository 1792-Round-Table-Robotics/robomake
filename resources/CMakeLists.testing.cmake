# To turn on append "-DlocalTesting=ON" to CMake command. Make sure you are NOT using the cross-compiler!
option(localTesting "Builds testing code. (Only tests and subsystems)" OFF)

# Make sure CMake finds our FindWPILib.cmake script
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/")
# Export compile_commands.json so VSCode knows the include paths of all the library headers (including WPILib)
set(CMAKE_EXPORT_COMPILE_COMMANDS true)
# Set our C++ standard to C++14 (latest version that the FRC GCC compiler can support)
set (CMAKE_CXX_STANDARD 14)

# ----------- Source Files -----------------------------------------------
# This is a very important Section. If you have trouble understanding, please visit the robomake README at https://github.com/jython234/robomake

# NOTICE: Everytime you add or delete a new source file (.cpp), you MUST modify these lines.
# If you don't, CMake won't know to compile a new file you added, or it will try to compile a file you deleted!

# Robot code source files. This should be anything in src/ that is NOT in "subsystems".
# These are the only files that can call WPILib. They also have access to subsystem code.
set (ROBOT_FILES 
    src/Robot.cpp
)

# Subsystem code source files. These should all be in "subsystems" folder. These can't call WPILib or Robot code.
set (SUBSYSTEM_FILES
    src/subsystems/NumberSubsystem.cpp
)

# Test source files. These use GoogleTest to run test code for the subsystems. They can only access Subsystem code.
set(TEST_FILES
    test/ExampleTest.cpp
)

# ----------- Dependencies -----------------------------------------------

if(NOT localTesting)
    # Find the WPILib files, using FindWPILib.cmake
    find_package(WPILib REQUIRED)
    # Tell CMake to use the WPILib header files the script found.
    include_directories(${WPILib_INCLUDE_DIRS})
endif(NOT localTesting)

# ----------- Google Test -----------------------------------------------
# This portion used from https://github.com/google/googletest/tree/master/googletest#incorporating-into-an-existing-cmake-project

# Download and unpack googletest at configure time
configure_file("${CMAKE_SOURCE_DIR}/cmake/GTest.txt.in" googletest-download/CMakeLists.txt)
execute_process(COMMAND ${CMAKE_COMMAND} -G "${CMAKE_GENERATOR}" .
    RESULT_VARIABLE result
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/googletest-download )
if(result)
    message(FATAL_ERROR "CMake step for googletest failed: ${result}")
endif()
execute_process(COMMAND ${CMAKE_COMMAND} --build .
    RESULT_VARIABLE result
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/googletest-download )
if(result)
    message(FATAL_ERROR "Build step for googletest failed: ${result}")
endif()

# Prevent overriding the parent project's compiler/linker
# settings on Windows
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)

# Add googletest directly to our build. This defines
# the gtest and gtest_main targets.
add_subdirectory(${CMAKE_BINARY_DIR}/googletest-src
                ${CMAKE_BINARY_DIR}/googletest-build
                EXCLUDE_FROM_ALL)

# The gtest/gtest_main targets carry header search path
# dependencies automatically when using CMake 2.8.11 or
# later. Otherwise we have to add them here ourselves.
if (CMAKE_VERSION VERSION_LESS 2.8.11)
    include_directories("${gtest_SOURCE_DIR}/include")
endif()

# ----------- Compiling --------------------------------------------------

# Add our Subsystems code as a library. We do this because we will have the Robot code and Testing code link to this library.
add_library(Subsystems ${SUBSYSTEM_FILES})
# Make sure our header files are included.
target_include_directories(Subsystems PRIVATE ${PROJECT_SOURCE_DIR}/include)
# No need to link to any other libraries, subsystems should not call WPILib as they need to be able to be built natively 
# instead of using the cross-compiler.

# We don't want to build the robot code when testing, as we are NOT using the cross compiler.
# That would cause the build to error because we can't link to WPILib (different architecture).
if(NOT localTesting)
    # Add our Robot code executable.
    add_executable (RobotProgram ${ROBOT_FILES})
    # Make sure our header files (like Robot.h) are included.
    target_include_directories(RobotProgram PRIVATE ${PROJECT_SOURCE_DIR}/include)
    # Link our executable with the WPILib libraries, and the Subsystems code.
    target_link_libraries (RobotProgram Subsystems ${WPILib_LIBRARIES})
endif(NOT localTesting)

# ----------- Tests ------------------------------------------------------
# Add our test executable.
add_executable(SubsystemTests ${TEST_FILES})

# Make sure our header files are included.
target_include_directories(SubsystemTests PRIVATE ${PROJECT_SOURCE_DIR}/include)
# Link with Google Test and the Subsystems code.
target_link_libraries(SubsystemTests gtest gtest_main Subsystems)

if(localTesting)
    enable_testing()

    # Automatically discover all our tests and add them to CTest.
    include(GoogleTest)
    gtest_discover_tests(SubsystemTests)
endif(localTesting)