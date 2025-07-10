---
title: Sightseeing the Sea of C++ (#1)
date: 2025-05-18
---

# introductio<span>n</span>

wow, where have I been... I have been **slacking** that is for sure... but fear not, 
for I have made the the executive decision to properly sit down and learn `c++`!!!

Unbeknownst to most people, I actually learned `c++` by doing [Leetcode problems](https://ericzheng.nz/leetcode.html),
(which I believe now to be an unironically terrible way to get started learning a language...).

Basically, this post will be less of a formal **tutorial** on how to program in `c++`,
(since there is already enough of that online)
but more just me yapping about **new concepts** I have grasped after going through the entirety of [https://www.learncpp.com/](https://www.learncpp.com/).

This is mainly because I want my employers to **not** get flash-banged by my cod-, 
**cough** because I realised I lack a lot of `c++` fundamentals and best practices that people... usually learn... first...

## post-editor messag<span>e</span>

Well, hey! Turns out `c++` has a **lot of new-content**; 
content that I do not think I will be able to get through in one sitting...

Unfortunately, while that does mean I will not be covering all the content in this write-up,
I guess it means, there will be more blog posts to come...!

# c++ basic<span>s</span>

## forms of initializatio<span>n</span>

```cpp
// Traditional initialization forms:
int b = 5;     // copy-initialization (initial value after equals sign)
int c ( 6 );   // direct-initialization (initial value in parenthesis)

// Modern initialization forms (preferred):
int d { 7 };   // direct-list-initialization (initial value in braces)
int e {};      // value-initialization (empty braces)
```

Apparently, there exist more than one way to initialize a variable.

Normally, to initialize a variable, I would just do `int b = 5;` (*copy-initialization*);
however there exists *direct-list-initialization* with `int b { 5 };`
where the main benefit is disallowing "**narrow conversions**".

This occurs, when you convert a value from a **larger** *data type* to a **smaller** *type*:

:::sidebar
- `int b = 4.5;`, will have the compiler drop the `.5` to make `b = 4`
- `int b { 4.5 };`, will let the compiler throw a **compilation error**
:::

Consequently, for objects where the initial value is temporary and will be replaced, it is also encouraged to use *value-initialization*
as it will implicitly initialized to zero (or whatever value is closest to zero).
```
int width {}; // value-initialization / zero-initialization to value 0
```

**Note**, even the creators of `c++` also recommended initializing variables [like this](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#Res-list).

## "std::endl" vs "\\n<span>"</span>

Unfortunately, I may have been using `std::endl` my entire career (which is not good performance-wise)
since it also flushes the buffer; this means if we have multiple `std::endl` commands, 
it leads to multiple output buffer flushes (which is inefficient).

Instead, using `\n` circumvents this issue completely, 
especially since `c++`'s output system is designed to self-flush periodically,
and it's both simpler and more efficient to let it flush itself.

# c++ basics: functions and file<span>s</span>

## parameters vs argument<span>s</span>

Disaster; I basically just called them both arguments.
However:

```cpp
int add(int a, int b) // `a` and `b` are "parameters"
{
    return a + b;
}

int main() 
{
    std::cout << add(2, 3) << std::endl; // `2` and `3` are "arguments"
}
```

However, it is possible to have **unnamed parameters**.

## unnamed parameter<span>s</span>

...where you omit the name of a function parameter.
It is used in cases where the parameter needs to exist, but it is not used in the body of the function.

```cpp
void doSomething(int)
{

}
```

Most common use case for this type of syntax would occur in functions that have already been initialized in several places.
If it originally had a parameter that is now **no longer needed**, 
it would be quite tedious having to *manually remove the argument from every call*.

Therefore, its better if we removed the name of the parameter (temporarily), 
as it signifies that it is **not** being used in the body of the function.

## forward declaration<span>s</span>

In `c++`, the ordering of how functions are declared is **important**.
Especially when you start *importing functions from other files*,
you have to make sure to use **forward declaration** to make sure that,
when the program compiles **sequentially**, that it has **already been defined**.

An example would be before a function definition like
```cpp
int doMath(int first, int second, int third, int fourth)
{
     return first + second * third / fourth;
}
```
its best to place a function declaration like:
```cpp
int doMath(int first, int second, int third, int fourth);
```
at the start of the program.

If you continue to work with **multiple files**, it is also imperative to use:

## namespace<span>s</span>

An example of namespaces are the `std::` you usally see in front of functions like `cout` to get `std::cout` 
(when you import from the *standard library*).

Whilst it might seem annoying to have to write `std::` in front of every identifier in the `c++` *standard library*,
without it it means that it could potentially conflict with *any identifier that you have defined previously*.

An example would be:

```cpp
#include <iostream>

using namespace std;

int cout() // defines our own "cout" function in the global namespace
{
    return 5;
}

int main()
{
    cout << "Hello, world!"; // Compile error!  Which cout do we want here? 
    // note, `::cout << "Hello, world!";` would accomplish the same thing here
    return 0;
}
```


:::important
### not<span>e</span>

You may have noticed the inclusion of `using namespace std;` in the above code.
As the name implies, it tells the compiler to use the `std` namespace by *default*.

This is often included in programs written for competitive programming competitions,
as the algorithms you devise are small enough such that having separate namespaces would be **overkill**
(You also tend to sacrifice code quality for speed, as you do not get points for code quality).
:::

However, for more complicated programs, using **namespaces** is an easy way to track where identifiers come from and avoid *name collisions*
(which is why its **BAD PRACTICE** to use `using namespace std;` as it forces us into a *specific namespace*).

:::important
### not<span>e</span>

The only instance where `using namespace` might be *slightly acceptable* is if you:

- use it in only `.cpp` files
- include it after all the `#include` directives
:::

An example:
```cpp
#include <iostream>

namespace tungTungTungSahur {
    int favouriteNumber = 24;
}

int main() {
    // accessing the variable `favouriteNumber` using the namespace
    std::cout << tungTungTungSahur::favouriteNumber << '/n';
    return 0;
}
```

You can also nest namespaces & multi-level namespaces are usually used to prevent conflicts between code generated by different teams:
```cpp
namespace tungTungTungSahur {
    int favouriteNumber = 24;
    namespace tralaleroTralala {
        int favouriteNumber = 42;
    }
}

tungTungTungSahur::tralaleroTralala::favouriteNumber // will be 42
```

## introduction to pre-processor<span>s</span>

Before compilation, the `c++` program goes into a **preprocessing** phase, where it

:::sidebar
- strips comments
- ensures each code file ends in a new line
- **(most importantly)** scans for **preprocessor directives**
:::

**Preprocessor directives** are any instructions that start with a `#` and end with a newline (no semicolon).
Examples and their use cases include:

:::sidebar
- **IMPORTS**:
    - `#include <iostream>`, the preprocessor replaces the `#include` directive with the contents of the included file (usually header files)
- **MACROS**:
    - `#define MOD 1e9+7`, the preprocessor defines a **macro** to define how input text is converted into replacement output text
        - `#define MOD`, however you can also define it without *substitution text*, this can be for:
- **CONDITIONAL STATEMENTS**:
    - `#ifdef MOD` and `#endif`, the preprocessor will check if an *identifier* has been **previously defined**
        - `#ifndef MOD`, however, checks if an *identifier* has **NOT** been **previously defined**
```cpp
#ifdef MOD
    std::cout << "Joe\n";
#endif
```
    - `#if 0`/`#if 1` and `#endif`, the preprocessor will compile (`#if 1`) or not compile (`#if 0`) the code within the conditional block
        - you usually as a way to comment out code in a more *explicit* way compared to *regular comments* (`//` or `/* */`)
        - note that `#elif` and `else` also exists with the same syntax
:::

Do note, that **preprocessor directives** do not understand `c++` syntax;
meaning if it is defined in a function, it is not restricted into the *local* scope
```cpp
void doSomething() 
{
    // this will still be defined globally,
    // being only valid from
    // point of definition -> end of the file
    #define MY_FAVOURITE_NUMBER 24
}
```

## header file<span>s</span>

Previously, we talked about **forward inclusion**.
This might be quite feasible with only a few functions, but for hundreds!?

That is why **header files** exist (usually with the `.h` extension).

**Header files** aim to include all the declarations for functions defined in the corresponding `.cpp` file.

For example, if `add.cpp` contains:
```cpp
int add(int x, int y)
{
    return x + y;
}
```
then, the respective `add.h` file contains:
```cpp
#ifndef ADD_H
#define ADD_H

int add(int x, int y);
#endif
```

Then, when you are compiling multiple `.cpp` files,
for *any files* that use functions from `add.cpp`,
we need to add the line `#include "add.h"` at the top of that respective file.
For example:
```cpp
#include "add.h" // inserts contents from `add.h`
#include <iostream>

int main() 
{
    std::cout << add(2, 3) << '\n';
    return 0;
}
```

Now, notice that at the top of the header file, we have a **header guard**:
```cpp
#ifndef ADD_H // header guard
#define ADD_H // header guard

//code goes here

#endif
```
Nowadays, every header file contains a **header guard** to prevent files from loading a header file **more than once**
and lead to **duplicate definitions** which would run into a *compilation errors*.

Note, in modern `c++`, `#pragma once` serves the same purpose as a **header guard**. 

# debugging c++ program<span>s</span>

(lowkey glossed over this section-)

This chapter mainly went into methods of debugging that are prevelant everywhere.
I believe the main take-aways for this chapter for me would that,
other than the normal debugging methods of *commenting out code* and *placing `print` statement* at the correct positions,
IDEs actually have quite extensive **integrated debugging** tools:

:::sidebar
- using a **stepper** you can execute code *statement by statement*
    - **step into** allows you to *step into* a function / method to see what happens within it
    - **step over** runs the current line of code but *skips over any function calls* (runs it all as a single step)
    - **step out** runs the remaining code in the current function and return to the point where it was called
    - **step back** (most debuggers do not have this functionality due to its complexity)
:::

# introduction to fundamental data type<span>s</span>

## introductio<span>n</span>

To check the size of any types, you can use the handy `sizeof` command (commonly used with `malloc`):
```cpp
std::cout << "long double: " << sizeof(long double) << " bytes\n";
// will output "long double: 8 bytes"
```
This will be of the **unsigned integer** type, however which type (e.g. `int`, `long`, `long long`, etc) is to be defined by the compiler
(This also implies that there exists an **upper limit** on the size of typing)

For the **fundamental data types**, we have 4 candidates:

:::sidebar
- integers
- floats
- booleans
- chars
:::

## integer<span>s</span>

### signed-integer<span>s</span>

Most of the time, we should be using signed integers:

:::sidebar
- **short** => `2 bytes` (16 bits)
- **int** => `2/4 bytes` (16/32 bits)
- **long** => `4/8 bytes` (32/64 bits)
- **long long** => `8 bytes` (64 bits)
:::

(Note, `int` and `long` are not of **fixed-size** to allow *compilers* to choose sizes that is optimal for the hardware to run on;
back in the old-days, this optimisation was made to improve **performance** as computers used to be quite slow)

Their ranges are consequently:

:::sidebar
- **short** => `-(2^15)` to `+(2^15-1)`
- **int** => `-(2^15)` to `+(2^15-1)` / `-(2^31)` to `+(2^31-1)`
    - approximately `-(3 * 10^5)` to `+(3 * 10^5)` / `-(2 * 10^9)` to `+(2 * 10^9)`
- **long** => `-(2^31)` to `+(2^31-1)` / `-(2^63)` to `+(2^63-1)`
- **long long** => `-(2^63)` to `+(2^63-1)`
    - approximately `-(9 * 10^18)` to `+(9 * 10^18)`
:::
(using **two's complement**)

### unsigned-integer<span>s</span>

There also exist *unsigned integer variants* which most people avoid ([Nuclear Gandhi](https://en.wikipedia.org/wiki/Nuclear_Gandhi)) 
since it is:

:::sidebar
1. quite easy to overflow, since it can not take **negative numbers**
2. in mathematical operations, if we have an operation between *signed* and *unsigned* integers, the **signed integer** will usually be *converted to* **unsigned integer**
:::

Unfortunately, unsigned operations are still okay/necessary in certain circumstances (that I agree with):

:::sidebar
1. for *bit manipulation*
2. in *array indexing*
3. with limited memory, like in embedded systems
:::

### fixed-size integer<span>s</span>

However, if we need **fixed-size** integers, we have e.g. `std::int#_t` and `std::uint#_t` for `8`, `16`, `32` and `64` bytes. 
There do exist potential down-sides to **fixed-size** integers:

:::sidebar
- `std::int8_t` and `std::uint8_t` will behave like `signed char` and `unsigned char` on **most modern architecture**
- **fixed-width** downsides, where it is *not guaranteed to be defined on all architectures*
- some **fixed-width** integers, e.g. `uint32_t` might be *slower* than `int` since the hardware might be *faster at processing 64-bit integers*.
:::

### other integer numbering system<span>s</span>

Note, we can convert these integers into binary, hexadecimal and even octal:
```cpp
// note the ' can be used to separate digits
int decimal{ 20'184'091 };  // demonstrating using (') to act as digit separators 
int binary{ 0b0010'0101 };  // 0b in front; 37 in decimal
int octal{ 012 };           // 0 in front; 10 in decimal
int hexadecimal{ 0x1F }     // 0x in front; 31 in decimal
```
and that there exists a datastructure `std::bitset<#>`

An exemplar of its syntax and what it can do:
``` cpp
#include <bitset>
#include <iostream>

int main()
{
    std::bitset<8> bits{ 0b0000'1101 };
    std::cout << bits.size() << " bits are in the bitset\n";   // 8
    std::cout << bits.count() << " bits are set to true\n";    // 3

    std::cout << std::boolalpha; // booleans output 'true' or 'false' instead of `1` or `0`
    std::cout << "All bits are true: " << bits.all() << '\n';  // false
    std::cout << "Some bits are true: " << bits.any() << '\n'; // true
    std::cout << "No bits are true: " << bits.none() << '\n';  // false

    return 0;
}
```

## floating poin<span>t</span>

In the *floating point category*, we have **3 main candidates**:

:::sidebar
- `float` => `4 bytes`
    - almost always uses **4-byte IEEE 754 single-precision format**
- `double` => `8 bytes`
    - almost always uses **8-byte IEEE 754 double-precision format**
- `long double` => `8, 12, 16 bytes`
    - **AVOID USING THIS**
    - the size varies, and sometimes it may not even use IEE754 compliant format
:::

The main issues we can encounter is **rounding errors**.
Since floating points can only display a *certain number of significant digits*:

:::sidebar
- `float` => accurate to 6 digits 
- `double` => accurate to 16 digits 
:::

meaning, for programs like:

```cpp
#include <iomanip> // for std::setprecision()
#include <iostream>

int main()
{
    // double not accurate to 17 digits
    std::cout << std::setprecision(17);

    //note `std::cout` only accurate to 6 digits

    double d1{ 1.0 };
    std::cout << d1 << ' ';

    double d2{ 0.1 + 0.1 + 0.1 + 0.1 + 0.1 + 0.1 + 0.1 + 0.1 + 0.1 + 0.1 }; // should equal 1.0
    std::cout << d2 << '\n';

    return 0;
}
```

we get:
```
1 0.99999999999999989
```
meaning we have to be **very** careful when handling **financial data** 

(yes, JS/HRT/CitSec/IMC/Optiver/SIG/etc I will be very careful)

Finally, there are also certain **special** floating point numbers (just possible with the IEE754 implementation):

:::sidebar
- `+Inf` and `-Inf` => *infinity*
- `+0.0` and `-0.0` => *positive/negative zero*
- `Nan` => *not a number*
:::

## booleans & char<span>s</span>

For both these sections, nothing novel was covered:

:::sidebar
- booleans (`bool`) takes on only **2 values**: `true` and `false`
- char (`char`) is a `1 byte` data type that takes on an `ASCII character`
    - can also take on **escape sequences** (that begin with `\` (backslash) like e.g. `\n` and `\t`)
    - avoid **multicharacter literals** e.g. `'56'` since the value depends on the *implementation*
:::

finally, since we do want to convert between types

## static_cas<span>t</span>

The common that we are used to is `implicit type conversion` like e.g. passing a `float` type into a function that takes an `int` parameter.

However, for **explicit** type conversion:
```cpp
#include <iostream>

float number { 5.5 };

// BAD - I used to use
std::cout << (int)number << '\n';

// GOOD - what I should be using
std::cout << static_cast<int>(number) << '\n';
```

The method I used previously is consdered **worse**, because it actually tries *many kind of casts*;
meaning, in certain situations, the output may *vary*, making it harder to interpret or debug.

For `static_cast`, realise that it only does **non-polymorphic** (classes with no `virtual` functions) conversions at **compile-time**.

# constants and string<span>s</span>

## constant<span>s</span>

There exist **2 types of constants**:

:::sidebar
- **named** constants are *associated with an identifier*
    - e.g. `const int FAVOURITE_NUMBER = 24`
    - **always** prefer *named constants* over *preprocessor macros*
        1. **scoping issues**; replaces ALL subsequent instances of the identifier in the file
        2. **harder to debug**; macro gets replaced after compilation, so compiler / debugger will not be able to see macro
        3. **naming conflicts**; macro replaces **ALL** exact-same instances in code and arguments
        4. **not type safe**
- **literal** constants are *NOT associated with an identifier*
    - e.g. `integers`, `floating point values`, `booleans`, `characters`, `strings` etc
    - are able to convert the types of literals using **suffixes**
        - from an `int`, you can convert using `u`, `L`, `uL`, `LL` or `uLL`
            - e.g. `500LL` gets converted to type `long long`
        - from a `double`, you can convert using `f` or `L`
            - e.g. `500.0L` gets converted to type `long double`
        - from a `c-style string`, you can convert using `s` or `sv`
:::

## compile-time optimisation's related to constants (as-if rule<span>)</span>

Outside of optimisations done by hand (using tools like a **[profiler](https://en.wikipedia.org/wiki/Profiling_(computer_programming))**),
most modern `c++` compilers are **optimizing compilers**.

In fact, they are given quite a lot of leeway:

::: important
### as-if rul<span>e</span>

the compiler can modify the original program in any way (in order to optimise)
as long as it does not produce any "observable changes"
:::

As a result, if *optimisations are not disabled*, 
modern `c++` compilers are capable of evaluating certain expressions during **compile-time** instead of during **runtime**
(using the `as-if rule`, this is hence called **compile-time evaluation**):

::: sidebar
- **constant folding**; simplifies expressions involving literals 
    - e.g. `3+4` turns into `7`
- **constant propagation**; replaces variables with their values (if known to be constants)
    - e.g. if we are trying to run `std::cout << x << '\n';` where `x` is a *constant* equal to `7`, the compiler will replace `x` with `7`, so computation does not need to be spent on **retrieving** the constant
- **dead-code elimination**; replace code that is **not used anywhere**
:::

Hence, we could conclude that having `const` makes these *compile-time* optimisations more efficient.
However, its deeper than that:

### const vs constexp<span>r</span>

While the `as-if rule` is good for improving performance,
it means we rely on the **compiler** to make these optimisations.
However, what if it was possible to make these optimisations **yourself**?!

Introduction: **compile-time programming!!!!**

For `c++` programs, you want to offset as much programming into the **compile-time** as possible
as its more performant (less run-time) and more secure (predictable).
You tend to do this through **constant expressions**.

:::important
### constant expressio<span>n</span>
you can think of as this; for an expression to be able to be ran on **compile-time**,
it must already have all the necessary information needed before-hand to make all operations **during** compile-time
:::

Therefore, to make comparisons between `const` and `constexpr`:

:::sidebar
- `const` means this value can **not** be changed after initialization
    - use when you want the value to be initialized during **run-time** and **immutable**
- `constexpr` means this value can **not** be changed after initialization **AND** can be used in an **constant expression**
    - value **MUST** be known at *compile-time*
    - use when you want the value to be initialized during **compile-time** and **immutable**
:::

Examples:

```cpp
const int a { 1 }          // a is usable in constant expressions (a is const integral variable)
int b { 5 };               // b is not usable in constant expressions (b is non-const)
const int c { d };         // c is not usable in constant expressions (initializer is not a constant expression)
const double d { 1.2 };    // d is not usable in constant expressions (not a const integral variable);

constexpr int e { 1 }      // e is usable in constant expressions 
constexpr double f { 1.2 } // ''
```

NOTE, the `as-if rule`-based optimisations and **compile-time programming** can be **disabled** for **debugging purposes**
because during compile-time, the optimisations usually *changes how the program looks* and how it *behaves under the hood*,
making actions like *stepping through code* confusing.

## string<span>s</span>

`C-style` strings are known to be *immutable*.
Hence, we have the `std::string` library importable from `#include <string>`
Note that, currently, any double-quoted strings are initialized as a `c-style` string (which is **null-terminated**; ends with the character `'\0'`).

The main issues with this is **performance**; initializing & copying `string` values are **expensive**.
Therefore, whenever it is possible, it is better to:

:::sidebar
- use `std::string_view` from `#include <string_view>`
    - provides **read-only access** to an *existing* string **without** making a copy
    - usually better since it is more versatile; takes in more types
- use a reference to the string e.g. `const std::string&`
:::

However, in functions, it is **fine** to return `string` from functions, 
if they are a **local variable** and not a copy of a pre-existing string.
It is still preferred to avoid returning `string` values if possible. 
For example, if the function is returning a `c-style` string literal,
then we can use a `std::string_view` return type instead.

In fact, `std::string_view` is very versatile:

:::sidebar
- able to be initialized / re-assigned using **ALL `string` types**
    - if we reassign a `std::string_view`, it just "views" the new string instead
- can **NOT** be implicitly converted to `std::string`
    - either use `static_cast`ing or define the string with `std::string_view` as the initializer
:::

the only problems are with **dangling** view. If the `std::string_view` is initialized to a `string`,
and that `string` gets edited / deleted, then undefined behaviour will result.

Finally, since technically `std::string_view` is like a "window" gazing at a `std::string`,
it is possible to attach curtains to limit what we can view. 
That is what the `string.remove_prefix(#)` and `string.remove_suffix(#)` function does,
which does have the side-affect of not being **null-terminated** anymore 
(if you need it to be null-terminated, you can simply just convert `std::string_view` to `std::string` instead).

# operator<span>s</span>

For most operators, I believe that I have a sound understanding of the operators that exist and the ordering of such operators.

The main takeaway for this chapter would be that, 
while *precendence and associativity rules* helps group complicated expressions into *"easier-to-digest" sub-expressions*,
the ordering at which these variables / sub-expressions can **still** be evaluated in any order.

In cases like `a * b + c * d`, the order in which the sub-expressions get evaluated does not matter at all,
however, the example provided illustrates this well:
```cpp
#include <iostream>

int getValue()
{
    std::cout << "Enter an integer: ";

    int x{};
    std::cin >> x;
    return x;
}

void printCalculation(int x, int y, int z)
{
    std::cout << x + (y * z);
}

int main()
{
    printCalculation(getValue(), getValue(), getValue()); // this line is ambiguous

    return 0;
}
```

In this case, if we entered in `1`, `2` and `3`,
unfortunately the arguments do not always get evaluated in the same order (compiler dependent):

:::sidebar
- `printCalculation(1, 2, 3) = 1 + (2 * 3) = 7` (Clang)
- `printCalculation(3, 2, 1) = 3 + (2 * 1) = 5` (GCC)
:::

meaning I need to ensure that functions that I write do not depend on the **operand evaluation order**.

Another example includes:
```cpp
int i = 0;
int arr[2] = {10, 20};
// undefined behaviour below
int val = arr[i] + i++; // do not know if `arr[i]` or `i++` is called first
```

Two other more niche parts that I should mention would be:

::: sidebar
- **comma operator** (,) allows you to compute multiple expressions on one-line
    - however, it returns the result of the **right-most** expression
- **avoid comparing floats** as they are rounded values; unable to compute exact values
    - can still compare them as long; want to see that they are **close enough** to `0`
:::

# scope, duration, and linkag<span>e</span>

## scop<span>e</span>

:::important
### scop<span>e</span>

declares where the identifier can be accessed within the code
:::

For this, you have the important two candidates:

- **local** scope
- **global** scope

## duratio<span>n</span>

:::important
### duratio<span>n</span>

declares when the identifier will be created & destroyed
:::

Global variables have **static** duration,
meaning they are created when the program starts and destroyed when it ends.

- note, that it is best to initialize them with `g_` at the front to name global variables to avoid collions
    - in fact, its also recommended to place every global in a separate namespace

## linkag<span>e</span>

:::important
### linkag<span>e</span>

declares whether an identifier declared in a separate scope refers to the same object
:::

For object defined in the **local scope**, there is **no linkage**.
```cpp
#include <iostream>

int main()
{
    int x { 2 }; // local variable, no linkage

    {
        int x { 3 }; // this declaration of x refers to a different object than the previous x
        
        std::cout << x << '\n'; // outputs '3'
    }

    std::cout << x << '\n'; // outputs '2'

    return 0;
}
```
This is called **variable shadowing**, as you are effectively "hiding" the outer variable when they are both in scope,
which is something we want to *avoid*.

For global variables and function identifiers, there exists two types of linkages:

#### interal and external linkages ('static' and 'extern'<span>)</span>

:::sidebar
- **internal linkages**:
    - makes the identifier seen **only within the file** that they are defined in
:::

If we want to make identifiers have internal linkage, then we have two options:

- we can use keyword `static` when we do **NOT** want identifiers accessible to other files.

```cpp
// Internal global variables definitions:
static int g_x;          // defines non-initialized internal global variable (zero initialized by default)
static int g_x{ 1 };     // defines initialized internal global variable

// Internal function definitions:
static int foo() {};     // defines internal function
```

Variables with inherent internal linkages are `const` and `constexpr`:
```cpp
// Internal global variables definitions (no static):
const int g_y { 2 };     // defines initialized internal global const variable
constexpr int g_y { 3 }; // defines initialized internal global constexpr variable
```

However the better option is:

- using an **unnamed** `namespace` and wrapping it around all the identifires we do not want accessible from other files
```cpp
#include <iostream>

namespace // unnamed namespace
{
    void doSomething() // can only be accessed in this file
    {
        std::cout << "v1\n";
    }
}

int main()
{
    doSomething(); // we can call doSomething() without a namespace prefix

    return 0;
}
```


:::sidebar
- **external linkages**:
    - makes the identifier seen and useable **within other files** (via forward declaration)
:::

We can make variables have external linkages with `extern`

- best to use `extern` for *global variable* forward declaration or *const global definitions*

```cpp
// Global variable forward declarations (extern w/ no initializer):
extern int g_y;                 // forward declaration for non-constant global variable
extern const int g_y;           // forward declaration for const global variable
extern constexpr int g_y;       // not allowed: constexpr variables can't be forward declared

// External const global variable definitions (extern w/ initializer)
extern const int g_x { 2 };     // defines initialized const external global variable
extern constexpr int g_x { 3 }; // defines initialized constexpr external global variable
```

Variables with inherent external linkages are non-`const` global variables:
```cpp
// External global variable definitions (no extern)
int g_x;                        // defines non-initialized external global variable (zero initialized by default)
int g_x { 1 };                  // defines initialized external global variable
```

In this case, `extern` and `static` are **storage class specifiers** (as they detail the *storage duration* and *linkage*)

#### 'static' on local scope variable<span>s</span>

In fact, using `static` has different interactions with **local scope variables**.
Basically, when used on local variables, `static` makes the local variables only created **once** and will be deleted once the program ends.
This means that the

- **scope** will still be local
- **BUT** the variable's value will be **preserved** across several different calls


finally, the last keyword to mention is:

#### inline (history lesson<span>)</span>

Historically speaking, `inline` optimisation used to be a thing:

:::sidebar
- **functions** (not useable anymore)
    - functions have **overhead**; have to call the functions and the arguments involved with it
    - in order to save overhead for defining the functions, it was better for smaller functions to use `inline` so that the function could potentially replace the function call with the function body
:::

Now, `inline` has evolved to imply **"multiple definitions are allowed"**; however, these definitions have to be **identical**
(will de-duplicate if multiple definitions)

:::important
### not<span>e</span>

Understand, that `inline` variables have **external linkages** by default, so that the *linker* is able to see them and de-duplicate the definitions.
:::

Now, onto something thats **not history**. Now, the definition of inline is:

:::important
### inlin<span>e</span>

multiple definitions are **allowed**, without violating ODR (one definition rule);
these definitions have to be **exactly the same**
:::

which can be used on:

#### inline function<span>s</span>

... which is used mainly to define **header-only functions**.

If possible, we do **NOT** want to do this, since the compilation time will drastically increase
(same function definition has to be compiled in every file it is imported in before it gets de-duplicated in).

(it is acceptable if you are creating something like a **header-only library** though)

#### inline variable<span>s</span>

... which is used mainly to define **header-only global constants**

There exists 2 (worse) ways to define **header-only global constants**:

**1. `constexpr` in the header files**

Example:
```cpp
// constants.h
#ifndef CONSTANTS_H
#define CONSTANTS_H

// Define your own namespace to hold constants
namespace constants
{
    // Global constants have internal linkage by default
    constexpr double pi { 3.14159 };
    constexpr double avogadro { 6.0221413e23 };
    constexpr double myGravity { 9.2 }; // m/s^2 -- gravity is light on this planet
    // ... other related constants
}
#endif
```

Problem with this implementation, is any file that imports `constants.h` will have an **independent copy** of the global variable,
potentially leading to:

- lengthy rebuild times
- large files (especially if constants are large)

**2. `extern constexpr` in the cpp file**

```cpp
// constants.cpp
#include "constants.h"

namespace constants
{
    // We use extern to ensure these have external linkage
    extern constexpr double pi { 3.14159 };
    extern constexpr double avogadro { 6.0221413e23 };
    extern constexpr double myGravity { 9.2 }; // m/s^2 -- gravity is light on this planet
}
```

```cpp
// constants.h
#ifndef CONSTANTS_H
#define CONSTANTS_H

namespace constants
{
    // Since the actual variables are inside a namespace, the forward declarations need to be inside a namespace as well
    // We can't forward declare variables as constexpr, but we can forward declare them as (runtime) const
    extern const double pi;
    extern const double avogadro;
    extern const double myGravity;
}

#endif
```

Note, using this implementation, we have defined the `extern constexpr` in `constants.cpp`
and have created a **forward declaration** in `constants.h` which we can also import.

However, the main problem with this implementation is the inability to use **compilation-time optimisations**

- this is because in the **forward declaration**, we had to give them the type `extern const` (since they have no value)
    - we **cannot** place the `extern constexpr` inside of the *header file*, else it will be defined multiple times, thus giving us a **compilation error**
    - however, it means that we they are now a **runtime** constant
        - this is because, during **compile-time**, the compiler is unable to see variable definitions from separate files, so they can only see the `extern const` type we gave it in the header file

However, if we use `inline constexpr`:
```cpp
#ifndef CONSTANTS_H
#define CONSTANTS_H

// define your own namespace to hold constants
namespace constants
{
    inline constexpr double pi { 3.14159 }; // note: now inline constexpr
    inline constexpr double avogadro { 6.0221413e23 };
    inline constexpr double myGravity { 9.2 }; // m/s^2 -- gravity is light on this planet
    // ... other related constants
}
#endif
```

Then, even if we import it to multiple files, since the **definitions** of all the identifiers are the same, 
only **one** instance of the variables will be created AND you can take advantage of **constant expression** optimisations.

:::important
### main co<span>n</span>

Unfortunately, the one downside of all these implementations,
is that **any change** to the header files will require a recompilation of **any file** that imports the header files
:::

#### inline namespace<span>s</span>
- used mainly for **versioning**:
- example:
```cpp
inline namespace v1 { void foo(); }
namespace v2 { void foo(); }
```
- by placing the new `foo()` version in a **non-inline** namespace, and keeping the original in a **inline namespace**:
    - running `foo();` will call `v1::foo();`
    - running `v2::foo();` will call `v2::foo();`
:::








