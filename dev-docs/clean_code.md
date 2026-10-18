# Clean Code Rules

Code is clean if it can be understood easily by everyone on the team. Clean code can be
read and enhanced by a developer other than its original author. With understandability
comes readability, changeability, extensibility and maintainability.

## General rules

- Follow standard conventions.
- **Keep it simple, stupid.** Simpler is always better. Reduce complexity as much as possible.
- **Boy scout rule.** Leave the campground cleaner than you found it.
- **Always find root cause.** Always look for the root cause of a problem.
- Make sure files are not too long: max about 250 lines, otherwise split the file.
- Check for dead code and get rid of it.
- Check for KISS, DRY and YAGNI violations, and fix them.
- **Follow the SOLID principles:** Single Responsibility, Open/Closed, Liskov Substitution,
  Interface Segregation and Dependency Inversion. These five principles are the cornerstones
  of writing code that scales and is easy to maintain.
- **Make testing easy.** Good code should be easy to test, both by reducing the complexity of
  each component and by supporting automated testing to ensure it behaves as expected.
- **Abstraction.** Good code should have a moderate level of abstraction, neither over-designed
  nor neglecting long-term expandability and maintainability.
- **Utilize design patterns, but don't over-design.** Overusing or misusing design patterns may
  make your code more complex and difficult to understand.
- **Reduce global dependencies.** Good code should rely on localized state and parameter passing.
  Functions should be side-effect free.
- **Continuous refactoring.** Good code is maintainable and extensible. Continuous refactoring
  reduces technical debt by identifying and fixing problems as early as possible.
- Separation of concerns in files, functions, classes and methods, to avoid complexity.
- **Security is a top priority.** Good code should avoid common security vulnerabilities.

## Design rules

- Keep configurable data at high levels.
- Prefer polymorphism to if/else or switch/case.
- Separate multi-threading code.
- Prevent over-configurability.
- Use dependency injection.
- **Follow the Law of Demeter.** A class should know only its direct dependencies.

## Understandability tips

- **Be consistent.** If you do something a certain way, do all similar things in the same way.
- Use explanatory variables.
- **Encapsulate boundary conditions.** Boundary conditions are hard to keep track of. Put the
  processing for them in one place.
- Prefer dedicated value objects to primitive types.
- **Avoid logical dependency.** Don't write methods which work correctly depending on something
  else in the same class.
- Avoid negative conditionals.

## Names rules

- Choose descriptive and unambiguous names.
- Make meaningful distinctions.
- Use pronounceable names.
- Use searchable names.
- Replace magic numbers with named constants.
- **Avoid encodings.** Don't append prefixes or type information.

## Functions rules

- Small.
- Do one thing.
- Use descriptive names.
- Prefer fewer arguments.
- Have no side effects.
- **Don't use flag arguments.** Split the method into several independent methods that can be
  called from the client without the flag.

## Comments rules

- Always try to explain yourself in code.
- Don't be redundant.
- Don't add obvious noise.
- Don't use closing brace comments.
- Don't comment out code. Just remove it.
- Use as explanation of intent.
- Use as clarification of code.
- Use as warning of consequences.
- Do not use em dashes; comments should use proper punctuation.

### The ten rules

1. Comments should not duplicate the code.
2. Good comments do not excuse unclear code.
3. If you can't write a clear comment, there may be a problem with the code.
4. Comments should dispel confusion, not cause it.
5. Explain unidiomatic code in comments.
6. Provide links to the original source of copied code.
7. Include links to external references where they will be most helpful.
8. Add comments when fixing bugs.
9. Use comments to mark incomplete implementations.
10. We shouldn't see a comment and be looking for another file; the comment should be clear
    and obvious.

## Source code structure

- Separate concepts vertically.
- Related code should appear vertically dense.
- Declare variables close to their usage.
- Dependent functions should be close.
- Similar functions should be close.
- Place functions in the downward direction.
- Keep lines short.
- Don't use horizontal alignment.
- Use white space to associate related things and disassociate weakly related ones.
- Don't break indentation.

## Objects and data structures

- Hide internal structure.
- Prefer data structures.
- Avoid hybrid structures (half object and half data).
- Should be small.
- Do one thing.
- Small number of instance variables.
- Base classes should know nothing about their derivatives.
- Better to have many functions than to pass some code into a function to select a behavior.
- Prefer non-static methods to static methods.

## Tests

- One assert per test.
- Readable.
- Fast.
- Independent.
- Repeatable.

## Code smells

- **Rigidity.** The software is difficult to change. A small change causes a cascade of
  subsequent changes.
- **Fragility.** The software breaks in many places due to a single change.
- **Immobility.** You cannot reuse parts of the code in other projects because of involved
  risks and high effort.
- **Needless complexity.**
- **Needless repetition.**
- **Opacity.** The code is hard to understand.
