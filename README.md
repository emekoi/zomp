# zomp
a library for building zsh prompts in zig. as this library is built for zsh it might not work properly for other shells.

## features
### speed
prompts built with zomp are fast since they are native executables, that can be fine-tuned you see fit.

### async tasks (WIP)
supports spawning background commands asynchronously. slow process like `git status --porcelain` in the background so it doesn't freeze the terminal while `git` does it's thing and update the prompt when the task completes.

### written in zig
because zprompt is written in Zig, you get all the benefits of Zig when writing a prompt. interfacing with existing C libraries is also extremely easy thanks to Zig. 
