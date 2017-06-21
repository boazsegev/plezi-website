# Plezi&#39;s Asynchronous Engine

Inside Plezi's core code is an IO reactor called [Iodine](https://github.com/boazsegev/iodine), implemented in C using `kqueue` or `epoll`. Iodine's intuitive engine allows us to enjoy both Multi-Threading and Multi-Processing.

Although multi-threading is highly regarded, it should be pointed out that using the [Iodine](https://github.com/boazsegev/iodine) with just one thread is both faster and more efficient, especially when considering Ruby's GVL (Global VM Lock). However, when writing web applications, using a number of threads (and/or processes) is a better practice and should improve responsiveness (even if at the cost of speed).

You can read more about [Iodine](https://github.com/boazsegev/iodine) and it's ansychronouse IO engine features in Iodine's [documentation](http://www.rubydoc.info/github/boazsegev/iodine/master).

Here we will discuss the methods used for asynchronous processing of different tasks that allow us to break big heavy tasks into smaller bits, allowing our application to 'flow' and stay responsive even while under heavy loads.

## HTTP streaming, SSE, long polling and friends

A word, before we continue, about HTTP streaming, SSE (Server Side Events), long polling and friends.

Plezi is a Rack based framework (starting with Plezi 0.14.0). This, sadly, means that HTTP streaming, SSE and long polling are very hard to achive.

On the bright side, Plezi make Websockets easy to implement (and yes, it's easy to use websockets to stream long responses), allowing us to utilize a more optimized solution for accomplishing the same goal.

Having said that, whatever "hacks" normally used with Rack for initiating HTTP streaming, SSE or long polling connections should work (or fail) in the same way.

## Asynchronous code execution

[Iodine](https://github.com/boazsegev/iodine) has a very powerful Asynchronous Workflow Engine which offers a very intuitve and simplified way to use API both for queuing code snippets (blocks / methods) and for schedualing non-persistent timed events (future timed events are discarded during shutdown and need to be re-initiated).

### The Asynchronous Queue

`Iodine`'s core is built with simplicity in mind, making the programmer happy. With this in mind, Iodine offers a single and simple method that allow us to easily queue code execution.


#### `Iodine.run`

`Iodine.run { block }` takes a block of code and adds it to the task queue for asynchronous execution.

For example:

    require 'plezi'

    class MyController
        def index
            t = Time.now
            Iodine.run { puts "Someone poked me at: #{t}" } # maybe send an email?
            "Hello World"
        end
    end

    Plezi.route '/', MyController

    exit

### Connection bound execution (`defer`)

`Iodine::Protocol#defer { block }` and `Iodine::Websocket#defer { block }` are very similar to the `Iodine.run`, except they are connection bound and will only execute if the connection is still alive.

These methods cause the `block` to execute within the connection's lock, meaning it is safe to update connection data as long as all updates occure either within the connection's `on_message` callback or within a `defer` block.

    require 'plezi'

    class MyController
        def on_message data
            @count = 0
            4.times do
              defer do
                tmp = @count
                # do stuff, maybe takes time
                write "[#{tmp}] start"
                sleep(0.5)
                write "[#{tmp}] finish"
                @count = tmp + 1
              end
            end
        end
    end

    Plezi.route '/', MyController

    exit

    # @count will always end up as 4, actions always performed "atomically".

### Timed events

Sometimes we want to schedule something to be done in a while, or maybe we want a task to repeat every certain interval...

In come Iodine's TimedEvents: `Plezi.run_after` and `Plezi.run_every`

#### `Iodine.run_every`

`Iodine.run_every(milliseconds, repetitions = 0) { block }` is very similar to the `Iodine.run`, except it repeats the task (endlessly or a few times) every time the specified timeout (in milliseconds) had been reached.

    require 'plezi'

    class MyController
        def index
            counter = 0
            Iodine.run_every(1000, 10) do
                counter +=1
                puts("Counting %d out of 10" % counter)
            end
            "Hello World"
        end
    end


    Plezi.route '/', MyController

    exit

Iodine directly links these timers to the system's native API (epoll/kqueue) and they take the same resources a single connection would take. These timers tasks persist for the lifetime of the application.

#### `Iodine.run_after`

`Iodine.run_after(milliseconds) { block }` is very similar to the `Iodine.run_every`, except it is designed to "self destruct" after a single execution. This way, even though precious resources are used, they are released immediately once the task is complete.

The timed event allows us to create a new event with the same job, if we wish. However, using `Iodine.run_every` will be more efficient when the limit is known in advance.

    require 'plezi'

    class MyController
        def index
            counter = 0
            task = Iodine.run_after(1000)
                counter +=1
                puts "Counting #{counter}/3"
                Iodine.run_after(1000, &task) if (counter < 3)
            end
            "Hello World"
        end
    end

    Plezi.route '/', MyController

    exit
