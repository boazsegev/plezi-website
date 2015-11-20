# Plezi&#39;s Logging

Inside Plezi's core code is a pure Ruby IO reactor called [Iodine](https://github.com/boazsegev/iodine), a wonderful Asynchronous Workflow Engine that allows us to enjoy both Multi-Threading and Multi-Processing.

Plezi leverages [Iodine's](https://github.com/boazsegev/iodine) logging support to help you log to both files and STDOUT (terminal screen) - either one or both

You can read more about [Iodine](https://github.com/boazsegev/iodine) and it's amazing features in it's [documentation](http://www.rubydoc.info/github/boazsegev/iodine/master).

## Setting up a Logger

Logging is based on the standard Ruby `Logger`, and replaceing the default logger (STDOUT) to a different logger (such as a file based logger), is as simple as:

    Iodine.logger = Logger.new filename
    # # the same can be done using Plezi.logger, which automatically defers to Iodine.logger
    # Plezi.logger = Logger.new filename


## Logging Helpers Methods

Iodine supports the most commonly used mathods from the [Ruby Logger](http://ruby-doc.org/stdlib-2.2.3/libdoc/logger/rdoc/Logger.html) class.

If you use `Plezi.info` instead of `Iodine.info`, Plezi will simply defer to Iodine for implementing the method. Although, for performance reasons, you might consider using the `Iodine` methods directly.

### `Iodine.info`

Log an INFO message. See[Logger#info](http://ruby-doc.org/stdlib-2.2.3/libdoc/logger/rdoc/Logger.html#method-i-info).

The method will return the string (or object) that was logged, allowing you to reuse the object or clear the string's buffer.

### `Iodine.debug`

Log a DEBUG message. See[Logger#debug](http://ruby-doc.org/stdlib-2.2.3/libdoc/logger/rdoc/Logger.html#method-i-debug).

The method will return the string (or object) that was logged, allowing you to reuse the object or clear the string's buffer.

### `Iodine.warn`

Log a WARN message. See[Logger#warn](http://ruby-doc.org/stdlib-2.2.3/libdoc/logger/rdoc/Logger.html#method-i-warn).

The method will return the string (or object) that was logged, allowing you to reuse the object or clear the string's buffer.

### `Iodine.error`

Log an ERROR message. See[Logger#error](http://ruby-doc.org/stdlib-2.2.3/libdoc/logger/rdoc/Logger.html#method-i-error).

The method will return the string (or object) that was logged, allowing you to reuse the object or clear the string's buffer.

### `Iodine.fatal`

Log a FATAL message. See[Logger#fatal](http://ruby-doc.org/stdlib-2.2.3/libdoc/logger/rdoc/Logger.html#method-i-fatal).

The method will return the string (or object) that was logged, allowing you to reuse the object or clear the string's buffer.

### `Iodine.log(raw_string)`

Logs a raw string to the logging output. Remember to add the `"\n"` when using this method, as it will NOT be added automatically.

The method will return the string (or object) that was logged, allowing you to reuse the object or clear the string's buffer.
