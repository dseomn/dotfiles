# DotFiles Git Repo (dfgr)

dfgr is a simple wrapper around git for when you basically want [plain git
dotfiles](https://www.atlassian.com/git/tutorials/dotfiles), but you also want a
separate command to operate on your dotfiles repo, with command completion.

Another way of thinking about it is that it's like [yadm](https://yadm.io/) with
almost all the features removed. If you copy your dotfiles manager's code into
your dotfiles repo (which dfgr encourages), the much smaller amount of code will
hopefully minimize how often that code needs to be updated. Additionally, it
should be much easier to review this code if you don't want to trust some
stranger on the internet. That said, if you want the extra features, yadm is
great too.

## Installation

1.  If needed, add `~/.local/bin` to your `$PATH`.
1.  Copy `dfgr` to `~/.local/bin/dfgr`, or link it from there.
1.  If you want bash completion, copy `bash-completion/completions/dfgr` to
    `~/.local/share/bash-completion/completions/dfgr`, or link it from there.

## Creating or cloning a repo

```sh
mkdir -p ~/.local/share/dfgr
git --git-dir ~/.local/share/dfgr/dotfiles.git --work-tree ~ init
```

Then, if you are cloning an existing repo:

```sh
git --git-dir ~/.local/share/dfgr/dotfiles.git remote add -f origin <URL>
git --git-dir ~/.local/share/dfgr/dotfiles.git switch main
```

If the `git-switch` command gives the error below, resolve the conflicts between
the local files and the ones in the dotfiles repo, and run the command again.

```
error: The following untracked working tree files would be overwritten by checkout
```

## Configuration

`dfgr` reads [git config](https://git-scm.com/docs/git-config) from
`~/.config/dfgr/config` in addition to the usual places. Some options that might
make sense to set there:

*   Running `dfgr clean` could do a lot more damage than `git clean`. One option
    is to set
    [`clean.requireForce`](https://git-scm.com/docs/git-config#Documentation/git-config.txt-cleanrequireForce)
    to `false` in `~/.config/git/config` and to `true` in
    `~/.config/dfgr/config`. Then get in the habit of not using `-f` by default.

## FAQ

### How should I handle files that I don't want in my dotfiles repo?

I know of two main approaches, with pros and cons for both.

1.  Set
    [`status.showUntrackedFiles`](https://git-scm.com/docs/git-config#Documentation/git-config.txt-statusshowUntrackedFiles)
    to `no`. It's simple and reasonably safe. However, it's not possible to show
    untracked files on a per-directory basis, so it's easier to forget to add
    files that you do want to add.

2.  Ignore all files by default in
    [`.gitignore`](https://git-scm.com/docs/gitignore), with `!` exclusions for
    the files and directories you don't want to ignore. **WARNING**: git may
    delete files you care about, since it considers ignored files to be
    unimportant. There is a `--no-overwrite-ignore` flag to some subcommands,
    but it doesn't work in all cases. As of 2025-03-16,
    https://lore.kernel.org/git/CABPp-BEwLYhfBN6esMdeTcby4=12zhFeSqrih-WPy8D+pW3sxQ@mail.gmail.com/
    is the most recent description I see of the current state of this issue.

### Why not use [`--separate-git-dir`](https://git-scm.com/docs/git-init#Documentation/git-init.txt-code--separate-git-dirltgit-dirgtcode)?

That would make the regular `git` command work on the dotfiles repo like any
other repo. E.g., if you use
[`__git_ps1`](https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh),
it would show your dotfile repo's status whenever you're in a directory under
`$HOME` but not under another git repo.

### Why not use [`--bare`](https://git-scm.com/docs/git-init#Documentation/git-init.txt-code--barecode)?

The dotfiles repo does have a worktree, `$HOME`. If some git commands behave
differently based on whether there's a worktree or not, it's probably better for
them to know about the worktree.

### Why don't the instructions for cloning a repo use `git clone`?

[`git-clone`'s
documentation](https://git-scm.com/docs/git-clone#Documentation/git-clone.txt-emltdirectorygtem)
says:

> Cloning into an existing directory is only allowed if the directory is empty.

Since home directories are often not empty, the instructions use a different
approach.

### Why do some of the instructions use `git` instead of `dfgr`?

If you keep your copy of `dfgr` in your dotfiles repo, it won't be available
before that repo is cloned.
