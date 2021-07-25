# `rocker` working examples

This directory contains working examples for rocker.  The `.rocker`
file is suffixed with the image name, and must be removed to use.  To
try out the `dragonfire` example:

    mkdir /tmp/dragonfire
    cp examples/.rocker-dragonfire /tmp/dragonfire
    cd /tmp/dragonfire
    rocker -b
    rocker minetest  # Run minetest

## Example descriptions

- `.rocker-dragonfire`:  [Dragonfireclient][dfc] is a Minetest cheat
  client for use with anarchy servers


[dfc]: https://github.com/EliasFleckenstein03/dragonfireclient
