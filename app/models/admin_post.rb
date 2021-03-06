class AdminPost < ActiveRecord::Base
  acts_as_commentable
  belongs_to :language
  belongs_to :translated_post, :class_name => 'AdminPost'
  has_many :translations, :class_name => 'AdminPost', :foreign_key => 'translated_post_id'
  has_many :admin_post_taggings
  has_many :tags, :through => :admin_post_taggings, :source => :admin_post_tag

  attr_protected :content_sanitizer_version
  
  validates_presence_of :title
  validates_length_of :title,
    :minimum => ArchiveConfig.TITLE_MIN,
    :too_short=> t('title_too_short', :default => "must be at least %{min} letters long.", :min => ArchiveConfig.TITLE_MIN)

  validates_length_of :title,
    :maximum => ArchiveConfig.TITLE_MAX,
    :too_long=> t('title_too_long', :default => "must be less than %{max} letters long.", :max => ArchiveConfig.TITLE_MAX)
  
  validates_presence_of :content
  validates_length_of :content, :minimum => ArchiveConfig.CONTENT_MIN, 
    :too_short => t('content_too_short', :default => "must be at least %{min} letters long.", :min => ArchiveConfig.CONTENT_MIN)

  validates_length_of :content, :maximum => ArchiveConfig.CONTENT_MAX, 
    :too_long => t('content_too_long', :default => "cannot be more than %{max} characters long.", :max => ArchiveConfig.CONTENT_MAX)

  scope :non_translated, where('translated_post_id IS NULL')
  
  # Return the name to link comments to for this object
  def commentable_name
    self.title
  end
  def commentable_owners
    begin
        [Admin.find(self.admin_id)]
    rescue
      []
    end
  end
  
  def tag_list
    tags.map{ |t| t.name }.join(", ")
  end
  
  def tag_list=(list)
    self.tags = list.split(",").uniq.collect { |t| 
      AdminPostTag.fetch(:name => t.strip, :language_id => self.language_id, :post => self)
      }.compact
  end

end
