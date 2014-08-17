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

  _get_grouped_data: (direction)->
    switch direction
      when 'left'
        @each_cell (row, col)=> @_get_number_of row, col
      when 'right'
        @each_cell (row, col)=> @_get_number_of row, @size - 1 - col
      when 'up'
        @each_cell (row, col)=> @_get_number_of col, row
      when 'down'
        @each_cell (row, col)=> @_get_number_of @size - 1 - col, row

  _get_number_of: (row, col)->
    @data[row][col]

  move: (direction)->
    for arr in @_get_grouped_data(direction)
      @_count_step arr

    @merge_stack = @each_cell -> []
    moved = false
    @each_cell (row, col)=>
      tile = @data[row][col]
      if tile
        moved = true if tile.next_move_step
        tile.move direction

    @each_cell (row, col)=>
      merge = @merge_stack[row][col]
      switch merge.length
        when 0
          @data[row][col] = null
        when 1
          @data[row][col] = merge[0]
        when 2
          merge[0].remove()
          merge[1].up()
          @data[row][col] = merge[1]

    return moved

  # 分组
  __split_group: (arr)->
    groups = []
    tmp = []
    last_tile = null

    for tile in arr

      if tile is null
        tmp.push null
        continue

      if last_tile is null
        tmp.push tile
        last_tile = tile
        continue

      if tile.number == last_tile.number
        tmp.push tile
        groups.push tmp
        tmp = []
        last_tile = null
        continue

      groups.push tmp
      tmp = [tile]
      last_tile = tile

    groups.push tmp if tmp.length
    groups

  _count_step: (arr)->
    groups = @__split_group(arr)
    # console.log groups

    delta = 0
    for group in groups
      for idx in [0...group.length]
        tile = group[idx]
        tile.next_move_step = delta + idx if tile
      delta += group.length - 1

class Tile
  constructor: (@board, @row, @col, number)->
    @number = number || 2
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

  move: (direction)->
    dir =
      left:   [ 0 , -1]
      right:  [ 0 ,  1]
      up:     [-1 ,  0]
      down:   [ 1 ,  0]

    _dir = dir[direction]

    @row = @row + @next_move_step * _dir[0]
    @col = @col + @next_move_step * _dir[1]

    @$tile.css
      top: @board.cell_pos(@row)
      left: @board.cell_pos(@col)

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