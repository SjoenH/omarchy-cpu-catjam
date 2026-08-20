# CPU Catjam

A stupid fun CPU visualizer for Omarchy Quattro that plays the iconic catjam gif faster or slower based on your CPU usage. Higher CPU = faster jams!

![Preview](preview.png)

## Features

- Real-time CPU monitoring
- Animated catjam gif that speeds up with CPU usage
- Tooltip shows exact CPU percentage
- Minimal performance impact (updates every 500ms)

## Install

```sh
omarchy plugin add https://github.com/SjoenH/omarchy-cpu-catjam.git --enable
```

## Usage

The catjam will automatically appear in your bar and start jamming! The animation speed adjusts based on CPU:

- **0-20% CPU**: Slow, chill vibes
- **20-60% CPU**: Medium speed, getting into it
- **60-100% CPU**: MAXIMUM OVERDRIVE JAM

Hover over the catjam to see the exact CPU percentage.

## Configure

Move it to a different bar section:

```sh
omarchy bar move henry.cpu-catjam --section left
```

## Remove

```sh
omarchy plugin remove henry.cpu-catjam
```

## Credits

- Catjam gif from the internet meme culture
- Built for Omarchy Quattro

## License

MIT License - See LICENSE file for details
