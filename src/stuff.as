// import required classes
import com.agnosticmedia.logger.*;
import com.agnosticmedia.tools.Timecode;
// Create log and observers properties
var log:Logger;
var outputLogView:OutputPanelView;
var textLogView:TextFieldView;
var debugKeyListener:Object;
/**
  *  FlashVars - passed in values from the object/embed tag
  */
//var videoclip:String = "CBS_BIGBROTHER.flv";
var videoclip:String;
var guid;
var cid;
var aid;
var debug;
/**
 * Add the debug items if needed
 */
if (debug == "true") {
	// Create the log and observer objects
	log = Logger.getLog();
	outputLogView = new OutputPanelView(log);
	// internal non runtime flash output window
	textLogView = new TextFieldView(log, this, 0, 10, 10, 375, 200);
	// runtime text window
	log.addObserver(outputLogView);
	log.addObserver(textLogView);
	// set the log message level
	log.setLevel(Logger.DEBUG);
	log.info("Open debugging window");
	textLogView.showTextField();
	// show the window
	// add the keybord controls for the debug window
	// ANY OF THE ARROW KEYS WORK TO SHOW AND HIDE.
	debugKeyListener = new Object();
	debugKeyListener.onKeyUp = function():Void  {
		var myKeyCode = Key.getCode();
		log.info("oKeyListener.onKeyUp(" + myKeyCode + ")");
		if (myKeyCode == Key.RIGHT or myKeyCode == Key.LEFT or myKeyCode == Key.UP or myKeyCode == Key.DOWN) {
			// Ok we've got an arrow key
			if (textLogView.isFieldVisible()) {
				log.info("Close debugging window");
				textLogView.hideTextField();
			} else {
				log.info("Open debugging window");
				textLogView.showTextField();
			}
		}
	};
	Key.addListener(debugKeyListener);
}
log.info("Flash version = " + $version);
log.info("FlashVars param vaules loaded");
log.debug("videoclip = " + videoclip);
log.debug("guid = " + guid);
log.debug("cid = " + cid);
log.debug("aid = " + aid);
if (videoclip == null or videoclip == undefined) {
	log.fatal("NO videoclip param passed in");
}
if (cid == null or cid == undefined) {
	log.fatal("NO cid param passed in");
}
if (aid == null or aid == undefined) {
	log.fatal("NO aid param passed in");
}
if (guid == null or guid == undefined) {
	log.fatal("NO guid param passed in");
}
/**
 * init all global vars
 */ 
log.info("Init all global variables");
log.info("global style haloOrange");
_global.style.setStyle("themeColor", "haloOrange");
var nc:NetConnection;
var ns:NetStream;
var videoInterval = setInterval(videoStatus, 100);
var amountLoaded:Number;
var duration:Number;
var framerate:Number;
var timeLineBar:Number = 575;
var scrubInterval:Number;
var forwardInterval:Number;
var loopInterval:Number;
var hideMessageInterval:Number;
// user feedback interval
var so:Sound = new Sound(vSound);
var clips:Array = new Array();
// Array of all clips loaded from XML
var draftClip:Object = {name:"", inpoint:0, outpoint:0};
// temp clip object to track unsaved changes
var currentClip:Number = 0;
// clip number is 0 for start
var isEditing:Boolean = false;
// is the user editing a sub clip
var currentPosition:Number = 0;
// track current position for pausing 
var playState:Boolean = false;
// play/pasue state - Playing = true, Paused = false
var xmlEDLout:XML;
// output EDL xml the post metadata
var xmlEDLin:XML;
// input the get metadata clips
var feedback:TextFormat = new TextFormat();
// user feedback text formatting
var baseUrl:String;
// base url
var tc:Timecode;
// timecode obj
// Start the application
init();
/**
 * Most Init statements and functions. 
 *
 * @Note The debug Init is prior to these statements. See the debug if statement above.
 */
