require "git"
require 'fileutils'

module Newsbot
  module Repo
    def self.pull repo_path
      repo = Git.open(repo_path)
      repo.pull
    end
    
    def self.clone path, host
      FileUtils.mkdir File.dirname(__FILE__) + "/../../" + path
      Git.clone(host, "./", :path => File.dirname(__FILE__) + "/../../" + path)
    end
    
  end
end