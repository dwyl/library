defmodule Library.GoogleBooksTest do
  use Library.DataCase
  alias Library.GoogleBooks

  describe "Google books helper functions" do

    test "rename_keys renames the keys in a map" do
      map = %{"hello" => "hi", "hiya" => "sup"}
      renamed_map = %{new_hello: "hi", new_hiya: "sup"}
      rename_list = [{"hello", :new_hello},
                     {"hiya", :new_hiya},
                     {"bad_value", :new_bad_value}]

      assert GoogleBooks.rename_keys(map, rename_list) == renamed_map
    end

    test "get_if_value gets the string value from a map if it exists" do
      map = %{"key" => "value",
              "unused_key" => "unused_value",
              "nest" => %{"nested_key" => "value"}}

      assert GoogleBooks.get_if_value("key", map) == %{"key" => "value"}
      assert GoogleBooks.get_if_value("bad_value", map) == %{}

      assert GoogleBooks.get_if_value(["key"], map) == %{"key" => "value"}
      assert GoogleBooks.get_if_value(["bad_value"], map) == %{}
      assert GoogleBooks.get_if_value(["nest", "nested_key"], map) == %{"nested_key" => "value"}
      assert GoogleBooks.get_if_value(["bad_value", "nested_key"], map) == %{}
    end
  end

  test "get_values_from_map gets the values from a map if they exist" do
    map = %{"key1" => "value1",
            "key2" => "value2",
            "key3" => %{"nested_key" => "value3"},
            "unused_key" => "unused_value"}

    result = %{"nested_key" => "value3", "key1" => "value1", "key2" => "value2"}

    list_of_keys = ["key1", ["key2"], ["key3", "nested_key"], "key", ["key"],
                    ["key3", "key"]]

    assert GoogleBooks.get_values_from_map(map, list_of_keys) == result
  end

  test "create_url returns a url with different queries and categories" do
    assert GoogleBooks.create_url("Hi", "title") ==
      "https://www.googleapis.com/books/v1/volumes?key=&q=intitle:Hi"

    assert GoogleBooks.create_url("Hi", "isbn") ==
      "https://www.googleapis.com/books/v1/volumes?key=&q=isbn:Hi"

    assert GoogleBooks.create_url("Hi", "author") ==
      "https://www.googleapis.com/books/v1/volumes?key=&q=inauthor:Hi"

    assert GoogleBooks.create_url("Hi", "bad_value") ==
      "https://www.googleapis.com/books/v1/volumes?key=&q="
  end

  test "google_books_search does a search" do
    result = %{author_list: ["hemingway"], owned: false, title: "hello world", web: true}
    assert GoogleBooks.google_books_search("harry potter", "title") ==
      [result]

    assert GoogleBooks.google_books_search("bad_value", "title") ==
      []

    assert GoogleBooks.google_books_search("bad_value2", "title") ==
      {:error, "bad"}

    assert GoogleBooks.google_books_search("bad_json_response", "title") ==
      {:invalid, "t", 3}

  end
end