function init() {
	log.info("Init()");
	nc = new NetConnection();
	nc.connect(null);
	ns = new NetStream(nc);
	videoClip.attachVideo(ns);
	ns.setBufferTime(10);
	ns.onStatus = function(info) {
		log.debug("NetStream.onStatus " + info.code);
		if (info.code == "NetStream.Buffer.Full") {
			bufferClip._visible = false;
		}
		if (info.code == "NetStream.Buffer.Empty") {
			bufferClip._visible = true;
		}
		if (info.code == "NetStream.Play.Stop") {
			ns.seek(0);
		}
		if (info.code == "NetStream.Play.Start") {
			ns.pause();
			playState = false;
		}
	};
	if (videoclip == null or videoclip == undefined) {
		log.fatal("No Video Clip To Load");
	}
	ns.play(videoclip);
	log.debug("NetStream.play(" + videoclip + ")");
	ns["onMetaData"] = function (obj) {
		duration = obj.duration;
		framerate = obj.framerate;
		log.debug("OnMetaData - duration = " + duration + " framerate " + framerate);
		if (duration == null or duration == undefined) {
			log.fatal("MetaData has NO duration value");
		}
		if (framerate == null or framerate == undefined) {
			log.fatal("MetaData has NO framerate value");
		}
		getClipMetaData();
	};
	_root.createEmptyMovieClip("vSound", _root.getNextHighestDepth());
	vSound.attachAudio(ns);
	so.setVolume(100);
	// get the base URL
	baseUrl = videoclip;
	var questionIndex = baseUrl.indexOf("?");
	baseUrl = baseUrl.substring(0, questionIndex);
	log.debug("Base URL = " + baseUrl);
	// Create the timecode obj
	tc = new Timecode();
}
/**
 * Button event handler fuctions
 *
 */
