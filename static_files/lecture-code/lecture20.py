#!/usr/local/bin/python

message=" is cute"

def f(s):
  print(s + message)

def g():
  message=" is smelly"
  f("nico")

f("nico")
g()
f("nico")
