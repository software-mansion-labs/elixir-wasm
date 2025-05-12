defmodule Mix.Tasks.Compile.Popcorn do
  use Mix.Task.Compiler

  @impl true
  def run(_args) do
    # {opts, _, _} = OptionParser.parse(args, switches: [force: :boolean, compile_path: :string])
    app_entrypoint = get_starting_point()
    entrypoint = create_starting_point(app_entrypoint)

    Popcorn.pack(start_module: entrypoint)
  end

  defp get_starting_point() do
    config = Mix.Project.config()
    app = Keyword.get(config, :app)

    case Application.spec(app, :mod) do
      {_mod, _args} = app_mod ->
        app_mod

      _ ->
        raise "Missing application starting point. Please provide `:mod` in applocation config of your `mix.exs`"
    end
  end

  # module is expected to implement Application behaviour
  defp create_starting_point({module, args}) do
    contents =
      quote do
        def start() do
          :erlang.display("Entrystart")
          unquote(module).start(:normal, unquote(args))
          :ok
        end
      end

    Mix.shell().info(Macro.to_string(contents))
    module_name = Popcorn.Entrypoint

    # TODO: `mix compile.app` will autogenerate `:modules` key for app,
    # resulting in this module being autoloaded and then trigger a warning about module redefinition
    {:module, _module_name, binary_content, _term} =
      Module.create(module_name, contents, Macro.Env.location(__ENV__))

    filename = Mix.Project.compile_path() |> Path.join("#{module_name}.beam")
    File.write!(filename, binary_content)
    module_name
  end
end