this.bu_pause._visible = false;
this.bu_play.onRelease = function() {
	log.info("playButton.onRelease()");
	togglePlay();
};
this.bu_pause.onRelease = function() {
	log.info("pauseButton.onRelease()");
	togglePlay();
};
this.bu_stop.onRelease = function() {
	log.info("stopButton.onRelease()");
	stopIt();
};
this.bu_rewind.onPress = function() {
	log.info("rewindButton.onPress()");
	backwardInterval = setInterval(rewindIt, 10);
};
this.bu_rewind.onRelease = function() {
	log.info("rewindButton.onRelease()");
	//ns.seek(0);
	//stopIt();
	clearInterval(backwardInterval);
};
playLoop.onRelease = function() {
	log.info("playLoop.onRelease()");
	ns.seek(draftClip.inpoint);
	playIt();
	loopInterval = setInterval(stopPreview, 10);
};
this.bu_nudgeBackward.onRelease = function() {
	log.info("nudgeBack.onRelease()");
	stopIt();
	ns.seek(ns.time - 1);
	//clearInterval(scrubInterval);
	//videoInterval = setInterval(videoStatus, 100);
	//this._parent.controlBar.inPoint._x  = this._parent.controlBar.thumbScrub._x;
	//draftClip.inpoint = ns.time -1;
	//text_inPoint.text = tc.getTimecode(ns.time, framerate);
};
this.bu_nudgeForward.onRelease = function() {
	log.info("nudgeForward.onRelease()");
	stopIt();
	ns.seek(ns.time + 1);
	//draftClip.outpoint = ns.time;
	//text_outPoint.text = tc.getTimecode(ns.time, framerate);
	//setEditPoints(draftClip.inpoint, draftClip.outpoint);
};
this.bu_forward.onRelease = function() {
	log.info("forwardButton.onRelease()");
	clearInterval(forwardInterval);
};
this.bu_forward.onPress = function() {
	log.info("forwardButton.onPress()");
	forwardInterval = setInterval(forwardIt, 10);
};
this.controlBar.thumbScrub.onPress = function() {
	log.info("controlBar.thumbScrub.onPress()");
	clearInterval(videoInterval);
	scrubInterval = setInterval(scrubIt, 10);
	this.startDrag(false, 0, this._y, (amountLoaded * timeLineBar), this._y);
};
this.controlBar.thumbScrub.onRelease = controlBar.thumbScrub.onReleaseOutside = function () {
	log.info("controlBar.thumbScrub.onRelease()");
	clearInterval(scrubInterval);
	videoInterval = setInterval(videoStatus, 100);
	this.stopDrag();
};
this.controlBar.inPoint.onRollOver = function() {
	//if (this._x > 2) {
	//	this.nudgeTool._visible = true;
	//	}
};
this.controlBar.inPoint.onPress = function() {
	log.info("controlBar.inPoint.onPress()");
	stopIt();
	clearInterval(videoInterval);
	scrubInterval = setInterval(scrubIt_endpoint, 10, controlBar.inPoint);
	this.startDrag(false, 0, this._y, (controlBar.outPoint._x), this._y);
};
this.controlBar.inPoint.onRelease = function() {
	log.info("controlBar.inPoint.onRealease()");
	clearInterval(scrubInterval);
	videoInterval = setInterval(videoStatus, 100);
	this.stopDrag();
	draftClip.inpoint = ns.time;
	text_inPoint.text = tc.getTimecode(ns.time, framerate);
};
this.controlBar.inPoint.onReleaseOutside = function() {
	log.info("controlBar.inPoint.onRealease()");
	clearInterval(scrubInterval);
	videoInterval = setInterval(videoStatus, 100);
	this.stopDrag();
	draftClip.inpoint = ns.time;
	text_inPoint.text = tc.getTimecode(ns.time, framerate);
};
this.controlBar.inPoint.onRollOut = function() {
	//this.nudgeTool._visible = false;
};
this.controlBar.outPoint.onPress = function() {
	log.info("controlBar.outPoint.onPress()");
	stopIt();
	clearInterval(videoInterval);
	scrubInterval = setInterval(scrubIt_endpoint, 10, controlBar.outPoint);
	this.startDrag(false, controlBar.inPoint._x, this._y, (amountLoaded * timeLineBar), this._y);
};
this.controlBar.outPoint.onRelease = function() {
	log.info("controlBar.outPoint.onRelease()");
	clearInterval(scrubInterval);
	videoInterval = setInterval(videoStatus, 100);
	this.stopDrag();
	draftClip.outpoint = ns.time;
	text_outPoint.text = tc.getTimecode(ns.time, framerate);
};
this.controlBar.outPoint.onReleaseOutside = function() {
	log.info("controlBar.outPoint.onRelease()");
	clearInterval(scrubInterval);
	videoInterval = setInterval(videoStatus, 100);
	this.stopDrag();
	draftClip.outpoint = ns.time;
	text_outPoint.text = tc.getTimecode(ns.time, framerate);
	clipSaver._visible = true;
};
this.bu_setInPoint.onRelease = function() {
	log.info("setOutButton.onRelease()");
	//if (ns.time > draftClip.outpoint) {
	//return;
	//}
	draftClip.inpoint = ns.time;
	setEditPoints(draftClip.inpoint, draftClip.outpoint, false);
};
this.bu_setOutPoint.onRelease = function() {
	log.info("setOutButton.onRelease()");
	if (ns.time < draftClip.inpoint) {
		return;
	}
	draftClip.outpoint = ns.time;
	setEditPoints(draftClip.inpoint, draftClip.outpoint, false);
	//outTimeLabel.text = tc.getTimecode(ns.time, framerate);
};
this.bu_mute.onRelease = function() {
	log.info("mute.onRelease()");
	if (so.getVolume() == 100) {
		so.setVolume(0);
		this.gotoAndStop("muteOver");
	} else {
		so.setVolume(100);
		this.gotoAndStop("onOver");
	}
};
this.bu_saveClip.onRelease = function() {
	this._parent.saveClipSection();
};
this.bu_saveClip.onRollOver = function() {
	this.gotoAndStop("Over");
};
this.bu_saveClip.onRollOut = function() {
	this.gotoAndStop("Up");
};
this.bu_clearClip.onRelease = function() {
	this._parent.clearClipSection();
};
this.bu_clearClip.onRollOver = function() {
	this.gotoAndStop("Over");
};
this.bu_clearClip.onRollOut = function() {
	this.gotoAndStop("Up");
};
this.bu_removeClip.onRelease = function() {
	this._parent.removeSelectedClip();
};
this.bu_removeClip.onRollOver = function() {
	this.gotoAndStop("Over");
};
this.bu_removeClip.onRollOut = function() {
	this.gotoAndStop("Up");
};
this.bu_jumpTo.onRelease = function() {
	//TODO: add some validation here
	if (this._parent.input_jumpSpot.text.length == 8) {
		var newSpot = this._parent.convertTimeString(input_jumpSpot.text);
		this._parent.ns.seek(newSpot);
	}
};
/**
 * Functions called using setInterval. 
 *
 * @Note 	These are all for the scrub and thumb movement. We do it this way to get better
 *			performance, over typical frame animation.
 */
