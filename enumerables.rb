# rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
module Enumerable
  def my_each
    i = 0
    while i < length
      yield self[i] if block_given?
      i += 1
    end
  end

  def my_each_with_index
    j = 0
    while j < length
      yield self[j], j if block_given?
      j += 1
    end
  end

  def my_select
    selected = []
    my_each do |i|
      result = yield(i)
      selected << i if result
    end
    selected
  end

  def my_all?
    condition = true
    my_each do |i|
      return true unless block_given?
      return false unless i

      result = yield(i)
      return false unless result
    end
    condition
  end

  def my_any?
    condition = true
    my_each do |i|
      return true unless block_given?

      result = yield(i)
      return true if result
    end
    condition
  end

  def my_none?
    condition = true
    my_each do |i|
      return true unless block_given?

      result = yield(i)
      return false if result == true
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
      val = param1[0]
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

# rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
def multiply_els(val)
  val.my_inject(:*)
end
