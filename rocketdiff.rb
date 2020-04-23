require 'rocket-chat-notifier'

# Oxidized hook to post changes to RocketChat using a webhook.
#
# Installation:
#   1. Install the rocket-chat-notifier gem: gem install rocket-chat-notifier
#   2. Copy this hook to the oxidized homedir in the hook directory (create it if it does not already exist),
#      eg. /home/oxidized/.config/oxidized/hook
#      The hook should be named rocketdiff.rb
#
# Usage:
#   Update the Oxidized configuration and add a hook for this. As an example:
#     hooks:
#       rocket_output:
#         type: rocketdiff
#         events: [post_store]
#         url: 'WEBHOOK-URL-HERE'
#         message: "Node %{node}(%{model}) in %{group} updated - http://SOMEURL/commit/%{commitref}"
#         diff: false
#
#   If the diff option is set, a complete diff will also be sent to the channel.
#
# This script can be modified for your requirements as needed. For updates please see the repository URL:
# https://github.com/sysadminblog/oxidized-rocketchat

class RocketDiff < Oxidized::Hook
  def validate_cfg!
    raise KeyError, 'hook.url is required' unless cfg.has_key?('url')
  end

  def run_hook(ctx)
    if ctx.node
      if ctx.event.to_s == "post_store"
        log "Setting up rocketchat client"
        client = RocketChat::Notifier.new cfg.url

        # Set the channel if required
        if cfg.has_key?('channel') == true
          client.channel = cfg.channel
        end

        # Set the username if required
        if cfg.has_key?('username') == true
          client.username = cfg.username
        end

        # Check if diff required
        diffenable = true
        if cfg.has_key?('diff') == true
          if cfg.diff == false
            diffenable = false
          end
        end

        # Send message to channel about config update
        if cfg.has_key?('message') == true
          log "Sending message to rocketchat to notify about a new diff"
          msg = cfg.message % {:node => ctx.node.name.to_s, :group => ctx.node.group.to_s, :commitref => ctx.commitref, :model => ctx.node.model.class.name.to_s.downcase}
          client.ping msg
        end

        # Send the diff if required
        if diffenable == true
          # Get the diff
          gitoutput = ctx.node.output.new
          diff = gitoutput.get_diff ctx.node, ctx.node.group, ctx.commitref, nil
          # Send the diff
	  client.ping "```diff\n#{diff[:patch].lines.to_a[4..-1].join}\n```"
        end
      end
    end
  end
end
