# In this example we might expect Blog.fetch_post/1 to return
# {:error, :not_found} if the post is not found and Authorizer.authorize/3 might return
# {:error, :unauthorized} if the user is unauthorized
defmodule HelloWeb.MyFallbackController do
  use Phoenix.Controller
  alias HelloWeb.ErrorView

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(ErrorView)
    |> render(:"404")
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(403)
    |> put_view(ErrorView)
    |> render(:"403")
  end
end
