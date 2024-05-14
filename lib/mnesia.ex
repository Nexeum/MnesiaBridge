defmodule MnesiaAdapter do
  @moduledoc """
  Module that provides a high-level interface for interacting with the Mnesia database.
  """

  use GenServer
  require Logger
  alias :mnesia, as: Mnesia

  @behaviour MnesiaBehaviour

  @type table_name :: atom()
  @type table_data :: list({atom(), term()})
  @type data_item :: term()
  @type result :: :ok | {:error, term()}

  @doc """
    {:ok, _pid} = MnesiaAdapter.start_link()
    Starts the GenServer of the MnesiaAdapter.
    Returns `{:ok, pid}` if the GenServer is successfully started, or `{:error, reason}` if there is an error.
  """
  @impl MnesiaBehaviour
  @spec start_link() :: {:ok, pid()} | {:error, term()}
  def start_link do
    case GenServer.start_link(__MODULE__, :ok, name: __MODULE__) do
      {:ok, pid} ->
        Logger.info("MnesiaAdapter GenServer started successfully")
        {:ok, pid}

      {:error, reason} ->
        Logger.error("Error starting MnesiaAdapter GenServer: #{inspect(reason)}")
        {:error, reason}
    end
  end

  @doc """
  Creates a Mnesia table with the provided data.
  Returns `:ok` if the table is successfully created, or `{:error, reason}` if there is an error.
  """
  @impl MnesiaBehaviour
  @spec create_table(table_name(), table_data()) :: result()
  def create_table(table, data) when is_atom(table) and is_list(data) do
    Logger.info("Creating Mnesia table: #{table}")

    case GenServer.call(__MODULE__, {:create_table, table, data}) do
      :ok ->
        Logger.info("Mnesia table #{table} created successfully")
        :ok

      {:error, reason} ->
        Logger.error("Error creating Mnesia table #{table}: #{inspect(reason)}")
        {:error, reason}
    end
  end

  @doc """
  Writes data to the Mnesia database.
  Returns `:ok` if the data is successfully written, or `{:error, reason}` if there is an error.
  """
  @impl MnesiaBehaviour
  @spec write(data_item()) :: result()
  def write(data) do
    Logger.info("Writing data to Mnesia: #{inspect(data)}")

    case GenServer.call(__MODULE__, {:write, data}) do
      :ok ->
        Logger.info("Data written to Mnesia successfully")
        :ok

      {:error, reason} ->
        Logger.error("Error writing data to Mnesia: #{inspect(reason)}")
        {:error, reason}
    end
  end

  @doc """
  Reads data from the Mnesia database.
  Returns `{:ok, [data_item()]}` if the data is successfully read, or `{:error, reason}` if there is an error.
  """
  @impl MnesiaBehaviour
  @spec read(data_item()) :: {:ok, list(data_item())} | {:error, term()}
  def read(data) do
    Logger.info("Reading data from Mnesia: #{inspect(data)}")

    case GenServer.call(__MODULE__, {:read, data}) do
      :ok ->
        Logger.info("No data found in Mnesia")
        {:ok, []}

      result when is_list(result) ->
        Logger.info("Data read from Mnesia successfully: #{inspect(result)}")
        {:ok, result}

      {:error, reason} ->
        Logger.error("Error reading data from Mnesia: #{inspect(reason)}")
        {:error, reason}
    end
  end

  @impl true
  def init(_args) do
    case Mnesia.start() do
      :ok ->
        Logger.info("Mnesia started successfully")
        {:ok, []}

      {:error, {:already_started, _node}} ->
        Logger.info("Mnesia already started")
        {:ok, []}

      {:error, reason} ->
        Logger.error("Error starting Mnesia: #{inspect(reason)}")
        {:stop, reason}
    end
  end

  @impl true
  def handle_call({:create_table, table, data}, _from, state) do
    case Mnesia.create_table(table, attributes: data) do
      {:atomic, :ok} ->
        {:reply, :ok, state}
  
      {:aborted, reason} ->
        Logger.error("Error creating Mnesia table #{table}: #{inspect(reason)}")
        {:reply, {:error, reason}, state}
    end
  end
  
  @impl true
  def handle_call({:write, data}, _from, state) do
    case Mnesia.dirty_write(data) do
      :ok ->
        {:reply, :ok, state}
  
      {:error, reason} ->
        Logger.error("Error writing data to Mnesia: #{inspect(reason)}")
        {:reply, {:error, reason}, state}
    end
  end
  
  @impl true
  def handle_call({:read, data}, _from, state) do
    case Mnesia.dirty_read(data) do
      [] ->
        {:reply, :ok, state}
  
      result when is_list(result) ->
        {:reply, result, state}
  
      {:error, reason} ->
        Logger.error("Error reading data from Mnesia: #{inspect(reason)}")
        {:reply, {:error, reason}, state}
    end
  end
end