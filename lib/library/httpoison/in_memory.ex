defmodule Library.HTTPoison.InMemory do
  def get("https://www.googleapis.com/books/v1/volumes?key=&q=intitle:harry%20potter") do
    {
      :ok,
      %{
        body: """
          {
            \"items\": [{
              \"volumeInfo\": {
              \"title\": \"hello world\",
              \"authors\": [\"hemingway\"],
              \"industryIdentifiers\": [{\"identifier\": \"isbn_10\", \"type\": \"123\"}]
              }
            }]
          }
        """
      }
    }
  end

  def get("https://www.googleapis.com/books/v1/volumes?key=&q=intitle:bad_value") do
    {
      :ok,
      %{
        body: """
          {
            \"items\": [{
              \"volumeInfo\": {
              \"title\": \"hello world\"
              }
            }]
          }
        """
      }
    }
  end

  def get("https://www.googleapis.com/books/v1/volumes?key=&q=intitle:bad_json_response") do
    {
      :ok,
      %{
        body: """
          {test: 1"test"}
        """
      }
    }
  end

  def get("https://www.googleapis.com/books/v1/volumes?key=&q=intitle:bad_value2") do
    {:error, "bad"}
  end
end
