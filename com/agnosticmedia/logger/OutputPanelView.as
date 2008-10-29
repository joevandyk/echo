import com.agnosticmedia.util.Observer;
import com.agnosticmedia.util.Observable;
import com.agnosticmedia.logger.Logger;
import com.agnosticmedia.logger.LogMessage;

/**
 * An observer of the Logger class. When a movie is played in 
 * the Flash authoring tool's Test Movie mode, this class displays
 * log messages in the Output panel.
 */
class com.agnosticmedia.logger.OutputPanelView implements Observer {
  // The log that this object is observing.
  private var log:Logger;

  /**
   * Constructor
   */
  public function OutputPanelView (l:Logger) {
    log = l;
  }

  /**
   * Invoked when the log changes. For details, see the 
   * Observer interface.
   */
  public function update (o:Observable, infoObj:Object):Void {
    // Cast infoObj to a LogMessage instance for type checking.
    var logMsg:LogMessage = LogMessage(infoObj);
    trace(Logger.getLevelDesc(logMsg.getLevel()) + ": " + logMsg.getMessage());
  }

  public function destroy ():Void {
    log.removeObserver(this);
  }
}