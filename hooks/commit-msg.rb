#!/usr/bin/env ruby
require 'ruby_git_hooks'

class MessageHook < RubyGitHooks::Hook
  def check
    if !commit_message or commit_message.length < 10
      STDERR.puts 'Commit must be at least 10 characters long'
      return false
    end
    return true
  end
end

RubyGitHooks.register MessageHook.new
RubyGitHooks.run