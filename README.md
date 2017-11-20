# Oxidized Rocket.Chat Hook

This hook is for [Oxidized](https://github.com/ytti/oxidized). This hook will message changes for Oxidized to an existing chat using the Rocket.Chat API.

The hook assumes that you are using the Git output to store the configurations for devices.

## Requirements

You must have the [rocket-chat-notifier](https://github.com/thiagofelix/rocket-chat-notifier) gem installed. This can be installed by running `gem install rocket-chat-notifier`.

## Installation

Copy the [rocketdiff.rb](rocketdiff.rb) file to the `hook` directory in your Oxidized home folder (if you have not created any custom hooks you will need to create this directory). As an example, my Oxidized users home directory is `/home/oxidized/.config/oxidized`. The `rocketdiff.rb` file is located at `/home/oxidized/.config/oxidized/hook/rocketdiff.rb`.

## Configuration

### Rocket.Chat

In your Rocket.Chat administration area, create a web hook integration by going to "Integration" in the left menu and then "New Integration" at the top right. Select the "Incoming WebHook" option. You will need to fill out the following options at the minimum:
```
Enabled: True
Post to Channel: (@Username or #Channel-name)
Post as: (Rocket.Chat username for this bot)
```
Once you create the integration, copy the Webhook URL for the next step.

### Oxidized

Edit your Oxidized configuration file (eg. `/home/oxidized/.config/oxidized/config`). Create (if it does not exist already) a hooks key with the following configuration:
```
hooks:
  rocket_output:
    type: rocketdiff
    events: [post_store]
    url: '(WEB HOOK URL HERE)'
    message: "Node %{node}(%{model}) updated - Commit: %{commitref}"
    diff: false
```
Reload the oxidized configuration and it should then be working.

## Available Options

The following configuration settings can be set:

`url`: This must be the Incoming WebHook URL that is generated from the Rocket.Chat admin area.

`message`: This string is output to Rocket.Chat. If this variable is not defined, no messages will be sent to Rocket.Chat about changes (you can still enable the `diff` output if required though). You can use the following variables in the string:
  - `%{node}`: This is the name of the node
  - `%{model}`: This is the device modle (eg. ios, junos)
  - `%{commitref}`: This is the commit reference. This can be used to link to a web interface if you push the changes to one, eg. if you have a GitLab server you can set this to `https://GITLAB-HOSTNAME/USER-NAME/REPO-NAME/commit/%{commitref}` and it will link directly to the change.
  - `%{group}`: This is the group, if configured, that the node is in

`diff`: If this is set to true, a second message will be sent to Rocket.Chat containing the diff output.

`channel`: If this option is defined, the messages will be sent to this channel/username.

`username`: If this option is defined, the messages will be sent from this username.