function videoStatus() {
	amountLoaded = ns.bytesLoaded / ns.bytesTotal;
	controlBar.loadbar._width = amountLoaded * timeLineBar;
	controlBar.thumbScrub._x = ns.time / duration * timeLineBar;
	var temp = tc.getTimecode(ns.time, framerate);
	var tempElapsed = temp.split(".");
	text_elapsedTime.text = tempElapsed[0];
}
function scrubIt() {
	ns.seek(Math.floor((controlBar.thumbScrub._x / timeLineBar) * duration));
	//trace(tc.getTimecode(ns.time, framerate));
}
function scrubToMouse() {
	ns.seek(Math.floor((controlBar._xmouse / timeLineBar) * duration));
	//trace(tc.getTimecode(ns.time, framerate));
}
function scrubIt_endpoint(clip) {
	controlBar.thumbScrub._x = clip._x;
	if (clip._name == "inPoint") {
		var temp = tc.getTimecode(ns.time, framerate);
		var tempIn = temp.split(".");
		inTimeLabel.text = tempIn[0];
	} else {
		var temp = tc.getTimecode(ns.time, framerate);
		var tempOut = temp.split(".");
		outTimeLabel.text = tempOut[0];
	}
	ns.seek(Math.floor((controlBar.thumbScrub._x / timeLineBar) * duration));
	controlBar.selectedArea._x = controlBar.inPoint._x;
	controlBar.selectedArea._width = (controlBar.outPoint._x - controlBar.inPoint._x);
}
function stopPreview() {
	if (ns.time >= draftClip.outpoint) {
		clearInterval(loopInterval);
		stopIt();
	}
}
/**
 * General button functions
 */
function playIt() {
	log.info("playIt()");
	clearInterval(loopInterval);
	// kill the loop play
	if (!playState) {
		ns.pause();
		playState = true;
		this.bu_play._visible = false;
		this.bu_pause._visible = true;
	}
}
function togglePlay() {
	log.info("togglePlay()");
	if (playState) {
		pauseIt();
	} else {
		playIt();
	}
}
function pauseIt() {
	log.info("pauseIt()");
	clearInterval(loopInterval);
	// kill the loop play
	if (playState) {
		ns.pause();
		playState = false;
		this.bu_play._visible = true;
		this.bu_pause._visible = false;
	}
}
function stopIt() {
	log.info("stopIt()");
	clearInterval(loopInterval);
	// kill the loop play
	// set the play button to play
	//playButton.gotoAndStop("play");
	if (playState) {
		ns.pause();
		playState = false;
	}
}
function restartIt() {
	log.info("restartIt()");
	ns.seek(0);
	playIt();
}
function forwardIt() {
	log.info("forwardIt()");
	clearInterval(loopInterval);
	// kill the loop play
	ns.seek(ns.time + 1);
}
function rewindIt() {
	log.info("rewindIt()");
	//ns.seek(0);
	ns.seek(ns.time - 1);
	//stopIt();
}
/**
  * Place each handle at an edit point. This also moves the thumb to the start point.
  *
  * inTime	seconds (2.985) value for inpoint
  * outTime	seconds (22.987) value for outpoint
  * @Note	The duration, controlBar, timeLineBar, currentClip are global values.
  */
