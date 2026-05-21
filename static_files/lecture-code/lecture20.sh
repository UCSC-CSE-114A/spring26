#!/bin/bash

message=" is cute"

f() {
    echo $1$message
}

g() {
  local message=" is smelly";
  f "nico"
}

f "nico"
g
f "nico"
