# Vim bosh

Syntax detection and highlighting for [bosh](http://bosh.io).

## Features

* Custom highlighting aware of bosh terminology
* Folding
* Auto detecting bosh files
* [Tagbar](https://raw.githubusercontent.com/luan/boshtags/master/screenshots/screenshot-01.png) integration
* Automatic [ctags](http://ctags.sourceforge.net/) generation for use with `<c-]>` on jobs and resources

## Settings

By default vim-bosh will generate ctags for your bosh pipelines using [boshtags](http://github.com/luan/boshtags) on save.
You can disable this functionality with:
```vim
let g:bosh_tags_autosave = 0
```

## In Action

![vim-bosh video](https://raw.githubusercontent.com/luan/vim-bosh/master/screenshots/video-01.gif)

## Credits

* [vim-go](https://github.com/fatih/vim-go), where from a lot of the plugin code was based
* [vim-concourse](https://github.com/luan/vim-concourse), original plugin for alternative yaml
* [bosh](http://bosh.io), BOSH

## License

The BSD 3-Clause License - see [LICENSE](LICENSE) for more details.

Uses the vim-go LICENSE and copyrights since a lot of the code was re-used.

