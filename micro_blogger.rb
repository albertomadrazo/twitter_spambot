require 'jumpstart_auth'
require 'bitly'
require 'klout'

class MicroBlogger
	attr_reader :client

	def initialize
		puts "Initializing..."
		@client = JumpstartAuth.twitter
		Klout.api_key = 'xu9ztgnacmjx3bu82warbr3h'
	end

	def tweet(message)
		ok = check_message_length(message)

		if ok
			@client.update(message)			
			puts "Message sent."
		else
			puts "Your message is too long (#{message.length}) it won't make it through Twitter. 140 characters max."
		end
	end

	def everyones_last_tweet
		puts "HIA..."
		friends = @client.friends

		friends = @client.friends.sort_by{|friend| @client.user(friend).screen_name.downcase}
		
		friends.each do |friend|
			puts @client.user(friend).screen_name
			puts @client.user(friend).status.text
			timestamp = @client.user(friend).status.created_at
			puts timestamp.strftime("%A, %b %d")
			puts ""
		end
	end

	def dm(target, message)
		puts "Trying to reach #{target} with this message:"
		puts message

		if follows_you?(target)
			message = "d @#{target} #{message}"
			tweet(message)
		else
			puts "You can only DM people who follow you."
		end
	end

	def spam_my_followers(message)
		screen_names = followers_list
		screen_names.each{|follower| dm(follower, message)}
	end

	def followers_list
		screen_names = @client.followers.collect{|follower| @client.user(follower).screen_name}
	end

	def friends_list
		screen_names = @client.friends.collect{|friend| @client.user(friend).screen_name}
	end

	def follows_you?(target)
		screen_names = followers_list
		target_follows_you = screen_names.include?(target)
	end

	def shorten(original_url)
		Bitly.use_api_version_3
		bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
		bitly.shorten(original_url).short_url
	end

	def tweet_with_url(message, original_url)
		short_url = shorten(original_url)
		message = "#{message} #{short_url}"
		tweet(message)
	end

	def klout_score
		friends = friends_list

		puts "Your friends Klout Score:"

		friends.each do |friend|
			identity = Klout::Identity.find_by_screen_name(friend.screen_name)
			user = Klout::user.new(identity.id)
			puts "#{friend.screen_name} - #{user.score.score}"
			puts ""
		end

	end

	def run
		puts "Welcome to the JSL Twitter Client!"
		input = ""
		parts =[]
		while input != "q"
			printf "enter command: "
			input = gets.chomp
			parts = input.split(" ")
			command = parts[0]
			case command

				when 'q' then puts "Goodbye!"
				when 't' then tweet(parts[1..-1].join(" "))
				when 'dm' then dm(parts[1], parts[2..-1].join(" "))
				when 'spam' then spam_my_followers(parts[1..-1].join(" "))
				when 'elt' then everyones_last_tweet
				when 'sh' then puts shorten(parts[1])
				when 'turl' then tweet_with_url(parts[1..-2].join(" "), parts[-1])
				when 'klout' then klout_score
				else
					puts "Sorry, I don't know how to #{command}"
			end
		end
	end

	def check_message_length(message)
		message.length <= 140
	end

end

blogger = MicroBlogger.new
blogger.run