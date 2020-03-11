# rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/ModuleLength
module Enumerable
  def my_each
    return to_enum(:my_each) unless block_given?

    i = 0
    while i < length
      yield self[i]
      i += 1
    end
  end

  def my_each_with_index
    return to_enum(:my_each_with_index) unless block_given?

    j = 0
    while j < length
      yield self[j], j
      j += 1
    end
  end

  def my_select
    return to_enum(:my_select) unless block_given?

    selected = []
    my_each do |i|
      result = yield(i)
      selected << i if result
    end
    selected
  end

  def my_all?(arg = nil)
    condition = true
    return true if empty?

    my_each do |i|
      return false unless i
      return true if i && !arg

      case arg
      when Class
        condition = false if i.is_a?(arg) == false
      when Regexp
        condition = false unless i&.to_s&.match?(arg)
      when String || Numeric
        condition = false if arg != i
      end
      result = yield(i) if block_given?
      condition = result if block_given?
      break if condition == false
    end
    condition
  end

  def my_any?(arg = nil)
    condition = false
    return false if empty?

    my_each do |i|
      case arg
      when Class
        condition = true if i.is_a?(arg)
      when Regexp
        condition = true if i&.to_s&.match?(arg)
      when String || Numeric
        condition = true if arg == i
      end
      result = yield(i) if block_given?
      condition = result if block_given?
      break if condition == true
    end
    condition
  end

  def my_none?(arg = nil)
    condition = true
    return false if empty?

    my_each do |i|
      case arg
      when Class
        condition = false if i.is_a?(arg)
      when Regexp
        condition = true if i&.to_s&.match?(arg)
      when String || Numeric
        condition = false if arg == i
      end
      result = yield(i) if block_given?
      condition = false if result && block_given?
    end
    condition
  end

  def my_count
    return length unless block_given?

    counter = []
    my_each do |i|
      my_block = yield(i)
      counter << i if my_block
    end
    counter.length
  end

  def my_map(&prc)
    results = []
    return to_enum(:my_map) unless block_given?

    my_each do |i|
      my_block_map = yield(i)
      results << (prc ? prc.call(i) : my_block_map)
    end
    results
  end

  def my_inject(*param)
    return nil if empty?

    sym = nil
    val = nil
    sym = param[0] unless param.length == 2
    if param.length == 2
      sym = param[1]
      val = param[0]
    elsif block_given? && param
      self << param[0]
    end
    temp = sym && sym.to_s == '*' ? 1 : 0

    my_each_with_index do |i, j|
      temp = temp.send(sym, i) unless block_given?
      if block_given? && self[j + 1]
        my_yield = yield(self[j], self[j + 1])
        self[j + 1] = my_yield
        temp = my_yield
      end
    end
    val ? temp.send(sym, val) : temp
  end
end

# rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/ModuleLength
def multiply_els(val)
  val.my_inject(:*)
end
