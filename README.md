# Gist Notifications

Send emails when new comments are made on your gists.

This is useful because Github [does not currently send any notifications](https://github.com/isaacs/github/issues/21).

This script uses a file to keep track of the last run time, and has been designed to run alone without any extra gems.

## Usage

With some defaults:

    $ ./notify_of_new_gist_comments github_username recipient_email sender_email email_password

This will notify for public gists only, will use `smtp.gmail.com` to send your emails, and use the file `/tmp/gist-notifications-last-run-time` to store the last run time in.

To see comments on private gists that you have shared with others, you will need to create a Github OAuth token with the `gist` scope [here](https://github.com/settings/applications#personal-access-tokens), and pass the token in after the email_password.

With all args:

    $ ./notify_of_new_gist_comments github_username recipient_email sender_email email_password github_auth_token smtp.gmail.com /tmp/gist-notifications-last-run-time


## Installing with Launchd configuration

Update `com.bethesque.gist-notifications.plist` with appropriate values, and run the following:

```shell
cp notify_of_new_gist_comments /usr/local/bin/notify_of_new_gist_comments
chmod +x /usr/local/bin/notify_of_new_gist_comments
sudo mkdir /var/log/gist-notifications
sudo chown $USER:staff /var/log/gist-notifications
cp com.bethesque.gist-notifications.plist $HOME/Library/LaunchAgents/com.bethesque.gist-notifications.plist
launchctl load $HOME/Library/LaunchAgents/com.bethesque.gist-notifications.plist
launchctl start com.bethesque.gist-notifications
```

To update the launchd config:

```shell
launchctl unload $HOME/Library/LaunchAgents/com.bethesque.gist-notifications.plist && \
launchctl load $HOME/Library/LaunchAgents/com.bethesque.gist-notifications.plist && \
launchctl start com.bethesque.gist-notifications
```


## Troubleshooting

If you get a Net::SMTPAuthenticationError, try going to `https://accounts.google.com/b/0/DisplayUnlockCaptcha`, submitting, and then running the code again.


For launchd issues, try:

    $ tail -f /var/log/system.log

Or

    $ tail -f /var/log/gist-notifications/launchd.out
