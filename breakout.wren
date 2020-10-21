// title:  breakout clone
// author: camilo castro
// desc:   a breakout clone in wren
// script: wren
// based on: https://github.com/digitsensitive/tic-80-tutorials/tree/master/tutorials/breakout

import "random" for Random

var Seed = Random.new()
var T = TIC

class ScreenWidth {
    static min {0}
    static max {240}
}

class ScreenHeight {
    static min {0}
    static max {136}
}
    
class Screen {
    static height {ScreenHeight}
    static width {ScreenWidth}
}

class Input {
    static left {T.btn(2)}
    static right {T.btn(3)}
    static x {T.btn(5)}
}

class Color {
    static black {0}
    static white {12}
    static orange {3}
    static greyl {13}
    static greyd {15}
}

class Collisions {
   // Implements
  // https://developer.mozilla.org/en-US/docs/Games/Techniques/2D_collision_detection
  static collide(hitbox, hitbox2) {
    return (hitbox.x < hitbox2.x + hitbox2.width &&
            hitbox.x + hitbox.width > hitbox2.x &&
            hitbox.y < hitbox2.y + hitbox2.height &&
            hitbox.y + hitbox.height > hitbox2.y)
  }
}

class PlayerSpeed {
    x {_x}
    x = (value) {
        _x = value
    }
    
    max {_max}
    max = (value) {
        _max = value
    }
    
    construct new() {
        _x = 0
        _max = 4
    }
}

class Player {
    x {_x}
    y {_y}
    width {_width}
    height {_height}
    color {_color}
    speed {_speed}

    state {_state}

    construct new(state) {
        _state = state
        _width = 24
        _height = 4
        _y = 120
        _color = Color.orange
        reset()
    }

    reset() {
        _x = (Screen.width.max/2) - _width/2
        _speed = PlayerSpeed.new()
    }

    draw() {
        T.rect(x, y, width, height, color)
    }

    wall() {
        if (x < Screen.width.min) {
            _x = Screen.width.min
        } else if(x + width > Screen.width.max) {
            _x = Screen.width.max - width
        }
    }

    collisions() {
        wall()
    }

    update() {
        _x = x + speed.x
        if (speed.x != 0) {
            if (speed.x > 0) {
              speed.x = speed.x - 1
            } else {
              speed.x = speed.x + 1
            }
        }
    }

    input() {
        if (Input.left) {
                if (speed.x > -speed.max) {
                    speed.x = speed.x - 2
                } else {
                    speed.x = -speed.max
                }
            }
            
            if (Input.right) {
                if (speed.x < speed.max) {
                        speed.x = speed.x + 2
                    } else {
                        speed.x = speed.max
                    }
            }
    }
}

class BallSpeed {
    x {_x}
    x = (value) {
        _x = value
    }
    
    y {_y}
    y = (value) {
        _y = value
    }
    
    max {_max}
    
    construct new() {
        _x = 0
        _y = 0
        _max = 1.5
    }
}

class Ball {
    x {_x}
    y {_y}
    width {_width}
    height {_height}
    color {_color}
    deactive {_deactive}
    speed {_speed}
    
    player {_player}
    player = (value) {
        _player = value
    }
    
    state {_state}
    
    construct new(player, state) {
        _width = 3
        _height = 3
        _color = Color.greyl
        _player = player
        _state = state
        reset()
    }
    
    position() {
        _x = player.x + (player.width / 2) - 1.5
        _y = player.y - 5
    }
    
    reset() {
        position()
        _deactive = true
        _speed = BallSpeed.new()
    }
    
    input() {
        if (deactive) {
                position()
                if (Input.x) {
                    speed.x = (Seed.float(0, 10).floor * 2) - 1
                        speed.y = speed.y - 1.5
                        _deactive = false
                }
            }
    }
    
    wall() {
        // top
        if (y < 0) {
            speed.y = -speed.y
            
        // left
        } else if (x < 0) {
            speed.x = -speed.x
        
        // right
        } else if (x > 240 - width) {
            speed.x = -speed.x
        }
    }
    
    ground() {
        if (y > 136 - width) {
                reset()
                state.lifeDown()
        }
    }
    
    paddle() {
        if (Collisions.collide(this, player)) {
            speed.y = -speed.y
            speed.x = speed.x + 0.3 * player.speed.x
        } 
    }
    
    brick(brick) {

        // collide left or right side
        if (brick.y < y &&
            y < brick.y + brick.height &&
            (x < brick.x || brick.x + brick.width < x)) {
                speed.x = -speed.x
            }
        // collide top or bottom
        if (y < brick.y ||
        (y > brick.y && brick.x < x &&
        x < brick.x + brick.width)) {
            speed.y = -speed.y
        }
    }

    collisions() {
        wall()
        ground()
        paddle() 
    }
    
    update() {
        _x = x + speed.x
        _y = y + speed.y
        
        if (speed.x > speed.max) {
            speed.x = speed.max
        }
    }
    
    draw() {
        T.rect(x, y, width, height, color)
    }
}

class Brick {
    x {_x}
    y {_y}
    width {_width}
    height {_height}
    color {_color}

    construct new(x, y, color) {
        _x = x
        _y = y
        _width = 10
        _height = 4
        _color = color
    }
    
    draw() {
        T.rect(x, y, width, height, color)
    }
}

class Board {
    width {19}
    height {12}

    ball {_ball}
    state {_state}

