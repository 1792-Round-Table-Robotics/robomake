import std.stdio;
import std.conv;

import robomake.console;
import robomake.commands;

int main(string[] args) @system {
	if(args.length > 1) {
		if(processPrimaryCommand(args)) {
			return 0;
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
		case "version":
			processVersionCommand();
			break;
		case "help":
			processHelpCommand();
			break;
		case "create":
			processCreateCommand(args);
			break;
		default:
			writeError("Failed to process primary command! First argument must be a valid command!");
			writeError("Please run \"robomake help\" to see command options.");
			return false;
	}
	return true;
}