module Subscriber::FavoritesHelper

  def render_favoriting_button nonprofit_id, status, options={}
    classes = []
    classes << (status ? 'is-on' : 'is-off')
    classes << options[:class] if options[:class].present?
    render partial: 'subscriber/favorites/button', locals: { nonprofit_id: nonprofit_id, classes: classes.join(" ") }
  end

end
