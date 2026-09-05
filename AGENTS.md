This is Parties for All, a web service for individuals to host parties with friends.

* All features are free. Do not account for potential future monetization.
* Events are assumed to be private. Any public advertisement is at the discretion of the host to do manually.
* There is no limit to attendee count, but do not complicate designs if supporting more than a hundred attendees requires significant additional work.

## Architecture

This application is a Rails app with a vanilla Javascript frontend. Use established Rails idioms and features wherever possible for consistency. 

## Infrastructure

This application is packaged as a Docker image, and includes Terraform designed to provision infrastructure to run the application in AWS in the `infrastructure/` directory.

When choosing infrastructure, use products that bill by usage instead of by time as much as possible, such as using serverless functions over a persistent server for new compute-intensive features.

## Development

When writing tests, iterate on just the tests you've written until they pass, but when tests relevant to your change are passing, run the full test suite as a final check. It is not sufficient to ensure relevant tests are passing: your code is only working correctly if the entire test suite passes.

## Coding style

### General

* Avoid introducing new frameworks or design patterns if an established pattern exists.
* If a dependency can be replaced by a bit of extra boilerplate, do not use it. Use dependencies to handle areas of logic that are not relevant to the core application, such as maintaining lists of locations or processing images.
* Avoid repeating yourself as much as possible.
* Keep code stateless and functional. Use functions that return new objects rather than mutating existing ones, and pass values as arguments rather than assigning them to persistent variables. State should only live in persistence layers such as object storage or the database.
* If building a feature requires writing logic that is not specific to that feature, such as code that handles processing text input, keep that logic in a generic location so it can be used in other contexts.
* Structure functions so that the purpose of each argument is clear both in the function's implementation and at call sites. For instance, avoid accepting boolean flags for secondary behavior such as caching, using keyword arguments or options objects instead.

#### Comments

Do not write comments under any circumstances, except when the structure or purpose of the code is unintuitive for readers without context around the function's implementation, and when the code cannot be refactored to be clearer.

When doing something unintuitive due to an unaddressed bug in a dependency, link to an issue in the dependency's issue tracker if one exists. If the bug has been resolved in a later version, favor upgrading rather than working around the bug.

Comments must ONLY describe the code as it currently exists. References to code that has been removed, or explanations for changes that have already been made, should be in PR descriptions or commit messages.

When writing comments, use only language that would be familiar to software engineers who were not involved in developing the current change. If you have defined new terms while discussing the requirements of a change or planning implementation details, DO NOT use those terms in comments.

### TypeScript
ALWAYS use strong types. `any` is NEVER acceptable as a type for variables we control. If an object has a predictable shape, use a dedicated type for it.

File names use kebab case (e.g. `dynamic-list-controller.ts`).

Imports must be side-effect-free: modules export values, and initialization happens in entrypoints. For example, `controllers/index.ts` exports a registry of Stimulus controllers that `application.ts` registers with the Stimulus application.