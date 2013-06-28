#!/usr/bin/env ruby
# encoding: utf-8
#
# gem install twitter libnotify rufus-scheduler
#

require 'twitter'
require 'libnotify'
require 'net/http'
require 'rufus/scheduler'

#
# TODO : use daemons to run the script as daemon http://daemons.rubyforge.org/
#


#
# User Settings - Change the following values only with yours
#
CONSUMER_KEY        = ""
CONSUMER_SECRET     = ""
OAUTH_TOKEN         = ""
OAUTH_TOKEN_SECRET  = ""
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
                :body => info[:text], :icon_path => image, :timeout => 10
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



=begin
check last 10 mentions
check last 5 DM
check last 5 followers

save last 10 mentions_ids in queue
check last new 10 followers
if any one of last new mentions ids exist in the queue then delete it
clear the queue , then add the last new mentions in the queue
send notification
=end
getinfo = GetInfo.new(OAUTH_TOKEN , OAUTH_TOKEN_SECRET)
notify =  Notifier.new
getinfo.direct_messages(NUM_OF_DIRECT_MSGS)

while true

    last_mentions = getinfo.mentions(NUM_OF_MENTIONS)
    mention_ids   = last_mentions.map do |mention|
        mention[:id]
    end


    # repeated mentions_queue
    mentions_queue = mentions_queue & mention_ids1

    # Unique mentions
    mentions_queue.map do |repeated|
        mention_ids1.delete(repeated)
    end

    new_mentions.each do |mention|
        next if mentions_queue.include?mention[:id]
        p mention[:id]
        p mention
    end


    sleep TWITTER_CHECK_PERIOD
end



#getinfo = GetInfo.new(OAUTH_TOKEN , OAUTH_TOKEN_SECRET)
#p getinfo.mentions(10)
#puts
#p getinfo.direct_messages(5)


