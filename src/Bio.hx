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
import haxe.ds.StringMap;
import haxe.macro.Context;

/**
 * Bioruebe's helper class containing various functions to be used across different projects.
 * @author Bioruebe
 */
class Bio
{
	private static inline var seperator = "\r\n---------------------------------------------------------------------\r\n";
	private static var promptSettings = new StringMap<PromptSetting>();
	
	/**
	 * Returns first string found between given start and end string.
	 * @param	string	the search string
	 * @param	start	the start string to search between
	 * @param	end		the end string to search between
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
	public static function StringInsert(string:String, insertString:String, pos:Int) {
		if (pos < 0) {
			throw "Invalid string insert position";
		}
		else {
			return string.substr(0, pos) + insertString + string.substr(pos);
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
		if (severity != LogSeverity.MESSAGE) msg = '[${severity}] ${msg}';
		
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
	 * Prints an array along with its indices
	 * @param	array	The array to print
	 * @param	offset	Integer offset for indices, e.g. to start with index 1
	 */
	public static function PrintArray(array:Array<Dynamic>, offset:Int = 1) {
		for (i in 0...array.length) {
			Sys.println('\t[${i + offset}] ' + array[i]);
		}
	}
	
	/**
	 * Display a prompt and wait for user input
	 * @param	msg		The question to display
	 * @param	chars	Characters used for positive and negative result, in format y|n
	 * @return			User choice: true or false
	 */
	public static function Prompt(msg:String, id:String = "", choices:String = "[Y]es | [N]o | [A]lways | n[E]ver", chars:String = "y|n|a|e") {
		// Check setting from previous function calls
		var setting = promptSettings.get(id);
		if (setting != null) {
			if (setting == PromptSetting.ALWAYS) return true;
			if (setting == PromptSetting.NEVER) return false;
		}
		
		var aChars = chars.split("|");
		var input:Int;
		
		while (true) {
			Sys.println(msg + ' $choices');
			input = String.fromCharCode(Sys.getChar(true)).toLowerCase().charCodeAt(0);
			Sys.println("");
			
			if (input == aChars[0].charCodeAt(0)) return true;
			if (input == aChars[1].charCodeAt(0)) return false;
			if (input == aChars[2].charCodeAt(0)) {
				promptSettings.set(id, PromptSetting.ALWAYS);
				return true;
			}
			if (input == aChars[3].charCodeAt(0)) {
				promptSettings.set(id, PromptSetting.NEVER);
				return false;
			}
		}
		
	}
	
	/**
	 * Prompt for an integer, validate input and return user choice
	 * @param	msg	The message to print before waiting for input
	 * @param	min	Minimum value to accept
	 * @param	max	Maximum value to accept
	 */
	public static function IntPrompt(msg:String, min:Null<Int>, max:Null<Int>) {
		Sys.println(msg);
		var input = Std.parseInt(String.fromCharCode(Sys.getChar(true)));
		Sys.println("");
		
		while (input == null || (min != null && input < min) || (max != null && input > max)) {
			input = Std.parseInt(String.fromCharCode(Sys.getChar(true)));
			Sys.println("");
		}
		
		return input;
	}
	
	/**
	 * Print standard command line tool header
	 * @param	name		Name of the program
	 * @param	version		Version of the program
	 * @param	description Short description of the main functionality
	 */
	public static function Header(name:String, version:String, description:String, ?usage:String) {
		Seperator();
		var header = name + " by Bioruebe (http://bioruebe.com), " + getBuildYear() + ", Version " + version + ", Released under a BSD 3-Clause style license\n\n" + description + (usage == null? "": "\n\nUsage: " + getProgramName() + " " + usage);
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
		var path:String = Sys.programPath();
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

enum LogSeverity {
	DEBUG;
	INFO;
	WARNING;
	ERROR;
	CRITICAL;
	MESSAGE;
}

enum PromptSetting {
	ALWAYS;
	NEVER;
	NONE;
}