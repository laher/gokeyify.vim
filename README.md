# gokeyify.vim

keyify wrapper for vim

Totally copied from [vim-go](https://github.com/fatih/vim-go) and [gorename](https://github.com/mattn/vim-gorename). I just added an installer `:GoKeyifyInstall`

## Install (this plugin and keyify)

### Install plugin in the usual way

For example, using vim-plug:

```
Plug 'laher/gokeyify.vim'
```

### Installing keyify (once only)

```
:GoKeyifyInstall
```

NOTE: if you have [async.vim](https://github.com/prabirshrestha/async.vim) installed, it will install keyify asyncrhonously … if not, it'll let you know it's blocking your UI thread

## Usage

Running keyify 

1. Navigate your cursor to a place where a struct has been disappointingly initialised without field names.
2. `:GoKeyify`

## NOTES

 * Totally copied from [vim-go](https://github.com/fatih/vim-go) and [gorename](https://github.com/mattn/vim-gorename)
 * This plugin can be used to replace a small part of vim-go functionality, in the age of LSP. 
 * See also:
   * https://github.com/mattn/vim-goimports
   * https://github.com/mattn/vim-gorename
   * https://github.com/mattn/vim-goaddtags
   * https://github.com/mattn/vim-gorun
   * https://github.com/mattn/vim-goimports
   * https://github.com/mattn/vim-goimpl
   * https://github.com/mattn/vim-gosrc
   * https://github.com/mattn/go-errcheck-vim
