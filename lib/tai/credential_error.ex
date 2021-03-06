defmodule Tai.CredentialError do
  @moduledoc """
  Module which represents errors with credentials e.g. invalid api keys
  """

  @enforce_keys [:reason]
  defstruct [:reason]
end
