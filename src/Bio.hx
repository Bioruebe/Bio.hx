/**
 * Copyright (c) 2015-16, Bioruebe
 * 
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 * 
 * 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * 
 * 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * 
 * 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/ 

package ;
import haxe.crypto.BaseCode;
import haxe.ds.StringMap;
import haxe.io.Bytes;
import haxe.macro.Context;
import sys.FileSystem;

/**
 * Bioruebe's helper class containing various functions to be used across different projects.
 * @author Bioruebe
 */
class Bio {
	public static inline var seperator = "\r\n---------------------------------------------------------------------\r\n";
	private static var promptSettings = new StringMap<Dynamic>();
	private static var baseCode = new BaseCode(Bytes.ofString("0123456789abcdef"));
	public static var pathSeperator = Sys.systemName() == "Windows"? "\\": "/";
	public static var defaultPromptOptions = [ 
		new PromptOption("Yes", "y", true),
		new PromptOption("No", "n", false),
		new PromptOption("Always", "a", true, true),
		new PromptOption("Never", "e", false, true)
	];
	
	/**
	 * Returns first string found between given start and end string.
	 * @param	string	The string to search for
	 * @param	start	The start string to search between
	 * @param	end		The end string to search between
	 * @return	first string found between start and end
	 */
	public static function StringBetween(string:String, start:String, ?end:String):String {
		var startPos:Int = string.indexOf(start);
		
		if (startPos != -1) {
			startPos += start.length;
			var endPos = end == null? string.length: string.indexOf(end, startPos + 1);
			//trace(startPos + "   " + endPos);
			if(endPos != -1) return string.substring(startPos, endPos);
		}
		
		return "";
	}
	
	/**
	 * Replace between two strings.
	 * @param	string	The string to search for
	 * @param	start	The start string to replace between
	 * @param	end		The end string to replace between
	 * @param	replace The replacement string
	 */
	public static function StringReplaceBetween(string:String, start:String, end:String, replace:String):String {
		var startPos = start == ""? 0: string.indexOf(start);
		var endPos = string.indexOf(end, startPos + 1);
		
		if (startPos == -1 || endPos == -1) return string;
		
		startPos += start.length;
		return string.substring(0, startPos) + replace + string.substring(endPos);
	}
	
	/**
	 * Return all strings between given start and end string.
	 * @param	string	the search string
	 * @param	start	the start string to search between
	 * @param	end		the end string to search between
	 * @return	an array of all found strings
	 */
	public static function StringAllBetween(string:String, start:String, end:String):Array<String> {
		var aReturn:Array<String> = new Array();
		var returnString:String;
		var startPos:Int;
		var endPos:Int;
		
		do {
			startPos = string.indexOf(start);
			if (startPos == -1) break;
			startPos += start.length;
			endPos = string.indexOf(end, startPos + 1);
			if (endPos == -1) break;
			
			returnString = string.substring(startPos, endPos);
			//trace(returnString);
			aReturn.push(returnString);
			string = string.substr(endPos + end.length);
		} while (returnString != "");
		
		return aReturn;
	}
	
	/**
	 * Convenience function to check whether a string contains a given substring or not
	 * @param	string
	 * @param	substring
	 * @param	startIndex
	 * @return	true or false
	 */
	public static inline function StringInStr(string:String, substring:String, ?startIndex):Bool {
		return string.indexOf(substring, startIndex) != -1;
	}
	
	/**
	 * Insert given string at the specified position
	 * @param	string			The original string
	 * @param	insertString	The string to insert
	 * @param	pos				The position to insert string at
	 */
	public static function StringInsert(string:String, insertString:String, pos:Int):String {
		if (pos < 0) {
			throw "Invalid string insert position: " + pos;
		}
		else {
			return string.substr(0, pos) + insertString + string.substr(pos);
		}
	}
	
	/**
	 * Replace the first occurence of searchString
	 * @param	string			The original string
	 * @param	searchString	The string to search for
	 * @param	replaceString	The replacement string
	 */
	public static function StringReplaceFirst(string:String, searchString:String, replaceString:String) {
		var pos = string.indexOf(searchString);
		if (pos < 0) return string;
		return string.substring(0, pos) + replaceString + string.substring(pos + searchString.length);
	}
	
