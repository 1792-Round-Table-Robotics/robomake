import std.stdio : writeln;
import std.conv;

import robomake.console;
import robomake.commands;

int main(string[] args) @system {
	if(args.length > 1) {
		try {
			if(processPrimaryCommand(args)) {
				return 0;
			}
		} catch(Exception e) {
			writeError("Oh no! Something went wrong!");
			writeError("Caught exception: " ~ e.msg ~ " [in " ~ e.file ~ " at line " ~ to!string(e.line) ~ "]");
			debug writeln(e.toString());
			else {
				writeWarning("Stack trace not printed as this is a release build.");
			}
			return 1;
		}
		return 1;
	} else {
		writeError("No arguments provided! Please run \"robomake help\" to see options.");
		return 1;
	}
}

private bool processPrimaryCommand(string[] args) @safe {
	immutable auto primaryCommand = args[1]; // First argument is always the executable
	switch(primaryCommand) {
		case "--version":
		case "version":
			processVersionCommand();
			break;
		case "--help":
		case "help":
			processHelpCommand();
			break;

		case "create":
			return processCreateCommand(args);
		case "build":
			return processBuildCommand(args);
		case "test":
			return processTestCommand();
		case "deploy":
			return processDeployCommand();
		default:
			writeError("Failed to process primary command! First argument must be a valid command!");
			writeError("Please run \"robomake help\" to see command options.");
			return false;
	}
	return true;
}