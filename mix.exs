defmodule FIFO.Mixfile do
  use Mix.Project

  def project do
    [app: :fifo,
     version: "0.0.1",
     elixir: "~> 1.0",
     source_url: "https://github.com/eugmes/ex_fifo.git"
    ]
  end

  def application do
    []
  end
end
