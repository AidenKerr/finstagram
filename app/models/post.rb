class Post < ActiveRecord::Base
    
    belongs_to :user
    has_many :comments
    has_many :likes
    
    validates_presence_of :photo_url, :user
    
    # returns time since posted in most relevant unit
    def humanized_time_ago
        time_ago_in_seconds = Time.now - self.created_at
        time_ago_in_minutes = time_ago_in_seconds / 60
        
        #TODO CHECK FOR SINGLE UNITS AND REMOVE THE S
        case time_ago_in_minutes
            when 0..1
                "#{time_ago_in_seconds.round} seconds ago"
            when 1..59
                "#{time_ago_in_minutes.round} minutes ago"
            when 60..1439
                "#{(time_ago_in_minutes / 60.0).round} hours ago"
            when 1440..10079
                "#{(time_ago_in_minutes / 1440.0).round} days ago"
            when 10080..88292039
                "#{(time_ago_in_minutes / 10080.0).round} weeks ago"
            else
                "#{(time_ago_in_minutes / 525600.0).round} years ago"
        end
    end
    
    def like_count
        self.likes.size
    end
    
    def comment_count
       self.comments.size 
    end
    
end