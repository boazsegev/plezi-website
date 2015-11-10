class AIConnection
	NAMES = ["Finley", "Kadence", "Paityn", "Zander", "Theresa", "Lilyana", "Lewis", "Waylon", "Samuel", "Haiden", "Saniya", "Kyson", "Corinne", "Neil", "Maia", "Gia", "Lyla", "Kendrick", "Aditya", "Seamus",
		"Roselyn", "Ashleigh", "Hailey", "Edgar", "Caio", "Luis", "Gustavo", "Emil", "Jean", "Joey", "Anais", "Margaret"]
	MESSAGES = [
		"Hi!",
		"hi :-)",
		"hi",
		"yo!",
		"YO :-)",
		"Yo",
		"I think I saw someone with my handle! Not fair!",
		"hello world!",
		"hi world",
		"hello world",
		"test",
		"cool",
		"nice",
		"works",
		"Anybody there?",
		"I'm GOD!",
		"I love Ruby",
		"hi ya'll",
		"lol",
		"Help! I think I'm an AI...!",
		"bye",
		"Bye"
		]
	def initialize
		pause = rand(8..16)/5.0
		name = NAMES.sample
		message = MESSAGES.sample
		options = {}
		options[:on_open] = Proc.new { Iodine.run_after(pause) { write message; Iodine.run_after(pause) { close } } } 
		options[:on_message] = Proc.new {|data| }
		options[:url] = "ws://localhost:#{Iodine.port}/#{name}"
		Iodine::Http.ws_connect options
	end
end

Iodine.run_every(16) { AIConnection.new }
