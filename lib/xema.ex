defmodule Xema do
  @moduledoc """
  Xema ...
  """

  defstruct [
    :id,
    :schema,
    :title,
    :description,
    :default,
    :type,
    :keywords
  ]

  @types %{
    any: Xema.Any,
    nil: Xema.Nil,
    boolean: Xema.Boolean,
    map: Xema.Map,
    list: Xema.List,
    number: Xema.Number,
    integer: Xema.Integer,
    float: Xema.Float,
    string: Xema.String
  }

  @callback is_valid?(%Xema{}, any) :: boolean
  @callback validate(%Xema{}, any) :: :ok | {:error, any}
  @callback keywords(keyword) :: struct

  @spec type(%Xema{}) :: atom
  def type(schema) do
    if schema.keywords.as != nil,
      do: schema.keywords.as,
      else: schema.type
  end

  for {type, xema_module} <- Map.to_list(@types) do
    @spec create(unquote(type)) :: %Xema{}
    def create(unquote(type)), do: create(unquote(type), [])

    @spec create(unquote(type), keyword) :: %Xema{}
    def create(unquote(type), keywords) do
      with {id, keywords} <- Keyword.pop(keywords, :id),
           {schema, keywords} <- Keyword.pop(keywords, :schema),
           {title, keywords} <- Keyword.pop(keywords, :title),
           {description, keywords} <- Keyword.pop(keywords, :description),
           {default, keywords} <- Keyword.pop(keywords, :default)
      do
        %Xema{
          type: unquote(type),
          id: id,
          schema: schema,
          title: title,
          description: description,
          default: default,
          keywords: unquote(xema_module).keywords(keywords)
        }
      end
    end

    @spec xema(any) :: %Xema{}
    def xema({unquote(type), data}), do: Xema.create(unquote(type), xema(data))
    def xema(unquote(type)), do: Xema.create(unquote(type))

    @spec is_valid?(%Xema{type: unquote(type)}, any) :: boolean
    def is_valid?(%Xema{type: unquote(type)} = schema, value) do
      unquote(xema_module).is_valid?(schema, value)
    end

    @spec validate(%Xema{type: unquote(type)}, any) :: :ok | {:error, any}
    def validate(%Xema{type: unquote(type)} = schema, value) do
      unquote(xema_module).validate(schema, value)
    end
  end

  @spec xema(atom, keyword) :: %Xema{}
  def xema(type, data), do: xema {type, data}

  def xema(data) when is_list(data), do: Enum.map(data, &map_values/1)
  def xema(data) when is_map(data), do: Enum.into(data, %{}, &map_values/1)
  def xema(data), do: data

  defp map_values({key, value}), do: {key, xema(value)}
end
