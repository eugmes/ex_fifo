defmodule FIFOTest do
  use ExUnit.Case

  test "FIFO API" do
    f = FIFO.new
    assert FIFO.size(f) == 0
    f = FIFO.enqueue(f, 1) |> FIFO.enqueue("test") |> FIFO.enqueue(2)
    assert FIFO.size(f) == 3
    assert {1, f} = FIFO.dequeue(f)
    assert {"test", f} = FIFO.dequeue(f)
    f = FIFO.enqueue(f, :test)
    assert FIFO.to_list(f) == [2, :test]
    assert {2, f} = FIFO.dequeue(f)
    assert {:test, f} = FIFO.dequeue!(f)
    assert :empty = FIFO.dequeue(f)
    assert FIFO.size(f) == 0
    assert_raise ArgumentError, fn -> FIFO.dequeue!(f) end
  end

  test "Collectable protocol" do
    f = Enum.into([1, 2, 3], FIFO.new)
    f = Enum.into([4, 5, 6], f)
    assert FIFO.to_list(f) == [1, 2, 3, 4, 5, 6]
  end

  test "Enumerable protocol" do
    f = Enum.into([1, 2, 3], FIFO.new)
    assert {1, f} = FIFO.dequeue f
    f = FIFO.enqueue(f, 1)

    assert Enum.count(f) == 3
    assert Enum.member?(f, 1)
    assert Enum.member?(f, 3)
    refute Enum.member?(f, :foo)
    assert Enum.to_list(f) == [2, 3, 1]
  end
end
