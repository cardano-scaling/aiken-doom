use aiken/collection/list

pub fn unique(self: List<a>) -> Bool {
  let (duplicate, _) =
    list.reduce(
      self,
      (False, []),
      fn((break, acc), elem) {
        when break is {
          True -> (True, [])
          False ->
            when list.has(acc, elem) is {
              False -> (False, list.push(acc, elem))
              True -> (True, [])
            }
        }
      },
    )

  !duplicate
}

test unique_int_true() {
  unique([1, 2, 3, 4, 5, 6, 7, 8, 9]) == True
}

test unique_int_false() {
  unique([1, 2, 3, 4, 5, 6, 7, 8, 1]) == False
}
