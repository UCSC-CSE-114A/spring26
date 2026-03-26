# CSE114A lecture 1

Agenda:

- Course mechanics
- What is PL?

## Course mechanics

(tour of course website, course policies, schedule, etc.)

## What is PL?

Next time we'll start discussing lambda calculus, which is the topic of our first homework assignment, which is slated to come out on Sunday.  But first, to set the tone for this course and what we'll be doing all quarter, I want to say something about what PL is, as a field of study.

What is PL? What is the field of programming languages? So I think that PL is one of the most misunderstood areas of computer science, unfortunately. It's actually even misunderstood by other computer scientists who are not specialists in PL. And it's misunderstood because when people hear programming languages, well, they think of, well, particular programming languages. They think of languages that they may have seen and used and worked with, like Python and C and Java and so forth. But the essence of what the field of PL is about is not the details of this or that programming language. That's not really what it's about. So what is the field of PL actually about? What do PL people do?

What I'm about to say here is heavily inspired by my friend and sometime collaborator, Mike Hicks, who's an emeritus professor at the University of Maryland.  Mike says that there are two things that PL people do.

PL people:

- Consider the *programming language* to have a central place in solving computing problems.

This is actually a pretty unusual and niche point of view!  A lot of computer scientists, they don't actually think that the programming language that they use to solve a given problem is all that important. They're concerned with the problems that they want to solve, but the question of *what language* they might use to implement a solution to the problem is considered, well, an implementation detail. It's not considered particularly important. They might figure that most languages are more or less the same anyway. They're all Turing-complete or close enough, so who cares?

The PL point of view is different. The PL point of view says that the programming language itself actually has a central place in the problem-solving process.  And the choice of language matters. And the choice of abstractions that a language offers to the programmer matters. If you take the PL point of view, then the way that one approaches solving a computing problem is first by designing a language that offers the right tools for solving that particular problem, and then using the language you designed to implement a solution to the problem.

At the extreme, this might mean designing a new language to solve each new problem you have. Now that might sound at first like a ridiculous thing to do, right?  But the PL perspective is that this is actually already something programmers do.  Language design doesn't have to be something that takes months or years.  Language design, broadly construed, might be something that only takes a day, or a few hours, or a few minutes -- in fact, it's something that programmers are actually doing all the time, maybe without realizing it.  It could be as simple as designing a data structure that's a good fit for a problem one needs to solve, and then designing a few operations on that data structure that serve as its interface -- and that's actually language design in some sense, because it gives you a new way of talking about the problem you want to solve, and now you can write programs using that new way of talking, at a level of abstraction that suits the problem you want to solve.

So the PL perspective says, well, as long as we're gonna be doing things that kind of feel like language design anyway, let's take that seriously and let's actually study language design. Let's take language design seriously as a field of study in itself. And let's treat it like something that's actually important to the problem-solving process, rather than just something that happens accidentally. When we do that, we can distill some key principles that seem to show up again and again, where if we adopt those principles, we can avoid certain pitfalls and even rule out whole classes of bugs.

So that's one thing.

The other thing that Mike says PL people do is:

- Consider software behavior in a *rigorous* and *general* way.

What does this mean? What does it mean to consider software behavior in a rigorous way?  By this, I mean that programs are actually mathematical objects that we can reason about formally, using the tools of mathematics.  In fact, programs are actually things that we can write proofs about, if we want to.  I'm not just talking about testing.  Testing can only reveal the *presence* of bugs.  I'm talking about being about to verify the *absence* of certain kinds of bugs.

If we're willing to put forth the effort, we can achieve a very high level of assurance about the behavior of software. Most of the time, we're not gonna go to that level of effort, but it's nice to know that we could. It's nice to know that it's possible to rigorously know things about software behavior, that programs actually are mathematical objects that can be reasoned about with the tools of mathematics.  So that's what we mean by considering software behavior in a rigorous way.

OK, so that's the word "rigorous". What about the word "general"? By this, I mean that PL people are often not just concerned with, let's say, one particular program. We're concerned with a whole class of programs. Maybe we're concerned with all of the programs that you can write in a particular language, right? That language itself might be narrow or broad. But PL people often make claims about all of the programs that can be written in a particular language. Later in this course, I'm gonna be making claims about Haskell programs broadly, for example. It's very powerful to be able to say something about *all* of the programs written within a particular language, or all of the programs that use or don't use a particular language feature. Take Rust, for example: Rust is a memory-safe language, which means that there's a whole class of memory-related errors that will be ruled out if you're writing Rust, as long as you're not using the unsafe fragment of the language. If you're using safe Rust, that class of bugs is off the table.

And this is a wonderful, freeing thing, as a programmer, to know that in a given language, regardless of what code you write, a given class of bugs just cannot happen, unless there's a bug in the language implementation itself.

So, this is what PL is about. So considering the programming language to be central to solving computing problems, and considering software behavior in a rigorous and general way.

Obviously, we can only scratch the surface of these ideas in this class in 10 weeks. But we'll try. For a lot of people, this may be the first and last PL course you ever take. But I hope it's not the last time that you use the PL point of view. I hope it's not the last time that you try to apply this perspective to the way that you do computer science, and maybe even to the way that you live your life.

If you're in this class, there's a good chance that you're a future professional computer scientist. And this means that in the future, you're going to be expected to be conversant in a whole bunch of programming languages, including ones that haven't been invented yet, right? I brought up Rust as an example earlier, so let me tell you a story from my own life. When I was an undergrad -- I went to undergrad from 2000 to 2004 -- Rust did not exist yet. But when I was in grad school in 2011, I joined the Rust team as an intern, and I worked on the Rust compiler, which was itself being implemented *in* Rust. So there I was, at this internship in 2011, writing Rust, which was being developed in public, but there hadn't been any releases yet.  When I started we were still close to a year away from the 0.1 release, which happened in 2012. I had certainly never written Rust before that job, and neither had anyone else on the team.

How is that possible? How could we, people who had zero experience in this language, be working in this language on the compiler for this language?  It's because we had studied the foundations of programming languages. We had studied a rigorous and general approach to reasoning about software behavior, and we had studied the principles of language design and implementation. So it wasn't about having expertise in one particular programming language or another. The programming languages that you will be expected to use in the future haven't been invented yet. I sure hope they haven't, because the programming languages that we have right now are really not that great!  (Rust included!)

So I hope that when you are a professional computer scientist 10 years hence, or 20 years hence, that by then we'll have better languages, which you will be fluent in. How are you going to become fluent in them? I can't teach them to you, because they don't exist yet, or they're still in the realm of research.  But what I *can* do is help you to become fluent in the principles of programming languages, so that then you will be able to easily pick up the languages of the future.