	/**
	 * Replace placeholders in a template with the specified values
	 * @param	template		The template string
	 * @param	placeholders	A map containing the placeholder names and values
	 */
	public static function tpl(template:String, placeholders:Map<String, Dynamic>):String {
		for (key in placeholders.keys()) {
			template = StringTools.replace(template, key, placeholders.get(key));
		}
		
		return template;
	}
	
	/**
	 * Combine two maps.
	 * @param	m1			The first map
	 * @param	m2			The second map
	 * @param	overwrite	If true, keys from m2 replace keys from m1
	 */
	public static function CombineMaps<T>(m1:StringMap<T>, m2:StringMap<T>, overwrite:Bool = false):StringMap<T> {
		if (m2 == null) return m1;
		for (item in m2.keys()) {
			if (!m1.exists(item) || overwrite) m1.set(item, m2.get(item));
		}
		return m1;
	}

	/** Return an object with a path split into its parts, e.g. file name, extension and directory
	 * @param	path		The full file path
	 * @return				A FileParts object
	 */
	public static function FileGetParts(path:String):FileParts {
		var pos = path.lastIndexOf("\\");
		if (pos < 0) pos = path.lastIndexOf("/");
		if (pos < 0) {
			var split = path.split(".");
			return {name: split[0], fullName: path, extension: split.length > 1? split[1]: "", directory: "./"};
		}
		
		var directory = path.substring(0, pos + 1);
		var fullname = path.substring(pos + 1);
		pos = fullname.lastIndexOf(".");
		if (pos < 0) return {name: fullname, fullName: fullname, extension: "", directory: directory};
		
		var extension = fullname.substring(pos + 1);
		return {name: fullname.substring(0, pos), fullName: fullname, extension: extension, directory: directory};
	}
	
	/**
	 * Return true if the path ends with '/' or '\'
	 * @param	path
	 */
	public static inline function PathEndsWithSeperator(path:String):Bool {
		return StringTools.endsWith(path, "/") || StringTools.endsWith(path, "\\");
	}
	
	/**
	 * Append '/' to the path if it doesn't end with a seperator character
	 * @param	path
	 */
	public static inline function PathAppendSeperator(path:String):String {
		if (StringTools.endsWith(path, "\"")) path = path.substr(0, path.length - 1);
		return PathEndsWithSeperator(path)? path: path + pathSeperator;
	}
	
	/**
	 * Make sure directory structure exists. Returns the path for convenience.
	 * @param	path
	 */
	public static function AssurePathExists(path:String):String {
		var parts = path.split("/");
		if (parts.length < 2) parts = path.split("\\");
		var curr = "";
		for (p in parts) {
			curr += p + "/";
			if (p.indexOf(":") > -1 || p.indexOf(".") > -1) continue;
			try {
				if (!FileSystem.exists(curr)) FileSystem.createDirectory(curr);
			}
			catch (error:Dynamic) {
				Error("Failed to create Directory " + curr, 1);
			}
		}
		
		return path;
	}
	
	/**
	 * Convert a hex string to a bytes object
	 * @param	hex				String representation of hexadecimal values
	 * @param	useLowerCase	Convert hex string to lower case
	 */
	public static inline function HexToBytes(hex:String, useLowerCase:Bool = true):Bytes {
		return baseCode.decodeBytes(Bytes.ofString(useLowerCase? hex.toLowerCase(): hex));
	}
	
	/**
	 * XOR two bytes objects. The data object is modified in place. The key is repeated if it is shorter than the data.
	 * @param	data
	 * @param	key
	 */
	public static function Xor(data:Bytes, key:Bytes) {
		if (key == null || key.length <= 0) return;
		var keyLength = key.length;
		for (i in 0...data.length) {
			var k = key.get(i % keyLength);
			var d = data.get(i);
			data.set(i, d ^ k);
		}
	}
	
