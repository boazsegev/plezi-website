# Plezi&#39;s Logging

Plezi offers logging support to help you log any errors or issues to a single common Ruby Logger.

## Setting up a Logger

Logging is based on the standard Ruby `Logger`, and replacing the default logger (STDOUT) with a different logger (such as a file based logger), is as simple as:

    Plezi.logger = Logger.new filename

## Logging Helpers Methods

Plezi supports the most commonly used methods from the [Ruby Logger](http://ruby-doc.org/stdlib-2.2.3/libdoc/logger/rdoc/Logger.html) class.

### `Plezi.info`

Log an INFO message. See[Logger#info](http://ruby-doc.org/stdlib-2.2.3/libdoc/logger/rdoc/Logger.html#method-i-info).

The method will return the string (or object) that was logged, allowing you to reuse the object or clear the string's buffer.

### `Plezi.debug`

Log a DEBUG message. See[Logger#debug](http://ruby-doc.org/stdlib-2.2.3/libdoc/logger/rdoc/Logger.html#method-i-debug).

The method will return the string (or object) that was logged, allowing you to reuse the object or clear the string's buffer.

### `Plezi.warn`

Log a WARN message. See[Logger#warn](http://ruby-doc.org/stdlib-2.2.3/libdoc/logger/rdoc/Logger.html#method-i-warn).

The method will return the string (or object) that was logged, allowing you to reuse the object or clear the string's buffer.

### `Plezi.error`

Log an ERROR message. See[Logger#error](http://ruby-doc.org/stdlib-2.2.3/libdoc/logger/rdoc/Logger.html#method-i-error).

The method will return the string (or object) that was logged, allowing you to reuse the object or clear the string's buffer.

### `Plezi.fatal`

Log a FATAL message. See[Logger#fatal](http://ruby-doc.org/stdlib-2.2.3/libdoc/logger/rdoc/Logger.html#method-i-fatal).

The method will return the string (or object) that was logged, allowing you to reuse the object or clear the string's buffer.

### `Plezi.log(raw_string)`

Logs a raw string to the logging output. Remember to add the `"\n"` when using this method, as it will NOT be added automatically.

The method will return the string (or object) that was logged, allowing you to reuse the object or clear the string's buffer.
