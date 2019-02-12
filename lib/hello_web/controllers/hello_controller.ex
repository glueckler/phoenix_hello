defmodule HelloWeb.HelloController do
  use HelloWeb, :controller

  # controller name guidelines
  # index - renders a list of all items of the given resource type
  # show - renders an individual item by id
  # new - renders a form for creating a new item
  # create - receives params for one new item and saves it in a datastore
  # edit - retrieves an individual item by id and displays it in a form for editing
  # update - receives params for one edited item and saves it to a datastore
  # delete - receives an id for an item to be deleted and deletes it from a datastore

  # PARAMETERS
  # conn
  # https://hexdocs.pm/plug/Plug.Conn.html
  # params
  # pattern match to get any parameters added to HTTP request
  def index(conn, _params) do
    render(conn, "index.html")

    # FLASH MESSAGES
    # use any keys you'd like to.. :error and :info are common
    # put_flash/3
    # get_flash/2
    # clear_flash/1
    conn
    |> put_flash(:info, "Welcome to Phoenix, from flash info!")
    |> put_flash(:error, "Let's pretend we have an error.")
    |> render("index.html")
  end


  def show(conn, %{"message" => message}) do
    render(conn, "show.html", message: message)
  end





  # RENDERING
  # text/2, json/2, and html/2 functions require neither a Phoenix view, nor a template to rende
  # text/2
  text(conn, "Showing id #{id}")

  # json/2
  # We need to pass it something that the Jason library can decode into JSON
  json(conn, %{id: id})

  # html/2
  # HTML without a template
  html(conn, """
    <html>
      <head>
        <title>Passing an Id</title>
      </head>
      <body>
        <p>You sent in id #{id}</p>
      </body>
    </html>
  """)





  # In order for the render/3 function to work correctly,
  # the controller must have the same root name as the individual view.
  # The individual view must also have the same root name as the template
  # directory where the show.html.eex template lives. In other words,
  # the HelloController requires HelloView, and HelloView requires the existence
  # of the lib/hello_web/templates/hello directory, which must contain the show.html.eex template.
  def index(conn, _params) do
    # If we need to pass values into the template when using render,
    # that’s easy. We can pass a dictionary like we’ve seen with messenger:
    # messenger, or we can use Plug.Conn.assign/3, which conveniently returns conn
    conn
    |> assign(:message, "Welcome Back!")
    |> render("index.html")
    # We can access this message in our index.html.eex template, or in our layout, with this <%= @message %>

    # assign multiple values
    conn
    |> assign(:message, "Welcome Back!")
    |> assign(:name, "Dweezil")
    |> render("index.html")
  end




  # default welcome message that some actions can override
  plug :assign_welcome_message, "Welcome Back"
  # or assign it to specific functions
  # plug :assign_welcome_message, "Hi!" when action in [:index, :show]

  def index(conn, _params) do
    conn
    |> assign(:message, "Welcome Forward")
    |> render("index.html")
  end

  defp assign_welcome_message(conn, msg) do
    assign(conn, :message, msg)
  end




  # Let’s say we want to send a response with a status of “201” and no body whatsoever.
  # We can easily do that with the send_resp/3 function.
  def index(conn, _params) do
    conn
    # optional if you'd like to specify the res content type
    # |> put_resp_content_type("text/plain")
    |> send_resp(201, "")
  end






  # LAYOUTS
  # app.html.eex, is the layout into which all templates will be rendered by default
  # Since layouts are really just templates, they need a view to render them.
  # This is the LayoutView module defined in lib/hello_web/views/layout_view.ex

  # The Phoenix.Controller module provides the put_layout/2 function for us to switch layouts.
  # This takes conn as its first argument and a string for the basename of the layout we want to render
  # false as the second argument will render nothing
  def index(conn, _params) do
    conn
    # render without layout
    |> put_layout(false)
    |> render("index.html")
  end

  # admin.html.eex in the same directory lib/hello_web/templates/layout
  def index(conn, _params) do
    conn
    |> put_layout("admin.html")
    |> render("index.html")
  end


  # Overriding Rendering Formats
  # Phoenix allows us to change formats on the fly with the _format query string parameter.
  # ex.. http://localhost:4000/?_format=text
  # ex.. http://localhost:4000/?_format=text&message=CrazyTown
  # change the plug :accepts to include text as well as html like this: plug :accepts, ["html", "text"]

  # We also need to tell the controller to render a template with the same format as
  # the one returned by Phoenix.Controller.get_format/1. We do that by
  # substituting the name of the template “index.html” with the atom version :index
  def index(conn, _params) do
    render(conn, :index)
  end
  # or with data
  def index(conn, params) do
    render(conn, "index.text", message: params["message"])
  end
  # Here is our example index.text.eex template:
  # OMG, this is actually some text. <%= @message %>


  # Analogous to the _format query string param, we can render any sort of format we want by
  # modifying the HTTP Content-Type Header and providing the appropriate template.
  # If we wanted to render an xml version of our index action, we might implement the action like this
  def index(conn, _params) do
    conn
    |> put_resp_content_type("text/xml")
    |> render("index.xml", content: some_xml_content)
  end




  # HTTP STATUS
  def index(conn, _params) do
    conn
    |> put_status(202)
    |> render("index.html")
  end

  # friendly names found here: https://github.com/elixir-plug/plug/blob/v1.3.0/lib/plug/conn/status.ex#L9-L69
  def index(conn, _params) do
    conn
    |> put_status(:not_found)
    |> render("index.html")
  end

  # The correct way to render the 404 page from HelloWeb.PageController is:
  def index(conn, _params) do
    conn
    |> put_status(:not_found)
    |> put_view(HelloWeb.ErrorView)
    |> render("404.html")
  end






  # REDIRECTION
  # Notice that the redirect function takes conn as well as a string representing
  # a relative path within our application. It can also take conn and a
  # string representing a fully-qualified url with external: ....
  def index(conn, _params) do
    redirect(conn, to: "/redirect_test")
  end

  def index(conn, _params) do
    redirect(conn, external: "https://elixir-lang.org/")
  end

  # We can also make use of the path helpers we learned about in the Routing Guide.
  def index(conn, _params) do
    redirect(conn, to: Routes.redirect_test_path(conn, :redirect_test))
  end

  # Note that we can’t use the url helper here because redirect/2 using the atom :to, expects a path
  # this will fail..
  def index(conn, _params) do
    redirect(conn, to: Routes.redirect_test_url(conn, :redirect_test))
  end

  # If we want to use the url helper to pass a full url to redirect/2,
  # we must use the atom :external. Note that the url does not have to
  # be truly external to our application to use :external, as we see in this example.
  def index(conn, _params) do
    redirect(conn, external: Routes.redirect_test_url(conn, :redirect_test))
  end


  # Action Fallbacks (generally for error handling)
  # called when a controller action fails to return a Plug.Conn.t
  # These plugs receive both the conn which was originally passed
  # to the controller action along with the return value of the action
  use Phoenix.Controller
  alias Hello.{Authorizer, Blog}

  # see the plug in lib/hello_web/controllers/my_fallback_controller.ex
  action_fallback HelloWeb.MyFallbackController

  def show(conn, %{"id" => id}, current_user) do
    with {:ok, post} <- Blog.fetch_post(id),
         :ok <- Authorizer.authorize(current_user, :view, post) do

      render(conn, "show.json", post: post)
    # this repetitive code becomes unnecessary
    # else
    #   {:error, :not_found} ->
    #     conn
    #     |> put_status(:not_found)
    #     |> put_view(ErrorView)
    #     |> render(:"404")
    #   {:error, :unauthorized} ->
    #     conn
    #     |> put_status(403)
    #     |> put_view(ErrorView)
    #     |> render(:"403")
    end
  end






  # Halting the Plug Pipeline
  # typically because we’ve redirected or rendered a response.
  # Plug.Conn.t has a :halted key - setting it to true will cause downstream plugs to be skipped.
  # We can do that easily using Plug.Conn.halt/1

  # Consider a HelloWeb.PostFinder plug. On call, if we find a post related to a given
  # id then we add it to conn.assigns; and if we don’t find the post we respond with a 404 page
  use Plug
  import Plug.Conn

  alias Hello.Blog

  def init(opts), do: opts

  def call(conn, _) do
    case Blog.get_post(conn.params["id"]) do
      {:ok, post} ->
        assign(conn, :post, post)
      {:error, :notfound} ->
        conn
        |> send_resp(404, "Not found")
        # This will skip all the following plugs after this controller
        |> halt()
    end
  end

  # Function plugs will still execute unless their implementation checks for the :halted value
  def post_authorization_plug(%{halted: true} = conn, _), do: conn
  def post_authorization_plug(conn, _) do
    ...
  end


end
