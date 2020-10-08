defmodule ExForger do
  @moduledoc """
  Documentation for `ExForger`.
  """

  @typedoc """
  Option for ExForger, can be:
  - :repo, repo to be used when inserting data to DB
  - :smith, smith to be used when generating data
  """
  @type opt :: keyword()
  @type ecto_schema :: module
  @type attribute :: map

  @doc """
    Forge Ecto schema data to database
  """
  def forge(schema, attributes \\ %{}, opt \\ []) do
    opt = Keyword.merge(default_opt(), opt)
    opt = validate_opt(opt)
    opt[:smith].forge_schema(schema, attributes, opt)
  end

  defp default_opt() do
    [
      repo: Application.get_env(:ex_forger, :config, %{})[:default_repo],
      smith:
        Application.get_env(:ex_forger, :config, %{})[:default_smith] || ExForger.DefaultSmith
    ]
  end

  defp validate_opt(opt) do
    if opt[:repo] == nil do
      raise "Ecto.Repo for ExForger is nil, fill in config [:ex_forger, :config, :default_repo] or give :repo option"
    end

    opt
  end
end
