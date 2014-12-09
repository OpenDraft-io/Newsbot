require 'fileutils'
require 'mail'
require 'sanitize'
module Newsbot
  module Manager
    
    @index = {}
    
    # Newsbot::Manager.clean_output output
    def self.clean_output output
      FileUtils.rm_rf(output)
      FileUtils.mkdir(output)
      FileUtils.mkdir(output + "/categories")
      FileUtils.mkdir(output + "/posts")
    end


    # Newsbot::Manager.generate_posts repo, output
    def self.generate_posts repo, output
      iteration = 0
      
      # Loop through categories
      Dir.glob(repo + "/**/*/").each do |category|        
        # Remove the prefix
        category.slice! repo
        category.gsub! "/", ""
        
        # Create Category Index
        @index[category] = []
        
        # Loop Through Posts
        Dir.glob(repo + "/" + category + "/" + "*.md").sort_by{|c| File.stat(c).ctime}.each do |post|
          iteration += 1
          self.generate_post(post, category, output)
        end
      end
    
      self.generate_indexes output
    end
    
    def self.generate_post post, category, output
      data = Mail.read(post)
      slug = File.basename(post, ".md")
      
      content = {
        id: slug,
        category: category
      }
      
      ["Title", "Date", "Author"].each do |attribute|
        content[attribute.downcase.to_sym] = data[attribute].to_s
      end
      
      @index[category] << content.dup
      
      body = data.body.to_s
      
      body = Sanitize.document(body,
        :allow_doctype => true,
        :elements      => ['html', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'h7', 'h8', 'p', 'blockquote', 'pre', 'b', 'i', 'strong', 'em', 'tt', 'code', 'ins', 'del', 'sup', 'sub', 'kbd', 'samp', 'q', 'var', 'ol', 'ul', 'li', 'dl', 'dt', 'dd', 'table', 'thead', 'tbody', 'tfoot', 'tr', 'td', 'th', 'br', 'hr', 'ruby', 'rt', 'rp']
      )
      
      content[:body] = body
      
      new_path = output + "/posts/"+ slug + ".json"
      File.write(new_path, {post: content}.to_json)
    end
    
    # Newsbot::Manager.generate_indexes repo, output
    def self.generate_indexes output
      categories_index = {categories:[]}
      
      @index.each do |category, posts|
        data = {
          category: {
            id: category,
            name: category.split("_").join(" ").capitalize,
            posts: posts.map { |post|
              post[:id]
            }
          },
          posts: posts
        }
        
        
        
        new_path = output + "/categories/" + category + ".json"
        File.write(new_path, data.to_json)
        
        categories_index[:categories] << {
          id: category,
          name: category.split("_").join(" ").capitalize,
          post_count: posts.count
        }
        
      end
      
      File.write(output + "/categories.json", categories_index.to_json)
      
    end
    

  end
end