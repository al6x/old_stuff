class Rad::Face::Demo::Base
  inherit Rad::Controller::Http
  helper Rad::Face::Demo::ViewHelper

  layout '/rad/face/demo/layout'  

  def select_menu
    request.session['top_menu'] = params[:top_menu] if params[:top_menu]
    request.session['side_menu'] = params[:side_menu] if params[:side_menu]

    redirect_to :back
  end  

  attr_reader :samples

  # def title
  #   workspace.method_name.to_s.humanize
  # end
  # helper_method :title

  protected        
    def prepare_theme
      theme.name = params.theme
      theme.layout_template = params.layout_template
    end
    before :prepare_theme

    def prepare_samples
      @samples = {
        title: workspace.method_name.to_s.humanize,
      
        top_menu_items: %w(Email Contacts Calendar Files),
        active_top_menu: (request.session['top_menu'] || 'Email'),

        side_menu_items: %w(control_caption_0 control_caption_1 control_caption_2),
        active_side_menu: (request.session['side_menu'] || 'control_caption_0'),

        tabs: %w(Compose Contacts Import Categories),
        active_tab: 'Compose',

        name: "Terminator Movie Series",
        tags: ['egypt', 'photo', 'travel'].collect{|w| "<a href='#'>#{w}</a>"},
        details: ["Today at 15:58", "by <a href='#'>admin</a>", "{7}"],
        comment_details: ["Today at 15:58", "by <a href='#'>admin</a>"],
        controls: %w{add edit delete}.collect{|w| "<a href='#'>#{w}</a>"},
        
        attachments: [
          {
            name: 'img1', 
            url: url_for("/static/demo/images/img1.jpg"),
            icon_url: url_for("/static/demo/images/img1_icon.jpg"),
            thumb_url: url_for("/static/demo/images/img1_thumb.jpg")
          }.to_openobject,
          {
            name: 'img2',
            url: url_for("/static/demo/images/img2.jpg"),
            icon_url: url_for("/static/demo/images/img2_icon.jpg"),
            thumb_url: url_for("/static/demo/images/img2_thumb.jpg")
          }.to_openobject,
          {
            name: 'img3',
            url: url_for("/static/demo/images/img3.jpg"),
            icon_url: url_for("/static/demo/images/img3_icon.jpg"),
            thumb_url: url_for("/static/demo/images/img3_thumb.jpg")
          }.to_openobject
        ],
      
        model: {
          name: "Some Name", 
          active: true, 
          body: "Some text",
        	errors: {
        		base: ["Base Error Description", "Base Error Description 2"],
            name: ["Name Error Description 1", "Name Error Description 2"]
          }
        },

        detail_text: %(
<p>The Terminator (1984) <a href='#'>More at IMDbPro</a></p>
<p>Your future is in his hands.</p>      
        ),

        text: %(
<p>The Terminator (1984) <a href='#'>More at IMDbPro</a></p>
<p>In the Year of Darkness, 2029, the rulers of this planet devised the ultimate plan. They would reshape the Future by changing the Past. The plan required something that felt no pity. No pain. No fear. Something unstoppable. They created 'THE TERMINATOR'</p>
<p>The thing that won't die, in the nightmare that won't end. A human-looking, apparently unstoppable cyborg is sent from the future to kill Sarah Connor; Kyle Reese is sent to stop it.</p>
<p>Your future is in his hands.</p>
        ),
      
        comment_text: %(
<p>Although the Stack Overflow engine was always designed with a technical audience in mind, I'm intrigued to see how far we can push the boundaries of that audience.</p>
<p>We've pushed a little bit when going from programmers, to sysadmins, to power computer users - and we may try pushing a tad further this year with yet another site.</p>
        )
      }.to_openobject
    end
    before :prepare_samples
end