class ArrayUtils
  def self.except list1, list2
    temp, left, right = {}, [], []
    list1.each {|u| temp[yield(u)] = u }
    list2.each do |u|
      key = yield(u)
      if temp.key?(key)
        temp.delete(key)
      end
    end
    temp.values
  end
end