# [{:id=>350364868580347907, :name=>"♛KING SABRI", :account=>"KINGSABRI", :img=>"https://si0.twimg.com/profile_images/3286433187/399d60de067aa00d54324a7943a3c1aa_normal.jpeg", :text=>"@KINGSABRI test 1\nلا تدقق جالس أسوي سكريبت :)"}, {:id=>350346231127605248, :name=>"Mohammed AL Jeaid", :account=>"Linux4SA", :img=>"https://si0.twimg.com/profile_images/2436743720/Screenshot-15_2_normal.png", :text=>"@KINGSABRI لااله الا الله حق ... اللهم صل وسلم على حبيبنا محمد .... :D"}, {:id=>350345670433050624, :name=>"Mohammed AL Jeaid", :account=>"Linux4SA", :img=>"https://si0.twimg.com/profile_images/2436743720/Screenshot-15_2_normal.png", :text=>"@KINGSABRI اجل اذا رحت البيت انا بشيك وعطيك خبر .. عشرين شغله بيدك اخطبوط انت .. ركز بشغلك يامكينه"}, {:id=>350344773728612354, :name=>"Mohammed AL Jeaid", :account=>"Linux4SA", :img=>"https://si0.twimg.com/profile_images/2436743720/Screenshot-15_2_normal.png", :text=>"@KINGSABRI ليش الغلط الحين :D كيف مالقيت شي اشتريت والا باقي"}, {:id=>350344207019417600, :name=>"Mohammed AL Jeaid", :account=>"Linux4SA", :img=>"https://si0.twimg.com/profile_images/2436743720/Screenshot-15_2_normal.png", :text=>"@KINGSABRI مو كان احد نسي احد .. والا كيف يا اجنبي"}, {:id=>350297343997915136, :name=>"م/ فهد الباز", :account=>"fahadalbaz", :img=>"https://si0.twimg.com/profile_images/1796099316/FAHAD_ALBAZ_normal.gif", :text=>"@KINGSABRI هههههههه. اشغل بالبايثون ولا تشوف الطل"}, {:id=>350263258952904704, :name=>"أنس أحمد", :account=>"AnassAhmed", :img=>"https://si0.twimg.com/profile_images/3659902971/cdcdeabce194eeb3e045c70126bec02c_normal.jpeg", :text=>"@KINGSABRI LOL :D\nالجميلة واخدة حقها وزيادة ومش محتاجة ^_^"}, {:id=>350259366827536384, :name=>"ام يوسف ", :account=>"nohaelfayoumy", :img=>"https://si0.twimg.com/profile_images/344513261576878452/0b0cbac51fbec2f7934b3745a07d6d8b_normal.jpeg", :text=>"@KINGSABRI @ChaimaaElbassel مافيش حاجه بتنقرض فى البلد دى"}, {:id=>350259245515677696, :name=>"ام يوسف ", :account=>"nohaelfayoumy", :img=>"https://si0.twimg.com/profile_images/344513261576878452/0b0cbac51fbec2f7934b3745a07d6d8b_normal.jpeg", :text=>"@ChaimaaElbassel @KINGSABRI يعيشى ليه :))"}, {:id=>350258954426793984, :name=>" شِيَمُ ʚϊɞ", :account=>"ChaimaaElbassel", :img=>"https://si0.twimg.com/profile_images/3785004749/cae86d9e89ca5ec694b5c28ea112d143_normal.jpeg", :text=>"@nohaelfayoumy @KINGSABRI انا اجيبلك المصدر بنفسه يقولك يا نًها مش دى ام بس:))"}]
# [{:id=>349929418334019584, :name=>"Mohannad Alqouba", :account=>"MohannadAlqouba", :img=>"https://si0.twimg.com/profile_images/3308639864/51dc8221e18fa799610d3d61aa3423a1_normal.jpeg", :text=>"ان شاء الله بإذن الله :-)"}, {:id=>349874097066504192, :name=>"Mohannad Alqouba", :account=>"MohannadAlqouba", :img=>"https://si0.twimg.com/profile_images/3308639864/51dc8221e18fa799610d3d61aa3423a1_normal.jpeg", :text=>"السلام عليكم ورحمة الله وبركاته اكتشف بالمصادفه انني اقابلك كل يوم تقريباً فعلاً انت ذو خلق في الحياه الافتراضية و الواقعية وكما يذكرونه عنك"}, {:id=>342083654438248448, :name=>"Abdul Almohammadi", :account=>"AbdulAlmo", :img=>"https://si0.twimg.com/profile_images/3310838425/d384ac8bef2c347fdd1c7ca5d9095b17_normal.png", :text=>"سلام عليكم ..انا حاسس انوا في حكايه بس مش قادر اركز التركيز تعبان عندي بعد الغووص ."}, {:id=>331974080414773253, :name=>" عربي حرّ", :account=>"b_free2", :img=>"https://si0.twimg.com/profile_images/3548576582/5adb36035a3c29a2c61307e511d25f9f_normal.jpeg", :text=>"الحمد لله تمت الولادة على خير. ورزقنا الله بابنة. ام حامد والمولودة بخير والحمد لله \n\nتسلم يا طيب ودعواتك"}, {:id=>331895660683096066, :name=>" عربي حرّ", :account=>"b_free2", :img=>"https://si0.twimg.com/profile_images/3548576582/5adb36035a3c29a2c61307e511d25f9f_normal.jpeg", :text=>"الله يخليك يا اصيل مشتاق لك والله ومقصر وسامحني امانة على التقصير. إنت من القلة الي بقول الحمد لله ان تعرفت عليه. أخ كريم وأصيل\n"}]

#puts
#notify =  Notifier.new
#notify.notify(getinfo.mentions(1)[0])
#notify.notify(mentions[0])




