defmodule ChubiWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :chubi

  socket("/socket", ChubiWeb.UserSocket,
    websocket: true,
    longpoll: false
  )

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug(Plug.Static,
    at: "/",
    from: :chubi,
    gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)
  )

  # I haven't found any solution to config static plug dinamically by theme, this is a hack in case
  # you want switch theme dynamically

  Enum.each(ChubiWeb.ThemeHelpers.list_theme(), fn %{identifier: identifier} ->
    plug(Plug.Static,
      at: "/#{identifier}",
      from: ChubiWeb.ThemeHelpers.theme_directory(identifier, "static"),
      gzip: false,
      only: ~w(css fonts images js favicon.ico robots.txt)
    )
  end)

  # If you don't need to switch theme, comment above setting and uncomment below Plug
  # plug(Plug.Static,
  #   at: "/#{ChubiWeb.ThemeHelpers.current_theme_name()}",
  #   from: ChubiWeb.ThemeHelpers.current_theme_directory("static"),
  #   gzip: false,
  #   only: ~w(css fonts images js favicon.ico robots.txt)
  # )

  plug(Plug.Static,
    at: "/uploads/",
    from: "priv/uploads",
    gzip: false
  )

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket("/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket)
    plug(Phoenix.LiveReloader)
    plug(Phoenix.CodeReloader)
  end

  plug(Plug.RequestId)
  plug(Plug.Logger)

  plug(Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()
  )

  plug(Plug.MethodOverride)
  plug(Plug.Head)

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug(Plug.Session,
    store: :cookie,
    key: "_chubi_key",
    signing_salt: "WFr3VJ0d"
  )

  plug(ChubiWeb.Router)
end
