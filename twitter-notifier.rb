#!/usr/bin/env ruby
# encoding: utf-8
#
# gem install twitter libnotify rufus-scheduler
#

require 'twitter'
require 'libnotify'
require 'net/http'

#
# TODO : use daemons to run the script as daemon http://daemons.rubyforge.org/
#


#
# User Settings - Change the following values only with yours
#
CONSUMER_KEY        = "PUT YOUR CONSUMER KEY HERE"
CONSUMER_SECRET     = "PUT YOUR CONSUMER SECRET HERE"
OAUTH_TOKEN         = "PUT YOUR TOKEN HERE"
OAUTH_TOKEN_SECRET  = "PUT YOUR TOKEN SECRET HERE"
NOTIFY_ME_EACH      = 180   # Second
NUM_OF_MENTIONS     = 10
NUM_OF_DIRECT_MSGS  = 5
NUM_OF_FOLLOWERS    = 5
TWITTER_CHECK_PERIOD= 180   # 180 second is the Minimum otherwise twitter will block you ;)



class GetInfo

    def initialize(oauth_token, oauth_token_secret)
        @consumer_key       = CONSUMER_KEY
        @consumer_secret    = CONSUMER_SECRET
        @oauth_token        = oauth_token
        @oauth_token_secret = oauth_token_secret

        #
        # Application settings
        #
        Twitter.configure do |config|
            config.consumer_key       = @consumer_key
            config.consumer_secret    = @consumer_secret
        end
        #
        # Oauth of user - should not be shared!
        #
        @client = Twitter::Client.new(
                    :oauth_token        => @oauth_token ,
                    :oauth_token_secret => @oauth_token_secret
                  )
    end

    #
    # Find last @number of mentions
    #
    def mentions(num)
        # puts the last 10 mentions in queue and check the next if any of theme is exist , delete it from the queue
        last_mentions = @client.mentions_timeline.first(num).map do |data|
                {:id => data[:id] , :name => data[:user][:name], :account => data[:user][:screen_name],
                 :img => data[:profile_image_url_https], :text => data[:text]}
        end

        return last_mentions # [{:id => data[:id] , :name => data[:user][:name] , :account => data[:user][:screen_name] , :img => data[:profile_image_url_https] , :text => data[:text]}]
    end

    #
    # Find last @number of direct messages
    #
    def direct_messages(num)
        last_messages = @client.direct_messages.first(num).map do |data|
                {:id => data[:id] , :name => data[:sender][:name] , :account => data[:sender][:screen_name] ,
                 :img => data[:sender][:profile_image_url_https] , :text => data[:text]}
        end

        return last_messages # [{:id => data[:id] , :name => data[:sender][:name] , :account => data[:sender][:screen_name] , :img => data[:sender][:profile_image_url_https] , :text => data[:text]}]
    end

    def favorites(num)
        # TODO
        # @client.favorites
        # favo[0][:id]
        # favo[0][:name]
        # favo[0][:screen_name]
        # favo[0][:text]
        # favo[0][:user][:]
    end

    # FIXME - get the followers info
    def followers(num)
        last_followers = @client.followers

    end

end


class Notifier

    def initialize
        Dir.mkdir("cache") if !Dir.exist?("cache")
    end

    def notify(info)
        image = get_avatar(info[:account] , info[:img])
        Libnotify.show(
                :summary => "[ Mention ]\n @#{info[:account]} - #{info[:name]}",
                :body => info[:text], :icon_path => image, :timeout => 5
        )
    end

    #
    # Download user's avatar
    #
    def get_avatar(account, avatar_url)
        uri = URI.parse(avatar_url)
        ext = File.extname(uri.path)

        unless File.exist?("cache/#{account}#{ext}")
            begin

                http = Net::HTTP.new(uri.host , uri.port)
                http.use_ssl = true if uri.scheme == 'https'
                response = http.get(uri.path)
                open("cache/#{account}#{ext}", 'wb') do |file|
                    file.write(response.body)
                end

            rescue Exception => e
                puts e
            end
        end

        return File.expand_path("cache/#{account}#{ext}")
    end

end



getinfo  = GetInfo.new(OAUTH_TOKEN , OAUTH_TOKEN_SECRET)
notifier =  Notifier.new

#
# Showtime ;)
#
begin

    mentions_queue = []

    while true

        #
        # Mentions notification
        #
        last_mentions = getinfo.mentions(NUM_OF_MENTIONS)

        if mentions_queue.empty?
            mentions_queue = last_mentions
        else
            # Repeated mentions
            mentions_queue = last_mentions & mentions_queue

            # Delete repeated mentions
            # FIXME , BY THIS WAY IT WILL REPEAT THE REPEATED TWEETES EVERY 6 MINUTES , GENIUS
            mentions_queue.each do |repeated|
                last_mentions.delete(repeated)
            end
        end

        last_mentions.each do |mention|
            notifier.notify(mention)
            sleep 0.80
        end
        mentions_queue = last_mentions

        ##
        ## Direct messages notification
        ##
        #last_dms = getinfo.direct_messages(NUM_OF_DIRECT_MSGS)
        #
        #if mentions_queue.empty?
        #    dir_msgs_queue = last_dms
        #else
        #    # Repeated mentions
        #    dir_msgs_queue = last_dms & dir_msgs_queue
        #
        #    # Delete repeated mentions
        #    dir_msgs_queue.each do |repeated|
        #        last_dms.delete(repeated)
        #    end
        #end
        #
        #last_dms.each do |mention|
        #    notifier.notify(mention)
        #    sleep 0.80
        #end
        #mentions_queue = last_dms


        sleep TWITTER_CHECK_PERIOD
    end

rescue Exception => e
    puts  e
end


