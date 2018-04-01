defmodule InfoSys.Test.HTTPClient do

  @wolfram_xml File.read!("test/fixtures/wolfram.xml")
  require IEx
  # wolfram API request stub for test
  def request(url) do
    url = to_string(url)
    IEx.pry
    cond do
      String.contains?(url, "1%20+%201") -> {:ok, {[], [], @wolfram_xml}}
      true -> {:ok, {[], [], "<queryresult></queryresult>"}}
    end
  end
end
