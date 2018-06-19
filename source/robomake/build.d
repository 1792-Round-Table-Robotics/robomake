module robomake.build;

import std.conv;
import std.file;
import std.process;

static import std.stdio;

import core.cpuid : threadsPerCPU;

import robomake.console;
import robomake.cmake : cmakeGenerator;

/// The name of the CMake executable.
enum cmakeExecutable = "cmake";

version(Windows) {
    /// The name of the GNU Make executable to use. On Windows we use MinGW
    enum makeExecutable = "mingw32-make";
} else {
    /// The name of the GNU Make executable to use. On OS's other than Windows we use the default "make".
    enum makeExecutable = "make";
}

/// Directory where normal builds take place.
enum normalBuildDir = "build";
/// Directory where testing builds take place.
enum testsBuildDir = "buildTests";

/// Switches to the correct build directory based on the "testing" parameter, creating it if it doesn't exist.
void switchToBuildDirectory(in bool tests) @safe {
    immutable auto buildDir = tests ? testsBuildDir : normalBuildDir;
    if(!exists(buildDir)) {
        mkdir(buildDir);
    }
    chdir(buildDir);

    debug writeInfo("Switched current directory to \"" ~ buildDir ~ "\"");
}

/// Runs CMake for the current directory.
bool runCMake(in bool tests) @safe {
    immutable auto cmakeCommand = cmakeExecutable ~ " " ~ 
                                    (tests ? "-DlocalTesting=ON" : "-DCMAKE_TOOLCHAIN_FILE=arm-frc-toolchain.cmake") ~
                                    " -G \"" ~ cmakeGenerator ~ "\" ..";

    writeInfo("Running CMake: " ~ cmakeCommand);

    auto pid = spawnShell(cmakeCommand);
    if(wait(pid) != 0) {
        writeError("Build failure!");
        writeError("CMake exited with non-zero exit code!");
        return false;
    }

    return true;
}

/// Runs Make for the current directory.
bool runMake() @safe {
    immutable auto makeCommand = makeExecutable ~ " -j" ~ to!string(threadsPerCPU()); // -j[Number of threads our CPU has]

    writeInfo("Running Make: " ~ makeCommand);
    auto pid = spawnShell(makeCommand);
    if(wait(pid) != 0) {
        writeError("Build failure!");
        writeError("Make exited with non-zero exit code!");

        return false;
    }

    return true;
}

/// Runs the necessary commands to build a project in the current directory
bool buildProject(in bool tests) @safe {
    scope(exit) {
        chdir(".."); // Switch back to previous directory
        writeInfo("Switched back to previous directory.");
    }

    switchToBuildDirectory(tests); // Switch our current directory to the "build" directory

    if(!runCMake(tests)) return false;

    if(!runMake()) return false;

    return true;
}

/// Runs tests for the project
bool runCTest(in bool switchDirectory = true) @system {
    enum testCommand = makeExecutable ~ " all test"; // Compile if any changes were made, then run test

    scope(exit) {
        chdir("..");
        writeInfo("Switched back to previous directory.");
    }

    if(switchDirectory) switchToBuildDirectory(true);

    writeInfo("Running CTest: " ~ testCommand);

    auto pid = spawnShell(testCommand, 
        std.stdio.stdin,
        std.stdio.stdout,
        std.stdio.stdout,
        ["CTEST_OUTPUT_ON_FAILURE" : "1"] // Output the google test information so we can see why the test failed, if it did fail
    );
    if(wait(pid) != 0) { // Wait for the command to complete
        writeError("Test command failed!");
        return false;
    }

    return true;
}