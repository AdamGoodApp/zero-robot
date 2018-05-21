#!/bin/bash

gem install ruby_git_hooks
ln -sf ../../hooks/pre-commit.rb .git/hooks/pre-commit
ln -sf ../../hooks/commit-msg.rb .git/hooks/commit-msg