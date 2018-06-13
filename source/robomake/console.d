module robomake.console;
import consoled;

/**
 * Writes an Info message to the console.
 */
void writeInfo(in string message) @trusted {
    writecln(Fg.cyan, "[INFO]: ", FontStyle.bold, Fg.white, message);
    resetColors();
}

/**
 * Writes a Warning message to the console.
 */
void writeWarning(in string message) @trusted {
    writecln(Fg.yellow, "[WARN]: ", FontStyle.bold, Fg.white, message);
    resetColors();
}

/**
 * Writes an Error message to the console.
 */
void writeError(in string message) @trusted {
    writecln(Fg.red, "[ERROR]: ", FontStyle.bold, Fg.lightRed, message);
    resetColors();
}