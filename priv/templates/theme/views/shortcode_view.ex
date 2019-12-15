defmodule ChubiWeb.Themes.<%= theme_module %>.ShortcodeView do
  use ChubiWeb.Themes.<%= theme_module %>, :view

  def render("youtube", %{args: [video_id]}) do
    """
    <div class="embed video-player">
    <iframe class="youtube-player" type="text/html" width="640" height="385" src="https://www.youtube.com/embed/#{
      video_id
    }" allowfullscreen frameborder="0">
    </iframe>
    </div>
    """
  end
end
