module robomake.console;

import colorize;

/**
 * Writes an Info message to the console.
 */
void writeInfo(in string message) @trusted {
    cwriteln("[INFO]: ".color(fg.cyan) ~ message.color(fg.white));
}

/**
 * Writes a Warning message to the console.
 */
void writeWarning(in string message) @trusted {
    cwriteln("[WARN]: ".color(fg.yellow) ~ message.color(fg.white));
}

/**
 * Writes an Error message to the console.
 */
void writeError(in string message) @trusted {
    cwriteln("[ERROR]: ".color(fg.red) ~ message.color(fg.light_red));
}