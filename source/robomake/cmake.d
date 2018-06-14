module robomake.cmake;

import std.file;
import std.net.curl;

import robomake.console;

private void checkDirectory(string dir) {
    if(!exists(dir)) {
        mkdir(dir);
    } else if(exists(dir) && isDir(dir)) {
        rmdirRecurse(dir);
        mkdir(dir);
    }
}

/**
 * Creates the various CMake files for a project.
 */
void createCMakeProjectFiles(in string projectName, in bool testing) @trusted {
    // Create directory structure
    checkDirectory("cmake");
    checkDirectory(".vscode");
    checkDirectory("src");
    checkDirectory("include");
    if(testing) checkDirectory("test");

    // Delete cmake files if found
    if(exists("CMakeLists.txt")) {
        remove("CMakeLists.txt");
    }

    if(exists("arm-frc-toolchain.cmake")) {
        remove("arm-frc-toolchain.cmake");
    }

    // Download and save new files
    downloadAndSaveFiles(testing);

    createCMakeLists(projectName, testing);
}

private void downloadAndSaveFiles(in bool testing) @system {
    void downloadFile(in string name, in string savePath) @system {
        auto url = "https://raw.githubusercontent.com/jython234/robomake/master/resources/" ~ name;
        writeInfo("Downloading " ~ url ~ " to " ~ savePath);

        download(url, savePath);
    }

    if(testing) downloadFile("/GTest.txt.in", "cmake/GTest.txt.in");
    downloadFile("/FindWPILib.cmake", "cmake/FindWPILib.cmake");

    downloadFile("/arm-frc-toolchain.cmake", "arm-frc-toolchain.cmake");
    version(Windows) {
        downloadFile("/win32/cmake-kits.json", ".vscode/cmake-kits.json");
        downloadFile("/win32/c_cpp_properties.json", ".vscode/c_cpp_properties.json");
    } else {
        // Assume UNIX
        downloadFile("/unix/cmake-kits.json", ".vscode/cmake-kits.json");
        downloadFile("/unix/c_cpp_properties.json", ".vscode/c_cpp_properties.json");
    }
}

private void createCMakeLists(in string projectName, in bool testing) @system {
    write("CMakeLists.txt", "# Generated by robomake\n# Main CMake project file for " ~ projectName ~ "\n");
    append("CMakeLists.txt", "cmake_minimum_required(3.4)\nproject(" ~ projectName ~ ")\n\n");

    auto part1 = get("https://raw.githubusercontent.com/jython234/robomake/master/resources/CMakeLists.txt.1");
    append("CMakeLists.txt", part1 ~ "\n\n");

    if(testing) {
        append("CMakeLists.txt", 
                get("https://raw.githubusercontent.com/jython234/robomake/master/resources/CMakeLists.txt.gtest") ~ "\n\n");
        append("CMakeLists.txt", 
                get("https://raw.githubusercontent.com/jython234/robomake/master/resources/CMakeLists.txt.2") ~ "\n\n");
        append("CMakeLists.txt", 
                get("https://raw.githubusercontent.com/jython234/robomake/master/resources/CMakeLists.txt.3") ~ "\n\n");
    } else {
        append("CMakeLists.txt", 
                get("https://raw.githubusercontent.com/jython234/robomake/master/resources/CMakeLists.txt.2") ~ "\n");
    }
}