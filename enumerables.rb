# rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/ModuleLength, Metrics/MethodLength
module Enumerable
  def my_each
    arr = self.class == Range ? Array(self) : self
    return to_enum(:my_each) unless block_given?

    i = 0
    while i < arr.length
      yield arr[i]
      i += 1
    end
  end

  def my_each_with_index
    arr = self.class == Range ? Array(self) : self
    return to_enum(:my_each_with_index) unless block_given?

    j = 0
    while j < arr.length
      yield arr[j], j
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

  def my_all?(*arg)
    arr = self.class == Range ? Array(self) : self

    condition = true
    return true if empty?

    arr.my_each_with_index do |i, j|
      condition = true if i && arr[j + 1] && arr[j] == arr[j + 1] && !arg && !block_given?

      case arg[0]
      when Class
        condition = false if i.is_a?(arg[0]) == false
      when Regexp
        condition = false unless i&.to_s&.match?(arg[0])
      else
        condition = false if arg[0] != i
      end
      result = yield(i) if block_given?
      condition = result if block_given?
      break if condition == false
    end
    condition
  end

  def my_any?(*arg)
    arr = self.class == Range ? Array(self) : self

    condition = false
    return false if empty?

    arr.my_each do |i|
      condition = true if i && !arg[0] && !block_given?

      case arg[0]
      when Class
        condition = true if i.is_a?(arg[0])
      when Regexp
        condition = true if i&.to_s&.match?(arg[0])
      else
        condition = true if arg[0] == i
      end
      condition = yield(i) if block_given?
      break if condition == true
    end
    condition
  end

  def my_none?(*arg)
    arr = self.class == Range ? Array(self) : self
    condition = true
    return false if empty?

    arr.my_each_with_index do |i, j|
      condition = false if i && arr[j + 1] && arr[j] != arr[j + 1] && !arg[0] && !block_given?

      case arg[0]
      when Class
        condition = false if i.is_a?(arg[0])
      when Regexp
        condition = false if i&.to_s&.match?(arg[0])
      else
        condition = false if arg[0] == i
      end
      result = yield(i) if block_given?
      condition = false if result && block_given?
      break if condition == false
    end
    condition
  end

  def my_count(arg = nil)
    return length if !arg && !block_given?

    counter = []
    my_each do |i|
      counter << i if (i == arg) && !block_given?
      my_block = yield(i) if block_given?
      counter << i if block_given? && my_block
    end
    counter.length
  end

  def my_map(prc = nil)
    results = []
    return to_enum(:my_map) unless prc || block_given?

    my_each do |i|
      my_block_map = yield(i) if block_given?

      results << (prc ? prc.call(i) : my_block_map)
    end
    results
  end

  def my_inject(*param)
    arr = self.class == Range ? Array(self) : self
    return nil if self.class != Range && empty?

    sym = nil
    val = nil
    sym = param[0] unless param.length == 2
    if param.length == 2
      sym = param[1]
      val = param[0]
    elsif block_given? && param[0]
      arr << param[0]
    end
    temp = sym && sym.to_s == '*' ? 1 : 0

    arr.my_each_with_index do |i, j|
      return param[0].call(i, arr[j + 1]) if param[0].class == Proc

      temp = temp.send(sym, i) unless block_given?
      if block_given? && arr[j + 1]
        my_yield = yield(arr[j], arr[j + 1])
        arr[j + 1] = my_yield
        temp = my_yield
      end
    end
    val ? temp.send(sym, val) : temp
  end
end

# rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/ModuleLength, Metrics/MethodLength
def multiply_els(val)
  val.my_inject(:*)
end
