module robomake.commands;

import std.system;
import std.conv;
import std.getopt;

import robomake.console;

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

void processCreateCommand(string[] args) @safe {

}