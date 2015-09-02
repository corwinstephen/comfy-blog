class Comfy::Blog::Tagging < ActiveRecord::Base
  
  self.table_name = 'blog_post_taggings'

  belongs_to :tag
  belongs_to :post
  
end