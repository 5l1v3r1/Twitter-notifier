Twitter-notifier
================


Features
---------
* Commandline base.
* Check last 10 mentions.
* Check last 5 Direct messages.
* Check last followers.
* Show Account's avatar in notification.
* Support KDE, Gnome, etc..


How to use?
--------------
Open Twitter-notifier script, then add your twitter APIs.



Then, copy and paste in your OAuth data.

```ruby
CONSUMER_KEY        = "PUT YOUR CONSUMER KEY HERE"
CONSUMER_SECRET     = "PUT YOUR CONSUMER SECRET HERE"
OAUTH_TOKEN         = "PUT YOUR TOKEN HERE"
OAUTH_TOKEN_SECRET  = "PUT YOUR TOKEN SECRET HERE"
```

Then run the script
```bash
chmod +x twitter-notifier.rb && ruby twitter-notified.rb &
```
=======
    CONSUMER_KEY        = "PUT YOUR CONSUMER KEY HERE"
    CONSUMER_SECRET     = "PUT YOUR CONSUMER SECRET HERE"
    OAUTH_TOKEN         = "PUT YOUR TOKEN HERE"
    OAUTH_TOKEN_SECRET  = "PUT YOUR TOKEN SECRET HERE"

You can edit the other settings 
    NOTIFY_ME_EACH      = 180   # Second. 180 second is the Minimum otherwise twitter will block you ;)
    NUM_OF_MENTIONS     = 10
    NUM_OF_DIRECT_MSGS  = 5




Then run the script

    chmod +x twitter-notifier.rb && ruby twitter-notified.rb &



**Required gems**

    gem install twitter libnotify



**Suggestions?!**

please send request or send a mention in twitter @KINGSABRI

