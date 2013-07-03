#!/usr/bin/env ruby
# encoding: utf-8
#
# gem install twitter libnotify
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
NOTIFY_ME_EACH      = 80   # Second.
NUM_OF_MENTIONS     = 10
NUM_OF_DIRECT_MSGS  = 5
NUM_OF_FOLLOWERS    = 5




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
            config.consumer_key    = @consumer_key
            config.consumer_secret = @consumer_secret
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

    def notify(info , title)
        image = get_avatar(info[:account] , info[:img])
        Libnotify.show(
                :summary => "[ #{title} ]\n @#{info[:account]} - #{info[:name]}",
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

    mentions_queue  = []
    unique_mentions = []
    dirmsg_queue    = []
    unique_dirmsg   = []

    while true

        #
        # Mentions
        #
        last_mentions = getinfo.mentions(NUM_OF_MENTIONS)

        if mentions_queue.empty?
            mentions_queue  = last_mentions
            unique_mentions = last_mentions
        else
            # Unique mentions
            unique_mentions = last_mentions - mentions_queue
            mentions_queue  = last_mentions
        end

        #
        # Direct messages
        #
        last_dirmsgs = getinfo.direct_messages(NUM_OF_DIRECT_MSGS)
        if dirmsg_queue.empty?
            dirmsg_queue  = last_dirmsgs
            unique_dirmsg = last_dirmsgs
        else
            # Unique mentions
            unique_dirmsg = last_dirmsgs - dirmsg_queue
            dirmsg_queue  = last_dirmsgs
        end

        #
        # Notifications
        #
        unique_mentions.each do |mention|
            notifier.notify(mention, "Mentions")
            sleep 0.80
        end
        unique_dirmsg.each do |dm|
            notifier.notify(dm, "Direct Message")
            sleep 0.80
        end

        sleep NOTIFY_ME_EACH
    end

rescue Exception => e
    puts  e
end

