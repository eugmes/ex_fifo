defmodule FIFOTest do
  use ExUnit.Case

  test "FIFO API" do
    f = FIFO.new
    assert FIFO.size(f) == 0
    f = FIFO.enqueue(f, 1) |> FIFO.enqueue("test") |> FIFO.enqueue(2)
    assert FIFO.size(f) == 3
    assert {:ok, 1, f} = FIFO.dequeue(f)
    assert {:ok, "test", f} = FIFO.dequeue(f)
    f = FIFO.enqueue(f, :test)
    assert FIFO.to_list(f) == [2, :test]
    assert {:ok, 2, f} = FIFO.dequeue(f)
    assert {:test, f} = FIFO.dequeue!(f)
    assert {:empty, f} = FIFO.dequeue(f)
    assert FIFO.size(f) == 0
    assert_raise ArgumentError, fn -> FIFO.dequeue!(f) end
  end

  test "Collectable protocol" do
    f = Enum.into([1, 2, 3], FIFO.new)
    f = Enum.into([4, 5, 6], f)
    assert FIFO.to_list(f) == [1, 2, 3, 4, 5, 6]
  end
end
