defmodule Xema.Validator.Format do
  @moduledoc """
  TODO
  """

  import Xema.Helper.Error

  @formats %{
    email: ~r/.+@.*\..+/,
    hostname: ~r/^(?:[^0-9][a-z0-9]+(?:(?:\-|\.)[a-z0-9]+)*)$/i,
    ipv4: ~r/^([0-9]{1,3}\.){3}[0-9]{1,3}(\/([0-9]|[1-2][0-9]|3[0-2]))?$/,
    json_pointer: ~r/^\/.*$/
  }

  @spec validate(atom, String.t) :: :ok | {:error, any}
  def validate(:ipv6 = format, string) do
    if ipv6?(string),
      do: :ok,
      else: error(:invalid_format, format: format)
  end
  def validate(format, string) do
    with {:ok, regex} <- get(format) do
      if Regex.match?(regex, string),
        do: :ok,
        else: error(:invalid_format, format: format)
    end
  end

  defp get(format) do
    case Map.get(@formats, format) do
      nil -> error(:undefined_format, format: format)
      regex -> {:ok, regex}
    end
  end

  defp ipv6?(string) do
    Regex.match?(~r/^::[0-9a-f.]*$/i, string)
    || string
       |> String.split(~r/::\/|::|:\/|:|\/|\./)
       |> Enum.all?(&Regex.match?(~r/^[0-9a-f]{1,4}$/i, &1))
  end
end
