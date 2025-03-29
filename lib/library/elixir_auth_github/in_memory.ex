defmodule Library.ElixirAuthGithub.InMemory do
  defdelegate login_url_with_scope(scope), to: ElixirAuthGithub

  def github_auth("123") do
    {:error, "hello"}
  end

  def github_auth("456") do
    {:ok, %{"name" => "indiana", "login" => "temple-of-doom", "access_token" => "456"}}
  end

  def github_auth("789") do
    {:ok, %{"name" => "indiana", "login" => "temple-of-doom", "access_token" => "789"}}
  end

  def github_auth("159") do
    {:ok, %{"name" => "indiana", "login" => "temple-of-doom", "access_token" => "159"}}
  end

  def github_auth("260") do
    {:ok, %{"name" => "indiana", "login" => "temple-of-doom", "access_token" => "260"}}
  end

  def github_auth("235") do
    {:ok, %{"name" => "indiana", "login" => "temple-of-doom", "access_token" => "235"}}
  end

  def github_auth("420") do
    {:ok, %{"name" => "indiana", "login" => "temple-of-doom", "access_token" => "420"}}
  end

  def github_auth("365") do
    {:ok, %{"name" => "indiana", "login" => "temple-of-doom", "access_token" => "365"}}
  end

end
