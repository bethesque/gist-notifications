# Gist Notifications

## Usage

With some defaults:

    $ ruby notify.rb github_username recipient_email sender_email email_password

With all args:

    $ ruby notify.rb github_username recipient_email sender_email email_password smtp.gmail.com /tmp/gist-notifications-last-run-time


## Installing Launchd

```shell
cp notify_of_new_gist_comments /usr/local/bin/notify_of_new_gist_comments
chmod +x /usr/local/bin/notify_of_new_gist_comments
sudo mkdir /var/log/gist-notifications
sudo chown $USER:staff /var/log/gist-notifications
cp com.bethesque.gist-notifications.plist $HOME/Library/LaunchAgents/com.bethesque.gist-notifications.plist
launchctl unload $HOME/Library/LaunchAgents/com.bethesque.gist-notifications.plist ; \
launchctl load $HOME/Library/LaunchAgents/com.bethesque.gist-notifications.plist && \
launchctl start com.bethesque.gist-notifications
```

## Troubleshooting

If you get a Net::SMTPAuthenticationError, try going to `https://accounts.google.com/b/0/DisplayUnlockCaptcha`, submitting, and then running the code again.


For launchd issues, try:

    $ tail -f /var/log/system.log

Or
    $ tail -f /var/log/gist-notifications/launchd.out
