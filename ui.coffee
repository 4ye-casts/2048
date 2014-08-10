class Board
  constructor: ->
    @size = 4
    @width = 100
    @padding = 15

    @init_dom()

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
        @cells.push $cell

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

    for $cell in @cells
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
    $cell for $cell in @cells when !$cell.hasClass('filled')

class Tile
  constructor: (@board, @row, @col)->
    @init_dom()

  init_dom: ->
    width = @board.width
    padding = @board.padding

    $tile = jQuery '<div>'
      .addClass 'tile num-2'
      .html 2
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


jQuery ->
  board = new Board()