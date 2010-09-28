module BookmarksHelper
  
  # Generates a draggable, pop-up div which contains the bookmark form 
  def bookmark_link(bookmarkable, blurb=false)
    # blurb=true is passed from the bookmark blurb to generate a save/saved link
    if logged_in?
      if bookmarkable.class == Chapter
        bookmarkable = bookmarkable.work
      end
      
      if bookmarkable.class == Work
        fallback = new_work_bookmark_path(bookmarkable)
        blurb == true ? text = t('bookmarks_helper.save_bookmark', :default => 'Save') : 
        text = t('bookmarks_helper.bookmark_link', :default => 'Bookmark') 
      elsif bookmarkable.class == ExternalWork
        fallback = new_external_work_bookmark_path(bookmarkable)
        blurb == true ? text = t('bookmarks_helper.save_bookmark', :default => 'Save') :
        text = t('bookmarks_helper.add_new_bookmark', :default => 'Add A New Bookmark')
      elsif bookmarkable.class == Series
        fallback = new_series_bookmark_path(bookmarkable)
        blurb == true ? text = t('bookmarks_helper.save_bookmark', :default => 'Save') : text = t('bookmarks_helper.bookmark_series', :default => 'Bookmark Series')
      end
      # Check to see if the user has an existing bookmark on this object. Note: on work page we eventually want to change this so an 
      # existing bookmark is opened for editing but a new bookmark can be created by selecting a different pseud on the form.
      @existing = Bookmark.find(:all, :conditions => ["bookmarkable_type = ? AND bookmarkable_id = ? AND pseud_id IN (?)", bookmarkable.class.name.to_s, bookmarkable.id, current_user.pseuds.collect(&:id)])
      if @existing.blank?                                         
        link_to text, {:url => fallback, :method => :get}, :remote => true, :href => fallback
      else
        # eventually we want to add the option here to remove the existing bookmark
        # Enigel Dec 10 08 - adding an edit link for now
        if blurb == true 
          if @existing.many?
            id_symbol = (bookmarkable.class.to_s.underscore + '_id').to_sym
            link_to t('bookmarks_helper.saved_bookmarks', :default => 'Saved'), {:controller => :bookmarks, :action => :index, id_symbol => bookmarkable, :existing => true} 
          else
            link_to t('bookmarks_helper.saved_bookmark', :default => 'Saved'), bookmark_path(@existing)
          end
        else 
          if @existing.many?
            link_to t('bookmarks_helper.edit_bookmark', :default => "Edit/Add Bookmark"), edit_bookmark_path(@existing.last, :existing => true)
          else
            link_to t('bookmarks_helper.edit_bookmark', :default => "Edit/Add Bookmark"), edit_bookmark_path(@existing.last, :existing => false)
          end
        end      
      end
    end
  end
  
  def link_to_new_bookmarkable_bookmark(bookmarkable)
    id_symbol = (bookmarkable.class.to_s.underscore + '_id').to_sym
    link_to "Add a new bookmark for this item", {:controller => :bookmarks, :action => :new, id_symbol => bookmarkable}
  end
  
  def link_to_user_bookmarkable_bookmarks(bookmarkable)
    id_symbol = (bookmarkable.class.to_s.underscore + '_id').to_sym
    link_to "You have saved multiple bookmarks for this item", {:controller => :bookmarks, :action => :index, id_symbol => bookmarkable, :existing => true}
  end
  
  # tag_bookmarks_path was behaving badly for tags with slashes
  def link_to_tag_bookmarks(tag)
    {:controller => 'bookmarks', :action => 'index', :tag_id => tag}
  end
  
  def link_to_bookmarkable_bookmarks(bookmarkable, link_text='')
    if link_text.blank? 
      link_text = Bookmark.count_visible_bookmarks(bookmarkable, current_user)
    end
    id_symbol = (bookmarkable.class.to_s.underscore + '_id').to_sym    
    link_to link_text, {:controller => :bookmarks, :action => :index, id_symbol => bookmarkable}
  end
  
  def get_symbol_for_bookmark(bookmark)
    if bookmark.private?
      img = "bookmark-private"
      title_string = "Private Bookmark"
    elsif bookmark.hidden_by_admin?
      img = "bookmark-hidden"
      title_string = "Bookmark Hidden by Admin"
    elsif bookmark.rec?
      img = "bookmark-rec"
      title_string = "Rec"
    else
      img = "bookmark-public"
      title_string = "Public Bookmark"
    end
    link_to_help('bookmark-symbols-key', link = image_tag( "#{img}.png", :alt => title_string, :title => title_string))
  end
  
  def toggle_recs_bookmarks
    if params[:recs_only]
      link_to "View All Bookmarks", url_for(:overwrite_params => {:recs_only => false})        
    else
      link_to "View Recs Only", url_for(:overwrite_params => {:recs_only => true})
    end
  end
  
end