last_10_mentions = [{:id=>350364868580347907, :name=>"♛KING SABRI", :account=>"KINGSABRI", :img=>"https://si0.twimg.com/profile_images/3286433187/399d60de067aa00d54324a7943a3c1aa_normal.jpeg", :text=>"@KINGSABRI test 1\nلا تدقق جالس أسوي سكريبت :)"}, {:id=>350346231127605248, :name=>"Mohammed AL Jeaid", :account=>"Linux4SA", :img=>"https://si0.twimg.com/profile_images/2436743720/Screenshot-15_2_normal.png", :text=>"@KINGSABRI لااله الا الله حق ... اللهم صل وسلم على حبيبنا محمد .... :D"}, {:id=>350345670433050624, :name=>"Mohammed AL Jeaid", :account=>"Linux4SA", :img=>"https://si0.twimg.com/profile_images/2436743720/Screenshot-15_2_normal.png", :text=>"@KINGSABRI اجل اذا رحت البيت انا بشيك وعطيك خبر .. عشرين شغله بيدك اخطبوط انت .. ركز بشغلك يامكينه"}, {:id=>350344773728612354, :name=>"Mohammed AL Jeaid", :account=>"Linux4SA", :img=>"https://si0.twimg.com/profile_images/2436743720/Screenshot-15_2_normal.png", :text=>"@KINGSABRI ليش الغلط الحين :D كيف مالقيت شي اشتريت والا باقي"}, {:id=>350344207019417600, :name=>"Mohammed AL Jeaid", :account=>"Linux4SA", :img=>"https://si0.twimg.com/profile_images/2436743720/Screenshot-15_2_normal.png", :text=>"@KINGSABRI مو كان احد نسي احد .. والا كيف يا اجنبي"}, {:id=>350297343997915136, :name=>"م/ فهد الباز", :account=>"fahadalbaz", :img=>"https://si0.twimg.com/profile_images/1796099316/FAHAD_ALBAZ_normal.gif", :text=>"@KINGSABRI هههههههه. اشغل بالبايثون ولا تشوف الطل"}, {:id=>350263258952904704, :name=>"أنس أحمد", :account=>"AnassAhmed", :img=>"https://si0.twimg.com/profile_images/3659902971/cdcdeabce194eeb3e045c70126bec02c_normal.jpeg", :text=>"@KINGSABRI LOL :D\nالجميلة واخدة حقها وزيادة ومش محتاجة ^_^"}, {:id=>350259366827536384, :name=>"ام يوسف ", :account=>"nohaelfayoumy", :img=>"https://si0.twimg.com/profile_images/344513261576878452/0b0cbac51fbec2f7934b3745a07d6d8b_normal.jpeg", :text=>"@KINGSABRI @ChaimaaElbassel مافيش حاجه بتنقرض فى البلد دى"}, {:id=>350259245515677696, :name=>"ام يوسف ", :account=>"nohaelfayoumy", :img=>"https://si0.twimg.com/profile_images/344513261576878452/0b0cbac51fbec2f7934b3745a07d6d8b_normal.jpeg", :text=>"@ChaimaaElbassel @KINGSABRI يعيشى ليه :))"}, {:id=>350258954426793984, :name=>" شِيَمُ ʚϊɞ", :account=>"ChaimaaElbassel", :img=>"https://si0.twimg.com/profile_images/3785004749/cae86d9e89ca5ec694b5c28ea112d143_normal.jpeg", :text=>"@nohaelfayoumy @KINGSABRI انا اجيبلك المصدر بنفسه يقولك يا نًها مش دى ام بس:))"}]
new_last_10_mentions = [{:id=>350364868580347907, :name=>"♛KING SABRI", :account=>"KINGSABRI", :img=>"https://si0.twimg.com/profile_images/3286433187/399d60de067aa00d54324a7943a3c1aa_normal.jpeg", :text=>"@KINGSABRI test 1\nلا تدقق جالس أسوي سكريبت :)"}, {:id=>350346231127605248, :name=>"Mohammed AL Jeaid", :account=>"Linux4SA", :img=>"https://si0.twimg.com/profile_images/2436743720/Screenshot-15_2_normal.png", :text=>"@KINGSABRI لااله الا الله حق ... اللهم صل وسلم على حبيبنا محمد .... :D"}, {:id=>350345670433050624, :name=>"Mohammed AL Jeaid", :account=>"Linux4SA", :img=>"https://si0.twimg.com/profile_images/2436743720/Screenshot-15_2_normal.png", :text=>"@KINGSABRI اجل اذا رحت البيت انا بشيك وعطيك خبر .. عشرين شغله بيدك اخطبوط انت .. ركز بشغلك يامكينه"}, {:id=>350344773728612354, :name=>"Mohammed AL Jeaid", :account=>"Linux4SA", :img=>"https://si0.twimg.com/profile_images/2436743720/Screenshot-15_2_normal.png", :text=>"@KINGSABRI ليش الغلط الحين :D كيف مالقيت شي اشتريت والا باقي"}, {:id=>350344207019417600, :name=>"Mohammed AL Jeaid", :account=>"Linux4SA", :img=>"https://si0.twimg.com/profile_images/2436743720/Screenshot-15_2_normal.png", :text=>"@KINGSABRI مو كان احد نسي احد .. والا كيف يا اجنبي"}, {:id=>350297343997915136, :name=>"م/ فهد الباز", :account=>"fahadalbaz", :img=>"https://si0.twimg.com/profile_images/1796099316/FAHAD_ALBAZ_normal.gif", :text=>"@KINGSABRI هههههههه. اشغل بالبايثون ولا تشوف الطل"}, {:id=>350263258952904704, :name=>"أنس أحمد", :account=>"AnassAhmed", :img=>"https://si0.twimg.com/profile_images/3659902971/cdcdeabce194eeb3e045c70126bec02c_normal.jpeg", :text=>"@KINGSABRI LOL :D\nالجميلة واخدة حقها وزيادة ومش محتاجة ^_^"}, {:id=>350259366827536111, :name=>"ام يوسف ", :account=>"nohaelfayoumy", :img=>"https://si0.twimg.com/profile_images/344513261576878452/0b0cbac51fbec2f7934b3745a07d6d8b_normal.jpeg", :text=>"@KINGSABRI @ChaimaaElbassel مافيش حاجه بتنقرض فى البلد دى"}, {:id=>350259245515677333, :name=>"ام يوسف ", :account=>"nohaelfayoumy", :img=>"https://si0.twimg.com/profile_images/344513261576878452/0b0cbac51fbec2f7934b3745a07d6d8b_normal.jpeg", :text=>"@ChaimaaElbassel @KINGSABRI يعيشى ليه :))"}, {:id=>350258954426793444, :name=>" شِيَمُ ʚϊɞ", :account=>"ChaimaaElbassel", :img=>"https://si0.twimg.com/profile_images/3785004749/cae86d9e89ca5ec694b5c28ea112d143_normal.jpeg", :text=>"@nohaelfayoumy @KINGSABRI انا اجيبلك المصدر بنفسه يقولك يا نًها مش دى ام بس:))"}]

mention_ids = last_10_mentions.map do |mention|
    mention[:id]
end

puts "Old mentions"
p mention_ids
puts
mentions_queue = mention_ids
mention_ids1 = new_last_10_mentions.map do |mention|
    mention[:id]
end

puts "\n\nNew mentions"
p mention_ids1

mentions_queue = mentions_queue & mention_ids1

puts "\n\nrepeated mentions_queue"
p mentions_queue

puts "\n\nNotify Unique mentions"
mentions_queue.map do |repeated|
    mention_ids1.delete(repeated)
end
p mention_ids1

puts "\n\n\n"
new_last_10_mentions.each do |mention|
    next if mentions_queue.include?mention[:id]
    p mention[:id]
    p mention
end





















#scheduler = Rufus::Scheduler.start_new
#scheduler.every '2s' do
#    puts "order ristretto"
#end
#
#scheduler.join










