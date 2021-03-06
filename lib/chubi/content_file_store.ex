defmodule Chubi.ContentFileStore do
  alias Chubi.Content.Post
  alias Chubi.Content.Page
  @content_dir "./priv/content"

  def content_directory(suffix \\ "") do
    @content_dir
    |> Path.join(suffix)
    |> Path.absname()
  end

  def ensure_directory(path) do
    if File.dir?(path) do
      path
    else
      File.mkdir_p!(path)
      path
    end
  end

  defp directory(post) do
    case post do
      %Post{} ->
        ensure_directory(content_directory("posts"))

      %Page{} ->
        ensure_directory(content_directory("pages"))

      _ ->
        nil
    end
  end

  defp extension(post) do
    case post.format do
      "markdown" -> "md"
      _ -> "json"
    end
  end

  defp content(%Post{} = post) do
    case post.format do
      "markdown" ->
        post.content

      _ ->
        post
        |> Map.drop([:__meta__, :__struct__])
        |> Map.merge(%{
          categories: Enum.map(post.categories, & &1.name),
          tags: Enum.map(post.tags, & &1.name)
        })
        |> Jason.encode!()
    end
  end

  defp content(%Page{} = post) do
    case post.format do
      "markdown" ->
        post.content

      _ ->
        post
        |> Map.drop([:__meta__, :__struct__])
        |> Jason.encode!()
    end
  end

  defp file_name(post) do
    date = Timex.format!(post.date || post.inserted_at, "{YYYY}-{0M}-{0D}")
    "#{date}-#{post.slug}.#{extension(post)}"
  end

  defp file_path(post) do
    Path.join(directory(post), file_name(post))
  end

  def write(post) do
    File.write(file_path(post), content(post), [:write])
  end

  def write_mem(post) do
    {file_name(post), content(post)}
  end

  def delete(post) do
    File.rm(file_path(post))
  end

  def read_all_posts() do
    ensure_directory(content_directory("/posts"))
    |> read_directory
  end

  def read_all_pages() do
    ensure_directory(content_directory("/pages"))
    |> read_directory
  end

  def read_directory(path) do
    with {:ok, files} <- File.ls(path) do
      Enum.map(files, fn file ->
        Path.join(path, file)
        |> read_file
      end)
      |> Enum.filter(&(not is_nil(&1)))
    else
      _ -> []
    end
  end

  def read_file(file_path) do
    with {:ok, content} <- File.read(file_path) do
      case Path.extname(file_path) do
        ".md" -> %{"content" => content, "format" => "markdown"}
        ".json" -> Jason.decode!(content)
        _ -> nil
      end
    end
  end
end
