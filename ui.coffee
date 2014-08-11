class Board
  constructor: ->
    @size = 4
    @width = 100
    @padding = 15

    @init_dom()
    @init_key_enent()

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

    @cells = []
    for i in [0...@size]
      @cells.push []

    for row in [0...@size]
      for col in [0...@size]
        $cell = jQuery('<div>')
          .addClass('cell')
          .css
            'width': @width
            'height': @width
            'top': @padding + row * (@padding + @width)
            'left': @padding + col * (@padding + @width)
          .attr
            'data-row': row
            'data-col': col
          .appendTo $board
        @cells[row][col] = $cell

  _init_new_game_button: ->
    $new_game_button = jQuery('<div>')
      .addClass('new-game')
      .html 'New Game'
      .appendTo document.body
      .on 'click', =>
        @start_new_game()

  start_new_game: ->
    @clear()
    @generate_tile() for i in [0..1]

  clear: ->
    @data = ((null for j in [0...@size]) for i in [0...@size])
    @$board.find('.tile').remove()

    for arr in @cells
      for $cell in arr
        $cell.removeClass 'filled'


  generate_tile: ->
    empty_cells = @empty_cells()
    rand = ~~(Math.random() * empty_cells.length)
    $cell = empty_cells[rand]
    $cell.addClass 'filled'
    row = $cell.data('row')
    col = $cell.data('col')

    @data[row][col] = new Tile(@, row, col)

  empty_cells: ->
    re = []
    for arr in @cells
      for $cell in arr
        if !$cell.hasClass('filled')
          re.push $cell
    re

  init_key_enent: ->
    jQuery(document).on 'keydown', (evt)=>
      evt.preventDefault()
      direction = switch evt.keyCode
        when 38 then 'up'     # ↑
        when 40 then 'down'   # ↓
        when 37 then 'left'   # ←
        when 39 then 'right'  # →
      @move(direction) if direction

  move: (direction)->
    dir =
      left:   [ 0 , -1]
      right:  [ 0 ,  1]
      up:     [-1 ,  0]
      down:   [ 1 ,  0]

    _dir = dir[direction]

    if direction is 'left'
      arrs = 
        for i in [0...@size]
          for j in [0...@size]
            tile = @data[i][j]

    if direction is 'right'
      arrs = 
        for i in [0...@size]
          for j in [(@size - 1)..0]
            tile = @data[i][j]

    if direction is 'up'
      arrs = 
        for i in [0...@size]
          for j in [0...@size]
            tile = @data[j][i]

    if direction is 'down'
      arrs = 
        for i in [0...@size]
          for j in [(@size - 1)..0]
            tile = @data[j][i]

    @merge_stack = (([] for i in [0...@size]) for j in [0...@size])

    for arr in arrs
      _arr = for tile in arr
        if tile then tile.number else null
      
      merge = @merge _arr
      for i in [0...@size]
        tile = arr[i]
        move = merge[i]
        tile.move(_dir[0] * move, _dir[1] * move) if tile

    for i in [0...@size]
      for j in [0...@size]
        merge = @merge_stack[i][j]
        if merge.length is 0
          @cells[i][j].removeClass('filled')
        if merge.length is 1
          @cells[i][j].addClass('filled')
        if merge.length is 2
          @cells[i][j].removeClass('filled')
          merge[0].remove()
          merge[1].up()


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
    padding = @board.padding

    $tile = jQuery '<div>'
      .addClass "tile num-#{@number}"
      .html @number
      .css
        'width': width
        'height': width
        'top': padding + @row * (padding + width)
        'left': padding + @col * (padding + width)
        'line-height': "#{width}px"
      .appendTo @board.$board

    setTimeout ->
      $tile.addClass 'visible'
    , 1

    @$tile = $tile

  move: (row, col)->
    width = @board.width
    padding = @board.padding

    @$tile.css
      top: "+=#{(width + padding) * row}"
      left: "+=#{(width + padding) * col}"

    $cell = jQuery(@board.cells)
      .filter("[data-row=#{row}]")
      .filter("[data-col=#{col}]")

    @row = @row + row
    @col = @col + col

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

  # console.log board.merge [null, null, null, null]

  # console.log board.merge [null, null, null, 2]
  # console.log board.merge [null, null, 2, null]
  # console.log board.merge [null, 2, null, null]
  # console.log board.merge [2, null, null, null]

  # console.log board.merge [null, 4, 2, null, null, 2, 4]
  # console.log board.merge [null, 2, 2, null, 2, 2, 4]

  # console.log board.merge [2, 2, 4, 4, 8, 8, 2, 4]