	/**
	 * Write message to stdout/stderr
	 * @param	msg			The message to print
	 * @param	severity	The log severity, determines which output stream to use
	 */
	public static function Cout(msg:Dynamic, ?severity:LogSeverity) {
#if !debug	
		if (severity == LogSeverity.DEBUG) return true;
#end
		
		if (severity == null) severity = LogSeverity.INFO;
		if (severity != LogSeverity.MESSAGE) msg = StringTools.rpad('[${severity}]', " ", 12) + msg;
		
		switch (severity) {
			case LogSeverity.ERROR:
				Sys.stderr().writeString(cast msg + "\n");
				return false;
			case LogSeverity.CRITICAL:
				Sys.stderr().writeString(cast msg + "\n");
				Sys.exit(1);
			case LogSeverity.DEBUG:
				trace(msg);
			default:
				Sys.println(msg);
		}
		return true;
	}
	
	/**
	 * Convenience function, shortcut to calling Cout with LogSeverity.DEBUG
	 * @param	msg			The message to print	
	 */
	public static inline function Debug(msg:Dynamic) {
		Cout(msg, LogSeverity.DEBUG);
	}
	
	/**
	 * Convenience function, shortcut to calling Cout with LogSeverity.WARNING
	 * @param	msg			The message to print	
	 */
	public static inline function Warning(msg:Dynamic) {
		Cout(msg, LogSeverity.WARNING);
	}
	
	/**
	 * Convenience function, shortcut to calling Cout with LogSeverity.ERROR
	 * @param	msg			The message to print	
	 */
	public static function Error(msg:Dynamic, exitCode:Int = -1) {
		Cout(msg, LogSeverity.ERROR);
#if sys		
		if (exitCode > -1) Sys.exit(exitCode);
#end
	}
	
	/**
	 * Prints an array along with its indices
	 * @param	array	The array to print
	 * @param	offset	Integer offset for indices, e.g. to start with index 1
	 * @param	field	If specified, the field is printed instead of the toString output 
	 */
	public static function PrintArray(array:Array<Dynamic>, offset:Int = 1, ?field:String) {
		for (i in 0...array.length) {
			Sys.println('\t[${i + offset}] ' + (field == null? array[i]: Reflect.field(array[i], field)));
		}
	}
	
	/**
	 * Prints a list
	 * @param	list	The list to print
	 * @param	field	If specified, the field is printed instead of the toString output 
	 */
	public static function PrintList(list:List<Dynamic>, ?field:String) {
		for (el in list) {
			Sys.println('\t' + (field == null? el: Reflect.field(el, field)));
		}
	}
	
	/**
	 * Display a prompt and wait for user input
	 * @param	msg		The question to display
	 * @param	id		An unique id used for this prompt. This is used to save always/never preferences.
	 * @param	choices	Possible choices to display
	 * @return			User choice as defined in PromptOptions
	 */
	public static function Prompt(msg:String, id:String = "", options:Array<PromptOption> = null):Dynamic {
		if (options == null || options.length < 1) options = defaultPromptOptions;
		
		// Check setting from previous function calls
		var returnValue = promptSettings.get(id);
		if (returnValue != null) return returnValue;
		
		var input:String;
		var choices = "";
		for (opt in options) {
			var charPos = opt.text.toLowerCase().indexOf(opt.char);
			var text = opt.text;
			if (charPos > -1) text = StringInsert(StringInsert(text, "]", charPos + 1), "[", charPos);
			choices += " | " + text;
		}
		choices = choices.substr(3);
		
		while (true) {
			Sys.println("\n" + msg + ' $choices');
			input = String.fromCharCode(Sys.getChar(true)).toLowerCase();
			Sys.println("");
			
			var selectedOption = Lambda.find(options, function(o) return o.char == input);
			if (selectedOption == null) continue;
			
			if (selectedOption.setStandard) promptSettings.set(id, selectedOption.returnValue);
			return selectedOption.returnValue;
		}
	}
	
