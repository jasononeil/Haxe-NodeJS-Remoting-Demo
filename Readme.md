Haxenode-Remoting
=================

This repo is an example of Haxe Remoting working between NodeJS Server and JS Browser client.

Building / Running
------------------

You will need the NodeJS "connect" module installed.  To install, run
	npm install connect 			

Run these commands:
    haxe client.hxml 				# Compile the client
    haxe server.hxml 				# Compile the server
    node out/node.js 				# Run the server

Or have them all as one line:
    haxe client.hxml; haxe server.hxml; node out/node.js

Then visit http://localhost:8000/ in your browser, and open the console/firebug.

What this shows
---------------

* The 'remoting' haxelib does work, or at least, it would if it were running the latest version on github.
* That you can have a NodeJS server and a JS client, both with haxe, sharing code and using remoting to pass objects back and forth and call functions.

Why did I bother?

* I couldn't get the 'remoting' haxelib to work
* The examples seemed confusing, and the haxelibs were out of date (not the author's fault - he hasn't been able to update)
* I was determined to make it work, and needed a blank slate to test / debug.
* Example code of this working will be useful not only for me, but for many interested in using haxe to target NodeJS.
* If I comment it really well, I'll hopefully understand NodeJS alot better.
