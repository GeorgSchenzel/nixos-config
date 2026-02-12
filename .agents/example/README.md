<h1 align="center"> Dendritic Design</h1>

<h3 align="center"> A guide on how to structure your Nix code with Flake Parts using the Dendritic Pattern </h3>

As with many other programming languages, Nix offers numerous alternative approaches to implementing the desired outcome. While this freedom brings certain advantages, it also presents some drawbacks.

Some Nix users might find this journey relatable:<br/>
*As a beginner, you start with a single `configuration.nix` file. However, as your requirements grow, such as managing multiple hosts, users, and self-defined services, you redesign your code structure multiple times. Each iteration makes your code increasingly complex. The complexity reaches a new level when you integrate Home-Manager into your system configuration and when you use your code simultaneously for Linux and MacOS.*

With increasing experience, you desire:<img align="right" height="200" src="https://github.com/Doc-Steve/dendritic-design-with-flake-parts/wiki/blocks.png">
- **Reusable code** that can be easily integrated into various areas or foreign code that can be used without significant changes to your existing code.
- **Simple troubleshooting** that enables quick identification and resolution of errors in a single location.
- **A logical and easily expandable structure** that minimizes complexity and enhances manageability.

While there are software frameworks available that offer ready-made system configuration tools with precisely defined fixed structures, a more effective approach is to shift our mindset about **how we build and structure our own Nix code**, the [Dendritic Pattern](https://github.com/mightyiam/dendritic). 

This new approach eliminates the need to depend on a limited toolset that may not meet your future needs. It offers a design approach that directly addresses your pain points.

This guide aims to provide guidance on migrating existing code structures or assist you in planning a new (complex) structure from scratch. All the concepts and code snippets presented should be considered as ideas to ponder, which can always be adapted or expanded to suit your specific requirements.

For users solely relying on Nix to run a single machine, this guide may be overly detailed. However, it's beneficial for those contemplating refactoring their existing configuration, particularly when faced with design challenges arising from increased complexity.

Furthermore, this guide includes a [Comprehensive Example](https://github.com/Doc-Steve/dendritic-design-with-flake-parts/wiki/Comprehensive_Example#comprehensive-example) that demonstrates the typical usage of the Dendritic Design. The example primarily focuses on illustrating the code structure aspects outlined in this guide. While it's not meant to be a direct copy template, it serves as a valuable resource for incorporating ideas into your own design.

If you have any questions before you begin, please refer to the provided [FAQ](https://github.com/Doc-Steve/dendritic-design-with-flake-parts/wiki/FAQ).

# Contents

- [Basics for usage of the Dendritic Pattern](https://github.com/Doc-Steve/dendritic-design-with-flake-parts/wiki/Basics#basics-for-usage-of-the-dendritic-pattern)
  - [Libraries](https://github.com/Doc-Steve/dendritic-design-with-flake-parts/wiki/Basics#libraries)
  - [What is a *feature* ?](https://github.com/Doc-Steve/dendritic-design-with-flake-parts/wiki/Basics#what-is-a-feature-)
  - [File Organization](https://github.com/Doc-Steve/dendritic-design-with-flake-parts/wiki/Basics#file-organization)
  - [The Flake Parts Framework](https://github.com/Doc-Steve/dendritic-design-with-flake-parts/wiki/Basics#the-flake-parts-framework)
- [Design Patterns for Dendritic Aspects](https://github.com/Doc-Steve/dendritic-design-with-flake-parts/wiki/Dendritic_Aspects#design-patterns-for-dendritic-aspects)
  - [***Simple Aspect***](https://github.com/Doc-Steve/dendritic-design-with-flake-parts/wiki/Dendritic_Aspects#simple-aspect)
  - [***Multi Context Aspect***](https://github.com/Doc-Steve/dendritic-design-with-flake-parts/wiki/Dendritic_Aspects#multi-context-aspect)
  - [***Inheritence Aspect***](https://github.com/Doc-Steve/dendritic-design-with-flake-parts/wiki/Dendritic_Aspects#inheritence-aspect)
  - [***Conditional Aspect***](https://github.com/Doc-Steve/dendritic-design-with-flake-parts/wiki/Dendritic_Aspects#conditional-aspect)
  - [***Collector Aspect***](https://github.com/Doc-Steve/dendritic-design-with-flake-parts/wiki/Dendritic_Aspects#collector-aspect)
  - [***Constants Aspect***](https://github.com/Doc-Steve/dendritic-design-with-flake-parts/wiki/Dendritic_Aspects#constants-aspect)
  - [***DRY Aspect***](https://github.com/Doc-Steve/dendritic-design-with-flake-parts/wiki/Dendritic_Aspects#dry-aspect)
  - [***Factory Aspect***](https://github.com/Doc-Steve/dendritic-design-with-flake-parts/wiki/Dendritic_Aspects#factory-aspect)
  - [Applying and Selecting Aspect Patterns](https://github.com/Doc-Steve/dendritic-design-with-flake-parts/wiki/Dendritic_Aspects#applying-and-selecting-aspect-patterns)
  - [Bringing it all together](https://github.com/Doc-Steve/dendritic-design-with-flake-parts/wiki/Dendritic_Aspects#bringing-it-all-together)
- [Comprehensive Example](https://github.com/Doc-Steve/dendritic-design-with-flake-parts/wiki/Comprehensive_Example#comprehensive-example)
- [Acknowledgement and additional information](https://github.com/Doc-Steve/dendritic-design-with-flake-parts/wiki/Acknowledgement_and_additional_information#acknowledgement-and-additional-information)
  - [Dendritic Pattern](https://github.com/Doc-Steve/dendritic-design-with-flake-parts/wiki/Acknowledgement_and_additional_information#dendritic-pattern)
  - [Flake-Parts](https://github.com/Doc-Steve/dendritic-design-with-flake-parts/wiki/Acknowledgement_and_additional_information#flake-parts)
  - [Optional libraries](https://github.com/Doc-Steve/dendritic-design-with-flake-parts/wiki/Acknowledgement_and_additional_information#optional-libraries)
  - [Reference repositories utilizing the Dendritic Pattern](https://github.com/Doc-Steve/dendritic-design-with-flake-parts/wiki/Acknowledgement_and_additional_information#reference-repositories-utilizing-the-dendritic-pattern)

- [Frequently Asked Questions](https://github.com/Doc-Steve/dendritic-design-with-flake-parts/wiki/FAQ)
  - [What is it? Why should I care?](https://github.com/Doc-Steve/dendritic-design-with-flake-parts/wiki/FAQ#what-is-it-why-should-i-care)
  - [What are the advantages/drawbacks?](https://github.com/Doc-Steve/dendritic-design-with-flake-parts/wiki/FAQ#what-are-the-advantagesdrawbacks)
  - [Why is the definition of the Dendritic Pattern so complicated? What if I don't understand everything?](https://github.com/Doc-Steve/dendritic-design-with-flake-parts/wiki/FAQ#why-is-the-definition-of-the-dendritic-pattern-so-complicated-what-if-i-dont-understand-everything)
  - [Is Flake-Parts the Dendritic Pattern? Why use two names?](https://github.com/Doc-Steve/dendritic-design-with-flake-parts/wiki/FAQ#is-flake-parts-the-dendritic-pattern-why-use-two-names)
  - [Should I start  my config design with the Dendritic Pattern? Is a migration worth it?](https://github.com/Doc-Steve/dendritic-design-with-flake-parts/wiki/FAQ#should-i-start--my-config-design-with-the-dendritic-pattern-is-a-migration-worth-it)
  - [Is it only useful for cross-platform development, or is there more to it?](https://github.com/Doc-Steve/dendritic-design-with-flake-parts/wiki/FAQ#is-it-only-useful-for-cross-platform-development-or-is-there-more-to-it)
  - [Dendritic Pattern seems just like a "buzzword", why is this different from what I'm already doing for the configuration of my hosts?](https://github.com/Doc-Steve/dendritic-design-with-flake-parts/wiki/FAQ#dendritic-pattern-seems-just-like-a-buzzword-why-is-this-different-from-what-im-already-doing-for-the-configuration-of-my-hosts)
  - [How does it compare to other template repositories / host management tools?](https://github.com/Doc-Steve/dendritic-design-with-flake-parts/wiki/FAQ#how-does-it-compare-to-other-template-repositories--host-management-tools)
  - [I already use modules, why should I put an abstraction layer on top?](https://github.com/Doc-Steve/dendritic-design-with-flake-parts/wiki/FAQ#i-already-use-modules-why-should-i-put-an-abstraction-layer-on-top)
  - [Should I use Flake-Parts and what are the alternatives?](https://github.com/Doc-Steve/dendritic-design-with-flake-parts/wiki/FAQ#should-i-use-flake-parts-and-what-are-the-alternatives)
  - [Is it mandatory for me to learn all the `Aspect` patterns mentioned in the guide?](https://github.com/Doc-Steve/dendritic-design-with-flake-parts/wiki/FAQ#is-it-mandatory-for-me-to-learn-all-the-aspect-patterns-mentioned-in-the-guide)
  - [Why is the `flake.nix` so empty?](https://github.com/Doc-Steve/dendritic-design-with-flake-parts/wiki/FAQ#why-is-the-flakenix-so-empty)
