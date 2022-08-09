# XBar plugin for Nightscout

![Preview](Preview.png)

This is an [xbar](https://xbarapp.com/) plugin to show your BG levels in the OSX menu bar.

It's inspired on [NightscoutBitBar](https://github.com/jhaydraude/NightscoutBitBar/).

## Usage

You must edit the `nighscout.1m.rb` file to set up your configuration values. See the Configuration
section below for extended information.

After you've setup the config vars, move the `nightscout.1m.rb` file into your xbar plugin folder.

## Configuration

`SITE` must be changed to your Nightscout site name. If your Nightscout url is:
`https://jane-doe.herokuapp.com/` it should look like this:

```ruby
SITE = 'https://jane-doe.herokuapp.com/'
```

Don't forget the slash at the end of the URL or the plugin won't work!

`TOKEN` must contain the token for the role with read access to the API. Check [here](https://nightscout.github.io/nightscout/security/#create-a-token)
the Nightscout docs on how to create an access token.

`UNIT` has `mg/dl` as default. Change it to `mmol/L` if that's the unit you have configured in your Nightscout site.

Limits are inside the `LIMITS` variable. They're setup with the default Nightscout limits for mg/dl and mmol/L.
You can of course edit the values in case you need it.

### Coming soon

- Sound alerts (if supported by xbar)
- Get limits directly from NightScout
