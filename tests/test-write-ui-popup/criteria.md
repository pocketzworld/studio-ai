1. There is a directory called "Popup" in the project.
2. The directory contains a UXML file, a Lua script, and a USS file, each called "Popup" with the correct extension.
3. The UXML file contains a `<Label>` element with its name property set.
4. The Lua script has `--!Type(UI)` at the top.
5. The Lua script contains a binding for the `<Label>` element: it should be preceded by `--!Bind`, have the same name as the `<Label>` element's name property, the `Label` type annotation, and be initialized to `nil`.
6. The Lua script contains two serialized fields: one for each of the two values that the text should alternate between.
7. To alternate the text between the two values every second, the Lua script uses either (a) a `Timer` initiated in `self:Start()` or `self:Awake()`, or (b) a counter incremented in `self:Update()`.
8. The USS file contains the same class name as the `<Label>` element's class property, if specified.
9. The Lua script follows the entirety of the style instructions in `./resources/MyUIElement/MyUIElement.lua`, except for any guidance comments that were copied over from the template.
10. The USS file follows the entirety of the style instructions in `./resources/MyUIElement/MyUIElement.uss`, except for any guidance comments that were copied over from the template.
11. The UXML file follows the entirety of the style instructions in `./resources/MyUIElement/MyUIElement.uxml`, except for any guidance comments that were copied over from the template.
