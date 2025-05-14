defmodule Mix.Tasks.Compile.Popcorn do
  use Mix.Task.Compiler

  @impl true
  def run(_args) do
    app_entrypoint = get_app_entrypoint()
    {module, filename} = create_start_module(app_entrypoint)

    Popcorn.pack(start_module: module)
    # Remove generated module to not include it in regular application on next compilation
    File.rm!(filename)
  end

  defp get_app_entrypoint() do
    config = Mix.Project.config()
    app = Keyword.get(config, :app)

    case Application.spec(app, :mod) do
      {_mod, _args} = app_mod ->
        app_mod

      _ ->
        raise "Missing application starting point. Please provide `:mod` in application config of your `mix.exs`"
    end
  end

  # module is expected to implement Application behaviour
  defp create_start_module({module, args}) do
    contents =
      quote do
        def start() do
          unquote(module).start(:normal, unquote(args))
        end
      end

    module_name = Popcorn.Entrypoint

    {:module, _module_name, binary_content, _term} =
      Module.create(module_name, contents, Macro.Env.location(__ENV__))

    filename = Mix.Project.compile_path() |> Path.join("#{module_name}.beam")
    File.write!(filename, binary_content)
    {module_name, filename}
  end
end
