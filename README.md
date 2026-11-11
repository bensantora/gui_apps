# gui_apps

List installed GUI apps (those shipping a .desktop launcher). Defaults to apps you installed yourself; -a shows all.

## Requirements

apt/dpkg.

## Use

```
chmod +x gui-apps.sh
./gui-apps.sh       # your apps
./gui-apps.sh -a    # all apps
./gui-apps.sh firefox
```

Made for Debian. Run it from its folder or put it on your `PATH`. Run it with `-h` where supported, or read the comment header at the top of the script.

## License

MIT - see [LICENSE](LICENSE).
