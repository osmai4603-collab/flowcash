/// A utility class for combinatorial mathematics.
class CombinatoricsUtils {
  /// Generates the Cartesian product of a list of lists.
  ///
  /// For example, given [[1, 2], [3, 4]], it returns:
  /// [[1, 3], [1, 4], [2, 3], [2, 4]]
  ///
  /// If the input list is empty, it returns a list containing an empty list [[]].
  /// If any of the inner lists is empty, the result will be an empty list [].
  static List<List<T>> cartesianProduct<T>(List<List<T>> lists) {
    if (lists.isEmpty) return [[]];
    
    // We start with a list containing an empty combination.
    List<List<T>> result = [[]];
    
    for (var pool in lists) {
      if (pool.isEmpty) return []; // If any pool is empty, no combinations are possible.
      
      List<List<T>> temp = [];
      for (var combination in result) {
        for (var item in pool) {
          temp.add([...combination, item]);
        }
      }
      result = temp;
    }
    
    return result;
  }
}
