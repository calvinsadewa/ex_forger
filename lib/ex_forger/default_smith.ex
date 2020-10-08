defmodule ExForger.DefaultSmith do
  @moduledoc """
  Default Smith used by ExForger,
  default smith can be set via config (:ex_forger, :config, :default_smith)
  """
  def forge_schema(ecto_schema, attributes, opt) do
    fields = ecto_schema.__schema__(:fields)
    generated_fields = fields -- Map.keys(attributes)

    associations =
      ecto_schema.__schema__(:associations)
      |> Enum.map(fn assoc_field ->
        association = ecto_schema.__schema__(:association, assoc_field)
        {Map.get(association, :owner_key), association}
      end)
      |> Enum.filter(fn {_, assoc} -> match?(%Ecto.Association.BelongsTo{}, assoc) end)

    embed_fields = ecto_schema.__schema__(:embeds)

    attributes =
      generated_fields
      |> Enum.map(fn field ->
        type = ecto_schema.__schema__(:type, field)
        opt = Keyword.merge(opt, associations: associations)
        value = opt[:smith].generate_field(ecto_schema, field, type, opt)
        {field, value}
      end)
      |> Enum.into(attributes)

    changeset =
      struct(ecto_schema)
      |> Ecto.Changeset.cast(attributes, fields -- embed_fields)

    changeset =
      Enum.reduce(embed_fields, changeset, fn field, changeset ->
        Ecto.Changeset.put_embed(changeset, field, attributes[field])
      end)

    if ecto_schema.__schema__(:source) == nil do
      changeset
    else
      opt[:repo].insert!(changeset)
    end
  end

  def generate_field(schema, field, type, opt) do
    cond do
      opt[:associations][field] != nil ->
        generate_assoc_field(schema, field, opt)

      match?({:parameterized, Ecto.Embedded, _}, type) ->
        generate_embed_field(type, opt)

      true ->
        random_value(type)
    end
  end

  defp generate_assoc_field(schema, field, opt) do
    case opt[:associations][field] do
      # Auto generate belongs_to
      %Ecto.Association.BelongsTo{
        related: parent_schema,
        related_key: parent_key
      } ->
        # Self referencing schema is not auto generated
        if parent_schema == schema do
          nil
        else
          parent = ExForger.forge(parent_schema, %{}, opt)
          Map.get(parent, parent_key)
        end

      _ ->
        nil
    end
  end

  defp generate_embed_field(type, opt) do
    {_, _, %{cardinality: cardinality, related: embed_schema}} = type

    cond do
      cardinality == :one ->
        ExForger.forge(embed_schema, %{}, opt)

      cardinality == :many ->
        1..3 |> Enum.map(fn _ -> ExForger.forge(embed_schema, %{}, opt) end)

      true ->
        nil
    end
  end

  defp random_value(type)
  defp random_value(:id), do: System.unique_integer([:positive, :monotonic])
  defp random_value(:binary_id), do: <<Enum.random(0..255)>>
  defp random_value(:integer), do: System.unique_integer()
  defp random_value(:float), do: :random.uniform()
  defp random_value(:boolean), do: :random.uniform() < 0.5

  defp random_value(:string),
    do: 1..10 |> Enum.map(fn _ -> Enum.random(?a..?z) end) |> List.to_string()

  defp random_value(:binary), do: <<Enum.random(0..255)>>
  defp random_value(:decimal), do: :random.uniform() |> Decimal.new()
  defp random_value(:date), do: Date.utc_today()
  defp random_value(:time), do: Time.utc_now()
  defp random_value(:time_usec), do: Time.utc_now()
  defp random_value(:naive_datetime), do: DateTime.utc_now() |> DateTime.to_naive()
  defp random_value(:naive_datetime_usec), do: DateTime.utc_now() |> DateTime.to_naive()
  defp random_value(:utc_datetime), do: DateTime.utc_now()
  defp random_value(:utc_datetime_usec), do: DateTime.utc_now()
  defp random_value(_), do: nil
end
