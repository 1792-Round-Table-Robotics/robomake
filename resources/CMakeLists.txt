# To turn on append "-Dtesting=ON" to CMake command
option(testing "Build and run all tests." OFF) # Makes testing option avaliable

# Make sure CMake finds our FindWPILib.cmake script
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/")
# Export compile_commands.json so VSCode knows the include paths of all the library headers (including WPILib)
set(CMAKE_EXPORT_COMPILE_COMMANDS true)
# Set our C++ standard to C++14 (latest version that the FRC GCC compiler can support)
set (CMAKE_CXX_STANDARD 14)

# Create our SOURCES variable with all our C++ source files to compile
# NOTICE: You must add all your source files to this variable! Just add a new line and the path for each file
set (SOURCES 
    src/Robot.cpp
)

# Find the WPILib files, using FindWPILib.cmake
find_package(WPILib REQUIRED)
# Tell CMake to use the WPILib header files the script found.
include_directories(${WPILib_INCLUDE_DIRS})

# Add our code as an executable
add_executable (Robot ${SOURCES})
# Make sure our header files (like Robot.h) are included
target_include_directories(Robot PRIVATE ${PROJECT_SOURCE_DIR}/include)
# Link our executable with the WPILib libraries
target_link_libraries (Robot ${WPILib_LIBRARIES})