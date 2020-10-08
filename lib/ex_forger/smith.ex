defmodule ExForger.Smith do
  @moduledoc """
  Smith is component which is responsible for creating dummy data

  There is two call back that can be defined:
  - def forge_schema(ecto_schema, attribute, opt):
    handle main forging of data for an ecto schema, here you can use custom logic data in case your forging need total control of forging
  - def generate_field(ecto_schema, field, type, opt):
    handle generating a field in schema for easy customization of a specific schema field/ a type

  simplest thing that can be done for custom smith is just making a module which delegate all function to `ExForger.DefaultSmith`
  ```elixir
  defmodule MyApp.MySmith do
    def forge_schema(ecto_schema, attribute, opt) do
      ExForger.DefaultSmith.forge_schema(ecto_schema, attribute, opt)
    end

    def generate_field(ecto_schema, field, type, opt) do
      ExForger.DefaultSmith.generate_field(ecto_schema, field, type, opt)
    end
  end
  ```

  From it, you can do for example:
  1. Defining custom logic for schema, example for user social media profile, only twitter that has handle_id and google_plus doesn't have
  ```elixir
    def forge_schema(ecto_schema, attribute, opt) do
      attribute = case ecto_schema do
        ExForger.Test.User.SocialMediaProfile ->
          type = Enum.random(["twitter", "google_plus"])
          handle_id = if type == "twitter", do: "XLSKAS", else: nil
          Map.merge(%{type: type, handle_id: handle_id}, attriubte)
        _ -> attribute
      end
      ExForger.DefaultSmith.forge_schema(ecto_schema, attribute, opt)
    end
  ```
  2. Defining custom random value generation for uncommon type, defining random for KSUID field
  ```elixir
    def generate_field(_ecto_schema, _field, :ksuid, _opt) do
      ExKsuid.generate()
    end
    def generate_field(ecto_schema, field, type, opt) do
      ExForger.DefaultSmith.generate_field(ecto_schema, field, type, opt)
    end
  ```
  """
  @callback forge_schema(ExForger.ecto_schema(), ExForger.attribute(), ExForger.opt()) :: struct()
  @callback generate_field(ExForger.ecto_schema(), atom(), atom(), ExForger.opt()) :: term()
end
