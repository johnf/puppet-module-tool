TODOs
=====

Modules
-------

we should be able to specify a minimum puppet version as a dependency on a module

Exploder
--------

Basically Bundler type support for modules

### Parse the Modules file ###

we should specify a source, namely a forge
we should check we only have one copy of each gem
we should support forge and git as gem sources
we will only support the forge in the initial implementation

### Dependency resolution ###

we should pull in dependencies for each module in the Modules file
we should ensure there are no conflicting dependencies
