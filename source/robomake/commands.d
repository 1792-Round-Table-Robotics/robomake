module robomake.commands;

import std.stdio : readln;
import std.system;
import std.compiler;
import std.string;
import std.algorithm.searching;
import std.conv;
import std.getopt;
import std.file : write, readText, exists;
import std.datetime.stopwatch;

import core.cpuid;

import robomake.console;
import robomake.cmake;
import robomake.build;

/// The name of the software
immutable string softwareName = "Robomake";
/// Software version
immutable string softwareVersion = "v1.1.0";
debug {
    /// If we are running a debug or release build
    immutable string debug_ = "DEBUG";
} else {
    /// If we are running a debug or release build
    immutable string debug_ = "RELEASE";
}

/// Represents a project's information contained in the ".robomake" file
struct ProjectInfo {
    /// The project's name
    string name;
    /// The FRC team number
    string teamNumber;
}

private bool checkForDotfile() @safe {
    if(!exists(".robomake")) {
        writeError("Failed to find \".robomake\" file! There doesn't appear to be a project in this directory.");
        writeError("Think this is a mistake? Create a \".robomake\" file in the current directory with the project");
        writeError("name inside, then rerun this command.");
        return false;
    }
    return true;
}

private ProjectInfo getProjectInfo() @safe {
    immutable auto contents = readText(".robomake").split(",");
    return ProjectInfo(contents[0], contents[1]);
}

/// Processes the "version" command
void processVersionCommand() @safe {
    writeInfo(softwareName ~ " " ~ softwareVersion ~ 
        " " ~ debug_ ~ " on " ~ to!string(os) ~ " (built with " ~ name ~ ")");

    writeInfo("CPU:             " ~ processor());
    writeInfo("Cores Per CPU:   " ~ to!string(coresPerCPU()));
    writeInfo("Threads per CPU: " ~ to!string(threadsPerCPU()));
}

/// Processes the "help" command
void processHelpCommand() @safe {
    writeInfo("Usage: \"robomake [command] [options]\"");
    writeInfo("Avaliable commands:");
    writeInfo("\thelp                     Displays this output.");
    writeInfo("\tversion                  Displays version information.");
    writeInfo("\tcreate                   Creates a new project in the current directory.");
    writeInfo("\tbuild                    Builds the project in the current directory.");
    writeInfo("\ttest                     Builds and runs tests for the current directory.");
    writeInfo("\tdeploy                   Deploys the project to a connected roboRIO.");
    writeInfo("To learn more about each command type the command followed by \"--help\"");
    writeInfo("Example: \"robomake create --help\"");
}

/// Processes the "create" command
bool processCreateCommand(string[] args) @trusted {
    bool help; // If the user typed in --help
    string name; // The name of the project, from --name=Name
    uint team; //The team number of the project, from --team
    bool testing; // The

    getopt(args,
        "help", &help,
        "name", &name,
        "team", &team,
        "testing", &testing
    );

    if(help) {
        writeInfo("Usage: \"robomake create --name=[project name] --team[team number] --testing=[true|false]\"");
        writeInfo("\t--name              The name of the project, no spaces, CamelCase");
        writeInfo("\t--team              The FRC team number of the project.");
        writeInfo("\t--testing           Optional. If true, Google Testing support will be added. Default is false");
        writeInfo("\t--help              Displays this output.");
        writeInfo("Example: \"robomake create --name=MyProject --team=1714 --testing\"");
        return true;
    }
    
    if(!name) {
        writeError("Missing required parameter: \"--name\"!");
        writeError("To find out more on this command, run \"robomake create --help\"");
        return false;
    } else if(name.canFind(",")) {
        writeError("Invalid project name: can't contain \",\"");
        return false;
    }

    if(!team) {
        writeError("Missing required parameter: \"--team\"!");
        writeError("To find out more on this command, run \"robomake create --help\"");
        return false;
    }

    if(exists("CMakeLists.txt") || exists(".robomake")) {
        writeWarning("There appears to be a project already here. Are you sure you want to proceed? [y/N]");
        auto val = readln();
        if(val.strip().toLower() != "y") {
            // Abort
            writeInfo("Aborting.");
            return true;
        }
    }

    writeInfo("Creating project " ~ name ~ " (testing=" ~ to!string(testing) ~ ")");

    write(".robomake", name ~ "," ~ to!string(team)); // Create our robomake lockfile

    createCMakeProjectFiles(name, testing);
    writeInfo("Project creation complete, now running first build...");

    if(_processBuildCommand(false)) {
        writeInfo("Project is ready for use! :)");

        return true;
    } else {
        return false;
    }
}

/// Processes the "build" command
bool processBuildCommand(string[] args) @trusted {
    bool tests; // If we should build tests, that means use native compiler and build only subsystems and test code.
    bool help; // If we should display help information
    getopt(args,
        "tests", &tests,
        "help", &help
    );

    if(help) {
        writeInfo("Usage: \"robomake build --tests=[true|false]\"");
        writeInfo("\t--tests             Optional. If true, then the project will only be built with subsystems");
        writeInfo("\t                        and test code. It will use the native compiler instead of the cross-compiler\n");
        writeInfo("\t--help              Displays this output.");
        writeInfo("Example: \"robomake build --tests\"");
        return true;
    }

    return _processBuildCommand(tests);
}

private bool _processBuildCommand(in bool tests) @safe {
    if(!checkForDotfile()) return false;
    immutable auto projectInfo = getProjectInfo();

    writeInfo("Building project \"" ~ projectInfo.name ~ "\" (team " ~ projectInfo.teamNumber ~ ")...");

    if(tests) writeInfo("Notice: Building test code and subsystems ONLY, using native compiler.");

    auto sw = StopWatch();
    sw.start();
    auto result = buildProject(tests);
    sw.stop();

    if (result) writeInfo("Build complete! (Done in " ~ to!string(sw.peek.total!"msecs") ~ "ms)");
    return result;
}

/// Processes the "test" command
bool processTestCommand() @trusted {
    if(!checkForDotfile()) return false;
    //immutable auto projectInfo = getProjectInfo();

    /*writeInfo("Building tests for project \"" ~ projectInfo.name ~ "\" (team " ~ projectInfo.teamNumber ~ ")...");

    if(!buildProject(true)) {
        writeError("Error while building tests!");
        return false;
    }*/

    writeInfo("Running tests...");
    return runCTest();
}

/// Processes the "deploy" command
bool processDeployCommand() @safe {
    checkForDotfile();
    return true;
}