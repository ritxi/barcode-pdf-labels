require 'bundler/setup'

require 'prawn'
require 'barcode_dispatcher'
require 'barcode_dispatcher/ean13'

class FullInscripcio < Prawn::Document
  attr_reader :range, :row, :col


  def initialize(range)
    @range = range
    @options = { template: path_to('apliwebprint.pdf') }
    super(@options)
    @row = 14
    @col = 1
    @page = 1
    BarcodeDispatcher.height = 29
    go_to_page(1)
    build
  end

  def path_to(file)
    File.expand_path(File.dirname(__FILE__)) + "/#{file}"
  end

  def test
    (1..14).each do |num|
      self.row = num
      @barcode = num.to_s.rjust(12, '0')
      @image_pdf = ::BarcodeDispatcher::Ean13.new(@barcode).to_pdf

      embed_image(@image_pdf.build_pdf_object(self), @image_pdf, at: [x_coord, y_coord])
    end
  end

  def build
    range.each do |num|
      @barcode = num.to_s.rjust(12, '0')
      @image_pdf = ::BarcodeDispatcher::Ean13.new(@barcode).to_pdf

      embed_image(@image_pdf.build_pdf_object(self), @image_pdf, at: [x_coord, y_coord])

      next! unless range.end == num
    end
    self
  end

  def next!
    case
    when new_page?
      puts @barcode
      @page += 1
      puts "new page #{@page}"
      start_new_page(@options)
      go_to_page(@page)
      @row = 14
      @col = 1
    when new_row?
      next_row!
      next_col!
    else
      next_col!
    end
  end

  def new_page?
    @row == 1 && @col == 4
  end

  def new_row?
    @col == 4 && !new_page?
  end

  def last_col?
    @col == 4
  end

  def last_row?
    @col == 1
  end

  def next_row!
    @row = last_row? ? 14 : (@row - 1)
  end

  def next_col!
    @col = last_col? ? 1 : (@col + 1)
  end

  def x_coord
    {coord_4: 405, coord_3: 261, coord_2: 118, coord_1: -25}["coord_#{@col}".to_sym]
  end

  def y_coord
    {"coord_1"=>54, "coord_2"=>112, "coord_3"=>170, "coord_4"=>226,
     "coord_5"=>285, "coord_6"=>342, "coord_7"=>398, "coord_8"=>458,
     "coord_9"=>515, "coord_10"=>572, "coord_11"=>630, "coord_12"=>687,
     "coord_13"=>745, "coord_14"=>803}["coord_#{@row}"]
  end

  def row=(num)
    @row = num
  end

  def col=(num)
    @col = num
  end
end

@from = 1
@to = 56
files = 56

#@y_coord = {}
#(1..14).each do |n|
#
#  f.row = n
#  p f.row
#  @y_coord["coord_#{n}"] = f.y_coord
#end
#p @y_coord
1.upto(30) do |a|
  FullInscripcio.new(@from..@to).render_file("fitxer_#{a}.pdf")
   @from += files
   @to += files
 end