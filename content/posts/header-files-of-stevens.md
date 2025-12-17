+++
title = 'Source dive: the header files of W. Richard Stevens'
date = 2025-12-17T17:11:40-05:00
draft = false
+++

I like to blog about the art of writing secure, resilient, readable, writable system software. I like to find the patterns that make software pleasant to work with, and the anti-patterns that make it treacherous to maintain and operate.

*Source diving* is a term borrowed from players and hackers of the [rogue-like video game NetHack](https://nethackwiki.com/wiki/Source_diving) to describe a method of examining  the source code of a system. To source dive is not merely to read through code; it is a deliberate and judicious undertaking. It requires code written deliberately and judiciously.

I want to start off small and look at the works of W. Richard Stevens, author of TCP/IP Illustrated, Unix Network Programming, and Advanced Programming in the Unix Environment, as well as a half-bakers dozen of the RFCs that describe the protocols that make our internet. In an appendix in each of his major books, Stevens included a C header file to assist his readers in copying, compiling, modifying, and hacking the code examples in his books, as well as a set of error-handling and logging functions that can be used to keep code readers and writers happy. 

I'd like to look at these in turn starting with the header file but first a note on copyright. Per [the author's faq](http://www.kohala.com/start/rstevensfaq.html), *"my publishers graciously allow all the code to be made available, but the code is provided "as is" with no support implied."* While not an open source license, I'll interpret this as meaning that we can copy, discuss, and consider improvements to his code. These expensive books are valuable because they help us become better software developers, *and they are worth it.* Their publisher, Addison Wesley, would undercut their own value proposition if they were to try to undercut that of their readers.

The header file[^1] starts with a comment:

```C
/* Our own header, to be included before all standard system headers */
```
Stevens uses the portable `/* ... */` comment style rather than the svelte `// ...` which works with most modern C compilers because portability trumps trendiness whenever programmers can't be bothered to revisit old code. Notice, though, the prefatory clause: `Our own header...,`. To whom is he referring? The authors and readers? Or just the authors? A hint lies in the operative clause: `to be included before all standard system headers`. So then this file exists for all who might include it. If you were to put a similar prescription in a header file in your open source project, it would apply to the maintainers of that project. Because the code in this book was meant to be worked with by the reader, herein, author and reader are one and the same.

Next is a construction familiar to most C developers:

```C
#ifndef _APUE_H
#define _APUE_H
```

which is matched at the last line of the file:

```C
#endif /* _APUE_H */
```

This ensures that should the preprocessor include this header file twice in the same source file, either through straight-forward repetition or, more likely, because a source file includes two header files which each include this one, that the contents of this file are only supplied once, the first time the file is referenced. 

The next line, 

```C
#define _XOPEN_SOURCE 600
```

politely asks the underlying system to please serve up version 3 of the Single Unix Specification. Old Stevens heads like to get chapter and verse when it comes to the various attempts at standardization to make different flavors of Unix behave in unsurprising ways and Stevens devotes his second Chapter of APUE to describing them. This `#define` is here basically to state "if you behave like SUSv3, the bugs are all on me."

After this follows a variety of `#include`s of generally useful header files, with a few interesting constructions:

```C
#include <sys/termios.h>	
#ifndef TIOCGWINSZ
#include <sys/ioctl.h>
#endif
```

If  `sys/termios.h` doesn't provide the definition of `TIOCGWINSZ`, `sys/ioctl.h` will. Which Unices define this symbol where? [NetBSD 5.0.2](https://www.tuhs.org/cgi-bin/utree.pl?file=NetBSD-5.0.2/lib/libcurses/setterm.c) says that "old systems" define it in `sys/ioctl.h` and it is copyright 1994, so. This is one of those niggling little factoids of portability that everyone loathes knowing, despises remembering, and never under any circumstances wants to be bitten by. 

```C
#define MAXLINE 4096          /* max line length */

```

Some, but not all, library functions will insist that you identify a maximum line length, and whatever you use should be uniform across your program. Stevens uses 4096 for lots of default buffer sizes. Hereafter, Stevens defines some default filesystem permission modes and fills in a possible signal gap and gives us two convenience macros:

```C
#define min(a,b) ((a) < (b) ? (a) : (b))
#define max(a,b) ((a) > (b) ? (a) : (b))
```

which are defined as macros so that you can call them with any numeric data type and in fact can mix ints and floats:

```C
float f = 5.0;
int i = 6;
int j = max(i, f);
```

does what you think it will! But `int j - max(++i, f);` might not. We'll return to this in a future post.

After this, `apue.h` declares prototypes for all functions in the book so that any function can call any other function. Larger projects might not want global visibility across all functions, but larger projects are free to have many, smaller include files.

Next time we'll look at Stevens' error handling routines and talk about where Golang learned the wrong lesson from C. 

[^1]: I'm using Appendix B.1 from "Advanced Programming in the UNIX™ Environment", Second Edition, which he co-authored with Stephen A. Rago, but the themes we consider will apply throughout his work. His network-oriented works will have more networking material. His inter-process communication work will have stuff for that stuff.