	/**
	 * Prompt for an integer, validate input and return user choice
	 * @param	msg	The message to print before waiting for input
	 * @param	min	Minimum value to accept
	 * @param	max	Maximum value to accept
	 */
	public static function IntPrompt(?msg:String, min:Null<Int>, max:Null<Int>):Null<Int> {
		if (msg != null) Sys.println(msg);
		var input:Null<Int> = null;
		Sys.println("");
		
		var multiChar = max > 9 || min < -9;
		while (input == null || (min != null && input < min) || (max != null && input > max)) {
			input = Std.parseInt(multiChar? Sys.stdin().readLine(): String.fromCharCode(Sys.getChar(true)));
			Sys.println("");
		}
		
		return input;
	}
	
	/**
	 * Prompt for a string and return user input
	 * @param	msg The message to print before waiting for input
	 */
	public static function StringPrompt(?msg:String) {
		if (msg != null) Sys.println(msg);
		
		var input = Sys.stdin().readLine();
		Sys.println("");
		
		return input;
	}
	
	/**
	 * Wait for any key press
	 * @param	msg		The message to display before waiting
	 */
	public static function ContinuePrompt(msg:String) {
		Sys.println(msg);
		Sys.getChar(false);
	}
	
	/**
	 * Print standard command line tool header
	 * @param	name		Name of the program
	 * @param	version		Version of the program
	 * @param	year		The release year. The current year is automatically appended on build.
	 * @param	description Short description of the main functionality
	 * @param	usage		Command line usage help text. The programm name is automatically added before.
	 */
	public static function Header(name:String, version:String, year:String = "", description:String = "", ?usage:String) {
		Seperator();
		var buildYear = Std.string(getBuildYear());
		if (year != "" && year != buildYear) buildYear = year + "-" + buildYear;
		var header = name + " by Bioruebe (https://bioruebe.com), " + buildYear + ", Version " + version + ", Released under a BSD 3-Clause style license\n\n" + description + (usage == null? "": "\n\nUsage: " + getProgramName() + " " + usage);
#if sys
		Sys.println(header);
#else
		trace(header);
#end
		//Seperator();
	}
	
	/**
	 * Print seperator line
	 */
	public static inline function Seperator() {
#if sys
		Sys.println(seperator);
#else
		trace(seperator);
#end
	}
	
	/**
	 * Returns the name of the program
	 * @return
	 */
	public static function getProgramName():String {
#if sys
		var path:String = Sys.executablePath();
		return path.substr(path.lastIndexOf("\\") + 1);
#else
		return "<executableName>";
#end	
	}
	
	/**
	 * Calculate a rough estimate of the time needed to execute a function
	 * @param	func	The function to profile; if arguments are needed, encapsulate in anonymous function
	 * @return			The time in seconds
	 */
	public static function profile(func:Void->Void) {
		var time = Sys.cpuTime();
		func();
		Cout("Execution took " + (Sys.cpuTime() - time) + "s", LogSeverity.DEBUG);
	}
	
	/**
	 * Return the year the program was built
	 * [Compile time macro]
	 */
	macro private static function getBuildYear() {
		return Context.makeExpr(Date.now().getFullYear(), Context.currentPos());
	}
	
}

typedef FileParts = {
	/**
	 * The file name without extension
	 */
	var name:String;
	/**
	 * The file name + extension
	 */
	var fullName:String;
	/**
	 * The file's extension without leading dot
	 */
	var extension:String;
	/**
	 * The file directory
	 */
	var directory:String;
}

class PromptOption {
	/**
	 * The text to display
	 */
	public var text:String;
	/**
	 * A unique value to return
	 */
	public var returnValue:Dynamic;
	/**
	 * The character the user has to enter to select an option
	 * The respective character is automatically marked in the text
	 */
	public var char:String;
	/**
	 * If setStandard is true, the values will be returned without displaying a prompt for all future calls with the same id
	 * This is used for options like 'Always', 'Never' or 'Always rename'
	 */
	public var setStandard:Bool;
	
	public function new(text:String, char:String, returnValue:Dynamic, setStandard:Bool = false) {
		this.text = text;
		this.char = char;
		this.returnValue = returnValue;
		this.setStandard = setStandard;
	}
}

enum LogSeverity {
	DEBUG;
	INFO;
	WARNING;
	ERROR;
	CRITICAL;
	MESSAGE;
	UNITTEST;
}