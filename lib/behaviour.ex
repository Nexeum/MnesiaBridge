defmodule MnesiaBehaviour do
  @moduledoc """
  Behaviour that defines the API for interacting with the Mnesia database.
  """

  @type table_name :: atom()
  @type table_data :: list({atom(), term()})
  @type data_item :: term()
  @type result :: :ok | {:error, term()}

  @callback start_link() :: {:ok, pid()} | {:error, term()}

  @callback create_table(table_name(), table_data()) :: result()

  @callback write(data_item()) :: result()

  @callback read(data_item()) :: {:ok, list(data_item())} | {:error, term()}
end