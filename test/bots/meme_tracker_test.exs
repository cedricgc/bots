defmodule Bots.MemeTrackerTest do
   use ExUnit.Case, async: true

   setup context do
     {:ok, pid} = Bots.MemeTracker.start_link(context.test)
     {:ok, pid: pid}
   end

   test "stores name for user", %{pid: pid} do
     assert Bots.MemeTracker.get_meme(pid, "1234567") == nil

     Bots.MemeTracker.set_meme(pid, "1234567", "takeonme.gif", :add)
     assert Bots.MemeTracker.get_meme(pid, "1234567") == %{:name => "takeonme.gif", :action => :add}
   end

   test "delete meme metadata for user", %{pid: pid} do
     assert Bots.MemeTracker.get_meme(pid, "1234567") == nil

     Bots.MemeTracker.set_meme(pid, "1234567", "takeonme.gif", :add)
     Bots.MemeTracker.get_and_delete_meme(pid, "1234567")
     assert Bots.MemeTracker.get_meme(pid, "1234567") == nil
   end
 end