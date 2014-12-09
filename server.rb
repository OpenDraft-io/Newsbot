#!/usr/bin/env ruby

lib_dir = File.join(File.dirname(__FILE__), 'lib')
$LOAD_PATH.unshift lib_dir if File.directory?(lib_dir)

require 'newsbot'
require 'sinatra'

configure do
  mime_type :text, 'text/text'
end
set :logging, true


post '/run' do
  content_type :text
  
  output = ENV['newsbot_output']   || "./tmp/output"
  repo   = ENV['newsbot_repo']     || "./tmp/repository"
  url    = ENV['newsbot_repo_url'] || "https://github.com/Hunter-Dolan/GitTest.git"
  key    = ENV['newsbot_key']
  
  s3_access_key = ENV["s3_access_key"]
  s3_secret_key = ENV["s3_secret_key"]
  s3_bucket     = ENV["s3_bucket"]
  
  if(key == params["key"])

    Newsbot::Manager.clean_output output
    puts "[Cleaned Repo]"
    
    if File.directory?(repo)
      Newsbot::Repo.pull repo
      puts "[Pulled Repo]"
    else
      Newsbot::Repo.clone repo, url
      puts "[Cloned Repo]"
    end
    
    Newsbot::Manager.generate_posts repo, output
    puts "[Generated Posts]"

    Newsbot::Storage.new.sync(output, s3_access_key, s3_secret_key, s3_bucket) if s3_access_key && s3_secret_key && s3_bucket
    puts "[Uploaded to S3]"
    
    return "Done"
  else
    return "Invalid Key"
  end
end
