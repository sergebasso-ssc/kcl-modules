trimSuffix = lambda input: str, suffix: str -> str {
    """Removes a matching suffix from a string.

    Arguments
    ---------
    input : str
        The input string.
    suffix : str
        The suffix to remove.

    Returns
    -------
    str
        The input string without the suffix.
    """
    input[:-len(suffix)] if len(suffix) > 0 and input.endswith(suffix) else input
}
test_trimSuffix = lambda -> bool {
    assert trimSuffix("hello-world", "-world") == "hello", "Failed on suffix match"
    assert trimSuffix("hello-world", "-mars") == "hello-world", "Failed on suffix no match"
    assert trimSuffix("test", "t") == "tes", "Failed on single character suffix"
    assert trimSuffix("test", "") == "test", "Failed on empty suffix" + trimSuffix("test", "")
    assert trimSuffix("", "suffix") == "", "Failed on empty input"
}
test_trimSuffix()

distinct = lambda items: [any] -> [any] {
    """Returns a list of distinct items, preserving order.

    Arguments
    ---------
    items : [any]
        The input list.

    Returns
    -------
    [any]
        A list of distinct items.
    """
    [x for i, x in items if x not in items[:i]]
}
test_distinct = lambda -> bool {
    assert distinct([]) == [], "Failed on empty list"
    assert distinct(["a", "b", "a", "c", "b", "d"]) == ["a", "b", "c", "d"], "Failed on list with string duplicates"
    assert distinct([1, 2, 3, 2, 1, 4]) == [1, 2, 3, 4], "Failed on list with integer duplicates"
    assert distinct([{"a": 1}, {"b": 2}, {"a": 1}]) == [{"a": 1}, {"b": 2}], "Failed on list with object duplicates"
    assert distinct([{"a": {"x": 1}}, {"a": {"x": 1}}, {"b": {"y": 2}}]) == [{"a": {"x": 1}}, {"b": {"y": 2}}], "Failed on list with nested object duplicates"
    assert distinct([[1, 2], [3, 4], [1, 2]]) == [[1, 2], [3, 4]], "Failed on list with list duplicates"
}
test_distinct()

compact = lambda items: [any] -> [any] {
    """Removes nullish (null or undefined) values from a list.

    Arguments
    ---------
    items : [any]
        The input list.

    Returns
    -------
    [any]
        A list with nullish values removed.
    """
    [x for x in items if not isnullish(x)]
}
