import com.agnosticmedia.util.Observable;
import com.agnosticmedia.logger.LogMessage;

/**
 * A general log class. Use getLog() to create an app-wide instance.
 * Send messages with fatal(), error(), warn(), info(), and debug().
 * Add views for the log with addObserver() (views must implement Observer).
 * 
 * @version 1.0.0
 */
class com.agnosticmedia.logger.Logger extends Observable {
  // Static variable. A reference to the log instance (Singleton).
  private static var log:Logger = null;

  // The possible log levels for a message.
  public static var FATAL:Number = 0;
  public static var ERROR:Number = 1;
  public static var WARN:Number  = 2;
  public static var INFO:Number  = 3;
  public static var DEBUG:Number = 4;

  private var lastMsg:LogMessage;

  // The human-readable descriptions of the above log levels.
  public static var levelDescriptions = ["FATAL", "ERROR", 
                                         "WARN", "INFO", "DEBUG"];

  // The zero-relative filter level for the log. Messages with a level 
  // above logLevel will not be passed on to observers.
  // Default is 3, "INFO" (only DEBUG messages are filtered out).
  private var logLevel:Number;

  /**
   * Logger Constructor
   */
  private function Logger () {
    // Show "INFO" level messages by default.
    setLevel(Logger.INFO);   
  }

  /**
   * Returns a reference to the log instance.
   * If no log instance exists yet, creates one.
   *
   * @return   A Logger instance.
   */
  public static function getLog():Logger {
    if (log == null) {
      log = new Logger();
    }
    return log;  
  }

  /**
   * Returns a human readable string representing the specified log level.
   */
  public static function getLevelDesc(level:Number):String {
    return levelDescriptions[level];
  }

  /**
   * Sets the message filter level for the log.
   *
   * @param   lev   The level above which messages are filtered out.
   */
  public function setLevel(lev:Number):Void {
    // Make sure the supplied level is an integer.
    lev = Math.floor(lev);
    // Set the log level if it's one of the acceptable levels.
    if (lev >= Logger.FATAL && lev <= Logger.DEBUG) {
      logLevel = lev;
      info("Log level set to: " + lev);
      return;
    }
    // If we get this far, the log level isn't valid.
    warn("Invalid log level specified.");
  }

  /**
   * Returns the message filter level for the log.
   */
  public function getLevel():Number {
    return logLevel;
  }

  /**
   * Returns the most recent message sent to the log.
   */
  public function getLastMsg():LogMessage {
    return lastMsg;
  }

  /**
   * Sends a message to the log, with severity "FATAL".
   */
  public function fatal(msg:String):Void {
    // If the filter level is at least "FATAL", broadcast the message to observers.
    if (logLevel >= Logger.FATAL) {
      // Construct the log message object.
      lastMsg = new LogMessage(msg, Logger.FATAL);

      // Pass the message on to observers.
      setChanged();
      notifyObservers(lastMsg);
    }
  }

  /**
   * Sends a message to the log, with severity "ERROR".
   */
  public function error(msg:String):Void {
    // If the filter level is at least "ERROR", broadcast the message to observers.
    if (logLevel >= Logger.ERROR) {
      lastMsg = new LogMessage(msg, Logger.ERROR);

      setChanged();
      notifyObservers(lastMsg);
    }
  }

  /**
   * Sends a message to the log, with severity "WARN".
   */
  public function warn(msg:String):Void {
    // If the filter level is at least "WARN", broadcast the message to observers.
    if (logLevel >= Logger.WARN) {
      lastMsg = new LogMessage(msg, Logger.WARN);

      setChanged();
      notifyObservers(lastMsg);
    }
  }
  
  /**
   * Sends a message to the log, with severity "INFO".
   */
  public function info(msg:String):Void {
    // If the filter level is at least "INFO", broadcast the message to observers.
    if (logLevel >= Logger.INFO) {
      lastMsg = new LogMessage(msg, Logger.INFO);

      setChanged();
      notifyObservers(lastMsg);
    }
  }

  /**
   * Sends a message to the log, with severity "DEBUG".
   */
  public function debug(msg:String):Void {
    // If the filter level is at least "DEBUG", broadcast the message to observers.
    if (logLevel >= Logger.DEBUG) {
      lastMsg = new LogMessage(msg, Logger.DEBUG);

      setChanged();
      notifyObservers(lastMsg);
    }
  }
}