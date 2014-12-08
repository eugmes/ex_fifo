defmodule FIFO do
  @moduledoc """
  A FIFO implementation.

  The `FIFO` is internally represented as two lists, one for
  input, and one for output. Elements are added to the head of
  the input list. When dequeuing elements are taken from the
  head of the output list if possible, otherwise the input list
  is reversed and used as output list.

  Use `%FIFO{}` to much on any `FIFO`. Don't use the structure
  fields, use the access functions instead.
  """

  defstruct size: 0, output: [], input: []
  @opaque t :: %__MODULE__{size: non_neg_integer, input: list, output: list}

  @doc """
  Creates a new empty FIFO.
  """
  @spec new() :: FIFO.t
  def new, do: %FIFO{}

  @doc """
  Returns count of elements stored in `fifo`.
  """
  @spec size(FIFO.t) :: non_neg_integer
  def size(%FIFO{size: n}), do: n

  @doc """
  Enqueues `elem` into `fifo`

  Returns new `FIFO`.
  """
  @spec enqueue(FIFO.t, term) :: FIFO.t
  def enqueue(fifo = %FIFO{size: n, input: input}, elem) do
    %{fifo | size: n + 1, input: [elem | input]}
  end

  @doc """
  Dequeues an element from `fifo`.
  
  Returns tuple `{elem, new_fifo}` when `fifo` is not empty.
  Returns `:empty` otherwise.
  """
  @spec dequeue(FIFO.t) :: :empty | {term, FIFO.t}
  def dequeue(%FIFO{size: 0}) do
    :empty
  end

  def dequeue(fifo = %FIFO{size: n, output: [elem | rest]}) do
    {elem, %{fifo | size: n - 1, output: rest}}
  end

  def dequeue(fifo = %FIFO{size: n, output: [], input: input}) do
    [elem | rest] = Enum.reverse(input)
    {elem, %{fifo | size: n - 1, output: rest, input: []}}
  end

  @doc """
  Dequeues an element from `fifo`.

  Returns `{elem, new_fifo}` if `fifo` is not empty. Raises
  `ArgumentError` if `fifo` is empty.
  """
  @spec dequeue!(FIFO.t) :: {term, FIFO.t} | no_return
  def dequeue!(fifo) do
    case dequeue(fifo) do
      {elem, new_fifo} -> {elem, new_fifo}
      :empty ->
        raise ArgumentError, "Attempt to dequeue from empty FIFO"
    end
  end

  @doc """
  Returns the content of `fifo` as list.
  """
  @spec to_list(FIFO.t) :: list
  def to_list(%FIFO{input: input, output: output}) do
    output ++ Enum.reverse(input)
  end

  defimpl Collectable, for: FIFO do
    def into(original) do
      {original, fn
        fifo, {:cont, elem} -> FIFO.enqueue(fifo, elem)
        fifo, :done -> fifo
        _, :halt -> :ok
      end}
    end
  end

  defimpl Inspect, for: FIFO do
    import Inspect.Algebra

    def inspect(fifo, opts) do
      concat ["#FIFO<", Inspect.List.inspect(FIFO.to_list(fifo), opts), ">"]
    end
  end
end
