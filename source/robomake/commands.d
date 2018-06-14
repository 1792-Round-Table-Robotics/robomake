module robomake.commands;

import std.stdio : readln;
import std.system;
import std.string;
import std.conv;
import std.getopt;
import std.file : write, exists;

import robomake.console;
import robomake.cmake;

immutable string softwareName = "Robomake";
immutable string softwareVersion = "v1.0.0";
debug {
    immutable string debug_ = "DEBUG";
} else {
    immutable string debug_ = "RELEASE";
}

void processVersionCommand() @safe {
    writeInfo(softwareName ~ " " ~ softwareVersion ~ " " ~ debug_ ~ " on " ~ to!string(os));
}

void processHelpCommand() @safe {
    writeInfo("Usage: \"robomake [command] [options]\"");
    writeInfo("Avaliable commands:");
    writeInfo("\thelp                     Displays this output.");
    writeInfo("\tversion                  Displays version information.");
    writeInfo("\tcreate                   Creates a new project in the current directory.");
    writeInfo("\tbuild                    Builds the project in the current directory.");
    writeInfo("\tdeploy                   Deploys the project to a connected roboRIO.");
    writeInfo("To learn more about each command type the command followed by \"--help\"");
    writeInfo("Example: \"robomake create --help\"");
}

bool processCreateCommand(string[] args) @trusted {
    bool help;
    string name;
    bool testing;

    getopt(args,
        "help", &help,
        "name", &name,
        "testing", &testing
    );

    if(help) {
        writeInfo("Usage: \"robomake create --name=[project name] --testing=[true|false]\"");
        writeInfo("\t--name              The name of the project, no spaces, CamelCase");
        writeInfo("\t--testing           Optional. If true, Google Testing support will be added. Default is false");
        writeInfo("\t--help              Displays this output.");
        writeInfo("Example: \"robomake create --name=MyProject --testing\"");
        return true;
    }
    
    if(!name) {
        writeError("Missing required parameter: \"--name\"!");
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

    write(".robomake", "lock"); // Create our robomake lockfile

    createCMakeProjectFiles(name, testing);
    writeInfo("Done!");

    return true;
}