class AIConnection
	NAMES = ["Finley", "Kadence", "Paityn", "Zander", "Theresa", "Lilyana", "Lewis", "Waylon", "Samuel", "Haiden", "Saniya", "Kyson", "Corinne", "Neil", "Maia", "Gia", "Lyla", "Kendrick", "Aditya", "Seamus",
		"Roselyn", "Ashleigh", "Hailey", "Edgar", "Caio", "Luis", "Gustavo", "Emil", "Jean", "Joey", "Anais", "Margaret"]
	MESSAGES = [
		"Hi!",
		"hi :-)",
		"hi",
		'Hey',
		'hey',
		'hello',
		'Hello',
		'hola',
		'Hola',
		"yo!",
		"Yo",
		"bye",
		"Bye",
		"hello world!",
		"hi world",
		"hello world",
		"test",
		"cool",
		"nice",
		"nice :)",
		"lol",
		"LOL",
		"works",
		"works!",
		"hi ya'll",
		"YO :-)",
		"I'm here!",
		"eat THIS, node.js :p",
		"I think I saw someone with my handle! Not fair!",
		"Anybody there?",
		"I'm GOD!",
		"I love Ruby",
		"Help! I think I'm an AI...!",
		"I spy guides",
		"I spy source code",
		"I know you're there!",
		"I know you can read this"
		]
	MESSAGES[0..24].each {|m| MESSAGES << m}
	def initialize
		@name = NAMES.sample
		HomeController.broadcast :print, "#{@name} joind the chat."
		Iodine.run_after(pause) { post_message }
		# options = {}
		# options[:on_open] = Proc.new { Iodine.run_after(pause) { write MESSAGES.sample; rand(1..7).even? ? (Iodine.run_after(pause) { close }) : Iodine.run_after(pause) {on_open} } }
		# options[:on_message] = Proc.new {|data| }
		# options[:url] = "ws://localhost:#{Iodine.port}/#{name}"
		# Iodine::Http.ws_connect options
	end
	def post_message
		HomeController.broadcast :print, "#{@name}: #{MESSAGES.sample}"
		return Iodine.run_after(pause) { post_message } unless rand(1..7).even? # last?
		Iodine.run_after(pause) { leave }
	end
	def pause
		rand(8..24)/4.0
	end
	def leave
		HomeController.broadcast :print, "#{@name} left the chat."
	end
end

Iodine.run_every(16) { AIConnection.new }
