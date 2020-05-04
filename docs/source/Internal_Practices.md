# Internal Practices

## Documentation 

**Updating Documentation**
This is still in progress. ~Documentation should be edited in the [StackEdit](https://stackedit.io/). A different markdown editor can be used, if desired. However, StackEdit must be used to export the markdown into a HTML file, because the way GitHub renders Markdown is ugly.~

**Values of Instance Variables**
Where an instance variable stores an object, mention it in the single-sentence description. Otherwise, include a line e.g. _Value: `1`_.

**Constant vs. Mutable**
Distinguish between the two wherever the distinction is relevant. For example, there are certain classes where constants are used for internal parsing logic; the distinction is important there. 

## Development

**Branches**
All development should take place on `dev` or other branches *specifically intended for development*. The `master` branch is *only for production releases*. 

**Sparing Push**
When pushing, don't just push all edited files. Select the changes appropriately and thoughtfully. Don't push tiny or otherwise meaningless changes. Merge conflicts should be avoided as much as possible. 
