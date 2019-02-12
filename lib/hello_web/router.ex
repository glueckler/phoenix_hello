# Module Plugs
# Module plugs are another type of Plug that let us define a connection
# transformation in a module. The module only needs to implement two functions:
# init/1 which initializes any arguments or options to be passed to call/2
# call/2 which carries out the connection transformation. call/2 is just a function plug that we saw earlier
defmodule HelloWeb.Plugs.Locale do
  import Plug.Conn

  @locales ["en", "fr", "de"]

  def init(default), do: default

  def call(%Plug.Conn{params: %{"locale" => loc}} = conn, _default) when loc in @locales do
    assign(conn, :locale, loc)
  end
  def call(conn, default), do: assign(conn, :locale, default)
end



defmodule HelloWeb.Router do
  use HelloWeb, :router

  # The Endpoint Plugs
  # see lib/hello_web/endpoint.ex
  # Endpoints organize all the plugs common to every request,
  # and apply them before dispatching into the router(s)
  # with their underlying :browser, :api, and custom pipelines.

  # Pipelines are simply plugs stacked up together in a specific order and given a name.
  # They allow us to customize behaviors and transformations related to the handling of requests.
  # Phoenix provides us with some default pipelines for a number of common tasks.
  # In turn we can customize them as well as create new pipelines to meet our needs
  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug HelloWeb.Plugs.Locale, "en"
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # pipelines
  # What if we need to pipe requests through both :browser and one or more custom pipelines?
  # We simply pipe_through a list of pipelines, and Phoenix will invoke them in order.
  # commented for compiler
  # scope "/reviews" do
    # pipe_through [:browser, :review_checks, :other_great_stuff]

    # resources "/", HelloWeb.ReviewController
  # end

  # new pipelines
  pipeline :review_checks do
    # plug :ensure_authenticated_user
    # plug :ensure_user_owns_review
  end

  scope "/", HelloWeb do
    pipe_through :browser

    # use mix phx.routes to compile and see all routes
    get "/", PageController, :index
    get "/", RootController, :index # this cannot match and will generate a warning

    get "/hello", HelloController, :index
    get "/hello/:message", HelloController, :show

    get "/examples", ExamplesController, :index

    resources "/users", UserController
    # provides the following..
    # user_path  GET     /users           HelloWeb.UserController :index
    # this will invoke the edit action with an ID to retrieve an individual user from the data store and present the information in a form for editing
    # user_path  GET     /users/:id/edit  HelloWeb.UserController :edit
    # user_path  GET     /users/new       HelloWeb.UserController :new
    # user_path  GET     /users/:id       HelloWeb.UserController :show
    # user_path  POST    /users           HelloWeb.UserController :create
    # user_path  PATCH   /users/:id       HelloWeb.UserController :update
    #            PUT     /users/:id       HelloWeb.UserController :update
    # user_path  DELETE  /users/:id       HelloWeb.UserController :delete

    # Let’s say we have a read-only posts resource. We could define it like this
    resources "/posts", PostController, only: [:index, :show]

    resources "/comments", CommentController, except: [:delete]




    # forward
    # This means that all routes starting with /jobs will be sent to the BackgroundJob.Plug module
    # see lib/plugs/background_job_plug.ex
    forward "/jobs", BackgroundJob.Plug

    # This means that the plugs in the authenticate_user and ensure_admin pipelines will be called before the BackgroundJob.Plug allowing them to send an appropriate response and call halt()
    # pipe_through [:authenticate_user, :ensure_admin]
    # forward "/jobs", BackgroundJob.Plug




    # nested routes
    resources "/users", UserController do
      resources "/posts", PostController
    end
    # user_post_path  GET     /users/:user_id/posts           HelloWeb.PostController :index
    # user_post_path  GET     /users/:user_id/posts/:id/edit  HelloWeb.PostController :edit
    # user_post_path  GET     /users/:user_id/posts/new       HelloWeb.PostController :new
    # user_post_path  GET     /users/:user_id/posts/:id       HelloWeb.PostController :show
    # user_post_path  POST    /users/:user_id/posts           HelloWeb.PostController :create
    # user_post_path  PATCH   /users/:user_id/posts/:id       HelloWeb.PostController :update
    #                 PUT     /users/:user_id/posts/:id       HelloWeb.PostController :update
    # user_post_path  DELETE  /users/:user_id/posts/:id       HelloWeb.PostController :delete


  end

  # Scoped Routes
  # The paths to the user facing reviews would look like a standard resource.
  # /reviews
  # /reviews/1234
  # /reviews/1234/edit
  # ...
  # The admin review paths could be prefixed with /admin.
  # /admin/reviews
  # /admin/reviews/1234
  # /admin/reviews/1234/edit
  scope "/admin" do
    pipe_through :browser

    resources "/reviews", HelloWeb.Admin.ReviewController
    # mix phx.routes
    # review_path  GET     /admin/reviews           HelloWeb.Admin.ReviewController :index
    # review_path  GET     /admin/reviews/:id/edit  HelloWeb.Admin.ReviewController :edit
    # review_path  GET     /admin/reviews/new       HelloWeb.Admin.ReviewController :new
    # review_path  GET     /admin/reviews/:id       HelloWeb.Admin.ReviewController :show
    # review_path  POST    /admin/reviews           HelloWeb.Admin.ReviewController :create
    # review_path  PATCH   /admin/reviews/:id       HelloWeb.Admin.ReviewController :update
    #             PUT     /admin/reviews/:id       HelloWeb.Admin.ReviewController :update
    # review_path  DELETE  /admin/reviews/:id       HelloWeb.Admin.ReviewController :delete

    # NOTICE NOTICE NOTICE
    # the path helper "review_path" at the beginning of each line
    # We can fix this problem by adding an as: :admin option to our admin scope.
    # scope "/admin", as: :admin do
    #   resources "/reviews", HelloWeb.Admin.ReviewController
    # end

  end

  # Although technically scopes can also be nested (just like resources),
  # the use of nested scopes is generally discouraged because it can sometimes
  # make our code confusing and less clear.
  # With that said, suppose that we had a versioned API with resources defined for images,
  # reviews and users. Then technically we could setup routes for the versioned API like this:

  scope "/api", HelloWeb.Api, as: :api do
    pipe_through :api

    scope "/v1", V1, as: :v1 do
      resources "/images",  ImageController
      resources "/reviews", ReviewController
      resources "/users",   UserController
    end
  end
  # mix phx.routes
  # api_v1_image_path  GET     /api/v1/images            HelloWeb.Api.V1.ImageController :index
  # api_v1_image_path  GET     /api/v1/images/:id/edit   HelloWeb.Api.V1.ImageController :edit
  # api_v1_image_path  GET     /api/v1/images/new        HelloWeb.Api.V1.ImageController :new
  # api_v1_image_path  GET     /api/v1/images/:id        HelloWeb.Api.V1.ImageController :show
  # api_v1_image_path  POST    /api/v1/images            HelloWeb.Api.V1.ImageController :create
  # api_v1_image_path  PATCH   /api/v1/images/:id        HelloWeb.Api.V1.ImageController :update
  #                   PUT     /api/v1/images/:id        HelloWeb.Api.V1.ImageController :update
  # api_v1_image_path  DELETE  /api/v1/images/:id        HelloWeb.Api.V1.ImageController :delete
  # api_v1_review_path  GET     /api/v1/reviews           HelloWeb.Api.V1.ReviewController :index
  # api_v1_review_path  GET     /api/v1/reviews/:id/edit  HelloWeb.Api.V1.ReviewController :edit
  # api_v1_review_path  GET     /api/v1/reviews/new       HelloWeb.Api.V1.ReviewController :new
  # api_v1_review_path  GET     /api/v1/reviews/:id       HelloWeb.Api.V1.ReviewController :show
  # api_v1_review_path  POST    /api/v1/reviews           HelloWeb.Api.V1.ReviewController :create
  # api_v1_review_path  PATCH   /api/v1/reviews/:id       HelloWeb.Api.V1.ReviewController :update
  #                   PUT     /api/v1/reviews/:id       HelloWeb.Api.V1.ReviewController :update
  # api_v1_review_path  DELETE  /api/v1/reviews/:id       HelloWeb.Api.V1.ReviewController :delete
  # api_v1_user_path  GET     /api/v1/users             HelloWeb.Api.V1.UserController :index
  # api_v1_user_path  GET     /api/v1/users/:id/edit    HelloWeb.Api.V1.UserController :edit
  # api_v1_user_path  GET     /api/v1/users/new         HelloWeb.Api.V1.UserController :new
  # api_v1_user_path  GET     /api/v1/users/:id         HelloWeb.Api.V1.UserController :show
  # api_v1_user_path  POST    /api/v1/users             HelloWeb.Api.V1.UserController :create
  # api_v1_user_path  PATCH   /api/v1/users/:id         HelloWeb.Api.V1.UserController :update
  #                   PUT     /api/v1/users/:id         HelloWeb.Api.V1.UserController :update
  # api_v1_user_path  DELETE  /api/v1/users/:id         HelloWeb.Api.V1.UserController :delete



  # Interestingly, we can use multiple scopes with the same path as long as we are careful not to duplicate routes.
  # This router is perfectly fine with two scopes defined for the same path.
  scope "/", AnotherAppWeb do
    pipe_through :browser

    resources "/posts", PostController
  end

end
