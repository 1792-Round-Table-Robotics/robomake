module robomake.build;

import std.conv;
import std.file;
import std.process;

import core.cpuid : threadsPerCPU;

import robomake.console;

version(Windows) {
    /// The type of CMake generator to use. We need MinGW on Windows, elsewhere we use Unix Makefiles
    immutable string cmakeGenerator = "MinGW Makefiles";
    /// The name of the GNU Make executable to use. On Windows we use MinGW
    immutable string makeExecutable = "mingw32-make";
} else {
    /// The type of CMake generator to use. We need MinGW on Windows, elsewhere we use Unix Makefiles
    immutable string cmakeGenerator = "Unix Makefiles";
    /// The name of the GNU Make executable to use. On Windows we use MinGW
    immutable string makeExecutable = "make";
}

/// Runs the necessary commands to build a project in the current directory
bool buildProject() @system {
    immutable auto cmakeCommand = ["cmake", "\"-DCMAKE_TOOLCHAIN_FILE=arm-frc-toolchain.cmake\"",
                            "-G", "\"" ~ cmakeGenerator ~ "\"", ".."];
    immutable auto makeCommand = [makeExecutable, "-j" ~ to!string(threadsPerCPU())]; // -j[Number of threads our CPU has]

    scope(exit) {
        chdir(".."); // Switch back to previous directory
        writeInfo("Switched current directory back.");
    }

    if(!exists("build")) {
        mkdir("build");
    }
    chdir("build"); // Switch our current directory to the "build" directory
    writeInfo("Switched current directory to \"build\"");

    writeInfo("Running CMake: " ~ to!string(cmakeCommand));

    auto pid = spawnProcess(cmakeCommand);
    auto exitCode = wait(pid); // Wait for the command to complete
    if(exitCode != 0) {
        writeError("Build failure!");
        writeError("CMake exited with non-zero exit code!");
        return false;
    }

    writeInfo("Running Make: " ~ to!string(makeCommand));
    pid = spawnProcess(makeCommand);
    exitCode = wait(pid);
    if(exitCode != 0) {
        writeError("Build failure!");
        writeError("Make exited with non-zero exit code!");

        return false;
    }

    return true;
}