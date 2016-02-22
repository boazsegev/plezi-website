# Plezi&#39;s Asynchronous Engine

Plezi core code runs on top of Rack, using [Iodine's Rack server](https://github.com/boazsegev/iodine), which offers an evented Workflow Engine that allows us to enjoy both Multi-Threading and Multi-Processing.

Although multi-threading is highly regarded, it should be pointed out that using [Iodine](https://github.com/boazsegev/iodine) with just one thread is both faster and more efficient, as it's evented design allows us to avoid the cost of context switching... However, Rack isn't designed for an evented workflow, so that multi-threading is required when handling longer responses.

You can read more about [Iodine](https://github.com/boazsegev/iodine) and it's amazing features in it's [documentation](http://www.rubydoc.info/github/boazsegev/iodine/master).

Here we will discuss the methods used for asynchronous processing of different tasks that allow us to break big heavy tasks into smaller bits, allowing our application to 'flow' and stay responsive even while under heavy loads.

## Asynchronous HTTP responses

Starting with Iodine 0.2.x and Plezi 0.13.x, HTTP streaming is no longer natively supported. However, Iodine supports the `hijack` API, allowing developers to manually stream data using the hijacked IO.

## Asynchronous code execution

[Iodine](https://github.com/boazsegev/iodine) has a very powerful Asynchronous Workflow Engine which offers a very intuitve and simplified way to use API both for queuing code snippets (blocks / methods) and for schedualing non-persistent timed events (future timed events are discarded during shutdown and need to be re-initiated).

### The Asynchronous Queue

`Iodine`'s core is built with simplicity in mind, making the programmer happy. With this in mind, Iodine offers a single and simple method that allow us to easily queue code execution.


#### Run a task in parallel using `Plezi.run`

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

#### Schedule a connection related task using `Websocket#defer`

`Websocket#defer { block }` (inherited for Iodine) is similar to `Plezi.run`, except that the task will be performed within the connection's lock, preventing a websocket connection from running this task while performing another connection related tasks (such as broadcast or message handling).

The method (unless overridden) is available from within the controller. i.e.:

    def on_message data
       defer { puts "Upcoming websockets events will wait for this code to finish." }
    end

### Timed events

Starting with Plezi 0.13.x (and Iodine 0.2.x), timed events support had dramatically changed, so that timed events have moved from polling the Ruby layer to using system calls. Although the basic API seems unchanged, the change is actually dramatic and there is no available Ruby API will stop a timer once initiated.

Timed events are initiated using either `Plezi.run_after` or `Plezi.run_every`

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
            task = Plezi.run_after(1000) do
                counter +=1
                puts "Counting #{counter}/3"
                Plezi.run_after(1000, &task) if (counter < 3)
            end
            "Hello World"
        end
    end

    route '/', MyController

    exit

## Setting up the tasks

Asynchronous code execution is only available after Iodine is up and running - hence, to setup timed events or run globally asynchronous, they should be initiated within a `Plezi.on_start` block.

To demonstrate, the following piece of code prints out the number of connected clients every second (HTTP + Websocktes):

    Plezi.on_start do
        Plezi.run_every(1_000) { puts "There are #{Plezi.count} connected clients." }
    end
