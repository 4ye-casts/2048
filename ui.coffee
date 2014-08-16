class Board
  constructor: ->
    @size = 4
    @width = 100
    @padding = 15

    @init_data()
    @init_dom()
    @init_key_enent()

  each_cell: (func)->
    for row in [0...@size]
      for col in [0...@size]
        func(row, col)

  cell_pos: (i)->
    @padding + i * (@padding + @width)

  init_data: ->
    @data = @each_cell -> null

  init_dom: ->
    @_init_board_dom()
    @_init_new_game_button()

  _init_board_dom: ->
    board_width = @size * @width + (@size + 1) * @padding
    @$board = $board = jQuery('<div>')
      .addClass('board')
      .css
        'width': board_width
        'height': board_width
      .appendTo document.body

    @each_cell (row, col)=>
      jQuery('<div>')
        .addClass('cell')
        .css
          'width':  @width
          'height': @width
          'top':    @cell_pos(row)
          'left':   @cell_pos(col)
        .attr
          'data-row': row
          'data-col': col
        .appendTo $board

  _init_new_game_button: ->
    $new_game_button = jQuery('<div>')
      .addClass('new-game')
      .html 'New Game'
      .appendTo document.body
      .on 'click', =>
        @start_new_game()

  start_new_game: ->
    @clear()
    @generate_tile()
    @generate_tile()

  clear: ->
    @$board.find('.tile').remove()
    @init_data()

  generate_tile: ->
    empty_cells = @empty_cells()
    rand = ~~(Math.random() * empty_cells.length)
    [row, col] = empty_cells[rand]
    
    @data[row][col] = new Tile(@, row, col)

  empty_cells: ->
    re = []
    @each_cell (row, col)=>
      if @data[row][col] is null
        re.push [row, col]
    re

  init_key_enent: ->
    jQuery(document).on 'keydown', (evt)=>
      evt.preventDefault()
      direction = switch evt.keyCode
        when 38 then 'up'     # ↑
        when 40 then 'down'   # ↓
        when 37 then 'left'   # ←
        when 39 then 'right'  # →
      moved = @move(direction) if direction
      if moved
        @generate_tile()

  move: (direction)->
    dir =
      left:   [ 0 , -1]
      right:  [ 0 ,  1]
      up:     [-1 ,  0]
      down:   [ 1 ,  0]

    _dir = dir[direction]

    arrs = switch direction
      when 'left'
        @each_cell (row, col)=> @data[row][col]
      when 'right'
        @each_cell (row, col)=> @data[row][@size - 1 - col]
      when 'up'
        @each_cell (row, col)=> @data[col][row]
      when 'down'
        @each_cell (row, col)=> @data[@size - 1 - col][row]

    @merge_stack = @each_cell -> []

    moved = false
    for arr in arrs
      _arr = for tile in arr
        if tile then tile.number else null
      
      merge = @merge _arr
      for i in [0...@size]
        tile = arr[i]
        move = merge[i]
        tile.move(_dir[0] * move, _dir[1] * move) if tile
        moved = true if move > 0

    @each_cell (i, j)=>
      merge = @merge_stack[i][j]
      switch merge.length
        when 0
          @data[i][j] = null
        when 1
          @data[i][j] = merge[0]
        when 2
          merge[0].remove()
          merge[1].up()
          @data[i][j] = merge[1]

    console.log moved
    moved

  merge: (arr)->
    re = []
    stack = []
    last_number = null
    
    for number in arr

      if number is null
        stack.push number
        continue

      if last_number is null
        stack.push number
        last_number = number
        continue

      if number == last_number
        stack.push number
        re.push stack
        stack = []
        last_number = null
        continue

      re.push stack
      stack = [number]
      last_number = number

    re.push stack if stack.length > 0

    rre = []
    c = 0
    for stack in re
      for move in [0...stack.length]
        if stack[move] is null
          rre.push null
        else
          rre.push move + c
      c += stack.length - 1

    rre


class Tile
  constructor: (@board, @row, @col)->
    @number = 2
    @init_dom()

  init_dom: ->
    width = @board.width

    $tile = jQuery '<div>'
      .addClass "tile num-#{@number}"
      .html @number
      .css
        'width': width
        'height': width
        'top': @board.cell_pos(@row)
        'left': @board.cell_pos(@col)
        'line-height': "#{width}px"
      .appendTo @board.$board

    setTimeout ->
      $tile.addClass 'visible'
    , 1

    @$tile = $tile

  move: (row, col)->
    width = @board.width
    padding = @board.padding

    @row = @row + row
    @col = @col + col

    @$tile.css
      top: padding + @row * (padding + width)
      left: padding + @col * (padding + width)

    @board.merge_stack[@row][@col].push @

  up: ->
    @$tile.removeClass "num-#{@number}"

    @number = @number * 2
    @$tile.html @number
    @$tile.addClass "num-#{@number}"

  remove: ->
    @$tile.css 'z-index', 0
    setTimeout =>
      @$tile.remove()
    , 200


jQuery ->
  board = new Board()
  board.start_new_game()