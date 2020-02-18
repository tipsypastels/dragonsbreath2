Welcome! Dragonsbreath is a high-level scripting language for the Pokéemerald decomps. It uses a Python-inspired syntax and english-like keywords to create event code that feels natural and easy to understand.

Let's get started. This tutorial assumes some knowledge of Pokéemerald's builtin scripting language - if you're not up to scratch on that I recommend [Avara's excellent tutorial](https://www.pokecommunity.com/showthread.php?t=416800). This tutorial's structure is also inspired by that thread.

## Syntax
Dragonsbreath is *whitespace delimited*. If you like Python, you're going to feel pretty at home. A refresher: whitespace delimited means that lines with a higher indent are "children" of the last line with a lower indent. For example:

```
script MyScript
  lock
```

In this case, `lock` is a *child* of `script`. When a line has children and uses them in its output, we say it *yields*.

Almost all lines in Dragonsbreath follow the basic structure of `[command] [parameters seperated by commas...]`. There is one exception to this we'll get to later. In other seeming exceptions, such as with `if` statements, but the language is a bit flexible in defining what counts as a parameter. We'll get to this later.

Dragonsbreath supports comments using the hash (`#`) symbol.

## Scripts
Scripts are declared via the `script` command and then a label name. The children of this command become the body of the script. Scripts do not require and `end` keyword, but you can still specify it if you like being explicit. If your script ends with `return`, which jumps back to the calling script, Dragonsbreath will not automatically append the `end`.

```
script MyScript
  lock
    faceplayer
    "hello world!"
```

This becomes:
```
MyScript::
  lock
  faceplayer
  msgbox _MyScript_Subscript_Text_0, MSGBOX_DEFAULT
  release
  end

_MyScript_Subscript_Text_0:
  .string "hello world!$"
```

A lot nicer, huh? Don't worry if you're confused about the usage of the other commands. We'll get there.

## Script Types
There are four types of script commands. You say the first one already, the basic `script`. It's the one you'll use 90% of the time. There are also `map_scripts`, `text_script`, and `movement_script`.

### `map_scripts`
Pokéemerald uses map scripts to define events caused by certain triggers in the map, such as warping into it. Dragonsbreath provides a nice syntax abstraction around this. Map scripts are written like this:

```
map_scripts LittlerootTown
  on_transition
    if FLAG_VISITED_LITTLEROOT_TOWN is unset
      "Welcome to Littleroot Town!"
    setflag FLAG_VISITED_LITTLEROOT_TOWN
  on_frame_table MyExternalScriptToRun
```

The commands available directly inside `map_scripts` are lowercase versions of the map script triggers without the `MAP_SCRIPT_` prefix - for example, `on_transition`, `on_frame_table`, `on_warp_into_map_table`, etc. These commands can take children which defines the code to run when the event occurs, or can take the name of another script as a parameter, in which case they will call that instead.

As in that example, you can optionally omit the `_MapScripts` suffix from the script name and Dragonsbreath will add it for you. The same goes for the `.byte 0` final line.

### `text_script`
Text scripts are used to store textbox code. You've probably seen them in Pokéemerald as blocks full of `.string`. It's important to note that **use of `text_script` is usually unnecessary in Dragonsbreath** - it usually allows you to write text inline with the rest of your script without having to create an external script (see "Displaying Text" below). `text_script` exists to support writing files like `data/text/birch_speech.inc`, which consists only of global text declarations, in Dragonsbreath.

```
@global
text_script gText_Birch_Welcome
  "Hi! You're finally here!"
  # ...more text
```

> See the "Script Scopes" sub-section below for a note on `global`.

### `movement_script`
Movement scripts store movement code. As with text, `movement_script` is unnecessary as Dragonsbreath allows you to write movement commands inline inside the `move` command (see "Moving Events" below). `movement_script` exists to make globally shared movement actions possible.

```
movement_script MyMovement
  walk_down
  walk_up
  face_player
```

You don't need to add `step_end` at the end of a movement script. Dragonsbreath does that for you.

### Script Scopes
Pokéemerald supports two script visibilities: global and local (to the current file). Dragonsbreath handles this for you with some sensible defaults:

- User-created basic scripts are global, or local if they were auto-generated during the compilation
- Map scripts are global
- Text scripts are local
- Movement scripts are local

If you need to change this for some reason, Dragonsbreath provides the `@global` or `@local` decorator syntax:

```
@global
movement_script SomeGlobalMovement
  walk_down
  walk_right
  walk_down
```

Dragonsbreath does not modify the name of a script with the `@global` or `@local` declaration. It is up to you to choose and consistently apply a standard such as the  `gText_` prefix for global text used in some Pokéemerald files.

## Displaying Text
Displaying text is Dragonsbreath's one big syntax exception. A "headless line" with only a string and no command becomes text output.

```
script MyScript
  lock
    "hello world!"
```
If you don't like this magic syntax, you can use `say "hello world"` which does exactly the same thing.

Dragonsbreath will automatically wrap your lines and add `$` at the end. You can also add your own formatting such as `\n`, etc and it will take account of that. If you want to opt out of this behavior completely, you can use `sayraw`, e.g. `sayraw "hello world$"`.

For information about specifying font sizes, the length of C constants like `{PLAYER}`, see "Configuring Dragonsbreath" below.

## Configuring Dragonsbreath
Dragonsbreath will look for an optional `dragonsbreath.config.rb` file in the root of your project to read config information from. You can generate a template file using `$ dragonsbreath configure`. It will look like this:

```ruby
class Dragonsbreath::Configuration
  # Uncomment this line to specify a font width in pixels to use for auto-wrapping text.
  
  # FONT_WIDTH = 8

  # Uncomment these lines to specify the base number of characters of C constants like {PLAYER}. If an unspecified constant is used in text, Dragonsbreath will always try to wrap the line after words containing it.
  
  # TEXT_CONSTANTS = {
  #   PLAYER: 7,
  # }

  # Uncomment the block below to create custom builtin commands.

  # class ShowPortraitGnosis < Command
  #   def render
  #     enclose_children end_with: 'hideportrait'
  #   end
  # end
  # Command.register 'showportrait', ShowPortraitGnosis, context: :code
end 