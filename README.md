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

You can edit the other settings 
```ruby
NOTIFY_ME_EACH      = 180   # Second. 180 second is the Minimum otherwise twitter will block you ;)
NUM_OF_MENTIONS     = 10
NUM_OF_DIRECT_MSGS  = 5
```

Then run the script
```bash
chmod +x twitter-notifier.rb && ruby twitter-notified.rb &
```
=======



**Required gems**

    gem install twitter libnotify


**TODO**
* Support new followers
* Run as daemon


## Configuration
Twitter API v1.1 requires you to authenticate via OAuth, so you'll need to
[register your application with Twitter][register]. Once you've registered an
application, make sure to set the correct access level, otherwise you may see
the error:

    Read-only application cannot POST

Your new application will be assigned a consumer key/secret pair and you will
be assigned an OAuth access token/secret pair for that application. You'll need
to configure these values before you make a request or else you'll get the
error:

    Bad Authentication data



**Suggestions?!**

please send request or send a mention in twitter @KINGSABRI

