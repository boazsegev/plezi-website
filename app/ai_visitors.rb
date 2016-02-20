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
		"go bears!",
		"test",
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
	MESSAGES[0..24].each {|m| MESSAGES << m} # make common messages more common.
	def initialize
		@name = NAMES.sample
		HomeController.broadcast :print, "#{@name} joind the chat."
		Iodine.run_after(pause) { post_message }
	end
	def post_message
		HomeController.broadcast :print, "#{@name}: #{MESSAGES.sample}"
		return Plezi.run_after(pause) { post_message } unless rand(1..7).even? # last?
		Plezi.run_after(pause) { leave }
	end
	def pause
		rand(8..24)/2.0
	end
	def leave
		HomeController.broadcast :print, "#{@name} left the chat."
	end
end

Plezi.on_start do
	Plezi.run_every(60_000) { AIConnection.new }
end