    bricks {
        if (!_bricks) {
            _blicks = []
        }

        return _bricks
    }
        
    construct new(ball, state) {
        _ball = ball
        _state = state
        reset()
    }

    reset() {
        _bricks = []
        for (i in 0..height) {
            for (j in 0..width) {
                var x = 10 + j * 11
                var y = 10 + i * 5
                var color = i + 1
                var brick = Brick.new(x, y, color)
                bricks.add(brick)
            }
        }
								ball.reset()
    }
        
    draw() {
        bricks.each {|brick|
            brick.draw()
        }
    }
    
    collisions() {
        var index = 0
        if (bricks.count <= 0) {
            reset()
        }

        var note = "C-%(Seed.int(4,7))"

        bricks.each {|brick|
            if (Collisions.collide(ball, brick)) {
                T.sfx(0, note, 10)
                bricks.removeAt(index)
                ball.brick(brick)
                state.scoreUp()
            }
            index = index + 1
        }
    }
    
    update() {}
    input() {}
}

class Stage {
    objects {_objects}
    state {_state}
    
    construct new(state) {
        _objects = []
        _state = state
    }
    
    add(object) {
        objects.add(object)
    }
    
    input() {
        if (!state.isPlaying) return
        
        objects.each {|object|
            object.input()
        }
    }
    
    draw() {
        if (!state.isPlaying) return
        
        objects.each {|object|
            object.draw()
        }
    }
    
    update() {
    
        if (!state.isPlaying) return
        
        objects.each {|object|
            object.update()
        }
    }
    
    collisions() {
        if (!state.isPlaying) return 
        
        objects.each {|object|
            object.collisions()
        }
    }
}

class GUI {
    player {_player}
    state {_state}
    
    construct new(player, state) {
        _player = player
        _state = state
    }
    
    scores() {
       // shadow
        T.print("SCORE ", 5, 1, Color.greyd)
        T.print(state.score, 40, 1, Color.greyd)
        
        // forecolor
        T.print("SCORE ", 5, 0, Color.white)
        T.print(state.score, 40, 0, Color.white)
        
        // shadow
        T.print("LIVES ", 190, 1, Color.greyd)
        T.print(state.lives, 225, 1, Color.greyd)
        
        // forecolor
        T.print("LIVES ", 190, 0, Color.white)
        T.print(state.lives, 225, 0, Color.white)
    }
    
    gameover() {
      T.print("Game Over", (Screen.width.max/2) - 6 * 4.5, 136/2, Color.white) 
    }
    
    input() {
        if (!state.isPlaying && Input.x) {
            state.start()
        }
    }
    
    draw() {
        if (state.isPlaying) {
            return scores()
        }
        gameover()
    }
}

class GameState {
    static game {__game}
    static game = (value) {
        __game = value
    }

    static isPlaying {__playing}
    
    static score {
        if (!__score) {
            __score = 0
        }
        
        return __score
    }
    
    static score = (value) {
        __score = value
    }
    
    static lives {
        if (!__lives || __lives < 0) {
            __lives = 3
        }
        
        return __lives
    }
    
    static lives = (value) {
        if (value < 0) {
            over()
        }
        __lives = value
    }
    
    static over() {
        reset()
        __playing = false
    }
    
    static start() {
        __playing = true
    }
    
    static lifeDown() {
        lives = lives - 1
    }
    
    static scoreUp() {
        score = score + 100
    }
    
    static reset() {
        score = 0
        lives = 3
        game.reset()
    }
}



class Game is TIC {
    player {_player }
    stage {_stage }
    gui {_gui }
    
    construct new() {
        reset()
    }

    reset() {
        GameState.start()
        GameState.game = this

        _player = Player.new(GameState)
        _ball = Ball.new(_player, GameState)
        
        _gui = GUI.new(_player, GameState)
        
        _board = Board.new(_ball, GameState)
            
        _stage = Stage.new(GameState)
        _stage.add(_player)
        _stage.add(_ball)
        _stage.add(_board)
    }
    
    TIC() {
        T.cls(0)
        input()
        update()
        collisions()
        draw()
    }
    
    input() {
        gui.input()
        stage.input()
    }
    
    update() {
        stage.update()
    }
    
    collisions() {
        stage.collisions()
    }
    
    draw() {
        stage.draw()
        gui.draw()
    }
}
// <TILES>
// 001:eccccccccc888888caaaaaaaca888888cacccccccacc0ccccacc0ccccacc0ccc
// 002:ccccceee8888cceeaaaa0cee888a0ceeccca0ccc0cca0c0c0cca0c0c0cca0c0c
// 003:eccccccccc888888caaaaaaaca888888cacccccccacccccccacc0ccccacc0ccc
// 004:ccccceee8888cceeaaaa0cee888a0ceeccca0cccccca0c0c0cca0c0c0cca0c0c
// 017:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
// 018:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
// 019:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
// 020:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
// </TILES>

// <WAVES>
// 000:00000000ffffffff00000000ffffffff
// 001:0123456789abcdeffedcba9876543210
// 002:0123456789abcdef0123456789abcdef
// </WAVES>

// <SFX>
// 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000400000000000
// 001:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000402000000000
// 002:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000404000000000
// 003:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000405000000000
// </SFX>

// <PATTERNS>
// 000:400008000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
// </PATTERNS>

// <TRACKS>
// 000:100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000
// </TRACKS>

// <PALETTE>
// 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
// </PALETTE>

