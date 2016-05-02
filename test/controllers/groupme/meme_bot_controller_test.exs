defmodule MemeBotControllerTest do
  use Bots.ConnCase

  @valid_message ~S({"attachments":[],"avatar_url":"https://i.groupme.com/8c294880d2f301301dd332bc697c4904","created_at":1460688555,"favorited_by":[],"group_id":"21250840","id":"146068855582848861","name":"Cedric Georgeo Charly","sender_id":"8500736","sender_type":"user","source_guid":"1b6cdc40f5fdeda88381463861138176","system":false,"text": "memebot","user_id":"8500736"})

  test "POST /groupme/memebot/callback with valid callback message", %{conn: conn} do
    conn = conn 
    |> put_req_header("content-type", "application/json")
    |> post("/groupme/memebot/callback", @valid_message)

    assert conn.status == 200
  end

  test "POST /groupme/memebot/callback with invalid callback message", %{conn: conn} do
    conn = conn 
    |> put_req_header("content-type", "application/json")
    |> post("/groupme/memebot/callback", "")

    assert conn.status == 417
  end
end