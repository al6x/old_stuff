class ThemeController < ActionController::Base
  before_filter :prepare_menu, :prepare_variables, :set_theme, :prepare_samples
  
  def help
    render :action => 'help', :layout => false
  end
  
  def index
    @title = "Theme"
    render :index, :layout => false
  end

  def select_menu
    session[:top_menu] = params[:top_menu] if params[:top_menu]
    session[:side_menu] = params[:side_menu] if params[:side_menu]
    
    redirect_to :back
  end  
  
  protected
    def prepare_menu
      @title = params[:action].humanize
      
      @top_menu_items = %w{Email Contacts Calendar Files}
      @active_top_menu = session[:top_menu] || @top_menu_items.first
    
      @side_menu_items = %w{control_caption_0 control_caption_1 control_caption_2}
      @active_side_menu = session[:side_menu] || @side_menu_items.first
    end

    def prepare_variables
      @tabs = %w{Compose Contacts Import Categories}
      @active_tab = @tabs.first
    end
  
    def set_theme
      current_theme.name = params[:_theme]
      current_theme.layout_template = params[:_layout_template]
    end
    before_filter :set_theme
  
    def prepare_samples
      @common_name = "Terminator Movie Series"
      @common_tags = ['egypt', 'photo', 'travel'].collect{|w| "<a href='#'>#{w}</a>"}
      @common_details = ["Today at 15:58", "by <a href='#'>admin</a>", "{7}"]
      @comment_details = ["Today at 15:58", "by <a href='#'>admin</a>"]
      @common_controls = %w{add edit delete}.collect{|w| "<a href='#'>#{w}</a>"}
      
      @detail_text = <<END
<p>The Terminator (1984) <a href='#'>More at IMDbPro</a></p>
<p>Your future is in his hands.</p>      
END
      
      @note_text = <<END
<p>The Terminator (1984) <a href='#'>More at IMDbPro</a></p>
<p>In the Year of Darkness, 2029, the rulers of this planet devised the ultimate plan. They would reshape the Future by changing the Past. The plan required something that felt no pity. No pain. No fear. Something unstoppable. They created 'THE TERMINATOR'</p>
<p>The thing that won't die, in the nightmare that won't end. A human-looking, apparently unstoppable cyborg is sent from the future to kill Sarah Connor; Kyle Reese is sent to stop it.</p>
<p>Your future is in his hands.</p>
END
      @comment_text = <<END
<p>Although the Stack Overflow engine was always designed with a technical audience in mind, I’m intrigued to see how far we can push the boundaries of that audience.</p>
<p>We’ve pushed a little bit when going from programmers, to sysadmins, to power computer users — and we may try pushing a tad further this year with yet another site.</p>
END
    end
end