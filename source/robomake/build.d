module robomake.build;

import std.conv;
import std.file;
import std.process;

static import std.stdio;

import core.cpuid : threadsPerCPU;

import robomake.console;

version(Windows) {
    /// The type of CMake generator to use. We need MinGW on Windows, elsewhere we use Unix Makefiles
    enum cmakeGenerator = "MinGW Makefiles";
    /// The name of the GNU Make executable to use. On Windows we use MinGW
    enum makeExecutable = "mingw32-make";
} else {
    /// The type of CMake generator to use. We need MinGW on Windows, elsewhere we use Unix Makefiles
    enum cmakeGenerator = "Unix Makefiles";
    /// The name of the GNU Make executable to use. On Windows we use MinGW
    enum makeExecutable = "make";
}

/// Directory where normal builds take place.
enum normalBuildDir = "build";
/// Directory where testing builds take place.
enum testsBuildDir = "buildTests";

/// Runs the necessary commands to build a project in the current directory
bool buildProject(in bool tests) @safe {
    immutable auto cmakeCommand = "cmake " ~ (tests ? "-DlocalTesting=ON" : "-DCMAKE_TOOLCHAIN_FILE=arm-frc-toolchain.cmake") ~
                                    " -G \"" ~ cmakeGenerator ~ "\" ..";
    immutable auto makeCommand = makeExecutable ~ " -j" ~ to!string(threadsPerCPU()); // -j[Number of threads our CPU has]
    immutable auto buildDir = tests ? testsBuildDir : normalBuildDir;

    scope(exit) {
        chdir(".."); // Switch back to previous directory
        writeInfo("Switched back to previous directory.");
    }

    if(!exists(buildDir)) {
        mkdir(buildDir);
    }
    chdir(buildDir); // Switch our current directory to the "build" directory
    writeInfo("Switched current directory to \"" ~ buildDir ~ "\"");

    writeInfo("Running CMake: " ~ cmakeCommand);

    auto pid = spawnShell(cmakeCommand);
    if(wait(pid) != 0) {
        writeError("Build failure!");
        writeError("CMake exited with non-zero exit code!");
        return false;
    }

    writeInfo("Running Make: " ~ makeCommand);
    pid = spawnShell(makeCommand);
    if(wait(pid) != 0) {
        writeError("Build failure!");
        writeError("Make exited with non-zero exit code!");

        return false;
    }

    return true;
}

/// Runs tests for the project
bool runCTest() @system {
    enum testCommand = makeExecutable ~ " all test"; // Compile if any changes were made, then run test

    scope(exit) {
        chdir("..");
        writeInfo("Switched back to previous directory.");
    }

    if(!exists(testsBuildDir)) {
        mkdir(testsBuildDir);
    }
    chdir(testsBuildDir);
    writeInfo("Switched current directory to \"" ~ testsBuildDir ~ "\"");

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