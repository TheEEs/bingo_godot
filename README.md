[![Screenshot-from-2020-08-19-11-38-09.png](https://www.upsieutoc.com/images/2020/08/19/Screenshot-from-2020-08-19-11-38-09.png)](https://www.upsieutoc.com/image/vr2fdw)

# Bingo
> A turn-based online game in which two players attempt to win by forming 5 lines(horizontal, vertical,diagonal) from numbers they choose on the board.

Thanks to Godot, my favorite game engine with an excellent multi-player API for helping me making my idea real.

## How to play

The First Player create a room. Then the second player join the room by entering the first player's id and hit "Join" button.

Players can randomly change their number table to a new one.

Once two players hit "Play", the game starts until one gain 5 lines.

If two players all get 5 lines at the same time, there will be a tie.

## Setup instructions

1. Start the server and expose it to the outside world with ngrok, NAT, dedicated container, ..etc...
2. Hosting the HTML5 export of the game somewhere so every one can get & play it.
3. Enjoy

## TODO
- [ ] Add visual and sound effects to make the game look better
- [ ] Add ability to list all online players
- [ ] Allow player to add their metadata
- [ ] Instant chat 

