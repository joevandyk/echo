import com.agnosticmedia.util.Observer;
import com.agnosticmedia.util.Observable;
import com.agnosticmedia.logger.Logger;
import com.agnosticmedia.logger.LogMessage;

/**
 * An observer of the Logger class. This class displays
 * messages sent to the log in an on-screen text field.
 */
class com.agnosticmedia.logger.TextFieldView implements Observer {
  // The log that this object is observing.
  private var log:Logger;
  // A reference to the text field.
  private var out:TextField;

  /**
   * TextFieldView Constructor
   */
  public function TextFieldView (l:Logger,
                                 target:MovieClip, 
                                 depth:Number, 
                                 x:Number,
                                 y:Number,
                                 w:Number,
                                 h:Number) {
    log = l;
    makeTextField(target, depth, x, y, w, h);
  }

  /**
   * Invoked when the log changes. For details, see the 
   * Observer interface.
   */
  public function update (o:Observable, infoObj:Object):Void {
    // Cast infoObj to a LogMessage instance for type checking.
    var logMsg:LogMessage = LogMessage(infoObj);
    // Display the log message in the log text field.
    out.text += Logger.getLevelDesc(logMsg.getLevel()) 
             + ": " + logMsg.getMessage()  + "\n";
    // Scroll to the bottom of the log text field.
    out.scroll = out.maxscroll;
  }

  /**
   * Creates a text field in the specified movie clip at
   * the specified depth. Log messages are displayed in the text field.
   */
  public function makeTextField (target:MovieClip, 
                              depth:Number,
                              x:Number,
                              y:Number,
                              w:Number,
                              h:Number):Void {
    // Create the text field.
    target.createTextField("log_txt", depth, x, y, w, h);
    // Store a reference to the text field.
    out = target.log_txt;
    // Put a border on the text field.
    out.border = true;
	// Set the background color to white.
	out.background = true; 
    // Make the text in the text field wrap.
    out.wordWrap = true;
	// hide the field
	out._visible = false;
  }

 public function showTextField ():Void {
	out._visible = true;
	}

  public function hideTextField ():Void {
		out._visible = false;
	}

  public function isFieldVisible ():Boolean {
		return out._visible;
	}

  public function destroy ():Void {
    log.removeObserver(this);
    out.removeTextField();
  }
}