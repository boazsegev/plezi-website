# Plezi&#39;s Asynchronous Engine

(todo: write documentation)

Inside Plezi's core code is a pure Ruby IO reactor called [Iodine](https://github.com/boazsegev/iodine), a wonderful Asynchronous Workflow Engine that allows us to enjoy both Multi-Threading and Multi-Processing.

Although multi-threading is highly regarded, it should be pointed out that using the [Iodine](https://github.com/boazsegev/iodine) with just one thread is both faster and more efficient. But, since some tasks that take more time (blocking tasks) can't be broken down into smaller tasks, using a number of threads (and/or processes) is a better practice.

You can read more about [Iodine](https://github.com/boazsegev/iodine) and it's amazing features in it's [documentation](http://www.rubydoc.info/github/boazsegev/iodine/master).

Here we will discuss the methods used for asynchronous processing of different tasks that allow us to break big heavy tasks into smaller bits, allowing our application to 'flow' and stay responsive even while under heavy loads.

## Asynchronous HTTP responses

Inside Plezi's core code is a pure Ruby Http and Websocket Server (and client) that comes with [Iodine](https://github.com/boazsegev/iodine) and allows for native Http/1.1 streaming using `chunked` encoding or native Http/2 streaming (built-in to the protocol).

Asynchronous Http method calls can be nested, but shouldn't be called one after the other.

i.e.:

    # right
    response.stream_async {  response.stream_async {'do after'}; 'do first'  }
    # wrong
    response.stream_async {  "who's first?"  }
    response.stream_async {  "I don't know..."  }

Since streaming is done asynchronously, and since Plezi is multi-threaded by default (this can be changed to single threaded, but is less recomended unless you know your code doesn't block - see `Plezi::Settings.max_threads = number`), Asynchronous HTTP method nesting makes sure that the code doesn't conflict and that race conditions don't occure within the same HTTP response.


### Iodines&#39;s `response.stream_async`

Iodines's response object, which is accessed by the controller using the `response` method (or the `@response` object), allows easy access to HTTP streaming.

For example (run this in the terminal using `irb`):

    require `plezi`

    class MyController
        def index
            response.stream_async do
                response << "This will stream.\n"
                response.stream_async do
                    response << "Streaming can be nested."
                end
            end
        end
    end

    route '/', MyController

    exit

As noted above, `response.stream_async` calls should always be nested and never called in 'parallel'.

Calling `response.stream_async`

### Iodines&#39;s `response.stream_array`

To make nesting easier, Iodines's response object provides the `response.stream_array enum, &block` method.

Here's our modified example:

    require 'plezi'

    class MyController
        def index
            data = ["This will stream.\n", "Streaming can be nested."]
            response.stream_array(data) {|s| response << s}
        end
    end

    route '/', MyController

    exit

You can also add data to the array while 'looping', which allows you to use the array as a 'flag' for looped streaming. The following is a very limited example, which could be used for "lazy loading" data from a database, in order to save on system resources or send large table data using JSON "packets".

    require 'plezi'

    class MyController
        def index
            data = ["This will stream.\n", "Streaming can be nested."]
            flag = [true]
            response.stream_array(flag) do
                response << data.shift
                flag << true unless data.empty?
            end
        end
    end

    route '/', MyController

    exit

## Asynchronous code execution

[Iodine](https://github.com/boazsegev/iodine) has a very powerful Asynchronous Workflow Engine which offers a very intuitve and simplified way to use API both for queuing code snippets (blocks / methods) and for schedualing non-persistent timed events (future timed events are discarded during shutdown and need to be re-initiated).

### The Asynchronous Queue

`Iodine`'s core is built with simplicity in mind, making the programmer happy. With this in mind, Iodine offers a single and simple method that allow us to easily queue code execution.


#### `Plezi.run`

`Plezi.run { block }` (inherited for Iodine) takes a block of code and adds it to the task queue for asynchronous execution.

For example:

    require 'plezi'

    class MyController
        def index
            t = Time.now
            Plezi.run { puts "Someone poked me at: #{t}" } # maybe send an email?
            "Hello World"
        end
    end

    route '/', MyController

    exit

### Timed events

Sometimes we want to schedule something to be done in a while, or maybe we want a task to repeat every certain interval...

In come Iodine's TimedEvents: `Plezi.run_after` and `Plezi.run_every`

#### `Plezi.run_every`

`Plezi.run_every(milliseconds) { block }` is very similar to the `Plezi.run`, except it repeats the task (endlessly) every time the specified timeout (in milliseconds) had been reached.

    require 'plezi'

    class MyController
        def index
            counter = 0
            Plezi.run_every(1000) do
                counter +=1
                puts("Counting %d" % counter)
            end
            "Hello World"
        end
    end


    route '/', MyController

    exit

Iodine directly links these timers to the system's native API (epoll/kqueue) and they take the same resources a single connection would take. These timers tasks persist for the lifetime of the application.

#### `Plezi.run_after`

`Plezi.run_after(milliseconds) { block }` is very similar to the `Plezi.run_every`, except it is designed to "self destruct" after a single execution. This way, even though precious resources are used, they are released immediately once the task is complete.

The timed event allows us to create a new event with the same job, if we wish to.

    require 'plezi'

    class MyController
        def index
            counter = 0
            task = Plezi.run_after(1000)
                counter +=1
                puts "Counting #{counter}/3"
                Plezi.run_after(1000, &task) if (counter < 3)
            end
            "Hello World"
        end
    end

    route '/', MyController

    exit

## The Graceful Shutdown

Sometimes we want to run certain code only when the application is shutting down.

`Plezi.on_shutdown` is a reverse shutdown task queue (LIFO).

At any point while running the application (except during the shutdown process itself), whether initializing the application or running it, we can set up a shutdown task like so:

    Plezi.on_shutdown do
       puts "This is a shutdown task - check it out as the application quits ;-)"
    end