function setEditPoints(inTime:Number, outTime:Number, rewindToStart:Boolean):Void {
	log.info("setEditPoints(" + inTime + "," + outTime + "," + rewindToStart + ")");
	if (isNaN(inTime) || isNaN(outTime)) {
		log.error("Inpoint or outpoint is not a number");
		return;
	}
	//if ((inTime >= 0 && outTime >= 0) && (inTime <= outTime)) {                 
	var temp = tc.getTimecode(inTime, framerate);
	var tempIn = temp.split(".");
	text_inPoint.text = tempIn[0];
	temp = tc.getTimecode(outTime, framerate);
	var tempOut = temp.split(".");
	text_outPoint.text = tempOut[0];
	controlBar.outPoint._x = outTime / duration * timeLineBar;
	controlBar.inPoint._x = inTime / duration * timeLineBar;
	controlBar.selectedArea._x = controlBar.inPoint._x;
	controlBar.selectedArea._width = (controlBar.outPoint._x - controlBar.inPoint._x);
	if (rewindToStart) {
		ns.seek(inTime);
	}
	//}                  
}
function setClipOnTimeline(id:String, inTime:Number, outTime:Number):Void {
	controlBar.attachMovie("mc_clipIndicator", id, this.getNextHighestDepth());
	controlBar[id]._y = controlBar.selectedArea._y + controlBar.selectedArea._height + 6;
	controlBar[id]._x = inTime / duration * timeLineBar;
	controlBar[id]._width = (controlBar.outPoint._x - controlBar.inPoint._x);
}
// seando -------------------------------
this.input_jumpSpot.restrict = ": 0-9";
this.input_jumpSpot.maxChars = 8;
var tiListener:Object = new Object();
tiListener.change = function(evt_obj:Object) {
	if (input_jumpSpot.text.length == 2) {
		input_jumpSpot.text += ":";
	}
	if (input_jumpSpot.text.length == 5) {
		input_jumpSpot.text += ":";
	}
};
tiListener.enter = function(eventObject:Object) {
	if (input_jumpSpot.text.length == 8) {
		var newSpot = convertTimeString(input_jumpSpot.text);
		ns.seek(newSpot);
	}
};
this.input_jumpSpot.addEventListener("enter", tiListener);
this.input_jumpSpot.addEventListener("change", tiListener);
var givenClipId = 0;
var currentClipId;
var allClipsArray:Array = new Array();
// load array with some samples
allClipsArray.push({id:givenClipId, inpoint:90.89, outpoint:176.042});
givenClipId++;
allClipsArray.push({id:givenClipId, inpoint:148.247, outpoint:194.226});
givenClipId++;
allClipsArray.push({id:givenClipId, inpoint:179.145, outpoint:219.085});
givenClipId++;
allClipsArray.push({id:givenClipId, inpoint:232.098, outpoint:279.078});
givenClipId++;
allClipsArray.push({id:givenClipId, inpoint:474.239, outpoint:531.997});
givenClipId++;
var currentInPoint;
var currentOutPoint;
function loadSelectedClip(id) {
	for (var i = 0; i < allClipsArray.length; i++) {
		if (id == allClipsArray[i].id) {
			setEditPoints(Number(allClipsArray[i].inpoint), Number(allClipsArray[i].outpoint), true);
			break;
		}
	}
}
function saveClipSection() {
	allClipsArray.push({id:currentClipId, inpoint:draftClip.inpoint, outpoint:draftClip.outpoint});
	givenClipId++;
	this.allClipsHolder.refreshPane();
}
function clearClipSection() {
	// empty selected
	controlBar.inPoint._x = .5;
	controlBar.outPoint._x = .5;
	controlBar.selectedArea._x = 0;
	controlBar.selectedArea._width = 2;
}
function removeSelectedClip() {
	for (var i = 0; i < allClipsArray.length; i++) {
		trace(currentClipId + ", " + allClipsArray[i].id);
		if (currentClipId == allClipsArray[i].id) {
			allClipsArray.splice(i, 1);
			break;
		}
	}
	controlBar[currentClipId].unloadMovie();
	allClipsHolder.refreshPane();
	clearClipSection();
}
this.controlBar.timeLineBar.onRollOver = function() {
	this.useHandCursor = false;
};
this.controlBar.timeLineBar.onRelease = function() {
	scrubToMouse();
};
// tool tip function (unused for now)
// ** usage CaptionFN(true,"test tool tip",999);
// function to create tool tip for locations
function CaptionFN(showCaption, captionText, captionDepth) {
	if (showCaption) {
		this.createEmptyMovieClip("hoverCaption", captionDepth);
		cap.desc.text = captionText;
		cap.BG._width = cap.desc._width + 8;
		// keep tips within the map area
		if ((cap._width + _root._xmouse) > (_root.mc_MapMask._x + controlBar.width)) {
			xo = -2 - cap._width;
		} else {
			xo = 17;
		}
		if ((cap._height + _root._ymouse) > (_root.mc_MapMask._y + controlBar.height)) {
			yo = -2 - cap._width;
		} else {
			yo = -17;
		}
		hoverCaption.onEnterFrame = function() {
			cap._x = this._root._xmouse + xo;
			cap._y = this._root._ymouse + yo;
			cap._visible = true;
		};
	} else {
		delete hoverCaption.onEnterFrame;
		cap._visible = false;
	}
}
Array.prototype.remove = function(obj) {
	//trace("match: " + obj);
	var a = [];
	for (var i = 0; i < this.length; i++) {
		if (this[i] != obj) {
			a.push(this[i]);
		}
	}
	return a;
};
Array.prototype.exists = function(obj) {
	var a;
	for (var i = 0; i < this.length; i++) {
		if (this[i] == obj) {
			a = true;
			break;
		}
	}
	if (a == true) {
		return true;
	} else {
		return false;
	}
};
function convertTimeString(timeString) {
	var inTime = timeString.split(":");
	var hours = int(inTime[0]) / 60;
	var min = int(inTime[1]) * 60;
	var sec = int(inTime[2]);
	var convertedTime = hours + min + sec;
	return convertedTime;
}
//so.setVolume(0);
