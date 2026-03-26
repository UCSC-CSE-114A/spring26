---
layout: page
title: Additional materials
permalink: /materials/
---

## Setting up a native Haskell development environment

The homework assignments in this course use a Haskell build tool called Stack.
If you want to set up a native Haskell development environment, your first step should be to [install Stack](https://docs.haskellstack.org/en/stable/install_and_upgrade/).  This is a good way to go, especially if you're using Linux or macOS.
(Windows users might have a better time using the dev container or using Codespaces;
those alternatives are described below.)

All of the homework assignments in the course are structured as Stack projects.
You can build them using the command `stack build`, run tests using `stack test`, and so on.
Many more Stack commands are documented in the [Stack user's guide](https://docs.haskellstack.org/en/stable/GUIDE/).
Individual homework assignments will include information on the specific Stack commands you'll need to run to do the homework.

You can also run `stack ghci` to start an interactive session with GHCi,
in which Haskell expressions can be interactively evaluated.
We'll do a lot of playing in GHCi during lecture!

## VS Code Dev Container

Another alternative to installing a native Haskell environment is to use the CSE114A VS Code *dev container*.  This is a Docker container pre-configured
with a Haskell environment (including Stack and everything else you need) that you can interact with directly from [VS
Code](https://code.visualstudio.com/Download).  The dev container is a good option if you're having trouble setting up a native Haskell development environment for whatever reason, especially if you're using VS Code and running Docker anyway.  All of the homework assignments are already configured to use the dev container, though it's not required.

See the [CSE114A dev container documentation](https://github.com/UCSC-CSE-114A/cs114a-devcontainer/wiki/README)
for instructions on how to use it.

For general information on VS Code dev containers, see the [VS Code documentation](https://code.visualstudio.com/docs/remote/containers).

## GitHub Codespaces

Yet another alternative is to set up your development
environment using GitHub's [Codespaces](https://docs.github.com/en/codespaces/overview).  A Codespace is
just like a dev container, but instead of running on your local machine, it runs
in the cloud. 

To create a new Codespace, go to the repository created after you accept an
assignment. Click on the green `<> Code` button and select the Codespaces tab.
Finally click the green `Create codespace on main` button.

A new tab will open and GitHub will begin building your codespace based on the
CSE114A dev container. Once it is complete, a web-based VS Code interface will
display with your repository folder open. Notice there is a terminal on the
right (or you can open one using the Terminal menu).

Some VS Code extensions are not compatible with the web interface. If you would
like to open the codespace in the VS Code desktop app, click on the green `><
Codespaces` button at the bottom left, and select `Open in VS Code` from the
pull-down menu that appears at the top.

## Textbooks

There are no required textbooks for this course, but using one or more of the
following textbooks to expand your understanding of course topics is highly
recommended. In particular, these textbooks are good sources of example
problems to test your understanding of course concepts. When a free online copy
is available (either a preprint or an ebook via the UCSC library), I've noted
it below. More ebooks may become available through the library soon.

* <u>Programming Languages: Application and Interpretation</u> (third edition) by Shriram Krishnamurthi.  Available [free online](https://www.plai.org/).

* <u>Learn You a Haskell for Great Good</u> by Miran Lipovača. Available [free online](http://learnyouahaskell.com/).

* <u>An Introduction to Functional Programming Through Lambda Calculus</u> by Greg Michaelson.  Available [free online](https://www.cs.rochester.edu/~brown/173/readings/LCBook.pdf).

* <u>Thinking Functionally with Haskell</u> by Richard Bird.
         Available 
[online](https://ucsc.primo.exlibrisgroup.com/discovery/fulldisplay?docid=alma991024922807004876&context=L&vid=01CDL_SCR_INST:USCS&search_scope=MyInst_and_CI&tab=Everything&lang=en) (free via library).

* <u>Programming in Haskell</u> (second edition) by Graham Hutton.

* <u>Real World Haskell</u> by Bryan O'Sullivan.  Available [free online](https://book.realworldhaskell.org/).

## Exams from previous editions of the course

You might find these useful for studying.

* Spring 2025: [final](/static_files/materials/final-spring25.pdf); [solutions](/static_files/materials/final-spring25-solutions.pdf)
* Spring 2025: [midterm 2](/static_files/materials/midterm2-spring25.pdf); [solutions](/static_files/materials/midterm2-spring25-solutions.pdf)
* Spring 2025: [midterm 1](/static_files/materials/midterm1-spring25.pdf); [solutions](/static_files/materials/midterm1-spring25-solutions.pdf)
* Winter 2025: [final](/static_files/materials/final-winter25.pdf); [solutions](/static_files/materials/final-winter25-solutions.pdf)
* Winter 2025: [midterm](/static_files/materials/midterm-winter25.pdf); [solutions](/static_files/materials/midterm-winter25-solutions.pdf)
* Spring 2024: [final](/static_files/materials/final-spring24.pdf); [solutions](/static_files/materials/final-spring24-solutions.pdf)
* Spring 2024: [midterm](/static_files/materials/midterm-spring24.pdf); [solutions](/static_files/materials/midterm-spring24-solutions.pdf)
* Winter 2024: [final](/static_files/materials/final-winter24.pdf); [solutions](/static_files/materials/final-winter24-solutions.pdf)
* Winter 2024: [midterm 2](/static_files/materials/midterm2-winter24.pdf); [solutions](/static_files/materials/midterm2-winter24-solutions.pdf)
* Winter 2024: [midterm 1](/static_files/materials/midterm1-winter24.pdf); [solutions](/static_files/materials/midterm1-winter24-solutions.pdf)
* Fall 2023: [final](/static_files/materials/final-fall23.pdf); [solutions](/static_files/materials/final-fall23-solutions.pdf)
* Fall 2023: [midterm](/static_files/materials/midterm-fall23.pdf); [solutions](/static_files/materials/midterm-fall23-solutions.pdf)
* Spring 2023: [midterm](/static_files/materials/midterm-spring23.pdf); [solutions](/static_files/materials/midterm-spring23-solutions.pdf)
* Spring 2023: [final](/static_files/materials/final-spring23.pdf); [solutions](/static_files/materials/final-spring23-solutions.pdf)
* Fall 2022: [midterm](/static_files/materials/midterm-fall22.pdf); [solutions](/static_files/materials/midterm-fall22-solutions.pdf)
* Spring 2022: [midterm](/static_files/materials/midterm-spring22.pdf); [solutions](/static_files/materials/midterm-spring22-solutions.pdf)
* Spring 2022: [final](/static_files/materials/final-spring22.pdf); [solutions](/static_files/materials/final-spring22-solutions.pdf)
* Fall 2021: [midterm](/static_files/materials/midterm-fall21.pdf); [solutions](/static_files/materials/midterm-fall21-solutions.pdf)
* Fall 2021: [final](/static_files/materials/final-fall21.pdf); [solutions](/static_files/materials/final-fall21-solutions.pdf) 
* Fall 2019: [midterm](/static_files/materials/midterm-fall19.pdf); [solutions](/static_files/materials/midterm-fall19-solutions.pdf)
* Fall 2019: [final](/static_files/materials/final-fall19.pdf); [solutions](/static_files/materials/final-fall19-solutions.pdf) 
