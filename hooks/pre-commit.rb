#!/usr/bin/env ruby
require 'ruby_git_hooks/case_clash'

class TestsHook < RubyGitHooks::Hook
  def check
    system('MIN_COV=12 MAX_DROP=1 rspec --fail-fast')
  end
end

class JSTestsHook < RubyGitHooks::Hook
  def check
    system('teaspoon --fail-fast --no-color')
  end
end

RubyGitHooks.register CaseClashHook.new
RubyGitHooks.register TestsHook.new
RubyGitHooks.register JSTestsHook.new
RubyGitHooks.run