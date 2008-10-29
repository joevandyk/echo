class com.agnosticmedia.tools.Timecode {
	var delimiter:String = ":";
	// default delimiter
	/**
	 * constructor 
	 */
	function Timecode() {
		_root.log.info("com.agnosticmedia.tools.Timecode()");
	}
	/**
	* Set a new delimiter string.
	*
	* del				The new delimiter
	*/
	public function setDelimiter(del:String):Void {
		_root.log.info("setDelimiter(" + del + ")");
		this.delimiter = del;
	}
	/**
	* Convert milliseconds into hh:mm:ss.ff for a specific number of milliseconds.
	*
	* seconds			The seconds to be converted into hh:mm:ss:ff
	*/
	public function getTimecode(seconds:Number, framerate:Number):String {
		_root.log.info("getTimecode(" + seconds + "," + framerate + ")");
		var tc = convertTime(seconds, framerate);
		_root.log.debug("Timecode = " + tc);
		return tc;
	}
	public function convertTime(second:Number, framerate:Number) {
		_root.log.info("convertTime(" + second + "," + framerate + ")");
		// :: Convert Time
		var t = second * 1000;
		var d = new Date(t);
		var Hour = d.getUTCHours();
		var Min = d.getUTCMinutes();
		var Sec = d.getUTCSeconds();
		var MSec = d.getUTCMilliseconds();
		var Frame = Math.floor(convertMillisecondsToFrames(MSec, framerate));
		// :: Configure for Output
		Min = (Min < 10 ? "0" : "") + Min;
		Sec = (Sec < 10 ? "0" : "") + Sec;
		Hour = (Hour < 10 ? "0" : "") + Hour;
		Frame = (Frame < 10 ? "0" : "") + Frame;
		// :: Return
		return (Hour + ":" + Min + ":" + Sec + "." + Frame);
	}
	/** 
	 * Convert milliseconds to frames based on framerate
	 *
	 * milliseconds			The milliseconds of video
	 * frameRate			The video framerate
	 */
	public function convertMillisecondsToFrames(milliseconds:Number, frameRate:Number):Number {
		_root.log.info("convertMillisecondsToFrames(" + milliseconds + "," + frameRate + ")");
		return (milliseconds * frameRate) / 1000;
	}
	
}
