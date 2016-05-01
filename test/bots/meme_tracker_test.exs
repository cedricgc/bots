defmodule Bots.MemeTrackerTest do
   # Use the module
   use ExUnit.Case, async: true

   # The "test" macro is imported by ExUnit.Case
   test "stores name for user" do
     assert Bots.MemeTracker.get_meme("1234567") == nil

     Bots.MemeTracker.set_meme("1234567", "takeonme.gif", :add)
     assert Bots.MemeTracker.get_meme("1234567") == %{:name => "takeonme.gif", :action => :add}
   end
 end