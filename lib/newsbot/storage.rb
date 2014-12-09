require 'aws-sdk'
require 'json'
require 'digest/sha1'

module Newsbot
  class Storage
    def sync(input, s3_access_key, s3_secret_key, s3_bucket)
      
      AWS.config(
        :access_key_id => s3_access_key,
        :secret_access_key => s3_secret_key)
        
      s3 = AWS::S3.new
      @bucket = s3.buckets[s3_bucket]   
      
      generate_manifest(input)
      get_remote_manifest()
      
      enque_files()
      upload_queued_files(input)
      delete_queued_files()
      upload_manifest() unless @remote_manifest == @manifest
    end
    
    def generate_manifest(input)
      @manifest = {}
      
      Dir[input + '/**/*.*'].each do |path|
        @manifest[path.sub(input + "/", "")] = Digest::SHA1.hexdigest File.read(path)
      end      
    end
    
    def get_remote_manifest()
      manifest = @bucket.objects["manifest.json"]
      
      if manifest.exists?
        @remote_manifest = JSON.parse manifest.read
      else
        @remote_manifest = {}
      end
      
    end
    
    def enque_files
      @upload_queue = []
      @delete_queue = @remote_manifest.keys - @manifest.keys
      
      @manifest.each do |file, hash|
        unless hash == @remote_manifest[file]
          @upload_queue << file
        end
      end
    end
    
    def upload_queued_files input
      @upload_queue.reverse.each do |file|
        upload_file(file, File.read(input + "/" + file))
      end
    end
    
    def delete_queued_files
      @delete_queue.each do |file|
        delete_file(file)
      end
    end
    
    def upload_file(path, content)
      puts "Uploading #{path}"
      @bucket.objects[path].write(content, {public: true})
    end
    
    def delete_file(path)
      puts "Deleting #{path}"
      @bucket.objects[path].delete
    end
    
    def upload_manifest()
      upload_file("manifest.json", @manifest.to_json)
    end
    
  end
end