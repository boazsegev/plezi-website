class AIConnection
  NAMES = %w(Finley Kadence Paityn Zander Theresa Lilyana Lewis Waylon Samuel Haiden Saniya Kyson Corinne Neil Maia Gia Lyla Kendrick Aditya Seamus
             Roselyn Ashleigh Hailey Edgar Caio Luis Gustavo Emil Jean Joey Anais Margaret).freeze
  MESSAGES = [
    'Hi!',
    'hi :-)',
    'hi',
    'Hey',
    'hey',
    'hello',
    'Hello',
    'hola',
    'Hola',
    'yo!',
    'Yo',
    'bye',
    'Bye',
    'hello world!',
    'hi world',
    'hello world',
    'test',
    'cool',
    'nice',
    'nice :)',
    'lol',
    'LOL',
    'works',
    'works!',
    "hi ya'll",
    'YO :-)',
    "I'm here!",
    'eat THIS, node.js :p',
    'go bears!',
    'test',
    'I think I saw someone with my handle! Not fair!',
    'Anybody there?',
    "I'm GOD!",
    'I love Ruby',
    "Help! I think I'm an AI...!",
    'I spy guides',
    'I spy source code',
    "I know you're there!",
    'I know you can read this'
  ].dup
  MESSAGES[0..24].each { |m| MESSAGES << m } # make common messages more common.
  def initialize
    @name = NAMES.sample
    Iodine.publish :chat, "#{@name} joind the chat."
    ret = Iodine.run_after(pause) { post_message }
    leave unless ret

  end

  def post_message
    Iodine.publish :chat, "#{@name}: #{MESSAGES.sample}"
    ret = Iodine.run_after(pause) { (rand(1..7).even?) ? post_message : leave }
    leave unless ret
  end

  def pause
    rand(8000..24_000) / 2
  end

  def leave
    Iodine.publish :chat, "#{@name} left the chat."
  end
end
ROOT_PID = Process.pid
# Schedule Robot connection interval.
Iodine.run do
    next unless(Process.pid == ROOT_PID)
    Iodine.run_every(60_000) { AIConnection.new }
end
