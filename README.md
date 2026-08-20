# CPU Catjam

A stupid fun CPU visualizer for Omarchy Quattro that plays the iconic catjam gif faster or slower based on your CPU usage. Higher CPU = faster jams!

![Preview](preview.png)

## Features

- Real-time CPU monitoring
- Animated catjam gif that speeds up with CPU usage
- Hover tooltip shows exact CPU percentage
- Click to open detailed stats panel with color-coded progress bar
- Minimal performance impact (updates every 1.5s)

## Install

```sh
omarchy plugin add https://github.com/SjoenH/omarchy-cpu-catjam.git --enable
```

## Usage

The catjam will automatically appear in your bar and start jamming! The animation speed adjusts based on CPU:

- **0-20% CPU**: Slow, chill vibes (0.5x speed)
- **20-60% CPU**: Medium speed, getting into it
- **60-100% CPU**: MAXIMUM OVERDRIVE JAM (3x speed)

- **Hover** over the catjam to see the exact CPU percentage
- **Click** to open a detailed panel with stats and progress bar

## Configure

Move it to a different bar section:

```sh
omarchy bar move no.koka.cpu-catjam --section left
```

## Remove

```sh
omarchy plugin remove no.koka.cpu-catjam
```

## Credits

- Catjam gif from the internet meme culture
- Built for Omarchy Quattro
- By [koka.no](https://koka.no)

## License

MIT License - See LICENSE file for details
