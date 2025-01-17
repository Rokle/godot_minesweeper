# Minesweeper

 ![Minesweeper in Godot Engine](/.media/example_screenshot.png)

A minesweeper game made using Godot 4.3. Originally created by Awfyboy here: [Minesweeper in Godot](https://github.com/Awfyboy/Minesweeper)

Originally refactored by HunterIV4 here: [Minesweeper in Godot](https://github.com/HunterIV4/godot_minesweeper)

This isn't necessarily the "best" or "only" way of doing things, but it's useful to be able to compare two very different ways of handling the same game.

## Summary of Key Changes:

* Strongly decoupled all scenes
* Refactored communication using signals.
* Added secondary data structure for handling game board.
* Used custom resources for storing board state
* Removed all compiler warnings

## Purpose

The code is just to show how project could be structured differently