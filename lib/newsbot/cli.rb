$:.unshift File.dirname(__FILE__)

require "thor"


module Newsbot
  class CLI < Thor

    DEFAULT_INPUT  = "/tmp/newsbot_repo"
    DEFAULT_OUTPUT = "/tmp/newsbot_out"
    
    package_name "Newsbot"
    
    desc "build", "Run the Newsbot Build Process"
    map "build" => :build
    
    def build repo=DEFAULT_INPUT, output=DEFAULT_OUTPUT
      self.clean output
      self.pull repo
      self.generate repo, output
    end

    desc "clean", "Clear out the newsbot folder"
    map "clear" => :clean
    def clean output=DEFAULT_OUTPUT
      Newsbot::Manager.clean_output output
    end
    
    desc "pull", "Pull the latest newsbot repo"
    map "pull" => :pull
    def pull repo=DEFAULT_INPUT
      Newsbot::Repo.pull repo
    end
    
    desc "generate", "Generate newsbot files with repo"
    map "generate" => :build
    def generate repo=DEFAULT_INPUT, output=DEFAULT_OUTPUT
      Newsbot::Manager.generate_posts repo, output
    end
    
    
  end
end